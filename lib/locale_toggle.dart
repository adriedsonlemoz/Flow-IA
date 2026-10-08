import 'package:flutter/material.dart';

import 'prompt_builder.dart';

/// Alterna entre a versão do prompt em inglês e em português.
class LocaleToggle extends StatelessWidget {
  const LocaleToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final PromptLocale value;
  final ValueChanged<PromptLocale> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<PromptLocale>(
          segments: const [
            ButtonSegment(value: PromptLocale.en, label: Text('Inglês')),
            ButtonSegment(value: PromptLocale.pt, label: Text('Português')),
          ],
          selected: {value},
          onSelectionChanged: (selection) => onChanged(selection.first),
        ),
        if (value == PromptLocale.pt)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Para IAs de vídeo, o inglês costuma funcionar melhor.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
