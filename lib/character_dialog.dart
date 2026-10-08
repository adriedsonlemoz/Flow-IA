import 'package:flutter/material.dart';

import 'models.dart';

class CharacterDialog extends StatefulWidget {
  const CharacterDialog({super.key});

  @override
  State<CharacterDialog> createState() => _CharacterDialogState();
}

class _CharacterDialogState extends State<CharacterDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(
      context,
      Character(name: name, description: _descController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Novo personagem'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Aparência e roupa (em inglês)',
                hintText: 'Ex.: a young man with short black hair...',
                alignLabelWithHint: true,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }
}
