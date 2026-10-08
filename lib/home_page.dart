import 'package:flutter/material.dart';

import 'about_page.dart';
import 'app_info.dart';
import 'quick_page.dart';
import 'scenes_page.dart';
import 'settings_page.dart';
import 'wizard_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _HeroCard(),
            const SizedBox(height: 20),
            _BigTile(
              icon: Icons.auto_fix_high,
              title: 'Modo Fácil',
              subtitle: 'Passo a passo guiado para montar sua cena',
              highlight: true,
              onTap: () => _open(context, const WizardPage()),
            ),
            _BigTile(
              icon: Icons.video_library_outlined,
              title: 'Abrir prompt',
              subtitle: 'Seus prompts salvos',
              onTap: () => _open(context, const ScenesPage()),
            ),
            _BigTile(
              icon: Icons.bolt,
              title: 'Início Rápido',
              subtitle: 'Preencha tudo em uma única tela',
              onTap: () => _open(context, const QuickPage()),
            ),
            const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _SmallTile(
                      icon: Icons.info_outline,
                      title: 'Sobre quem desenvolve',
                      onTap: () => _open(context, const AboutPage()),
                    ),
                  ),
                  Expanded(
                    child: _SmallTile(
                      icon: Icons.settings_outlined,
                      title: 'Configurações',
                      onTap: () => _open(context, const SettingsPage()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = scheme.onPrimaryContainer;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primaryContainer, scheme.tertiaryContainer],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.movie_creation_outlined, size: 44, color: color),
          const SizedBox(height: 12),
          Text(
            'Flow IA',
            style: textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Prompts prontos para o Google Flow e outras IAs de vídeo.',
            style: textTheme.bodyMedium?.copyWith(color: color),
          ),
          const SizedBox(height: 12),
          Text(
            'Versão $appVersion',
            style: textTheme.bodySmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _BigTile extends StatelessWidget {
  const _BigTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: highlight ? scheme.primaryContainer : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: highlight ? scheme.primary : scheme.outlineVariant,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _SmallTile extends StatelessWidget {
  const _SmallTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
