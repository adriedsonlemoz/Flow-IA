import 'package:flutter/material.dart';

import 'models.dart';
import 'suggestion_picker.dart';
import 'suggestions.dart';

class CharacterDialog extends StatefulWidget {
  const CharacterDialog({super.key});

  @override
  State<CharacterDialog> createState() => _CharacterDialogState();
}

class _CharacterDialogState extends State<CharacterDialog> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  String _baseEn = '';
  String _basePt = '';
  String _outfitEn = '';
  String _outfitPt = '';
  String _accessoryEn = '';
  String _accessoryPt = '';
  bool _edited = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _join(List<String> parts) {
    return parts.where((p) => p.isNotEmpty).join(', ');
  }

  String get _ptText {
    if (_edited) return '';
    return _join([_basePt, _outfitPt, _accessoryPt]);
  }

  void _recompose() {
    setState(() {
      _descController.text = _join([_baseEn, _outfitEn, _accessoryEn]);
      _edited = false;
    });
  }

  /// Se o usuário editou o texto à mão, ele passa a ser a base.
  void _adoptManualText() {
    if (!_edited) return;
    _baseEn = _descController.text.trim();
    _basePt = '';
    _outfitEn = '';
    _outfitPt = '';
    _accessoryEn = '';
    _accessoryPt = '';
  }

  Future<void> _pickBase() async {
    final picked = await showSuggestionPicker(
      context,
      title: 'Sugestões de personagem',
      items: characterSuggestions,
      showDescription: true,
    );
    if (picked == null || picked.isNone) return;
    _baseEn = picked.english;
    _basePt = picked.portuguese;
    if (_nameController.text.trim().isEmpty) {
      _nameController.text = picked.label;
    }
    _recompose();
  }

  Future<void> _pickOutfit() async {
    final picked = await showSuggestionPicker(
      context,
      title: 'Roupa',
      items: outfitSuggestions,
      allowNone: true,
    );
    if (picked == null) return;
    _adoptManualText();
    _outfitEn = picked.english;
    _outfitPt = picked.portuguese;
    _recompose();
  }

  Future<void> _pickAccessory() async {
    final picked = await showSuggestionPicker(
      context,
      title: 'Acessório',
      items: accessorySuggestions,
      allowNone: true,
    );
    if (picked == null) return;
    _adoptManualText();
    _accessoryEn = picked.english;
    _accessoryPt = picked.portuguese;
    _recompose();
  }

  void _save() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(
      context,
      Character(
        name: name,
        description: _descController.text.trim(),
        descriptionPt: _ptText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pt = _ptText;
    return AlertDialog(
      title: const Text('Novo personagem'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: _pickBase,
              icon: const Icon(Icons.lightbulb_outline),
              label: const Text('Sugestões de personagem'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickOutfit,
                    child: const Text('Roupa'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickAccessory,
                    child: const Text('Acessório'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Aparência e roupa (em inglês)',
                hintText: 'Use as sugestões ou escreva aqui',
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(() => _edited = true),
            ),
            if (pt.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Em português: $pt',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
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
