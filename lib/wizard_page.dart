import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'character_dialog.dart';
import 'character_picker.dart';
import 'gemini_service.dart';
import 'improve_service.dart';
import 'locale_toggle.dart';
import 'models.dart';
import 'prompt_builder.dart';
import 'speech_counter.dart';
import 'storage.dart';
import 'suggest_field.dart';
import 'suggestions.dart';

const int _resultStep = 5;

const List<String> _stepTitles = [
  'Personagem',
  'Cena',
  'Ação e fala',
  'Voz',
  'Câmera e luz',
  'Resultado',
];

const List<String> _stepHints = [
  'Quem aparece na cena? Escolha um personagem salvo ou siga sem ele: '
      'a imagem de referência define a aparência.',
  'Descreva o cenário e a situação. Ex.: um apresentador em um estúdio '
      'moderno. Em inglês a IA costuma entender melhor.',
  'O que o personagem faz enquanto fala e o que ele diz. Falas longas '
      'pedem mais de uma cena.',
  'Escolha o estilo da voz.',
  'Escolha o movimento de câmera e a iluminação.',
  'Confira o prompt. Você pode copiar, salvar, melhorar com IA ou editar.',
];

class WizardPage extends StatefulWidget {
  const WizardPage({super.key});

  @override
  State<WizardPage> createState() => _WizardPageState();
}

class _WizardPageState extends State<WizardPage> {
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
  PromptLocale _locale = PromptLocale.en;

  int _step = 0;
  bool _editing = false;
  bool _improving = false;
  String? _improved;
  String? _improvedSource;
  int _usage = 0;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
    _loadUsage();
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

  Future<void> _loadUsage() async {
    final usage = await _storage.loadTodayUsage();
    if (!mounted) return;
    setState(() => _usage = usage);
  }

  String _build(PromptLocale locale) => buildPrompt(
        context: localizeScene(_contextController.text, locale),
        dialogue: _dialogueController.text,
        action: localizeAction(_actionController.text, locale),
        character: _character?.descriptionFor(locale) ?? '',
        voice: _voice,
        language: _language,
        lighting: _lighting,
        camera: _camera,
        locale: locale,
      );

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _goTo(int step, {bool editing = false}) {
    setState(() {
      _step = step;
      _editing = editing;
    });
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

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    _toast('Prompt copiado para a área de transferência!');
  }

  Future<void> _saveScene(String prompt) async {
    final title = _contextController.text.trim();
    final short = title.length > 40 ? '${title.substring(0, 40)}…' : title;
    final scene = SavedScene(title: short, prompt: prompt);
    final count = await _storage.addScene(scene);
    _toast('Cena $count salva na lista.');
  }

  Future<void> _improve() async {
    final base = _build(PromptLocale.en);
    setState(() => _improving = true);
    try {
      final text = await improvePrompt(_storage, base);
      await _loadUsage();
      if (!mounted) return;
      setState(() {
        _improved = text;
        _improvedSource = base;
      });
    } on GeminiException catch (e) {
      _toast(e.message);
    } finally {
      if (mounted) setState(() => _improving = false);
    }
  }

