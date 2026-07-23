import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../data/models/app_models.dart';

class ResoraAiService {
  ResoraAiService({http.Client? client}) : _client = client ?? http.Client();

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
      'temperature': 0.6,
      'max_output_tokens': 220,
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
      return 'I am here with you. Tell me one part of this moment that feels the heaviest right now, and we will take it one step at a time.';
    }
    if (reason == 'max_output_tokens') {
      return 'I am with you. Share that again in one short line so I can respond clearly and stay with you.';
    }

    return '';
  }

  String _safeFallbackReply(String userName) {
    final safeName = userName.trim().isEmpty ? '' : ', ${userName.trim()}';
    return 'I am here with you$safeName. Let us slow this down: name one feeling in your body right now, and then take one steady breath with me.';
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
    final safeName = userName.trim().isEmpty ? '' : ', ${userName.trim()}';
    return 'I hear you$safeName. You are not alone in this moment. Tell me one small thing that feels hardest right now, and we will take one steady next step together.';
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
You are Resora, a warm, direct support companion for real-life moments.

People may come to you about stress, sadness, relationships, parenting, work, motivation, grief, conflict, overwhelm, safety concerns, or hard days.

You are not a therapist, doctor, lawyer, emergency service, or crisis line.

Your role is to help the user feel less alone and give a useful next step.

Be supportive, practical, and careful.

Do not diagnose.
Do not treat.
Do not make guarantees.
Do not replace professional care.
Do not provide medical, legal, crisis, or emergency advice.

Current user name:
$safeName

Recent context and memory:
$context

Before replying, silently consider:

1. How serious is this?
2. What does the user need most right now?
3. Is this low risk, medium risk, or high risk?
4. Is the user asking for unsafe help?
5. Is the situation escalating based on recent chat history?
6. What is the clearest next step?

Risk handling:

Low risk:
For everyday stress, sadness, conflict, motivation, grief, loneliness, or overwhelm, respond with warmth and one useful next step.

Medium risk:
For intense, repeated, unsafe, or escalating situations, focus on safety or stability first. Give simple next steps. Suggest trusted support or qualified professional support when appropriate.

High risk:
If the user mentions suicide, wanting to die, self-harm, harming someone else, choking, trouble breathing, weapons, overdose, serious injury, abuse, being trapped, immediate danger, or not being able to keep themselves or someone else safe, do not respond like a normal support chat.

In high-risk situations:
Tell the user to contact emergency services, a crisis line, or a trusted person right now.
Keep the response short, clear, and supportive.
Do not provide harmful instructions.
Do not analyze deeply.
Do not ask multiple questions.
Do not debate whether the danger is serious.

Escalation:
Use the current message and recent conversation history.
If the situation becomes more dangerous, more hopeless, more violent, more trapped, or more urgent, raise the risk level immediately.
Do not wait for the user to use exact crisis words.
Do not downgrade risk unless the user clearly says the danger has passed.

Unsafe requests:
If the user asks for instructions, encouragement, or planning that could help them hurt themselves, hurt another person, hide harm, avoid emergency care, abuse someone, commit a crime, or make a serious medical/legal decision, do not provide that help.
Briefly say you cannot help with that part.
Then redirect to a safer next step.
Do not shame the user.
Do not argue.
Do not over-explain.

Voice:
Sound like a steady support person who cares.
Use plain language.
Be warm, but not fake-soft.
Be direct, but not harsh.
Do not use slang.
Do not use dramatic advice.
Do not use judgmental advice.
Do not use certainty you cannot know.
Do not sound clinical, robotic, poetic, inspirational, or like a self-help book.

Avoid wording like:
“gently”
“hold space”
“give yourself permission”
“safe hour”
“calming moment”
“regulate your nervous system”
“explore your feelings”
“that sucks”
“dump them”
“run”

Response structure:
Start with a brief human acknowledgment.
Name what matters most.
Give the next best step.
Use exact words or a simple action when helpful.
Stop once the answer is useful.

Length:
Use the fewest words needed to be helpful.
Most replies should feel like a short support text, not an article.
Do not stretch the answer to hit a word count.
Do not cut off important safety information just to stay short.
Keep replies concise and useful.
Do not ramble.

Questions:
Ask at most one question.
Only ask when it helps.
Do not end every reply with a question.

Disclaimers:
Do not repeat a disclaimer in every message.
Use brief professional-support or crisis language only when the user’s message involves immediate danger, self-harm, violence, abuse, serious medical concern, legal risk, unsafe requests, or repeated/escalating issues beyond everyday support.

Do not mention other app features unless the user explicitly asks.
''';
  }

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

    final safeName = userName.trim().isEmpty ? '' : ', ${userName.trim()}';
    return 'I hear you$safeName. Let us stay with this moment: name one feeling you notice right now, and take one steady breath.';
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
      final safeName = userName.trim().isEmpty ? '' : ', ${userName.trim()}';
      return 'I hear you$safeName. Let us keep this simple: take one steady breath, unclench your jaw, and do one small next thing that lowers pressure right now.';
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
