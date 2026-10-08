/// Opção exibida em português, com o termo em inglês e em português.
class PromptOption {
  const PromptOption(this.label, this.english, this.portuguese);

  final String label;
  final String english;
  final String portuguese;
}

/// Idioma do prompt gerado.
enum PromptLocale { en, pt }

const String consistencyPrefix =
    'Maintaining the same character appearance and clothes '
    'from the reference image: ';

const String qualitySuffix = 'ultra detailed, 4k resolution';

const String silentLabel = 'Sem Voz';

/// Limite prático de fala por clipe (~8 s a ~2,3 palavras/s).
const int maxWordsPerClip = 18;
const double wordsPerSecond = 2.3;

const List<PromptOption> voiceOptions = [
  PromptOption(
    'Narrador Corporativo',
    'professional corporate narrator voice, clear, confident and polished',
    'voz de narrador corporativo profissional, clara, confiante e polida',
  ),
  PromptOption(
    'Jovem Entusiasta',
    'young, energetic and enthusiastic voice, upbeat tone',
    'voz jovem, enérgica e entusiasmada, tom animado',
  ),
  PromptOption(
    'Tom Calmo/Explicativo',
    'calm, explanatory and friendly voice, steady pace',
    'voz calma, explicativa e amigável, ritmo constante',
  ),
  PromptOption(
    'Grave Cinematográfico',
    'deep cinematic voice, dramatic and resonant, movie trailer style',
    'voz grave cinematográfica, dramática e ressonante, estilo trailer',
  ),
  PromptOption(
    silentLabel,
    'no voice, no spoken dialogue, ambient sound only',
    'sem voz, sem diálogo falado, apenas som ambiente',
  ),
];

const List<PromptOption> languageOptions = [
  PromptOption(
    'Português (Brasil)',
    'Brazilian Portuguese',
    'português do Brasil',
  ),
  PromptOption('Inglês', 'English', 'inglês'),
  PromptOption('Espanhol', 'Spanish', 'espanhol'),
];

const List<PromptOption> cameraOptions = [
  PromptOption(
    'Estático',
    'static camera, locked-off shot',
    'câmera estática, plano fixo',
  ),
  PromptOption('Zoom Lento In', 'slow zoom in', 'zoom lento aproximando'),
  PromptOption('Zoom Lento Out', 'slow zoom out', 'zoom lento afastando'),
  PromptOption(
    'Panorâmica para Esquerda',
    'smooth pan left',
    'panorâmica suave para a esquerda',
  ),
  PromptOption(
    'Panorâmica para Direita',
    'smooth pan right',
    'panorâmica suave para a direita',
  ),
  PromptOption(
    'Tracking Shot',
    'smooth tracking shot following the subject',
    'tracking shot suave acompanhando o personagem',
  ),
];

const List<PromptOption> lightingOptions = [
  PromptOption(
    'Estúdio Tech com Neon',
    'modern tech studio lighting with vibrant neon accents',
    'iluminação de estúdio tecnológico com detalhes em neon vibrante',
  ),
  PromptOption(
    'Luz Natural Cinematográfica',
    'cinematic natural light, soft shadows, shallow depth of field',
    'luz natural cinematográfica, sombras suaves, pouca profundidade de campo',
  ),
  PromptOption(
    'Cyberpunk',
    'cyberpunk lighting, magenta and cyan neon glow, moody atmosphere',
    'iluminação cyberpunk, brilho neon magenta e ciano, atmosfera sombria',
  ),
  PromptOption(
    'Suave/Profissional',
    'soft, even, professional lighting, clean look',
    'iluminação suave, uniforme e profissional, visual limpo',
  ),
];

class _Labels {
  const _Labels({
    required this.prefix,
    required this.character,
    required this.action,
    required this.acting,
    required this.speakingIn,
    required this.voice,
    required this.lighting,
    required this.camera,
    required this.sync,
    required this.clean,
    required this.quality,
  });

  final String prefix;
  final String character;
  final String action;
  final String acting;
  final String speakingIn;
  final String voice;
  final String lighting;
  final String camera;
  final String sync;
  final String clean;
  final String quality;
}

const _enLabels = _Labels(
  prefix: consistencyPrefix,
  character: 'Character',
  action: 'Action',
  acting: 'The character is acting',
  speakingIn: 'The character is speaking in',
  voice: 'Voice',
  lighting: 'Lighting',
  camera: 'Camera',
  sync: 'Lips perfectly synced with the speech, natural mouth movement.',
  clean: 'No subtitles, no captions, no on-screen text.',
  quality: 'Ultra detailed, 4k resolution.',
);

const _ptLabels = _Labels(
  prefix: 'Mantendo a mesma aparência e roupas do personagem '
      'da imagem de referência: ',
  character: 'Personagem',
  action: 'Ação',
  acting: 'O personagem está atuando',
  speakingIn: 'O personagem está falando em',
  voice: 'Voz',
  lighting: 'Iluminação',
  camera: 'Câmera',
  sync: 'Lábios perfeitamente sincronizados com a fala, '
      'movimento natural da boca.',
  clean: 'Sem legendas, sem textos na tela.',
  quality: 'Ultra detalhado, resolução 4k.',
);

/// Conta as palavras de um texto.
int countWords(String text) {
  final t = text.trim();
  return t.isEmpty ? 0 : t.split(RegExp(r'\s+')).length;
}

/// Estima a duração da fala em segundos.
double estimateSeconds(int words) => words / wordsPerSecond;

/// Monta o prompt final (inglês por padrão) na estrutura obrigatória.
String buildPrompt({
  required String context,
  required String dialogue,
  required PromptOption voice,
  required PromptOption language,
  required PromptOption lighting,
  required PromptOption camera,
  String character = '',
  String action = '',
  PromptLocale locale = PromptLocale.en,
}) {
  final pt = locale == PromptLocale.pt;
  final labels = pt ? _ptLabels : _enLabels;
  String term(PromptOption o) => pt ? o.portuguese : o.english;

  final parts = <String>[];

  final ctx = context.trim();
  if (ctx.isNotEmpty) {
    parts.add(_sentence(ctx));
  }

  final who = character.trim();
  if (who.isNotEmpty) {
    parts.add('${labels.character}: ${_sentence(who)}');
  }

  final act = action.trim();
  if (act.isNotEmpty) {
    parts.add('${labels.action}: ${_sentence(act)}');
  }

  final silent = voice.label == silentLabel;
  final lang = term(language);
  final speech = dialogue.trim().replaceAll("'", '\u2019');
  final hasSpeech = speech.isNotEmpty;
  if (hasSpeech) {
    if (silent) {
      parts.add("${labels.acting}: '$speech'.");
    } else {
      parts.add("${labels.speakingIn} $lang: '$speech'.");
    }
  }

  parts.add('${labels.voice}: ${term(voice)}.');
  parts.add('${labels.lighting}: ${term(lighting)}.');
  parts.add('${labels.camera}: ${term(camera)}.');

  if (hasSpeech && !silent) {
    parts.add(labels.sync);
  }
  parts.add(labels.clean);
  parts.add(labels.quality);

  return labels.prefix + parts.join(' ');
}

String _sentence(String text) {
  final last = text[text.length - 1];
  final ended = '.!?'.contains(last) ? text : '$text.';
  return ended[0].toUpperCase() + ended.substring(1);
}
