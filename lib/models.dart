import 'prompt_builder.dart';

/// Personagem reutilizável: nome e descrição de aparência/roupa.
class Character {
  const Character({
    required this.name,
    required this.description,
    this.descriptionPt = '',
  });

  final String name;

  /// Descrição em inglês (usada no prompt).
  final String description;

  /// Descrição em português (opcional, para o prompt em português).
  final String descriptionPt;

  /// Devolve a descrição no idioma pedido (português só se existir).
  String descriptionFor(PromptLocale locale) {
    if (locale == PromptLocale.pt && descriptionPt.isNotEmpty) {
      return descriptionPt;
    }
    return description;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'descriptionPt': descriptionPt,
      };

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'] as String,
      description: json['description'] as String,
      descriptionPt: json['descriptionPt'] as String? ?? '',
    );
  }
}

/// Cena salva na lista de cenas.
class SavedScene {
  const SavedScene({required this.title, required this.prompt});

  final String title;
  final String prompt;

  Map<String, dynamic> toJson() => {'title': title, 'prompt': prompt};

  factory SavedScene.fromJson(Map<String, dynamic> json) {
    return SavedScene(
      title: json['title'] as String,
      prompt: json['prompt'] as String,
    );
  }
}
