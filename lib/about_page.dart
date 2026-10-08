import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_info.dart';
import 'backup_service.dart';
import 'links.dart';
import 'storage.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final _storage = Storage();

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copyPix() async {
    await Clipboard.setData(const ClipboardData(text: pixKey));
    _toast('Chave Pix copiada. Obrigado pelo apoio!');
  }

  Future<void> _export() async {
    final characters = await _storage.loadCharacters();
    final scenes = await _storage.loadScenes();
    final data = BackupData(characters: characters, scenes: scenes);
    await Clipboard.setData(ClipboardData(text: encodeBackup(data)));
    _toast(
      'Backup copiado: ${characters.length} personagens e '
      '${scenes.length} cenas. Cole em um lugar seguro (Notas, WhatsApp).',
    );
  }

  Future<void> _import() async {
    final text = await showDialog<String>(
      context: context,
      builder: (_) => const _ImportDialog(),
    );
    if (text == null) return;
    try {
      final data = decodeBackup(text);
      final currentCharacters = await _storage.loadCharacters();
      final currentScenes = await _storage.loadScenes();
      final characters = mergeCharacters(currentCharacters, data.characters);
      final scenes = mergeScenes(currentScenes, data.scenes);
      await _storage.saveCharacters(characters);
      await _storage.saveScenes(scenes);
      final newCharacters = characters.length - currentCharacters.length;
      final newScenes = scenes.length - currentScenes.length;
      _toast('Importado: $newCharacters personagens e $newScenes cenas novas.');
    } on FormatException catch (e) {
      _toast(e.message);
    }
  }

  Widget _section(String title, List<Widget> children) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _developerSection() {
    return _section('Quem desenvolve', [
      const Text(
        developerName,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      const Text('Canal: $channelName'),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => openLink(context, facebookUrl),
              icon: const Icon(Icons.facebook),
              label: const Text('Facebook'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => openLink(context, youtubeUrl),
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('YouTube'),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _donationSection() {
    final scheme = Theme.of(context).colorScheme;
    return _section('Apoie o projeto', [
      const Text(
        'O Flow IA é gratuito. Se ele ajuda você, contribua com qualquer '
        'valor via Pix. Obrigado!',
      ),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const SelectableText(
          pixKey,
          style: TextStyle(fontFamily: 'monospace', fontSize: 14),
        ),
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: _copyPix,
        icon: const Icon(Icons.copy_rounded),
        label: const Text('Copiar chave Pix'),
      ),
    ]);
  }

  Widget _changelogSection() {
    return _section('Últimas modificações', [
      for (var i = 0; i < changelog.length; i++)
        ExpansionTile(
          tilePadding: EdgeInsets.zero,
          childrenPadding: const EdgeInsets.only(bottom: 8),
          initiallyExpanded: i == 0,
          expandedAlignment: Alignment.centerLeft,
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text('Versão ${changelog[i].version}'),
          children: [
            for (final change in changelog[i].changes)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $change'),
              ),
          ],
        ),
    ]);
  }

  Widget _backupSection() {
    return _section('Backup', [
      Text(
        'Seus personagens e cenas ficam só neste aparelho. Exporte para '
        'guardar uma cópia e importe para restaurar. A chave do Gemini '
        'não entra no backup.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _export,
              icon: const Icon(Icons.upload_outlined),
              label: const Text('Exportar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _import,
              icon: const Icon(Icons.download_outlined),
              label: const Text('Importar'),
            ),
          ),
        ],
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _developerSection(),
            _donationSection(),
            _changelogSection(),
            _backupSection(),
            Center(
              child: Text(
                'Flow IA v$appVersion',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportDialog extends StatefulWidget {
  const _ImportDialog();

  @override
  State<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<_ImportDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text ?? '';
    if (!mounted) return;
    setState(() => _controller.text = text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Importar backup'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Cole o texto do backup exportado.'),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            minLines: 4,
            maxLines: 8,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Backup'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        TextButton(onPressed: _paste, child: const Text('Colar')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Importar'),
        ),
      ],
    );
  }
}
