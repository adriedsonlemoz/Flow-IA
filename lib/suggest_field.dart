import 'package:flutter/material.dart';

import 'suggestion_picker.dart';
import 'suggestions.dart';

/// Campo de texto com botão de lâmpada que abre uma lista de sugestões.
class SuggestField extends StatelessWidget {
  const SuggestField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.pickerTitle,
    required this.suggestions,
    this.minLines = 1,
    this.maxLines = 3,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String pickerTitle;
  final List<Suggestion> suggestions;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  Future<void> _pick(BuildContext context) async {
    final picked = await showSuggestionPicker(
      context,
      title: pickerTitle,
      items: suggestions,
    );
    if (picked == null || picked.isNone) return;
    controller.text = picked.label;
    controller.selection = TextSelection.collapsed(
      offset: picked.label.length,
    );
    onChanged?.call(picked.label);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        suffixIcon: IconButton(
          tooltip: 'Sugestões',
          icon: const Icon(Icons.lightbulb_outline),
          onPressed: () => _pick(context),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
