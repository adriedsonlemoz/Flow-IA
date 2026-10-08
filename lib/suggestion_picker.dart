import 'package:flutter/material.dart';

import 'suggestions.dart';

/// Abre uma lista de sugestões com busca. Devolve a escolhida (ou
/// [Suggestion.none]) e null se o usuário fechar sem escolher.
Future<Suggestion?> showSuggestionPicker(
  BuildContext context, {
  required String title,
  required List<Suggestion> items,
  bool allowNone = false,
  bool showDescription = false,
}) {
  return showModalBottomSheet<Suggestion>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _SuggestionSheet(
      title: title,
      items: items,
      allowNone: allowNone,
      showDescription: showDescription,
    ),
  );
}

class _SuggestionSheet extends StatefulWidget {
  const _SuggestionSheet({
    required this.title,
    required this.items,
    required this.allowNone,
    required this.showDescription,
  });

  final String title;
  final List<Suggestion> items;
  final bool allowNone;
  final bool showDescription;

  @override
  State<_SuggestionSheet> createState() => _SuggestionSheetState();
}

class _SuggestionSheetState extends State<_SuggestionSheet> {
  String _query = '';

  List<Widget> _rows() {
    final q = _query.trim().toLowerCase();
    final textTheme = Theme.of(context).textTheme;
    final color = Theme.of(context).colorScheme.primary;
    final rows = <Widget>[];

    if (widget.allowNone && q.isEmpty) {
      rows.add(
        ListTile(
          leading: const Icon(Icons.block),
          title: const Text('Nenhum'),
          onTap: () => Navigator.pop(context, Suggestion.none),
        ),
      );
    }

    String? lastGroup;
    for (final s in widget.items) {
      final matches = s.label.toLowerCase().contains(q) ||
          s.group.toLowerCase().contains(q);
      if (q.isNotEmpty && !matches) continue;
      if (s.group.isNotEmpty && s.group != lastGroup) {
        lastGroup = s.group;
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Text(
              s.group,
              style: textTheme.labelLarge?.copyWith(color: color),
            ),
          ),
        );
      }
      final description = widget.showDescription ? s.portuguese : '';
      rows.add(
        ListTile(
          title: Text(s.label),
          subtitle: description.isEmpty
              ? null
              : Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
          onTap: () => Navigator.pop(context, s),
        ),
      );
    }

    if (rows.isEmpty) {
      rows.add(
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Nada encontrado.')),
        ),
      );
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Buscar...',
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            Expanded(child: ListView(children: _rows())),
          ],
        ),
      ),
    );
  }
}
