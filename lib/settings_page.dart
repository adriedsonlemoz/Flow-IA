import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final _modelController = TextEditingController();

  bool _hideKey = true;
  bool _busy = false;
  int _usage = 0;
  String _learned = '';
  List<String> _available = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _keyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final key = await _storage.loadApiKey();
    final model = await _storage.loadModel();
    final usage = await _storage.loadTodayUsage();
    final learned = await _storage.loadLearnedLimit();
    if (!mounted) return;
    setState(() {
      _keyController.text = key;
      _modelController.text = model;
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

  Future<void> _save() async {
    await _storage.saveApiKey(_keyController.text.trim());
    final model = _modelController.text.trim();
    await _storage.saveModel(model.isEmpty ? defaultModel : model);
    _toast('Configurações salvas.');
  }

  Future<void> _remove() async {
    await _storage.saveApiKey('');
    if (!mounted) return;
    setState(() => _keyController.clear());
    _toast('Chave removida do aparelho.');
  }

  Future<void> _test() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      _toast('Cole a chave primeiro.');
      return;
    }
    setState(() => _busy = true);
    try {
      final service = GeminiService(apiKey: key, model: _modelController.text);
      final models = await service.listModels();
      if (!mounted) return;
      setState(() => _available = flashModels(models));
      _toast('Chave válida! ${models.length} modelos encontrados.');
    } on GeminiException catch (e) {
      _toast(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _section(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
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
          suffixIcon: IconButton(
            tooltip: _hideKey ? 'Mostrar' : 'Ocultar',
            icon: Icon(_hideKey ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _hideKey = !_hideKey),
          ),
        ),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton.tonalIcon(
            onPressed: _paste,
            icon: const Icon(Icons.content_paste),
            label: const Text('Colar chave'),
          ),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Salvar'),
          ),
          OutlinedButton.icon(
            onPressed: _busy ? null : _test,
            icon: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.wifi_tethering),
            label: const Text('Testar'),
          ),
          TextButton.icon(
            onPressed: _remove,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Remover'),
          ),
        ],
      ),
    ]);
  }

  Widget _modelSection() {
    return _section('Modelo de IA', [
      TextField(
        controller: _modelController,
        autocorrect: false,
        decoration: const InputDecoration(
          labelText: 'Modelo',
          helperText: 'Use um modelo Flash gratuito. Toque em Salvar.',
        ),
      ),
      const SizedBox(height: 12),
      const Text('Sugestões:'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final m in suggestedModels)
            ActionChip(
              label: Text(m),
              onPressed: () => setState(() => _modelController.text = m),
            ),
        ],
      ),
      if (_available.isNotEmpty) ...[
        const SizedBox(height: 16),
        const Text('Disponíveis na sua chave (Flash):'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final m in _available)
              ActionChip(
                label: Text(m),
                onPressed: () => setState(() => _modelController.text = m),
              ),
          ],
        ),
      ],
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
            'Volte aqui, toque em "Colar chave", depois em "Salvar" e em '
                '"Testar".',
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
            'O padrão é o gemini-3.5-flash-lite. Se o Google trocar os '
                'modelos, use "Testar" para listar os que sua chave aceita.',
            'Na página de preços do Google você confere quais modelos têm '
                'camada gratuita.',
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
                'coloque em repositórios públicos.',
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
