import 'package:flutter/material.dart';

import 'models.dart';

/// Seletor de personagem com botões de adicionar e remover.
class CharacterPicker extends StatelessWidget {
  const CharacterPicker({
    super.key,
    required this.characters,
    required this.selected,
    required this.onSelected,
    required this.onAdd,
    required this.onRemove,
  });

  final List<Character> characters;
  final Character? selected;
  final ValueChanged<Character?> onSelected;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownMenu<Character?>(
            key: ValueKey('${characters.length}-${selected?.name}'),
            expandedInsets: EdgeInsets.zero,
            label: const Text('Personagem'),
            leadingIcon: const Icon(Icons.person_outline),
            initialSelection: selected,
            requestFocusOnTap: false,
            dropdownMenuEntries: [
              const DropdownMenuEntry<Character?>(value: null, label: 'Nenhum'),
              for (final c in characters)
                DropdownMenuEntry<Character?>(value: c, label: c.name),
            ],
            onSelected: onSelected,
          ),
        ),
        IconButton(
          tooltip: 'Novo personagem',
          onPressed: onAdd,
          icon: const Icon(Icons.person_add_alt_1_outlined),
        ),
        if (selected != null)
          IconButton(
            tooltip: 'Remover personagem',
            onPressed: onRemove,
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    );
  }
}
