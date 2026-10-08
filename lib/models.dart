/// Personagem reutilizável: nome e descrição de aparência/roupa.
class Character {
  const Character({required this.name, required this.description});

  final String name;
  final String description;

  Map<String, dynamic> toJson() => {'name': name, 'description': description};

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      name: json['name'] as String,
      description: json['description'] as String,
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
