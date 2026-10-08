import 'gemini_service.dart';
import 'storage.dart';

/// Melhora [base] (prompt em inglês) com o Gemini e atualiza o contador.
Future<String> improvePrompt(Storage storage, String base) async {
  final key = await storage.loadApiKey();
  if (key.isEmpty) {
    throw GeminiException('Cole sua chave do Gemini em Opções (engrenagem).');
  }
  final model = await storage.loadModel();
  final service = GeminiService(apiKey: key, model: model);
  try {
    final text = await service.generate(
      system: improveSystemPrompt,
      user: base,
    );
    await storage.incrementUsage();
    return text;
  } on GeminiException catch (e) {
    if (e.quotaId != null) {
      await storage.saveLearnedLimit('${e.quotaId} = ${e.quotaValue}');
    }
    rethrow;
  }
}
