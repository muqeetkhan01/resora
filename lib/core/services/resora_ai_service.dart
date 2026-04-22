import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../data/models/app_models.dart';

class ResoraAiService {
  ResoraAiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _apiKey = String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );
  static const String _model =
      String.fromEnvironment('OPENAI_MODEL', defaultValue: 'gpt-4.1-mini');

  bool get isConfigured => _apiKey.trim().isNotEmpty;

  Future<String> generateReply({
    required List<ChatMessageModel> messages,
    required String userName,
  }) async {
    if (!isConfigured) {
      throw const _AiConfigException(
        'Talk to Resora is not configured yet.',
      );
    }

    final trimmedMessages =
        messages.where((message) => message.text.trim().isNotEmpty).toList();
    final contextWindow = trimmedMessages.length > 14
        ? trimmedMessages.sublist(trimmedMessages.length - 14)
        : trimmedMessages;

    final input = <Map<String, dynamic>>[
      {
        'role': 'system',
        'content': [
          {
            'type': 'input_text',
            'text': _systemPrompt(userName),
          },
        ],
      },
      ...contextWindow.map(_toInputMessage),
    ];

    final payload = {
      'model': _model,
      'input': input,
      'temperature': 0.6,
      'max_output_tokens': 260,
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
      return outputText;
    }

    final fallback = _extractIncompleteFallback(data);
    if (fallback.isNotEmpty) {
      return fallback;
    }

    return _safeFallbackReply(userName);
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

  String _systemPrompt(String userName) {
    final safeName = userName.trim().isEmpty ? 'friend' : userName.trim();

    return '''
You are Resora, a calm, non-judgmental support guide inside a mental wellness app.

Identity and tone:
- Address the user naturally as "$safeName" only when it feels helpful.
- Be warm, steady, grounded, and practical.
- Keep replies concise: 3-6 short sentences, under 120 words.
- No fluff, no long lists, no generic motivational speech.

Core behavior:
- First, validate the feeling in one sentence.
- Then offer one clear next step the user can take now.
- Optionally suggest ONE app-native support path if relevant:
  Journal, Gentle Reset, Quiet the Noise, Rehearse the Moment, Is This Normal.
- Prefer clear language and short concrete wording.

Safety and boundaries:
- Do not diagnose or provide medical/legal/financial advice.
- If the user mentions self-harm, suicide, harming others, or immediate danger:
  respond with empathy, urge contacting local emergency services immediately,
  and encourage reaching a trusted person right now.
- If uncertain about facts, do not fabricate.

Output style:
- Plain text only, no markdown bullets unless absolutely needed.
- End with a grounded, actionable close.
''';
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
