import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'storage.dart';

class ScenesPage extends StatefulWidget {
  const ScenesPage({super.key});

  @override
  State<ScenesPage> createState() => _ScenesPageState();
}

class _ScenesPageState extends State<ScenesPage> {
  final _storage = Storage();
  List<SavedScene> _scenes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final scenes = await _storage.loadScenes();
    if (!mounted) return;
    setState(() {
      _scenes = scenes;
      _loading = false;
    });
  }

  Future<void> _copy(String text, String message) async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _delete(int index) async {
    setState(() => _scenes.removeAt(index));
    await _storage.saveScenes(_scenes);
  }

  String _joinAll() {
    final buffer = StringBuffer();
    for (var i = 0; i < _scenes.length; i++) {
      if (i > 0) buffer.write('\n\n');
      buffer.write('Cena ${i + 1}:\n${_scenes[i].prompt}');
    }
    return buffer.toString();
  }

  Widget _body() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_scenes.isEmpty) {
      return const Center(child: Text('Nenhuma cena salva ainda.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _scenes.length,
      itemBuilder: (context, i) {
        final scene = _scenes[i];
        final number = i + 1;
        final label = scene.title.isEmpty ? '' : ' · ${scene.title}';
        return Card(
          child: ListTile(
            title: Text('Cena $number$label'),
            subtitle: Text(
              scene.prompt,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Copiar',
                  icon: const Icon(Icons.copy_rounded),
                  onPressed: () => _copy(scene.prompt, 'Cena $number copiada!'),
                ),
                IconButton(
                  tooltip: 'Excluir',
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(i),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cenas salvas'),
        actions: [
          IconButton(
            tooltip: 'Copiar todas',
            icon: const Icon(Icons.copy_all_rounded),
            onPressed: _scenes.isEmpty
                ? null
                : () => _copy(_joinAll(), 'Todas as cenas copiadas!'),
          ),
        ],
      ),
      body: _body(),
    );
  }
}
