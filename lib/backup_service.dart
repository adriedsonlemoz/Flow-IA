import 'dart:convert';

import 'models.dart';

/// Dados que entram no backup (a chave da API nunca é incluída).
class BackupData {
  const BackupData({required this.characters, required this.scenes});

  final List<Character> characters;
  final List<SavedScene> scenes;
}

/// Gera o texto do backup em JSON.
String encodeBackup(BackupData data) {
  return const JsonEncoder.withIndent('  ').convert({
    'app': 'flow_ia',
    'format': 1,
    'characters': [for (final c in data.characters) c.toJson()],
    'scenes': [for (final s in data.scenes) s.toJson()],
  });
}

bool _validCharacter(Object? e) =>
    e is Map<String, dynamic> &&
    e['name'] is String &&
    e['description'] is String;

bool _validScene(Object? e) =>
    e is Map<String, dynamic> && e['title'] is String && e['prompt'] is String;

/// Lê o texto de um backup. Lança [FormatException] se for inválido.
BackupData decodeBackup(String text) {
  final Object? raw;
  try {
    raw = jsonDecode(text.trim());
  } on FormatException {
    throw const FormatException('Este texto não é um backup válido.');
  }
  if (raw is! Map<String, dynamic> || raw['app'] != 'flow_ia') {
    throw const FormatException('Este texto não é um backup do Flow IA.');
  }
  final rawCharacters = raw['characters'];
  final rawScenes = raw['scenes'];
  return BackupData(
    characters: [
      if (rawCharacters is List<dynamic>)
        for (final e in rawCharacters)
          if (_validCharacter(e)) Character.fromJson(e as Map<String, dynamic>),
    ],
    scenes: [
      if (rawScenes is List<dynamic>)
        for (final e in rawScenes)
          if (_validScene(e)) SavedScene.fromJson(e as Map<String, dynamic>),
    ],
  );
}

/// Junta [incoming] a [current] sem duplicar personagens iguais.
List<Character> mergeCharacters(
  List<Character> current,
  List<Character> incoming,
) {
  final result = [...current];
  for (final c in incoming) {
    final exists = result.any(
      (e) => e.name == c.name && e.description == c.description,
    );
    if (!exists) result.add(c);
  }
  return result;
}

/// Junta [incoming] a [current] sem duplicar cenas com o mesmo prompt.
List<SavedScene> mergeScenes(
  List<SavedScene> current,
  List<SavedScene> incoming,
) {
  final result = [...current];
  for (final s in incoming) {
    if (!result.any((e) => e.prompt == s.prompt)) result.add(s);
  }
  return result;
}
