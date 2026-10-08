import 'dart:convert';

import 'package:flow_ia/gemini_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const quotaBody = '''
{"error": {"code": 429, "message": "You exceeded your current quota",
"status": "RESOURCE_EXHAUSTED", "details": [
{"@type": "type.googleapis.com/google.rpc.QuotaFailure", "violations": [
{"quotaId": "GenerateRequestsPerDayPerProjectPerModel-FreeTier",
"quotaValue": "20"}]},
{"@type": "type.googleapis.com/google.rpc.RetryInfo", "retryDelay": "27s"}]}}
''';

void main() {
  test('erro 429 diário expõe limite e tempo de espera', () {
    final e = parseGeminiError(429, quotaBody);

    expect(e.isDaily, isTrue);
    expect(e.retrySeconds, 27);
    expect(e.quotaValue, '20');
    expect(e.message.contains('Limite diário'), isTrue);
  });

  test('chave inválida gera mensagem amigável', () {
    final e = parseGeminiError(
      400,
      '{"error":{"message":"API key not valid.","status":"INVALID_ARGUMENT"}}',
    );

    expect(e.message.contains('Chave inválida'), isTrue);
  });

  test('generate envia a chave no header e limpa a resposta', () async {
    final client = MockClient((request) async {
      expect(request.headers['x-goog-api-key'], 'KEY');
      expect(request.url.path.endsWith('models/m1:generateContent'), isTrue);
      final reply = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': '```\n Hello world \n```'},
              ],
            },
          },
        ],
      };
      return http.Response(jsonEncode(reply), 200);
    });
    final service = GeminiService(apiKey: 'KEY', model: 'm1', client: client);

    final text = await service.generate(system: 's', user: 'u');

    expect(text, 'Hello world');
  });

  test('flashModels mantém só modelos Flash de texto', () {
    final result = flashModels([
      'gemini-3.5-flash-lite',
      'gemini-3.8-flash',
      'gemini-3.1-flash-image',
      'gemini-3.8-flash-tts',
      'gemini-3.1-pro-preview',
    ]);

    expect(result, ['gemini-3.5-flash-lite', 'gemini-3.8-flash']);
  });

  test('modelo sugerido vem primeiro na lista', () {
    final available = [
      'gemini-3.8-flash',
      'gemini-flash-latest',
      'gemini-3.5-flash-lite',
    ];

    expect(recommendedModel(available), 'gemini-flash-latest');
    expect(orderModels(available).first, 'gemini-flash-latest');
    expect(orderModels(available).length, 3);
    final other = ['gemini-3.8-flash', 'x-flash'];
    expect(recommendedModel(other), 'gemini-3.8-flash');
    expect(recommendedModel([]), defaultModel);
  });
}
