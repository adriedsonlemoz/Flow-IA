import 'package:flow_ia/backup_service.dart';
import 'package:flow_ia/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const characters = [
    Character(name: 'Ana', description: 'a woman with red hair'),
  ];
  const scenes = [SavedScene(title: 'Estúdio', prompt: 'Maintaining...')];

  test('exporta e importa sem perder dados', () {
    final text = encodeBackup(
      const BackupData(characters: characters, scenes: scenes),
    );
    final data = decodeBackup(text);

    expect(data.characters.single.name, 'Ana');
    expect(data.scenes.single.prompt, 'Maintaining...');
  });

  test('texto inválido gera FormatException', () {
    expect(() => decodeBackup('isso não é json'), throwsFormatException);
    expect(() => decodeBackup('{"app": "outro"}'), throwsFormatException);
  });

  test('importar ignora itens malformados', () {
    final data = decodeBackup(
      '{"app": "flow_ia", "characters": [{"name": 1}, '
      '{"name": "Bia", "description": "a girl"}], "scenes": ["x"]}',
    );

    expect(data.characters.length, 1);
    expect(data.scenes, isEmpty);
  });

  test('merge não duplica itens', () {
    final merged = mergeCharacters(characters, const [
      Character(name: 'Ana', description: 'a woman with red hair'),
      Character(name: 'Bia', description: 'a girl'),
    ]);

    expect(merged.length, 2);
    expect(mergeScenes(scenes, scenes).length, 1);
  });
}
