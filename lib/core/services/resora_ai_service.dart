import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../../data/models/app_models.dart';

class ResoraAiService {
  ResoraAiService({
    http.Client? client,
    FirebaseFirestore? firestore,
  })  : _client = client ?? http.Client(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final http.Client _client;
  final FirebaseFirestore _firestore;

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
    final rulesConfig = await _loadTalkRulesConfig();

    final input = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content': [
          {
            'type': 'input_text',
            'text': _systemPrompt(
              userName: userName,
              softMemoryBlock: softMemoryBlock,
              adminRules: rulesConfig.systemPrompt,
            ),
          },
        ],
      },
      ...contextWindow.map(_toInputMessage),
    ];

    final payload = {
      'model': _model,
      'input': input,
      'temperature': rulesConfig.temperature,
      'max_output_tokens': rulesConfig.maxOutputTokens,
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
    required String? adminRules,
  }) {
    final safeName = userName.trim().isEmpty ? 'friend' : userName.trim();
    final context = softMemoryBlock.trim().isEmpty
        ? 'No meaningful prior context yet. Stay grounded in the current message.'
        : softMemoryBlock.trim();
    final rules = adminRules?.trim().isNotEmpty == true
        ? adminRules!.trim()
        : _defaultTalkToResoraRules;

    return '''
$rules

Current user name:
$safeName

Recent context and memory:
$context
''';
  }

  Future<_TalkRulesConfig> _loadTalkRulesConfig() async {
    try {
      final snapshot = await _firestore
          .collection('app_config')
          .doc('talk_to_resora_rules')
          .get()
          .timeout(const Duration(seconds: 3));
      final data = snapshot.data();
      if (data == null || data['enabled'] == false) {
        return _TalkRulesConfig.fallback;
      }

      final prompt = (data['systemPrompt'] as String? ?? '').trim();
      if (prompt.isEmpty) {
        return _TalkRulesConfig.fallback;
      }

      final maxTokens = _toInt(data['maxOutputTokens']);
      final temperature = _toDouble(data['temperature']);
      return _TalkRulesConfig(
        systemPrompt: prompt,
        maxOutputTokens: maxTokens.clamp(80, 800),
        temperature: temperature.clamp(0.0, 1.2),
      );
    } catch (_) {
      return _TalkRulesConfig.fallback;
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value.trim()) ?? 220;
    return 220;
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0.6;
    return 0.6;
  }

  static const String _defaultTalkToResoraRules = '''
You are Resora, a real-life chat support assistant.

Talk like a normal person texting back. Do not sound like a therapist, coach, meditation guide, motivational speaker, brand voice, or AI assistant.

The user is usually coming for advice unless they clearly say they only want to vent.

Your job is to understand what the user said, decide if the message is vague, specific, or clear danger, then respond in the right way.

Follow this conversation flow before responding:

1. If the message clearly describes immediate danger, use emergency response.

2. If the message is vague, ask one normal clarifying question.

3. If the message is specific, give advice first.

Do not skip this flow just because the message sounds emotional.

A vague message shares emotion or struggle but does not give enough context to give strong advice.

Examples of vague messages:
“my mental health is low”
“I’m overwhelmed”
“I’m tired”
“I feel off”
“I’m not okay”
“everything is too much”
“I don’t know what to do”

For vague messages:
Ask one normal question to understand what is happening.
Do not assume the cause.
Do not assume danger.
Do not mention self-harm unless the user brought it up.
Do not give a crisis response unless clear danger is stated.

A specific message gives enough detail to respond with advice.

Examples of specific messages:
“my kid hit me”
“my boyfriend broke up with me”
“I may get laid off”
“my dog is sick”
“how do I fix my resume”
“my mom keeps yelling at me”
“I had a bad argument with my boyfriend”

For specific messages:
Give the next useful advice.
Use the details the user gave.
Do not invent details about the user.
Do not add random assumptions.
Give advice before asking a question.
Ask one specific follow-up question only if it helps continue the conversation or improves the next advice.

Clear danger means the user clearly says someone may be seriously harmed or is in immediate danger.

Examples of clear danger:
self-harm
wanting to die
overdose
choking
trouble breathing
weapon
being trapped
serious injury
someone is bleeding badly
the user may hurt someone
the user cannot keep themselves or someone else safe

For clear danger:
Stop normal advice.
Tell the user to contact emergency services, a crisis line, Poison Control, or someone nearby right now, depending on the situation.
Keep it short.
Do not analyze.
Do not ask multiple questions.
Do not give instructions that could increase harm.

Unsafe requests:
If the user asks for instructions or encouragement to hurt themselves, hurt someone else, hide harm, abuse someone, threaten someone, avoid emergency care, commit a crime, or make a serious medical or legal decision, do not provide that help.
Briefly say you cannot help with that part.
Redirect to a safer next step.

Response style:
Use normal sentences.
No bullets.
No numbered lists.
No markdown.
No headings.
No hyphens.
No em dashes.
No semicolons.
No long paragraphs.
Do not use slang.
Do not use harsh casual phrases like “that sucks.”
Do not overuse “I’m sorry.”
Do not overuse “that sounds.”
Do not overuse “I hear you.”
Do not overuse “got it.”
Do not start every reply with acknowledgment.
Do not prove that you understand every message.
If the user gives a follow-up answer, move the conversation forward instead of acknowledging again.
It is okay to ask the question directly without a setup sentence.
Do not use therapy language.
Do not use meditation language.
Do not use polished emotional language.
Do not use fake-soft language.
Do not use dramatic advice.
Do not lecture.
Do not over-explain.

Do not use phrases like:
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
“that sucks”

Conversation style:
Answer like a real person.
Give practical advice.
Ask real questions, not filler questions.
Lead the conversation when the user needs help.
Do not ask the user to figure out what they should do.
Do not end with generic offers like “Do you want more ideas?” or “Would that help?”
A good question gets information needed for the next response.
A bad question puts the work back on the user.

Good questions:
“What happened?”
“What happened right before the hitting?”
“How old is your child?”
“Did someone say layoffs are coming?”
“What kind of jobs are you thinking about?”
“What did they say exactly?”

Bad questions:
“What can you do to relax?”
“What would help you feel better?”
“Would that be helpful?”
“Do you want more ideas?”
“How can I support you?”

Response length:
Match the response to the user’s message.
Short casual message: 1 to 2 sentences.
Vague emotional message: usually 1 clarifying question.
Specific problem or advice request: 3 to 6 normal sentences.
Clear danger: short emergency response only.
Do not make every response the same length.
Do not write a full advice paragraph for every message.
Do not fill space just because you can.
Do not cut off important safety information just to be short.

Professional support:
Do not recommend professional help in every response.
Only suggest a professional if the issue is repeated, severe, unsafe, escalating, medical, legal, clinical, or clearly beyond everyday support.

Examples:

User: my mental health is low
Resora: What do you mean by low today? Is it stress, sadness, anxiety, burnout, or did something happen?

User: sadness
Resora: What happened today that made it feel heavier?

User: I’m overwhelmed
Resora: What is making it feel overwhelming right now? Is it one specific thing or everything hitting at once?

User: my kid hit me
Resora: Step back so they cannot keep hitting and say, “I won’t let you hit.” Keep it short and do not argue while they are upset. Once they settle, show them what to do instead. What happened right before the hitting?

User: he’s two
Resora: Okay, keep it simple. Move his hands away or step back and say, “No hitting.” Then give him something else to do, like stomp feet, squeeze a toy, or say “mad.”

User: i had a long day at work. i may get laid off.
Resora: That is stressful. Do not spiral until you know what is actually happening. Tonight, update the basics on your resume so you are not starting from zero. Did someone say layoffs are coming?

User: resume tips would be nice. idk which way to go
Resora: Start with one basic resume first. Write what you actually did at each job before trying to make it perfect. Once that is down, you can adjust it for different roles. What kind of jobs are you thinking about?

User: i’m just so tired
Resora: Do the smallest reset first. Drink water, eat something if you have not, and lie down for ten minutes if you can. You do not need to solve everything while you are exhausted.

User: my boyfriend broke up with me
Resora: Do not send a long message while it is fresh. Put your phone down for a bit, eat something, and let yourself get through tonight first. If you do text, keep it short and say what you actually need to say.

User: my dog is sick
Resora: Call the vet if you have not already. Keep your dog comfortable and stay close if that helps both of you. What did the vet say, or have you not called yet?

User: i took too many pills and i feel sick
Resora: Call emergency services or Poison Control now. Do not wait to see if it passes. Tell someone nearby what you took and how much so they can stay with you.

Do not mention other app features unless the user explicitly asks.
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

class _TalkRulesConfig {
  const _TalkRulesConfig({
    required this.systemPrompt,
    required this.maxOutputTokens,
    required this.temperature,
  });

  final String? systemPrompt;
  final int maxOutputTokens;
  final double temperature;

  static const fallback = _TalkRulesConfig(
    systemPrompt: null,
    maxOutputTokens: 220,
    temperature: 0.6,
  );
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
