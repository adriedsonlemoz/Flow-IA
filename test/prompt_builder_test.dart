import 'package:flow_ia/prompt_builder.dart';
import 'package:flutter_test/flutter_test.dart';

String build({
  String context = 'A presenter in a tech studio',
  String dialogue = 'Hello everyone',
  String action = '',
  String character = '',
  PromptOption? voice,
}) {
  return buildPrompt(
    context: context,
    dialogue: dialogue,
    action: action,
    character: character,
    voice: voice ?? voiceOptions.first,
    language: languageOptions.first,
    lighting: lightingOptions.first,
    camera: cameraOptions.first,
  );
}

void main() {
  test('prompt tem prefixo fixo e sufixo de qualidade', () {
    final prompt = build();

    expect(prompt.startsWith(consistencyPrefix), isTrue);
    expect(prompt.contains('Voice:'), isTrue);
    expect(prompt.contains('Lighting:'), isTrue);
    expect(prompt.contains('Camera:'), isTrue);
    expect(prompt.endsWith('Ultra detailed, 4k resolution.'), isTrue);
  });

  test('fala usa o idioma escolhido e pede sincronia labial', () {
    final prompt = build();

    expect(
      prompt.contains("speaking in Brazilian Portuguese: 'Hello everyone'"),
      isTrue,
    );
    expect(prompt.contains('Lips perfectly synced'), isTrue);
    expect(prompt.contains('No subtitles, no captions'), isTrue);
  });

  test('Sem Voz usa acting e não pede sincronia labial', () {
    final prompt = build(dialogue: 'Smiles', voice: voiceOptions.last);

    expect(prompt.contains("acting: 'Smiles'"), isTrue);
    expect(prompt.contains('speaking'), isFalse);
    expect(prompt.contains('Lips perfectly synced'), isFalse);
  });

  test('campos vazios não geram trechos vazios', () {
    final prompt = build(context: '', dialogue: '');

    expect(prompt.contains('speaking'), isFalse);
    expect(prompt.contains('acting'), isFalse);
    expect(prompt.contains('Lips perfectly synced'), isFalse);
    expect(prompt.contains('Action:'), isFalse);
    expect(prompt.contains('Character:'), isFalse);
  });

  test('personagem e ação entram no prompt', () {
    final prompt = build(
      character: 'a young man with short black hair',
      action: 'points at the screen and smiles',
    );

    expect(prompt.contains('Character: A young man'), isTrue);
    expect(prompt.contains('Action: Points at the screen'), isTrue);
  });

  test('contagem de palavras e duração estimada', () {
    expect(countWords('  '), 0);
    expect(countWords('uma duas  três'), 3);
    expect(estimateSeconds(23), 10);
  });

  test('versão em português usa os termos e rótulos em português', () {
    final prompt = buildPrompt(
      context: 'Um apresentador em um estúdio',
      dialogue: 'Olá',
      voice: voiceOptions.first,
      language: languageOptions.first,
      lighting: lightingOptions.first,
      camera: cameraOptions.first,
      locale: PromptLocale.pt,
    );

    expect(prompt.startsWith('Mantendo a mesma aparência'), isTrue);
    expect(prompt.contains("falando em português do Brasil: 'Olá'"), isTrue);
    expect(prompt.contains('Voz: voz de narrador'), isTrue);
    expect(prompt.contains('Lábios perfeitamente sincronizados'), isTrue);
    expect(prompt.endsWith('Ultra detalhado, resolução 4k.'), isTrue);
  });
}
