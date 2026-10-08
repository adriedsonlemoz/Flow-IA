import 'package:flutter/material.dart';

import 'prompt_builder.dart';

/// Mostra palavras e duração estimada da fala, com alerta se for longa.
class SpeechCounter extends StatelessWidget {
  const SpeechCounter({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final words = countWords(text);
    final seconds = estimateSeconds(words).round();
    final tooLong = words > maxWordsPerClip;
    final scheme = Theme.of(context).colorScheme;
    final String message;
    if (tooLong) {
      message = '$words palavras (~${seconds}s): longa demais para um clipe. '
          'Divida em mais cenas (máx. ~$maxWordsPerClip palavras).';
    } else {
      message = '$words palavras (~${seconds}s de fala)';
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          color: tooLong ? scheme.error : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
