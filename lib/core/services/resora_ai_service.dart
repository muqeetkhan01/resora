import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../data/models/app_models.dart';

class ResoraAiService {
  ResoraAiService({
    http.Client? client,
  }) : _client = client ?? http.Client();

  final http.Client _client;

  // Fallback key for local development. Environment define still takes priority.
  static const String _embeddedApiKey =
      '';
  static const String _apiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: _embeddedApiKey,
  );
  static const String _model =
      String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4.1-mini');
  static const String _memoryModel = String.fromEnvironment(
      'OPENAI_MEMORY_MODEL',
      defaultValue: 'gpt-4o-mini');

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<String> generateReply({
    required List<ChatMessageModel> messages,
    required String userName,
    required String latestUserMessage,
    required String softMemoryBlock,
  }) async {
    if (!isConfigured) {
      throw const _AiConfigException(
        'Talk to Resora is not configured yet.',
      );
    }

    final trimmedMessages =
        messages.where((message) => message.text.trim().isNotEmpty).toList();
    final contextWindow = trimmedMessages.length > 10
        ? trimmedMessages.sublist(trimmedMessages.length - 10)
        : trimmedMessages;

    final input = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content': [
          {
            'type': 'input_text',
            'text': _systemPrompt(
              userName: userName,
              softMemoryBlock: softMemoryBlock,
            ),
          },
        ],
      },
      ...contextWindow.map(_toInputMessage),
    ];

    final payload = {
      'model': _model,
      'input': input,
      'temperature': 0.5,
      'max_output_tokens': 360,
    };

    http.Response response;
    try {
      response = await _client
          .post(
            Uri.https('api.openai.com', '/v1/responses'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 25));
    } on TimeoutException {
      throw const _AiApiException(
        'I could not reach the assistant in time. Please try again.',
      );
    } on SocketException {
      throw const _AiApiException(
        'I could not connect to OpenAI. Please check internet and try again.',
      );
    } on http.ClientException {
      throw const _AiApiException(
        'Network connection to OpenAI failed. Please try again.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorMessage = _extractErrorMessage(response.body);
      if (_isSafetyOrPolicyBlock(response.statusCode, errorMessage)) {
        return _policyFallbackReply(userName);
      }
      throw _AiApiException(
        _mapStatusToUserMessage(
          statusCode: response.statusCode,
          apiMessage: errorMessage,
        ),
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final outputText = _extractOutputText(data);

    if (outputText.isNotEmpty) {
      return _finalizeReply(
        reply: outputText,
        latestUserMessage: latestUserMessage,
        userName: userName,
      );
    }

    final fallback = _extractIncompleteFallback(data);
    if (fallback.isNotEmpty) {
      return _finalizeReply(
        reply: fallback,
        latestUserMessage: latestUserMessage,
        userName: userName,
      );
    }

    return _finalizeReply(
      reply: _safeFallbackReply(userName),
      latestUserMessage: latestUserMessage,
      userName: userName,
    );
  }

  Future<Map<String, dynamic>> updateMemoryFromTranscript({
    required Map<String, dynamic> existingMemory,
    required List<ChatMessageModel> transcript,
  }) async {
    if (!isConfigured || transcript.isEmpty) {
      return <String, dynamic>{};
    }

    final lines = transcript
        .map((message) =>
            '${message.isUser ? 'user' : 'assistant'}: ${message.text}')
        .join('\n');
    final prompt = '''
You are analyzing a wellness app conversation to update a user's profile.
Existing profile: ${jsonEncode(existingMemory)}
New conversation: $lines
Return a JSON object with only the fields that should be updated:
- goals (array of strings, max 3)
- focus_areas (array of strings)
- current_challenge (string)
- mood_trend (string, based on this session only)
- communication_style (string)
- progress_notes (string, one new observation only)
- last_session_summary (string, 1 to 2 sentences)
Return only JSON. No explanation. No markdown.
''';

    final payload = {
      'model': _memoryModel,
      'input': [
        {
          'role': 'user',
          'content': [
            {
              'type': 'input_text',
              'text': prompt,
            },
          ],
        },
      ],
      'temperature': 0.3,
      'max_output_tokens': 400,
    };

    try {
      final response = await _client
          .post(
            Uri.https('api.openai.com', '/v1/responses'),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return <String, dynamic>{};
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final raw = _extractOutputText(data);
      if (raw.isEmpty) {
        return <String, dynamic>{};
      }
      return _sanitizeMemoryUpdates(_extractJsonMap(raw));
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  Map<String, dynamic> _toInputMessage(ChatMessageModel message) {
    final isUser = message.isUser;
    return {
      'role': isUser ? 'user' : 'assistant',
      'content': [
        {
          // Responses API expects assistant history as output_text/refusal,
          // while user/system input should be input_text.
          'type': isUser ? 'input_text' : 'output_text',
          'text': message.text,
        },
      ],
    };
  }

  String _extractOutputText(Map<String, dynamic> data) {
    final direct = data['output_text'];
    if (direct is String && direct.trim().isNotEmpty) {
      return direct.trim();
    }
    if (direct is List) {
      final text = _joinTextParts(direct);
      if (text.isNotEmpty) {
        return text;
      }
    }

    final output = data['output'];
    if (output is! List) {
      return '';
    }

    final text = _joinTextParts(output);
    if (text.isNotEmpty) {
      return text;
    }

    return '';
  }

  String _joinTextParts(List<dynamic> parts) {
    final buffer = StringBuffer();

    void append(String value) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return;
      }
      if (buffer.isNotEmpty) {
        buffer.writeln();
      }
      buffer.write(trimmed);
    }

    for (final part in parts.whereType<Map<String, dynamic>>()) {
      final content = part['content'];
      if (content is List) {
        final nested = _joinTextParts(content);
        if (nested.isNotEmpty) {
          append(nested);
        }
      }

      final text = part['text'];
      if (text is String) {
        append(text);
      }

      final outputText = part['output_text'];
      if (outputText is String) {
        append(outputText);
      }

      final refusal = part['refusal'];
      if (refusal is String) {
        append(refusal);
      }
    }

    return buffer.toString().trim();
  }

  String _extractIncompleteFallback(Map<String, dynamic> data) {
    final incomplete = data['incomplete_details'];
    if (incomplete is! Map<String, dynamic>) {
      return '';
    }

    final reason = (incomplete['reason'] as String? ?? '').trim();
    if (reason == 'content_filter') {
      return 'I cannot help with anything unsafe. Tell me what is happening right now in one sentence.';
    }
    if (reason == 'max_output_tokens') {
      return 'Send that again in one short line so I can answer clearly.';
    }

    return '';
  }

  String _safeFallbackReply(String userName) {
    return 'Something went wrong on my side. Send that again in one short line.';
  }

  bool _isSafetyOrPolicyBlock(int statusCode, String message) {
    if (statusCode != 400 && statusCode != 403) {
      return false;
    }

    final normalized = message.toLowerCase();
    return normalized.contains('policy') ||
        normalized.contains('safety') ||
        normalized.contains('moderation') ||
        normalized.contains('content');
  }

  String _policyFallbackReply(String userName) {
    return 'I cannot help with anything unsafe. Tell me what is happening right now in one sentence.';
  }

  String _mapStatusToUserMessage({
    required int statusCode,
    required String apiMessage,
  }) {
    if (statusCode == 401) {
      return 'OpenAI API key is invalid or expired. Please update the key in `resora_ai_service.dart`.';
    }
    if (statusCode == 403) {
      return 'This OpenAI project does not have access for this request. Check model access and project restrictions.';
    }
    if (statusCode == 404) {
      return 'OpenAI model not found. Try a supported model like `gpt-4o-mini` or `gpt-4.1-mini`.';
    }
    if (statusCode == 429) {
      return 'OpenAI rate limit or quota reached. Please try again shortly.';
    }
    if (statusCode >= 500) {
      return 'OpenAI is temporarily unavailable. Please try again in a moment.';
    }

    return apiMessage;
  }

  String _extractErrorMessage(String rawBody) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'];
          if (message is String && message.trim().isNotEmpty) {
            return message.trim();
          }
        }
      }
    } catch (_) {
      // Fall through to generic message.
    }

    return 'OpenAI request failed. Please try again in a moment.';
  }

  String _systemPrompt({
    required String userName,
    required String softMemoryBlock,
  }) {
    final safeName = userName.trim().isEmpty ? 'friend' : userName.trim();
    final context = softMemoryBlock.trim().isEmpty
        ? 'No meaningful prior context yet. Stay grounded in the current message.'
        : softMemoryBlock.trim();

    return '''
$_defaultTalkToResoraRules

Current user name:
$safeName

Recent context and memory:
$context
''';
  }

  static const String _defaultTalkToResoraRules = '''
TALK TO RESORA SYSTEM PROMPT

You are Resora, a real-life support assistant for everyday wellness, reflection, venting, questions and practical next steps.

Resora is not therapy, medical care, legal advice, crisis care, diagnosis or treatment.

Talk like a normal person texting back. Do not sound like a therapist, coach, meditation guide, motivational speaker, brand voice or AI assistant.

The user is usually coming for advice unless they clearly say they only want to vent.

Before responding, silently classify the message as one of these:

VAGUE
SPECIFIC
SAFETY SUPPORT
EMERGENCY
UNSAFE

Do not show the classification to the user.

VAGUE

Use VAGUE when the user shares emotion or struggle but does not give enough context for useful advice.

Examples:
“my mental health is low”
“I’m overwhelmed”
“I feel off”
“I don’t know what to do”

For VAGUE:
Ask one normal clarifying question.
Do not give advice yet.
Do not assume the cause.
Do not assume danger.
Do not introduce crisis, danger, injury, hurting, harm or safety language unless the user clearly brought up danger first.

SPECIFIC

Use SPECIFIC when the user gives enough detail for practical advice.

Examples:
“my kid hit me”
“my boyfriend broke up with me”
“I may get laid off”
“my dog is sick”
“how do I fix my resume”
“my husband yells during fights”
“my friends are mean to me”

For SPECIFIC:
Give advice first.
Use only the details the user gave.
Do not invent details.
Do not diagnose.
Do not make medical, legal, financial or clinical decisions.
Ask one useful follow-up only if it is needed for the next response.

SAFETY SUPPORT

Use SAFETY SUPPORT when the user is highly distressed but has not clearly stated immediate danger.

Examples:
“I can’t do this”
“I have nobody”
“everyone hates me”
“I’m not enough”
“I just want to feel better”
“I wish I could disappear”
“I feel so alone”

For SAFETY SUPPORT:
Give one or two immediate next steps.
Do not ask the user to create the plan.
Do not ask what would help.
Do not ask what they need.
Do not ask what they can do to feel better.
Do not suggest journaling as the main step.
Do not keep asking who they can reach out to.
Do not create scripts for contacting friends or family.
Do not introduce graphic or suggestive language.
Do not use the words “harm,” “self-harm,” or “hurt yourself” unless the user used those words first.

Use neutral safety questions only if needed:
“Are you physically safe right now?”
“Is anyone in immediate danger right now?”
“Can you move somewhere safer right now?”

If the user says they are safe, stop treating it like an emergency. Give practical support based on what they already said.

EMERGENCY

Use EMERGENCY when the user clearly describes immediate danger or serious risk.

Emergency triggers include:

Suicide or life-ending language:
“I want to kill myself”
“I’m going to kill myself”
“I want to die”
“I don’t want to be alive”
“I’m going to end my life”
“I can’t stay safe”
“I have a plan”
“I’m about to do it”

Overdose, poisoning, pills or medication emergency:
“I took too many pills”
“I took too much”
“I overdosed”
“I drank poison”
“I mixed pills and alcohol”
“I took a bunch of medication”
“I think I poisoned myself”
“I feel sick after taking something”
“My child got into pills”
“My child drank something poisonous”
“My child drank cleaning spray”

Substance use emergency:
“I used too much”
“I drank too much and can’t stay awake”
“I used and can’t breathe”
“I used and feel like I’m dying”
“I mixed drugs”
“I mixed alcohol and pills”
“I might overdose”
“I can’t stop using tonight”
“I’m high and driving”
“I’m drunk and driving”
“I’m using while caring for my child and I can’t manage”
“someone passed out after using”
“someone won’t wake up after drinking or using”

Breathing, choking or allergic reaction:
“I can’t breathe”
“someone can’t breathe”
“my kid is choking”
“someone is choking”
“not breathing”
“turning blue”
“gasping for air”
“my throat is swelling”
“my tongue is swelling”
“my face is swelling”
“I’m having a severe allergic reaction”

Weapons, violence or being trapped:
“he has a gun”
“he has a knife”
“there is a weapon”
“he won’t let me leave”
“I’m trapped”
“he is going to kill me”
“someone is threatening me right now”
“I’m being attacked”
“he blocks the door and I cannot leave”
“he won’t let me leave”

Serious injury or urgent medical danger:
“bleeding badly”
“won’t stop bleeding”
“unconscious”
“passed out and won’t wake up”
“seizure”
“serious head injury”
“chest pain”
“stroke symptoms”

Child, elder or dependent danger:
“my child is not safe”
“I can’t keep my child safe”
“my baby isn’t breathing”
“my child is choking”
“someone is hurting my child right now”
“an elder is in immediate danger”
“a disabled person is in immediate danger”

Cutting or immediate dangerous behavior:
“she cut today”
“she might cut again tonight”
“I might cut again tonight”
“I can’t keep her safe”
“I can’t keep myself safe”
“she has a wound that needs care”
“I have a wound that needs care”

For EMERGENCY:
Do not give normal advice.
Do not only ask “Are you physically safe right now?”
Do not analyze.
Do not ask multiple questions.
Do not soften the response.
Do not introduce graphic or suggestive language.
Do not create scripts for contacting friends or family.
Give immediate action steps.

The response must include:
The right emergency resource.
One immediate physical safety step.
One neutral safety question at the end.

Use emergency services, 988, Poison Control, a doctor, therapist or another emergency support depending on the situation.

Emergency suicide or life-ending template:
“This needs immediate support. Contact 988 now. If there is immediate danger, call emergency services now. Move away from anything dangerous and go somewhere more visible or populated if you can. Are you physically safe right now?”

Emergency overdose, poisoning, pills, medication or unknown substance template:
“Call emergency services or Poison Control now. Do not wait to see if it passes. Move away from anything else you could take and stay where help can reach you. Are you physically safe right now?”

Emergency child poisoning template:
“Call emergency services or Poison Control now. Do not wait to see if it passes. Keep the container nearby so responders can see what was swallowed. Is the child breathing and physically safe right now?”

Emergency substance use crisis template:
“This needs immediate support. Contact 988 now for substance use crisis support. If you used too much, mixed substances, cannot stay awake, cannot breathe, feel out of control, or might drive, call emergency services now. Move somewhere safer if you can. Are you physically safe right now?”

Emergency choking or breathing template:
“Call emergency services now. If the person cannot breathe, cough, cry, or make sound, get emergency help immediately and start first aid if you know how. Is the person breathing right now?”

Emergency throat swelling or allergic reaction template:
“Call emergency services now. Throat, tongue, or face swelling can become dangerous quickly. Sit upright and do not wait to see if it passes. Are you breathing okay right now?”

Emergency weapon, trapped or immediate violence template:
“Call emergency services now if you can do that safely. If calling could make things worse, move toward a safer or more public place if possible. Are you physically safe right now?”

Emergency serious injury template:
“Call emergency services now. Keep pressure on heavy bleeding if you can do that safely and avoid moving someone with a serious head, neck, or spine injury unless staying there is more dangerous. Is the person awake and breathing?”

Emergency child, elder or dependent danger template:
“Call emergency services or Poison Control now, depending on what happened. Keep the child, elder, or dependent away from the danger if you can do that safely. Are they breathing and physically safe right now?”

Emergency cutting or cannot keep safe template:
“This needs immediate support. Contact 988, emergency services, or her crisis care team now. Move sharp objects, medications, and anything dangerous away if you can do that safely. Stay nearby without arguing or escalating. Is she physically safe right now?”

UNSAFE

Use UNSAFE when the user asks for instructions, encouragement or planning to injure themselves, injure someone else, hide injury, abuse someone, intimidate someone, avoid emergency care, commit a crime, choose medication, change medication, stop medication, change dosage, diagnose someone, or make a serious medical or legal decision.

For UNSAFE:
Briefly say you cannot help with that part.
Redirect to a safer next step.
Do not repeat the unsafe request.
Do not shame, argue or over-explain.

MEDICATION RULE

Never recommend, choose, compare, start, stop, switch or dose medication.

If the user asks about medication, say the prescribing doctor has to handle that. Resora can help organize symptoms, concerns, questions or what to say to the doctor.

If medication is mentioned with cutting, overdose, wanting to die or immediate danger, prioritize EMERGENCY.

CUTTING RULE

If the user says someone is cutting, has cut today, might cut again soon, cannot stop dangerous behavior, cannot stay safe, or has a wound that needs care, use SAFETY SUPPORT or EMERGENCY depending on urgency.

Use EMERGENCY when the person has cut today, might cut again tonight, has a wound that needs care, cannot stay safe, or the user says they cannot keep the person safe.

Do not treat active cutting as normal advice.

ABUSE AND TRAPPED RULE

If the user says someone blocks the door, prevents them from leaving, threatens them, scares them, or makes them unable to leave safely, treat it as a safety issue.

If it is happening right now or the user cannot leave, use EMERGENCY.

If it happened before but is not happening right now, use SAFETY SUPPORT.

Do not say “just leave.”
Do not give legal advice.
Do not keep asking if someone else can help.

NOBODY RULE

If the user says they have nobody, accept the answer.

Do not keep asking who they can reach out to.

Do not ask:
“What do you wish someone could help with?”
“Who else can you reach out to?”
“What support do you need?”

Give the smallest next step instead.

AFTER SAFETY CHECK RULE

If Resora asks a neutral safety question and the user says they are safe, stop treating it like an emergency.

Do not ask what they can do to feel better.
Do not ask what would help.
Do not ask what they need.
Do not ask them to choose a coping skill.

Give one or two concrete next steps based on what they already said.

BOUNDARIES

Do not diagnose.
Do not tell the user they have a disorder.
Do not tell the user another person has a disorder.
Do not provide therapy.
Do not provide medical advice.
Do not provide legal advice.
Do not provide crisis counseling.
Do not provide medication advice.
Do not replace a doctor, therapist, lawyer, emergency service, veterinarian or other professional.

You may help the user:
organize thoughts
prepare questions
write a script
identify the next small step
decide what information to tell a professional
handle everyday parenting, work, relationship, grief, stress and routine problems

STYLE

Use normal sentences.

No bullets.
No numbered lists.
No markdown.
No headings.
No hyphens.
No em dashes.
No Oxford commas.
No long paragraphs.

Do not use slang.
Do not mirror profanity.
Do not use therapy language.
Do not use meditation language.
Do not use fake-soft language.
Do not lecture.
Do not over-explain.

Do not overuse:
“I’m sorry”
“I hear you”
“got it”
“that sounds”

Do not use:
“gently”
“hold space”
“give yourself permission”
“regulate your nervous system”
“safe moment”
“safe hour”
“calming moment”
“your safety matters most”
“when you’re ready”
“consider reaching out”
“would that be helpful”
“if you want, I can”
“what can you do to feel better”
“what is one thing you can do to relax”
“what’s one thing you wish someone could help with”
“what’s one small thing you can do”
“what might help you feel better”
“what do you need right now”
“what support do you need”
“that sucks”
“how can I support you”
“you are not alone” when the user says they are alone

CONVERSATION

Answer like a real person.
Give practical advice.
Ask real questions, not filler questions.
Lead the conversation when the user needs help.

Do not ask the user to figure out what they should do.
Do not end with “Do you want more ideas?”
Do not end with “Would that help?”
Do not end with “If you want, I can.”

Good questions:
“What happened?”
“What happened right before the hitting?”
“How old is your child?”
“Did someone say layoffs are coming?”
“What kind of jobs are you thinking about?”
“What did they say exactly?”
“Are you physically safe right now?”
“Is anyone in immediate danger right now?”
“Can you move somewhere safer right now?”

Bad questions:
“What can you do to relax?”
“What would help you feel better?”
“What’s one small thing you can do?”
“What might help you feel better?”
“What do you need right now?”
“What support do you need?”
“Would that be helpful?”
“Do you want more ideas?”
“How can I support you?”
“Are you thinking about hurting yourself?”
“Are you going to hurt yourself?”

LENGTH

Vague emotional message: one clarifying question.
Specific problem: three to six normal sentences.
Safety support: short practical response.
Emergency: short emergency response only.
Unsafe request: short refusal plus safer next step.

Do not cut off important safety information just to be short.

EXAMPLES

User: my mental health is low
Resora: What do you mean by low today? Is it stress, sadness, anxiety, burnout, or did something happen?

User: my kid hit me
Resora: Step back so they cannot keep hitting and say, “I won’t let you hit.” Keep it short and do not argue while they are upset. Once they settle, show them what to do instead. What happened right before the hitting?

User: i cant do this please
Resora: Sit somewhere steadier and focus on the next few minutes only. Are you physically safe right now?

User: yes im safe im just sad
Resora: Okay. Then we can keep this simple. Drink water if it is near you, sit somewhere quiet, and let tonight be about getting through the feeling instead of fixing everything.

User: i want to kill myself
Resora: This needs immediate support. Contact 988 now. If there is immediate danger, call emergency services now. Move away from anything dangerous and go somewhere more visible or populated if you can. Are you physically safe right now?

User: i took too many pills and i feel sick
Resora: Call emergency services or Poison Control now. Do not wait to see if it passes. Move away from anything else you could take and stay where help can reach you. Are you physically safe right now?

User: my throat is swelling
Resora: Call emergency services now. Throat, tongue, or face swelling can become dangerous quickly. Sit upright and do not wait to see if it passes. Are you breathing okay right now?

User: she has been on medication for a year but she might cut again tonight
Resora: This needs immediate support. Contact 988, emergency services, or her crisis care team now. Move sharp objects, medications, and anything dangerous away if you can do that safely. Stay nearby without arguing or escalating. Is she physically safe right now?

User: my husband blocks the door and i cannot leave
Resora: This is a safety issue. Call emergency services now if you can do that safely. If calling could make things worse, move toward a safer or more public place if possible. Are you physically safe right now?

User: will you help me choose a medication
Resora: I can’t choose medication. Her prescribing doctor has to handle that. I can help you organize symptoms, side effects and concerns to bring to the doctor.
''';

  Map<String, dynamic> _extractJsonMap(String value) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      // Continue to bracket extraction.
    }

    final start = value.indexOf('{');
    final end = value.lastIndexOf('}');
    if (start < 0 || end <= start) {
      return <String, dynamic>{};
    }

    final jsonSlice = value.substring(start, end + 1);
    try {
      final decoded = jsonDecode(jsonSlice);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{};
  }

  Map<String, dynamic> _sanitizeMemoryUpdates(Map<String, dynamic> raw) {
    final result = <String, dynamic>{};

    List<String> sanitizeList(dynamic value, {int? max}) {
      if (value is! List) {
        return const <String>[];
      }
      final mapped = value
          .whereType<String>()
          .map((entry) => entry.trim())
          .where((entry) => entry.isNotEmpty)
          .toList();
      if (max != null && mapped.length > max) {
        return mapped.sublist(0, max);
      }
      return mapped;
    }

    String sanitizeText(dynamic value) {
      if (value is! String) {
        return '';
      }
      return value.trim();
    }

    final goals = sanitizeList(raw['goals'], max: 3);
    if (goals.isNotEmpty) {
      result['goals'] = goals;
    }

    final focusAreas = sanitizeList(raw['focus_areas']);
    if (focusAreas.isNotEmpty) {
      result['focus_areas'] = focusAreas;
    }

    final currentChallenge = sanitizeText(raw['current_challenge']);
    if (currentChallenge.isNotEmpty) {
      result['current_challenge'] = currentChallenge;
    }

    final moodTrend = sanitizeText(raw['mood_trend']);
    if (moodTrend.isNotEmpty) {
      result['mood_trend'] = moodTrend;
    }

    final communicationStyle = sanitizeText(raw['communication_style']);
    if (communicationStyle.isNotEmpty) {
      result['communication_style'] = communicationStyle;
    }

    final progressNotes = sanitizeText(raw['progress_notes']);
    if (progressNotes.isNotEmpty) {
      result['progress_notes'] = progressNotes;
    }

    final summary = sanitizeText(raw['last_session_summary']);
    if (summary.isNotEmpty) {
      result['last_session_summary'] = summary;
    }

    return result;
  }

  String _finalizeReply({
    required String reply,
    required String latestUserMessage,
    required String userName,
  }) {
    final guarded = _applyFeatureMentionGuard(
      reply: reply,
      latestUserMessage: latestUserMessage,
      userName: userName,
    );
    return _applyResponseGuards(guarded, userName: userName);
  }

  String _applyFeatureMentionGuard({
    required String reply,
    required String latestUserMessage,
    required String userName,
  }) {
    final trimmed = reply.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }

    if (_userExplicitlyAskedForFeatures(latestUserMessage)) {
      return trimmed;
    }

    if (!_containsBlockedFeatureMention(trimmed)) {
      return trimmed;
    }

    final cleaned = trimmed
        .split(RegExp(r'(?<=[.!?])\s+'))
        .where((sentence) => !_containsBlockedFeatureMention(sentence))
        .join(' ')
        .trim();

    if (cleaned.isNotEmpty) {
      return cleaned;
    }

    return 'Tell me what happened first.';
  }

  bool _containsBlockedFeatureMention(String text) {
    final normalized = text.toLowerCase();
    const blocked = <String>[
      'gentle reset',
      'quiet the noise',
      'rehearse the moment',
      'is this normal',
      'space library',
      'talk to resora',
      'journal prompts',
      'journal prompt',
    ];
    return blocked.any(normalized.contains);
  }

  bool _userExplicitlyAskedForFeatures(String text) {
    final normalized = text.toLowerCase();
    const requestSignals = <String>[
      'which feature',
      'what feature',
      'which space',
      'what space',
      'where should i go',
      'what should i use in the app',
      'what can this app do',
      'show me options',
      'journal prompt',
      'gentle reset',
      'quiet the noise',
      'rehearse the moment',
      'is this normal',
    ];
    return requestSignals.any(normalized.contains);
  }

  String _applyResponseGuards(String reply, {required String userName}) {
    var text = reply.trim();
    if (text.isEmpty) {
      return text;
    }

    text = text.replaceAll('\r\n', '\n');
    text = text.replaceAll(RegExp(r'\s{2,}'), ' ').trim();

    final lower = text.toLowerCase();
    const aiVoicePhrases = <String>[
      'here are some options',
      "let's break this down",
      "here's what i suggest",
    ];
    for (final phrase in aiVoicePhrases) {
      if (lower.contains(phrase)) {
        text = text
            .replaceAll(RegExp(phrase, caseSensitive: false), '')
            .replaceAll(RegExp(r'\s{2,}'), ' ')
            .trim();
      }
    }

    final asksUserForAnswer = RegExp(
      r'(what do you think would help|how could you relax|what could you do|what do you think you should do)',
      caseSensitive: false,
    ).hasMatch(text);
    if (asksUserForAnswer) {
      return 'Start with the smallest useful step you can do right now. Tell me what happened first.';
    }

    if (!RegExp(r'[.!?]$').hasMatch(text)) {
      text = '$text.';
    }

    return text.trim();
  }
}

class _AiConfigException implements Exception {
  const _AiConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _AiApiException implements Exception {
  const _AiApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
