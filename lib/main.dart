import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'character_dialog.dart';
import 'models.dart';
import 'prompt_builder.dart';
import 'scenes_page.dart';
import 'storage.dart';

void main() {
  runApp(const FlowIaApp());
}

class FlowIaApp extends StatelessWidget {
  const FlowIaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flow IA',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C4DFF),
          brightness: Brightness.dark,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const FlowIaPage(),
    );
  }
}

class FlowIaPage extends StatefulWidget {
  const FlowIaPage({super.key});

  @override
  State<FlowIaPage> createState() => _FlowIaPageState();
}

class _FlowIaPageState extends State<FlowIaPage> {
  final _storage = Storage();
  final _contextController = TextEditingController();
  final _actionController = TextEditingController();
  final _dialogueController = TextEditingController();

  List<Character> _characters = [];
  Character? _character;
  PromptOption _voice = voiceOptions[1];
  PromptOption _language = languageOptions.first;
  PromptOption _camera = cameraOptions.first;
  PromptOption _lighting = lightingOptions[1];

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  @override
  void dispose() {
    _contextController.dispose();
    _actionController.dispose();
    _dialogueController.dispose();
    super.dispose();
  }

  Future<void> _loadCharacters() async {
    final items = await _storage.loadCharacters();
    if (!mounted) return;
    setState(() => _characters = items);
  }

  String get _prompt => buildPrompt(
        context: _contextController.text,
        dialogue: _dialogueController.text,
        action: _actionController.text,
        character: _character?.description ?? '',
        voice: _voice,
        language: _language,
        lighting: _lighting,
        camera: _camera,
      );

  void _toast(ScaffoldMessengerState messenger, String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copy() async {
    final messenger = ScaffoldMessenger.of(context);
    await Clipboard.setData(ClipboardData(text: _prompt));
    _toast(messenger, 'Prompt copiado para a área de transferência!');
  }

  Future<void> _saveScene() async {
    final messenger = ScaffoldMessenger.of(context);
    final prompt = _prompt;
    final title = _contextController.text.trim();
    final short = title.length > 40 ? '${title.substring(0, 40)}…' : title;
    final scenes = await _storage.loadScenes();
    scenes.add(SavedScene(title: short, prompt: prompt));
    await _storage.saveScenes(scenes);
    _toast(messenger, 'Cena ${scenes.length} salva na lista.');
  }

  Future<void> _addCharacter() async {
    final created = await showDialog<Character>(
      context: context,
      builder: (_) => const CharacterDialog(),
    );
    if (created == null) return;
    final items = [..._characters, created];
    await _storage.saveCharacters(items);
    if (!mounted) return;
    setState(() {
      _characters = items;
      _character = created;
    });
  }

  Future<void> _removeCharacter() async {
    final target = _character;
    if (target == null) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover personagem?'),
        content: Text('"${target.name}" será removido da lista.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    final items = _characters.where((c) => c != target).toList();
    await _storage.saveCharacters(items);
    if (!mounted) return;
    setState(() {
      _characters = items;
      _character = null;
    });
  }

  void _openScenes() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const ScenesPage()),
    );
  }

  Widget _dropdown({
    required String label,
    required IconData icon,
    required List<PromptOption> options,
    required PromptOption value,
    required ValueChanged<PromptOption> onChanged,
  }) {
    return DropdownMenu<PromptOption>(
      expandedInsets: EdgeInsets.zero,
      label: Text(label),
      leadingIcon: Icon(icon),
      initialSelection: value,
      requestFocusOnTap: false,
      dropdownMenuEntries: [
        for (final o in options) DropdownMenuEntry(value: o, label: o.label),
      ],
      onSelected: (selected) {
        if (selected != null) setState(() => onChanged(selected));
      },
    );
  }

  Widget _characterRow() {
    return Row(
      children: [
        Expanded(
          child: DropdownMenu<Character?>(
            key: ValueKey('${_characters.length}-${_character?.name}'),
            expandedInsets: EdgeInsets.zero,
            label: const Text('Personagem'),
            leadingIcon: const Icon(Icons.person_outline),
            initialSelection: _character,
            requestFocusOnTap: false,
            dropdownMenuEntries: [
              const DropdownMenuEntry<Character?>(value: null, label: 'Nenhum'),
              for (final c in _characters)
                DropdownMenuEntry<Character?>(value: c, label: c.name),
            ],
            onSelected: (c) => setState(() => _character = c),
          ),
        ),
        IconButton(
          tooltip: 'Novo personagem',
          onPressed: _addCharacter,
          icon: const Icon(Icons.person_add_alt_1_outlined),
        ),
        if (_character != null)
          IconButton(
            tooltip: 'Remover personagem',
            onPressed: _removeCharacter,
            icon: const Icon(Icons.delete_outline),
          ),
      ],
    );
  }

  Widget _counter() {
    final words = countWords(_dialogueController.text);
    final seconds = estimateSeconds(words).round();
    final tooLong = words > maxWordsPerClip;
    final scheme = Theme.of(context).colorScheme;
    final String text;
    if (tooLong) {
      text = '$words palavras (~${seconds}s): longa demais para um clipe. '
          'Divida em mais cenas (máx. ~$maxWordsPerClip palavras).';
    } else {
      text = '$words palavras (~${seconds}s de fala)';
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: tooLong ? scheme.error : scheme.onSurfaceVariant,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.movie_creation_outlined),
            SizedBox(width: 8),
            Text('Flow IA', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Cenas salvas',
            icon: const Icon(Icons.video_library_outlined),
            onPressed: _openScenes,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _characterRow(),
            const SizedBox(height: 16),
            TextField(
              controller: _contextController,
              minLines: 3,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Contexto / Descrição Visual',
                hintText: 'Ex.: Um apresentador em um estúdio moderno...',
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _actionController,
              minLines: 1,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Ação durante a fala',
                hintText: 'Ex.: aponta para a tela e sorri',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _dialogueController,
              minLines: 2,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Falas / Diálogo / Narração',
                hintText: 'Ex.: Olá, bem-vindos ao nosso canal!',
                alignLabelWithHint: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
            _counter(),
            const SizedBox(height: 16),
            _dropdown(
              label: 'Idioma da fala',
              icon: Icons.translate,
              options: languageOptions,
              value: _language,
              onChanged: (v) => _language = v,
            ),
            const SizedBox(height: 16),
            _dropdown(
              label: 'Estilo de Voz / Áudio',
              icon: Icons.record_voice_over_outlined,
              options: voiceOptions,
              value: _voice,
              onChanged: (v) => _voice = v,
            ),
            const SizedBox(height: 16),
            _dropdown(
              label: 'Movimento de Câmera',
              icon: Icons.videocam_outlined,
              options: cameraOptions,
              value: _camera,
              onChanged: (v) => _camera = v,
            ),
            const SizedBox(height: 16),
            _dropdown(
              label: 'Estilo de Iluminação',
              icon: Icons.light_mode_outlined,
              options: lightingOptions,
              value: _lighting,
              onChanged: (v) => _lighting = v,
            ),
            const SizedBox(height: 24),
            Text(
              'Prompt gerado (EN)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: SelectableText(
                _prompt,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _copy,
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copiar Prompt'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _saveScene,
              icon: const Icon(Icons.playlist_add),
              label: const Text('Salvar na lista de cenas'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
