import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'gemini_service.dart';
import 'links.dart';
import 'storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _storage = Storage();
  final _keyController = TextEditingController();

  bool _hideKey = true;
  bool _busy = false;
  int _usage = 0;
  String _learned = '';
  ThemeMode _themeMode = themeNotifier.value;
  String _model = defaultModel;
  List<String> _models = orderModels(suggestedModels);
  String _suggestedForKey = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  List<String> _ensure(List<String> list, String model) {
    return list.contains(model) ? list : [model, ...list];
  }

  Future<void> _load() async {
    final key = await _storage.loadApiKey();
    final model = await _storage.loadModel();
    final usage = await _storage.loadTodayUsage();
    final learned = await _storage.loadLearnedLimit();
    if (!mounted) return;
    setState(() {
      _keyController.text = key;
      _model = model;
      _models = _ensure(orderModels(suggestedModels), model);
      _usage = usage;
      _learned = learned;
    });
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _setTheme(ThemeMode mode) async {
    themeNotifier.value = mode;
    setState(() => _themeMode = mode);
    await _storage.saveThemeMode(mode);
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim() ?? '';
    if (text.isEmpty) {
      _toast('A área de transferência está vazia.');
      return;
    }
    if (!mounted) return;
    setState(() => _keyController.text = text);
    _toast('Chave colada. Toque em Salvar.');
  }

  Future<void> _copyKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      _toast('Não há chave para copiar.');
      return;
    }
    await Clipboard.setData(ClipboardData(text: key));
    _toast('Chave copiada.');
  }

  Future<void> _save() async {
    await _storage.saveApiKey(_keyController.text.trim());
    await _storage.saveModel(_model);
    _toast('Configurações salvas.');
  }

  Future<void> _remove() async {
    await _storage.saveApiKey('');
    if (!mounted) return;
    setState(() => _keyController.clear());
    _toast('Chave excluída do aparelho.');
  }

  Future<void> _test() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      _toast('Cole a chave primeiro.');
      return;
    }
    setState(() => _busy = true);
    try {
      final service = GeminiService(apiKey: key, model: _model);
      final models = await service.listModels();
      final flash = flashModels(models);
      if (!mounted) return;
      if (flash.isEmpty) {
        _toast('Chave válida, mas nenhum modelo Flash foi encontrado.');
        return;
      }
      final suggested = recommendedModel(flash);
      setState(() {
        _models = orderModels(flash);
        _model = suggested;
        _suggestedForKey = suggested;
      });
      _toast('Chave válida! Modelo sugerido: $suggested. Toque em Salvar.');
    } on GeminiException catch (e) {
      _toast(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
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

  Widget _fieldIcon(String tooltip, IconData icon, VoidCallback onPressed) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }

  Widget _appearanceSection() {
    return _section('Aparência', [
      SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(value: ThemeMode.light, label: Text('Claro')),
          ButtonSegment(value: ThemeMode.system, label: Text('Automático')),
          ButtonSegment(value: ThemeMode.dark, label: Text('Escuro')),
        ],
        selected: {_themeMode},
        onSelectionChanged: (selection) => _setTheme(selection.first),
      ),
    ]);
  }

  Widget _keySection() {
    return _section('Chave da API Gemini', [
      TextField(
        controller: _keyController,
        obscureText: _hideKey,
        autocorrect: false,
        enableSuggestions: false,
        decoration: InputDecoration(
          labelText: 'Chave',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _fieldIcon('Colar', Icons.content_paste, _paste),
              _fieldIcon('Copiar', Icons.copy_rounded, _copyKey),
              _fieldIcon(
                _hideKey ? 'Mostrar' : 'Ocultar',
                _hideKey ? Icons.visibility : Icons.visibility_off,
                () => setState(() => _hideKey = !_hideKey),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: _save,
              child: const Text('Salvar'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: _busy ? null : _test,
              child: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Testar'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: _remove,
              child: const Text('Excluir'),
            ),
          ),
        ],
      ),
    ]);
  }

  Widget _modelSection() {
    return _section('Modelo de IA', [
      DropdownMenu<String>(
        key: ValueKey('${_models.length}-$_model'),
        expandedInsets: EdgeInsets.zero,
        label: const Text('Modelo'),
        leadingIcon: const Icon(Icons.auto_awesome),
        initialSelection: _model,
        requestFocusOnTap: false,
        dropdownMenuEntries: [
          for (final m in _models)
            DropdownMenuEntry(
              value: m,
              label: m == _suggestedForKey ? '$m (sugerido)' : m,
            ),
        ],
        onSelected: (m) {
          if (m != null) setState(() => _model = m);
        },
      ),
      const SizedBox(height: 8),
      Text(
        _suggestedForKey.isEmpty
            ? 'Toque em Testar para listar os modelos da sua chave.'
            : 'Sugerido para a sua chave: $_suggestedForKey. '
                'Toque em Salvar para usar.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ]);
  }

  Widget _usageSection() {
    return _section('Uso e limites', [
      Text('Neste app, hoje: $_usage requisição(ões) à IA.'),
      const SizedBox(height: 4),
      Text(
        'Contagem aproximada: só conta o que passou por aqui, e o horário em '
        'que o Google reinicia a cota diária pode ser outro.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      if (_learned.isNotEmpty) ...[
        const SizedBox(height: 12),
        Text('Último limite informado pela API: $_learned'),
      ],
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: () => openLink(context, rateLimitUrl),
        icon: const Icon(Icons.open_in_new),
        label: const Text('Ver limites no console do Google'),
      ),
    ]);
  }

  Widget _manualSection() {
    return _section('Manual', [
      ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: const Text('Como obter a chave (grátis)'),
        children: [
          const _Steps([
            'Toque no botão abaixo para abrir o Google AI Studio.',
            'Entre com sua conta Google.',
            'Toque em "Create API key" (Criar chave de API) e escolha ou '
                'crie um projeto.',
            'Copie a chave gerada.',
            'Volte aqui, toque em Colar (ícone ao lado do olho), depois em '
                '"Salvar" e em "Testar".',
          ]),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: () => openLink(context, apiKeyUrl),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir página das chaves'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      const ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text('Como conferir os limites'),
        children: [
          _Steps([
            'O Google não publica mais uma tabela fixa de limites: eles '
                'aparecem por projeto no console do AI Studio.',
            'Toque em "Ver limites no console do Google" (seção Uso e '
                'limites) e consulte o seu projeto.',
            'Se a IA responder "limite atingido", espere o tempo informado '
                'ou troque o modelo nas opções.',
            'O app guarda o último limite que a API informar e conta seus '
                'usos do dia, mas o console é a fonte oficial.',
          ]),
        ],
      ),
      const ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text('Qual modelo usar?'),
        children: [
          _Steps([
            'O plano gratuito cobre modelos da família Flash (e Flash-Lite). '
                'Modelos Pro, de imagem e de vídeo não são gratuitos.',
            'Toque em "Testar": o app lista os modelos Flash da sua chave e '
                'já seleciona o sugerido, que vem primeiro na lista.',
            'O padrão é o gemini-flash-latest, atalho que aponta para o '
                'Flash mais recente (os limites podem mudar junto com ele).',
          ]),
        ],
      ),
      const ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text('Privacidade e segurança'),
        children: [
          _Steps([
            'No plano gratuito, o Google pode usar o conteúdo enviado para '
                'melhorar seus produtos. Não envie dados sensíveis.',
            'A chave fica salva só neste aparelho. Não a compartilhe nem a '
                'coloque em repositórios públicos ou em conversas.',
            'Se a chave vazar, exclua-a no AI Studio e gere outra.',
          ]),
        ],
      ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => openLink(context, pricingUrl),
          icon: const Icon(Icons.open_in_new),
          label: const Text('Preços e modelos gratuitos (Google)'),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opções')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _appearanceSection(),
            _keySection(),
            _modelSection(),
            _usageSection(),
            _manualSection(),
          ],
        ),
      ),
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps(this.steps);

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('${i + 1}. ${steps[i]}'),
            ),
        ],
      ),
    );
  }
}
