import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

const String geminiBase = 'https://generativelanguage.googleapis.com/v1beta';

/// Modelo padrão: Flash-Lite, listado como gratuito na página de preços
/// do Gemini API (conferida em out/2026). Pode ser trocado nas opções.
const String defaultModel = 'gemini-3.5-flash-lite';

const List<String> suggestedModels = [
  'gemini-3.5-flash-lite',
  'gemini-3.8-flash',
  'gemini-3.7-flash',
  'gemini-3.1-flash-lite',
];

const String apiKeyUrl = 'https://aistudio.google.com/apikey';
const String rateLimitUrl = 'https://aistudio.google.com/rate-limit';
const String pricingUrl = 'https://ai.google.dev/gemini-api/docs/pricing';

const String improveSystemPrompt =
    'You are an expert prompt engineer for AI video generators such as '
    'Google Flow (Veo). Rewrite the prompt the user sends so it is more '
    'vivid, specific and cinematic while keeping every instruction. Rules: '
    '1) Output only the final prompt, in English, as a single paragraph, '
    'with no explanations, markdown or quotes around it. '
    '2) Keep the opening sentence "Maintaining the same character '
    'appearance and clothes from the reference image:" exactly as it is. '
    '3) Translate any Portuguese descriptions (scene, character, action) '
    'to English, but keep the spoken dialogue between single quotes exactly '
    'as written, in its original language. '
    '4) Keep the spoken-language, voice, lighting, camera, lip-sync and '
    'no-subtitles instructions. '
    '5) Keep the final words "ultra detailed, 4k resolution". '
    '6) Do not invent new characters or change the dialogue. '
    '7) Keep it concise: the clip is about 8 seconds long.';

/// Erro amigável da API (mensagem já em português).
class GeminiException implements Exception {
  GeminiException(
    this.message, {
    this.isDaily = false,
    this.retrySeconds,
    this.quotaId,
    this.quotaValue,
  });

  final String message;
  final bool isDaily;
  final int? retrySeconds;
  final String? quotaId;
  final String? quotaValue;

  @override
  String toString() => message;
}

/// Converte uma resposta de erro da API em [GeminiException].
GeminiException parseGeminiError(int status, String body) {
  Map<String, dynamic>? error;
  try {
    final data = jsonDecode(body);
    final e = data is Map<String, dynamic> ? data['error'] : null;
    if (e is Map<String, dynamic>) error = e;
  } on FormatException {
    error = null;
  }

  final apiMessage = '${error?['message'] ?? ''}';
  final details = error?['details'];
  int? retry;
  String? quotaId;
  String? quotaValue;
  var daily = false;

  if (details is List<dynamic>) {
    for (final d in details) {
      if (d is! Map<String, dynamic>) continue;
      final delay = d['retryDelay'];
      if (delay is String) {
        retry = double.tryParse(delay.replaceAll('s', ''))?.ceil();
      }
      final violations = d['violations'];
      if (violations is! List<dynamic>) continue;
      for (final v in violations) {
        if (v is! Map<String, dynamic>) continue;
        final id = '${v['quotaId']}';
        if (id.contains('PerDay')) daily = true;
        quotaId ??= id;
        quotaValue ??= v['quotaValue']?.toString();
      }
    }
  }

  if (status == 429) {
    final limit = quotaValue == null ? '' : ' (cota: $quotaValue)';
    final String message;
    if (daily) {
      message = 'Limite diário gratuito atingido$limit. Tente amanhã, '
          'troque o modelo nas opções ou confira o console.';
    } else {
      message = 'Muitas requisições em pouco tempo. '
          'Tente de novo em ~${retry ?? 60}s.';
    }
    return GeminiException(
      message,
      isDaily: daily,
      retrySeconds: retry,
      quotaId: quotaId,
      quotaValue: quotaValue,
    );
  }

  final invalidKey =
      body.contains('API_KEY_INVALID') || apiMessage.contains('API key');
  if (invalidKey || status == 401) {
    return GeminiException('Chave inválida. Confira se copiou tudo.');
  }
  if (status == 403) {
    return GeminiException('Acesso negado para esta chave ou modelo.');
  }
  if (status == 404) {
    return GeminiException('Modelo não encontrado. Troque-o nas opções.');
  }
  if (status >= 500) {
    return GeminiException('Gemini indisponível agora. Tente em instantes.');
  }
  return GeminiException('Erro $status: $apiMessage');
}

/// Filtra a lista de modelos deixando só os de texto da família Flash.
List<String> flashModels(List<String> all) {
  const blocked = [
    'image',
    'tts',
    'live',
    'transcribe',
    'omni',
    'embedding',
    'audio',
    'robotics',
    'computer',
  ];
  return [
    for (final m in all)
      if (m.contains('flash') && !blocked.any(m.contains)) m,
  ];
}

String _cleanOutput(String text) {
  var t = text.trim();
  if (t.startsWith('```')) {
    t = t.replaceFirst(RegExp(r'^```[a-zA-Z]*\n?'), '');
    t = t.replaceFirst(RegExp(r'```\s*$'), '');
  }
  return t.trim();
}

class GeminiService {
  GeminiService({
    required this.apiKey,
    required this.model,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _client;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-goog-api-key': apiKey,
      };

  Future<http.Response> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(const Duration(seconds: 45));
    } on TimeoutException {
      throw GeminiException('Tempo esgotado. Tente de novo.');
    } on Exception {
      throw GeminiException('Sem conexão com a internet.');
    }
    if (response.statusCode != 200) {
      throw parseGeminiError(response.statusCode, response.body);
    }
    return response;
  }

  /// Envia [user] com a instrução [system] e devolve o texto gerado.
  Future<String> generate({
    required String system,
    required String user,
  }) async {
    final uri = Uri.parse('$geminiBase/models/$model:generateContent');
    final body = jsonEncode({
      'systemInstruction': {
        'parts': [
          {'text': system},
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': user},
          ],
        },
      ],
      'generationConfig': {'temperature': 0.7},
    });

    final response = await _send(
      () => _client.post(uri, headers: _headers, body: body),
    );

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final candidates = data is Map<String, dynamic> ? data['candidates'] : null;
    if (candidates is! List<dynamic> || candidates.isEmpty) {
      throw GeminiException('A IA não devolveu resposta (bloqueada?).');
    }
    final first = candidates.first;
    final content = first is Map<String, dynamic> ? first['content'] : null;
    final parts = content is Map<String, dynamic> ? content['parts'] : null;
    final buffer = StringBuffer();
    if (parts is List<dynamic>) {
      for (final p in parts) {
        if (p is! Map<String, dynamic> || p['thought'] == true) continue;
        buffer.write(p['text'] ?? '');
      }
    }
    final text = _cleanOutput(buffer.toString());
    if (text.isEmpty) {
      throw GeminiException('A IA devolveu uma resposta vazia.');
    }
    return text;
  }

  /// Lista os modelos que aceitam geração de texto (também valida a chave).
  Future<List<String>> listModels() async {
    final uri = Uri.parse('$geminiBase/models?pageSize=200');
    final response = await _send(() => _client.get(uri, headers: _headers));
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    final models = data is Map<String, dynamic> ? data['models'] : null;
    final names = <String>[];
    if (models is List<dynamic>) {
      for (final m in models) {
        if (m is! Map<String, dynamic>) continue;
        final methods = m['supportedGenerationMethods'];
        if (methods is List<dynamic> && !methods.contains('generateContent')) {
          continue;
        }
        names.add('${m['name']}'.replaceFirst('models/', ''));
      }
    }
    return names;
  }
}
