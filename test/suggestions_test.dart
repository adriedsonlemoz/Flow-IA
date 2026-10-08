import 'package:flow_ia/models.dart';
import 'package:flow_ia/prompt_builder.dart';
import 'package:flow_ia/suggestions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catálogos têm itens completos e sem repetição', () {
    final catalogs = {
      'personagens': characterSuggestions,
      'roupas': outfitSuggestions,
      'acessórios': accessorySuggestions,
      'cenários': sceneSuggestions,
      'ações': actionSuggestions,
      'falas': speechSuggestions,
    };

    catalogs.forEach((name, items) {
      expect(items, isNotEmpty, reason: name);
      final labels = items.map((s) => s.label).toList();
      expect(labels.toSet().length, labels.length, reason: '$name repetido');
      for (final s in items) {
        expect(s.group, isNotEmpty, reason: '$name: ${s.label}');
        expect(s.label, isNotEmpty, reason: name);
      }
    });
    expect(characterSuggestions.length, greaterThanOrEqualTo(40));
  });

  test('personagens, roupas e acessórios têm inglês e português', () {
    final items = [
      ...characterSuggestions,
      ...outfitSuggestions,
      ...accessorySuggestions,
    ];

    for (final s in items) {
      expect(s.english, isNotEmpty, reason: s.label);
      expect(s.portuguese, isNotEmpty, reason: s.label);
    }
  });

  test('cenários e ações têm texto em inglês', () {
    for (final s in [...sceneSuggestions, ...actionSuggestions]) {
      expect(s.english, isNotEmpty, reason: s.label);
    }
  });

  test('falas cabem em um clipe', () {
    for (final s in speechSuggestions) {
      expect(countWords(s.label), lessThanOrEqualTo(maxWordsPerClip));
    }
  });

  test('sugestão vira inglês; texto livre fica como digitado', () {
    final scene = sceneSuggestions.first;

    expect(localizeScene(scene.label, PromptLocale.en), scene.english);
    expect(localizeScene(scene.label, PromptLocale.pt), scene.label);
    expect(localizeScene('Meu cenário', PromptLocale.en), 'Meu cenário');
    expect(localizeAction(' ', PromptLocale.en), '');
  });

  test('descrição do personagem respeita o idioma', () {
    const withPt = Character(
      name: 'Ana',
      description: 'a woman',
      descriptionPt: 'uma mulher',
    );
    const withoutPt = Character(name: 'Bia', description: 'a girl');

    expect(withPt.descriptionFor(PromptLocale.en), 'a woman');
    expect(withPt.descriptionFor(PromptLocale.pt), 'uma mulher');
    expect(withoutPt.descriptionFor(PromptLocale.pt), 'a girl');
    expect(Character.fromJson(withPt.toJson()).descriptionPt, 'uma mulher');
  });
}