  Future<void> _edit() async {
    final step = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'O que você quer editar?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            for (var i = 0; i < _resultStep; i++)
              ListTile(
                title: Text(_stepTitles[i]),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(ctx, i),
              ),
          ],
        ),
      ),
    );
    if (step == null || !mounted) return;
    _goTo(step, editing: true);
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

  Widget _optionList({
    required List<PromptOption> options,
    required PromptOption selected,
    required ValueChanged<PromptOption> onSelected,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (final o in options)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: o == selected ? scheme.primary : scheme.outlineVariant,
              ),
            ),
            child: ListTile(
              title: Text(o.label),
              trailing: o == selected
                  ? Icon(Icons.check_circle, color: scheme.primary)
                  : null,
              onTap: () => setState(() => onSelected(o)),
            ),
          ),
      ],
    );
  }

  Widget _characterStep() {
    final description =
        _character?.descriptionFor(PromptLocale.pt) ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CharacterPicker(
          characters: _characters,
          selected: _character,
          onSelected: (c) => setState(() => _character = c),
          onAdd: _addCharacter,
          onRemove: _removeCharacter,
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(description),
        ],
      ],
    );
  }

  Widget _sceneStep() {
    return SuggestField(
      controller: _contextController,
      label: 'Contexto / Descrição Visual',
      hint: 'Ex.: Um apresentador em um estúdio moderno...',
      pickerTitle: 'Sugestões de cenário',
      suggestions: sceneSuggestions,
      minLines: 4,
      maxLines: 8,
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _speechStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SuggestField(
          controller: _actionController,
          label: 'Ação durante a fala',
          hint: 'Ex.: aponta para a tela e sorri',
          pickerTitle: 'Sugestões de ação',
          suggestions: actionSuggestions,
          minLines: 1,
          maxLines: 3,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        SuggestField(
          controller: _dialogueController,
          label: 'Falas / Diálogo / Narração',
          hint: 'Ex.: Olá, bem-vindos ao nosso canal!',
          pickerTitle: 'Sugestões de fala',
          suggestions: speechSuggestions,
          minLines: 2,
          maxLines: 5,
          onChanged: (_) => setState(() {}),
        ),
        SpeechCounter(text: _dialogueController.text),
        const SizedBox(height: 16),
        _dropdown(
          label: 'Idioma da fala',
          icon: Icons.translate,
          options: languageOptions,
          value: _language,
          onChanged: (v) => _language = v,
        ),
      ],
    );
  }

  Widget _voiceStep() {
    return _optionList(
      options: voiceOptions,
      selected: _voice,
      onSelected: (v) => _voice = v,
    );
  }

  Widget _cameraLightStep() {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Movimento de câmera', style: titleStyle),
        const SizedBox(height: 8),
        _optionList(
          options: cameraOptions,
          selected: _camera,
          onSelected: (v) => _camera = v,
        ),
        const SizedBox(height: 16),
        Text('Iluminação', style: titleStyle),
        const SizedBox(height: 8),
        _optionList(
          options: lightingOptions,
          selected: _lighting,
          onSelected: (v) => _lighting = v,
        ),
      ],
    );
  }

  Widget _improveButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.tonalIcon(
          onPressed: _improving ? null : _improve,
          icon: _improving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.auto_awesome),
          label: Text(_improving ? 'Melhorando...' : 'Melhorar com IA'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            'Uso da IA hoje (neste app): $_usage',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _improvedCard() {
    final improved = _improved;
    if (improved == null || _improvedSource != _build(PromptLocale.en)) {
      return const SizedBox.shrink();
    }
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        Text(
          'Prompt melhorado pela IA',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.primary),
          ),
          child: SelectableText(
            improved,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton.tonalIcon(
                onPressed: () => _copy(improved),
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copiar'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _saveScene(improved),
                icon: const Icon(Icons.playlist_add),
                label: const Text('Salvar'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _resultBody() {
    final shown = _build(_locale);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LocaleToggle(
          value: _locale,
          onChanged: (l) => setState(() => _locale = l),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: SelectableText(
            shown,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => _copy(shown),
          icon: const Icon(Icons.copy_rounded),
          label: const Text('Copiar Prompt'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _saveScene(shown),
                icon: const Icon(Icons.playlist_add),
                label: const Text('Salvar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _improveButton(),
        _improvedCard(),
      ],
    );
  }

  Widget _stepBody() {
    switch (_step) {
      case 0:
        return _characterStep();
      case 1:
        return _sceneStep();
      case 2:
        return _speechStep();
      case 3:
        return _voiceStep();
      case 4:
        return _cameraLightStep();
      default:
        return _resultBody();
    }
  }

  Widget _bottomBar() {
    if (_editing) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () => _goTo(_resultStep),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          child: const Text('Concluir edição'),
        ),
      );
    }
    final last = _step == _resultStep - 1;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _step == 0 ? null : () => _goTo(_step - 1),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
              child: const Text('Voltar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: () => _goTo(_step + 1),
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
              child: Text(last ? 'Ver resultado' : 'Próximo'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente de cena'),
        leading: IconButton(
          tooltip: 'Fechar',
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / _stepTitles.length),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Etapa ${_step + 1} de ${_stepTitles.length}',
                    style: textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(_stepTitles[_step], style: textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  Text(_stepHints[_step]),
                  const SizedBox(height: 20),
                  _stepBody(),
                ],
              ),
            ),
            if (_step != _resultStep) _bottomBar(),
          ],
        ),
      ),
    );
  }
}
