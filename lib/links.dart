import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Abre [url] no navegador; se falhar, copia o link.
Future<void> openLink(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final uri = Uri.parse(url);
  var ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Exception {
    ok = false;
  }
  if (ok) return;
  await Clipboard.setData(ClipboardData(text: url));
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      const SnackBar(content: Text('Não foi possível abrir. Link copiado.')),
    );
}
