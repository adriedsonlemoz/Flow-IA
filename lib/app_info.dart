/// Versão exibida no app (deve ser igual à do pubspec.yaml; há um teste).
const String appVersion = '1.0.10';

const String developerName = 'Adriedson Aparecido Lemos';
const String channelName = 'UaiNao PareceReal';
const String pixKey = 'adriedson@outlook.com';

/// Links que redirecionam para as páginas do canal (busca pelo nome).
/// Troque pelos links diretos quando quiser.
const String facebookUrl =
    'https://www.facebook.com/search/top?q=UaiNao%20PareceReal';
const String youtubeUrl =
    'https://www.youtube.com/results?search_query=UaiNao+PareceReal';

class ChangelogEntry {
  const ChangelogEntry(this.version, this.changes);

  final String version;
  final List<String> changes;
}

const List<ChangelogEntry> changelog = [
  ChangelogEntry('1.0.10', [
    'Sugestões de personagens (pessoas, ETs, animais, frutas e objetos), '
        'com roupas e acessórios, já em inglês e em português.',
    'Listas de sugestões com busca para cenário, ação e fala.',
    'Mais opções de voz, câmera e iluminação.',
  ]),
  ChangelogEntry('1.0.9', [
    'Nova tela inicial: Modo Fácil, Abrir prompt e Início Rápido.',
    'Página Sobre com doação, últimas modificações e backup.',
    'Backup: exportar e importar personagens e cenas.',
  ]),
  ChangelogEntry('1.0.8', [
    'Assistente passo a passo (Modo Fácil) com botão Editar no resultado.',
    'Prompt também em português, com cópia em inglês ou português.',
  ]),
  ChangelogEntry('1.0.7', [
    'Tema Claro, Automático ou Escuro, com fundo mais escuro.',
    'Modelo da IA em lista única, com o sugerido para a sua chave.',
    'Botões da chave compactos: colar, copiar e excluir.',
  ]),
  ChangelogEntry('1.0.6', [
    'Modelo padrão da IA: gemini-flash-latest.',
  ]),
  ChangelogEntry('1.0.5', [
    'Melhorar com IA (Gemini) e tela de Opções com manual.',
    'Contador de uso e leitura do limite informado pela API.',
  ]),
  ChangelogEntry('1.0.4', [
    'Personagens salvos e lista de cenas.',
    'Ação durante a fala, contador de duração e idioma da fala.',
    'Sincronia labial e "sem legendas" no prompt.',
    'APK gerado com o nome Flowiav + versão.',
  ]),
  ChangelogEntry('1.0.0 a 1.0.3', [
    'Primeira versão do gerador de prompts, APK pelo GitHub Actions '
        'e nome Flow IA.',
  ]),
];
