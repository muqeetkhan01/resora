import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../data/models/app_models.dart';

enum _TalkToResoraMode {
  vague,
  practicalSupport,
  vent,
  safetySupport,
  boundary,
  emergency,
}

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

    final savedEmergencyReply = _savedEmergencyReplyFor(latestUserMessage);
    if (savedEmergencyReply != null) {
      return _cleanFinalText(savedEmergencyReply);
    }

    final savedBoundaryReply = _savedBoundaryReplyFor(latestUserMessage);
    if (savedBoundaryReply != null) {
      return _cleanFinalText(savedBoundaryReply);
    }

    final classifiedMode = await _classifyMode(
      messages: contextWindow,
      latestUserMessage: latestUserMessage,
      softMemoryBlock: softMemoryBlock,
    );
    if (classifiedMode == _TalkToResoraMode.emergency) {
      return _cleanFinalText(
        _savedEmergencyReplyFor(latestUserMessage) ?? _defaultEmergencyReply,
      );
    }
    if (classifiedMode == _TalkToResoraMode.boundary) {
      return _cleanFinalText(
        _savedBoundaryReplyFor(latestUserMessage) ?? _defaultBoundaryReply,
      );
    }

    final firstDraft = await _generateModeReply(
      messages: contextWindow,
      userName: userName,
      latestUserMessage: latestUserMessage,
      softMemoryBlock: softMemoryBlock,
      mode: classifiedMode,
    );

    final firstFinal = _finalizeReply(
      reply: firstDraft,
      latestUserMessage: latestUserMessage,
      userName: userName,
    );
    if (!_containsBlockedOutputPhrase(firstFinal)) {
      return firstFinal;
    }

    final repairedDraft = await _generateModeReply(
      messages: contextWindow,
      userName: userName,
      latestUserMessage: latestUserMessage,
      softMemoryBlock: softMemoryBlock,
      mode: classifiedMode,
      blockedDraft: firstFinal,
    );
    final repairedFinal = _finalizeReply(
      reply: repairedDraft,
      latestUserMessage: latestUserMessage,
      userName: userName,
    );
    if (!_containsBlockedOutputPhrase(repairedFinal)) {
      return repairedFinal;
    }

    return _finalizeReply(
      reply: _safeFallbackReplyForMode(classifiedMode),
      latestUserMessage: latestUserMessage,
      userName: userName,
    );
  }

  Future<_TalkToResoraMode> _classifyMode({
    required List<ChatMessageModel> messages,
    required String latestUserMessage,
    required String softMemoryBlock,
  }) async {
    final heuristicMode = _heuristicModeFor(latestUserMessage);
    if (heuristicMode == _TalkToResoraMode.emergency ||
        heuristicMode == _TalkToResoraMode.boundary) {
      return heuristicMode;
    }

    final transcript = _compactTranscript(messages);
    final memory = softMemoryBlock.trim().isEmpty
        ? 'No prior context.'
        : softMemoryBlock.trim();
    final input = _textInput(
      role: 'system',
      text: '''
Classify the latest message for a wellness support chat.
Return exactly one label:
VAGUE
PRACTICAL SUPPORT
VENT
SAFETY SUPPORT
BOUNDARY
EMERGENCY

VAGUE: unclear emotion or struggle without enough detail for useful advice.
PRACTICAL SUPPORT: concrete everyday problem where practical next steps fit.
VENT: user clearly only wants to vent or be heard.
SAFETY SUPPORT: high distress but no clear immediate danger.
BOUNDARY: asks for medication choice, diagnosis, legal/medical decision or unsafe instructions.
EMERGENCY: immediate danger, suicide intent, overdose, poisoning, choking, weapon, trapped violence, serious injury or cannot stay safe.
Do not explain.
''',
    );
    final userInput = _textInput(
      role: 'user',
      text: '''
Recent context:
$transcript

Memory:
$memory

Latest message:
$latestUserMessage
''',
    );

    try {
      final data = await _postResponses(
        payload: {
          'model': _model,
          'input': [input, userInput],
          'temperature': 0,
          'max_output_tokens': 12,
        },
      );
      final raw = _extractOutputText(data);
      return _parseMode(raw) ?? heuristicMode;
    } catch (_) {
      return heuristicMode;
    }
  }

  Future<String> _generateModeReply({
    required List<ChatMessageModel> messages,
    required String userName,
    required String latestUserMessage,
    required String softMemoryBlock,
    required _TalkToResoraMode mode,
    String? blockedDraft,
  }) async {
    final input = <Map<String, dynamic>>[
      _textInput(
        role: 'system',
        text: _modePrompt(
          mode: mode,
          userName: userName,
          softMemoryBlock: softMemoryBlock,
          blockedDraft: blockedDraft,
        ),
      ),
      ...messages.map(_toInputMessage),
    ];

    final data = await _postResponses(
      payload: {
        'model': _model,
        'input': input,
        'temperature': 0.45,
        'max_output_tokens': 320,
      },
    );
    final outputText = _extractOutputText(data);
    if (outputText.isNotEmpty) {
      return outputText;
    }

    final fallback = _extractIncompleteFallback(data);
    if (fallback.isNotEmpty) {
      return fallback;
    }

    return _safeFallbackReplyForMode(mode);
  }

  Future<Map<String, dynamic>> _postResponses({
    required Map<String, dynamic> payload,
  }) async {
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
        throw _AiApiException(_policyFallbackReply('friend'));
      }
      throw _AiApiException(
        _mapStatusToUserMessage(
          statusCode: response.statusCode,
          apiMessage: errorMessage,
        ),
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Map<String, dynamic> _textInput({
    required String role,
    required String text,
  }) {
    return {
      'role': role,
      'content': [
        {
          'type': 'input_text',
          'text': text,
        },
      ],
    };
  }

  _TalkToResoraMode _heuristicModeFor(String latestUserMessage) {
    final text = _normalizeForPolicy(latestUserMessage);
    if (_savedEmergencyReplyFor(latestUserMessage) != null) {
      return _TalkToResoraMode.emergency;
    }
    if (_savedBoundaryReplyFor(latestUserMessage) != null) {
      return _TalkToResoraMode.boundary;
    }

    const safetySupportSignals = <String>[
      "i can't do this",
      'i cant do this',
      'i have nobody',
      'everyone hates me',
      "i'm not enough",
      'im not enough',
      'i wish i could disappear',
      'i feel so alone',
      'i just want to feel better',
    ];
    if (safetySupportSignals.any(text.contains)) {
      return _TalkToResoraMode.safetySupport;
    }

    const ventSignals = <String>[
      'i just need to vent',
      'i need to vent',
      'just venting',
      'let me vent',
      "don't give advice",
      'dont give advice',
      'no advice',
    ];
    if (ventSignals.any(text.contains)) {
      return _TalkToResoraMode.vent;
    }

    final wordCount = text
        .split(RegExp(r'\s+'))
        .where((word) => word.trim().isNotEmpty)
        .length;
    if (wordCount <= 5 ||
        RegExp(r'\b(overwhelmed|low|off|sad|stressed|anxious)\b')
            .hasMatch(text)) {
      return _TalkToResoraMode.vague;
    }

    return _TalkToResoraMode.practicalSupport;
  }

  _TalkToResoraMode? _parseMode(String raw) {
    final normalized = raw
        .toUpperCase()
        .replaceAll(RegExp(r'[^A-Z\s]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.contains('EMERGENCY')) {
      return _TalkToResoraMode.emergency;
    }
    if (normalized.contains('BOUNDARY')) {
      return _TalkToResoraMode.boundary;
    }
    if (normalized.contains('SAFETY SUPPORT')) {
      return _TalkToResoraMode.safetySupport;
    }
    if (normalized.contains('PRACTICAL SUPPORT')) {
      return _TalkToResoraMode.practicalSupport;
    }
    if (normalized.contains('VENT')) {
      return _TalkToResoraMode.vent;
    }
    if (normalized.contains('VAGUE')) {
      return _TalkToResoraMode.vague;
    }
    return null;
  }

  String _compactTranscript(List<ChatMessageModel> messages) {
    final recent =
        messages.length > 6 ? messages.sublist(messages.length - 6) : messages;
    return recent
        .map((message) =>
            '${message.isUser ? 'user' : 'resora'}: ${message.text.trim()}')
        .where((line) => line.trim().isNotEmpty)
        .join('\n');
  }

  String _modePrompt({
    required _TalkToResoraMode mode,
    required String userName,
    required String softMemoryBlock,
    String? blockedDraft,
  }) {
    final safeName = userName.trim().isEmpty ? 'friend' : userName.trim();
    final context = softMemoryBlock.trim().isEmpty
        ? 'No meaningful prior context yet. Stay grounded in the current message.'
        : softMemoryBlock.trim();
    final repairInstruction = blockedDraft == null
        ? ''
        : '''

The previous draft was blocked and must not be reused:
$blockedDraft
Rewrite once without any blocked phrase.
''';

    return '''
You are Resora, a real-life support assistant for everyday wellness, reflection, venting, questions and practical next steps.
Resora is not therapy, medical care, legal advice, crisis care, diagnosis or treatment.
User name: $safeName
Recent context and memory: $context

Mode: ${_modeLabel(mode)}
${_modeInstruction(mode)}

Style rules:
Talk like a normal person texting back.
No bullets, numbered lists, markdown, headings or long paragraphs.
Do not diagnose, prescribe, give legal advice or make medical decisions.
Do not use therapy language, meditation language or fake-soft language.
Do not mention app features unless the user asks.
Never use these phrases: ${_blockedOutputPhrases.join('; ')}.
$repairInstruction
''';
  }

  String _modeInstruction(_TalkToResoraMode mode) {
    switch (mode) {
      case _TalkToResoraMode.vague:
        return 'Ask exactly one normal clarifying question. Do not give advice yet. Do not assume danger.';
      case _TalkToResoraMode.practicalSupport:
        return 'Give practical advice first using only the details given. Use three to six normal sentences. Ask one useful follow-up only if it is needed for the next response.';
      case _TalkToResoraMode.vent:
        return 'Do not solve the problem unless the user asks for advice. Stay brief and human. Ask one real question about what happened or what part is weighing on them most.';
      case _TalkToResoraMode.safetySupport:
        return 'Give one or two immediate concrete next steps. Do not ask the user to create the plan. Use a neutral safety question only if needed.';
      case _TalkToResoraMode.boundary:
        return 'Briefly say you cannot help with that part and redirect to a safer next step.';
      case _TalkToResoraMode.emergency:
        return 'Do not write emergency responses. The app should use a saved emergency reply.';
    }
  }

  String _modeLabel(_TalkToResoraMode mode) {
    switch (mode) {
      case _TalkToResoraMode.vague:
        return 'VAGUE';
      case _TalkToResoraMode.practicalSupport:
        return 'PRACTICAL SUPPORT';
      case _TalkToResoraMode.vent:
        return 'VENT';
      case _TalkToResoraMode.safetySupport:
        return 'SAFETY SUPPORT';
      case _TalkToResoraMode.boundary:
        return 'BOUNDARY';
      case _TalkToResoraMode.emergency:
        return 'EMERGENCY';
    }
  }

  String _safeFallbackReplyForMode(_TalkToResoraMode mode) {
    switch (mode) {
      case _TalkToResoraMode.vague:
        return 'What happened?';
      case _TalkToResoraMode.practicalSupport:
        return 'Start with the most immediate piece first. What happened?';
      case _TalkToResoraMode.vent:
        return 'That is a lot to carry. What part is weighing on you most right now?';
      case _TalkToResoraMode.safetySupport:
        return 'Sit somewhere steadier and focus on the next few minutes only. Are you physically safe right now?';
      case _TalkToResoraMode.boundary:
        return _defaultBoundaryReply;
      case _TalkToResoraMode.emergency:
        return _defaultEmergencyReply;
    }
  }

  String? _savedEmergencyReplyFor(String message) {
    final text = _normalizeForPolicy(message);
    if (_mentionsChildPoisoning(text)) {
      return 'Call emergency services or Poison Control now. Do not wait to see if it passes. Keep the container nearby so responders can see what was swallowed. Is the child breathing and physically safe right now?';
    }
    if (_mentionsPoisoningOrOverdose(text)) {
      return 'Call emergency services or Poison Control now. Do not wait to see if it passes. Move away from anything else you could take and stay where help can reach you. Are you physically safe right now?';
    }
    if (_mentionsSubstanceEmergency(text)) {
      return 'This needs immediate support. Contact 988 now for substance use crisis support. If you used too much, mixed substances, cannot stay awake, cannot breathe, feel out of control, or might drive, call emergency services now. Move somewhere safer if you can. Are you physically safe right now?';
    }
    if (_mentionsChokingOrBreathing(text)) {
      return 'Call emergency services now. If the person cannot breathe, cough, cry, or make sound, get emergency help immediately and start first aid if you know how. Is the person breathing right now?';
    }
    if (_mentionsAllergicReaction(text)) {
      return 'Call emergency services now. Throat, tongue, or face swelling can become dangerous quickly. Sit upright and do not wait to see if it passes. Are you breathing okay right now?';
    }
    if (_mentionsWeaponTrapOrViolence(text)) {
      return 'Call emergency services now if you can do that safely. If calling could make things worse, move toward a safer or more public place if possible. Are you physically safe right now?';
    }
    if (_mentionsSeriousInjury(text)) {
      return 'Call emergency services now. Keep pressure on heavy bleeding if you can do that safely and avoid moving someone with a serious head, neck, or spine injury unless staying there is more dangerous. Is the person awake and breathing?';
    }
    if (_mentionsDependentDanger(text)) {
      return 'Call emergency services or Poison Control now, depending on what happened. Keep the child, elder or dependent away from the danger if you can do that safely. Are they breathing and physically safe right now?';
    }
    if (_mentionsCuttingOrCannotStaySafe(text)) {
      return 'This needs immediate support. Contact 988, emergency services or their crisis care team now. Move sharp objects, medications and anything dangerous away if you can do that safely. Stay nearby without arguing or escalating. Are they physically safe right now?';
    }
    if (_mentionsSuicideOrLifeEnding(text)) {
      return _defaultEmergencyReply;
    }
    return null;
  }

  String? _savedBoundaryReplyFor(String message) {
    final text = _normalizeForPolicy(message);
    const boundarySignals = <String>[
      'choose a medication',
      'which medication',
      'what medication should',
      'change medication',
      'stop medication',
      'start medication',
      'increase my dose',
      'lower my dose',
      'diagnose me',
      'diagnose him',
      'diagnose her',
      'is this legal',
      'should i sue',
      'help me hurt',
      'help me kill',
      'how to hurt',
      'how to kill',
      'how to overdose',
      'avoid emergency care',
      'avoid calling 911',
    ];
    if (boundarySignals.any(text.contains)) {
      if (text.contains('medication') ||
          text.contains('dose') ||
          text.contains('prescription')) {
        return 'I can’t choose or change medication. The prescribing doctor has to handle that. I can help you organize symptoms, side effects and concerns to bring to the doctor.';
      }
      return _defaultBoundaryReply;
    }
    return null;
  }

  String _normalizeForPolicy(String value) {
    return value
        .toLowerCase()
        .replaceAll('’', "'")
        .replaceAll('‘', "'")
        .replaceAll(RegExp(r"[^\w\s']+"), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool _mentionsSuicideOrLifeEnding(String text) {
    const phrases = <String>[
      'kill myself',
      'want to die',
      'wanna die',
      'end my life',
      "i don't want to be alive",
      'i dont want to be alive',
      'cannot stay safe',
      "can't stay safe",
      'cant stay safe',
      'i have a plan',
      'about to do it',
    ];
    return phrases.any(text.contains);
  }

  bool _mentionsChildPoisoning(String text) {
    return text.contains('child got into pills') ||
        text.contains('child drank something poisonous') ||
        text.contains('child drank cleaning spray') ||
        text.contains('baby drank') ||
        text.contains('kid drank poison');
  }

  bool _mentionsPoisoningOrOverdose(String text) {
    const phrases = <String>[
      'took too many pills',
      'took too much',
      'overdose',
      'overdosed',
      'drank poison',
      'mixed pills and alcohol',
      'mixed alcohol and pills',
      'took a bunch of medication',
      'poisoned myself',
      'feel sick after taking',
    ];
    return phrases.any(text.contains);
  }

  bool _mentionsSubstanceEmergency(String text) {
    const phrases = <String>[
      'used too much',
      'drank too much and cant stay awake',
      "drank too much and can't stay awake",
      'used and cant breathe',
      "used and can't breathe",
      'mixed drugs',
      'might overdose',
      'cant stop using tonight',
      "can't stop using tonight",
      'high and driving',
      'drunk and driving',
      'someone passed out after using',
      'wont wake up after drinking',
      "won't wake up after drinking",
      'wont wake up after using',
      "won't wake up after using",
    ];
    return phrases.any(text.contains);
  }

  bool _mentionsChokingOrBreathing(String text) {
    const phrases = <String>[
      'cant breathe',
      "can't breathe",
      'cannot breathe',
      'not breathing',
      'choking',
      'turning blue',
      'gasping for air',
    ];
    return phrases.any(text.contains);
  }

  bool _mentionsAllergicReaction(String text) {
    const phrases = <String>[
      'throat is swelling',
      'tongue is swelling',
      'face is swelling',
      'severe allergic reaction',
    ];
    return phrases.any(text.contains);
  }

  bool _mentionsWeaponTrapOrViolence(String text) {
    const phrases = <String>[
      'has a gun',
      'has a knife',
      'has a weapon',
      'wont let me leave',
      "won't let me leave",
      'blocks the door',
      'blocked the door',
      'trapped',
      'being attacked',
      'going to kill me',
      'threatening me right now',
    ];
    return phrases.any(text.contains) ||
        RegExp(r'\b(gun|knife|weapon|weapons)\b').hasMatch(text);
  }

  bool _mentionsSeriousInjury(String text) {
    const phrases = <String>[
      'bleeding badly',
      'wont stop bleeding',
      "won't stop bleeding",
      'unconscious',
      'passed out and wont wake up',
      "passed out and won't wake up",
      'seizure',
      'head injury',
      'chest pain',
      'stroke symptoms',
    ];
    return phrases.any(text.contains);
  }

  bool _mentionsDependentDanger(String text) {
    const phrases = <String>[
      'child is not safe',
      'cant keep my child safe',
      "can't keep my child safe",
      'cannot keep my child safe',
      'baby isnt breathing',
      "baby isn't breathing",
      'hurting my child right now',
      'elder is in immediate danger',
      'disabled person is in immediate danger',
    ];
    return phrases.any(text.contains);
  }

  bool _mentionsCuttingOrCannotStaySafe(String text) {
    const phrases = <String>[
      'cut today',
      'cut again tonight',
      'might cut again',
      'cut myself',
      'cannot stay safe',
      "can't stay safe",
      'cant stay safe',
      'cannot keep myself safe',
      "can't keep myself safe",
      'cant keep myself safe',
      'cannot keep them safe',
      "can't keep them safe",
      'cant keep them safe',
      'wound that needs care',
    ];
    return phrases.any(text.contains);
  }

  static const String _defaultEmergencyReply =
      'This needs immediate support. Contact 988 now. If there is immediate danger, call emergency services now. Move away from anything dangerous and go somewhere more visible or populated if you can. Are you physically safe right now?';

  static const String _defaultBoundaryReply =
      'I can’t help with that part. I can help you take a safer next step right now.';

  static const List<String> _blockedOutputPhrases = <String>[
    "what's one small thing you can do",
    'what is one small thing you can do',
    'what’s one small thing you can do',
    'how can i support you',
    'are you thinking about hurting yourself',
    'are you going to hurt yourself',
    'if you want, i can',
    'would that be helpful',
    'do you want more ideas',
    'what can you do to feel better',
    'what would help',
    'what do you need right now',
    'what support do you need',
    'how could you relax',
    'what could you do',
    'what do you think you should do',
    'what do you think would help',
  ];

  bool _containsBlockedOutputPhrase(String text) {
    final normalized = text.toLowerCase();
    return _blockedOutputPhrases.any(normalized.contains);
  }

  String _cleanFinalText(String reply) {
    var text = reply.trim();
    if (text.isEmpty) {
      return text;
    }
    text = text.replaceAll('\r\n', '\n');
    text = text.replaceAll(RegExp(r'\s{2,}'), ' ').trim();
    if (!RegExp(r'[.!?]$').hasMatch(text)) {
      text = '$text.';
    }
    return text;
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
