/// Opção exibida em português com o termo correspondente em inglês.
class PromptOption {
  const PromptOption(this.label, this.english);

  final String label;
  final String english;
}

const String consistencyPrefix =
    'Maintaining the same character appearance and clothes '
    'from the reference image: ';

const String qualitySuffix = 'ultra detailed, 4k resolution';

const String syncText =
    'lips perfectly synced with the speech, natural mouth movement';

const String cleanText = 'no subtitles, no captions, no on-screen text';

const String silentLabel = 'Sem Voz';

/// Limite prático de fala por clipe (~8 s a ~2,3 palavras/s).
const int maxWordsPerClip = 18;
const double wordsPerSecond = 2.3;

const List<PromptOption> voiceOptions = [
  PromptOption(
    'Narrador Corporativo',
    'professional corporate narrator voice, clear, confident and polished',
  ),
  PromptOption(
    'Jovem Entusiasta',
    'young, energetic and enthusiastic voice, upbeat tone',
  ),
  PromptOption(
    'Tom Calmo/Explicativo',
    'calm, explanatory and friendly voice, steady pace',
  ),
  PromptOption(
    'Grave Cinematográfico',
    'deep cinematic voice, dramatic and resonant, movie trailer style',
  ),
  PromptOption(
    silentLabel,
    'no voice, no spoken dialogue, ambient sound only',
  ),
];

const List<PromptOption> languageOptions = [
  PromptOption('Português (Brasil)', 'Brazilian Portuguese'),
  PromptOption('Inglês', 'English'),
  PromptOption('Espanhol', 'Spanish'),
];

const List<PromptOption> cameraOptions = [
  PromptOption('Estático', 'static camera, locked-off shot'),
  PromptOption('Zoom Lento In', 'slow zoom in'),
  PromptOption('Zoom Lento Out', 'slow zoom out'),
  PromptOption('Panorâmica para Esquerda', 'smooth pan left'),
  PromptOption('Panorâmica para Direita', 'smooth pan right'),
  PromptOption('Tracking Shot', 'smooth tracking shot following the subject'),
];

const List<PromptOption> lightingOptions = [
  PromptOption(
    'Estúdio Tech com Neon',
    'modern tech studio lighting with vibrant neon accents',
  ),
  PromptOption(
    'Luz Natural Cinematográfica',
    'cinematic natural light, soft shadows, shallow depth of field',
  ),
  PromptOption(
    'Cyberpunk',
    'cyberpunk lighting, magenta and cyan neon glow, moody atmosphere',
  ),
  PromptOption(
    'Suave/Profissional',
    'soft, even, professional lighting, clean look',
  ),
];

/// Conta as palavras de um texto.
int countWords(String text) {
  final t = text.trim();
  return t.isEmpty ? 0 : t.split(RegExp(r'\s+')).length;
}

/// Estima a duração da fala em segundos.
double estimateSeconds(int words) => words / wordsPerSecond;

/// Monta o prompt final em inglês seguindo a estrutura obrigatória.
String buildPrompt({
  required String context,
  required String dialogue,
  required PromptOption voice,
  required PromptOption language,
  required PromptOption lighting,
  required PromptOption camera,
  String character = '',
  String action = '',
}) {
  final parts = <String>[];

  final ctx = context.trim();
  if (ctx.isNotEmpty) {
    parts.add(_sentence(ctx));
  }

  final who = character.trim();
  if (who.isNotEmpty) {
    parts.add('Character: ${_sentence(who)}');
  }

  final act = action.trim();
  if (act.isNotEmpty) {
    parts.add('Action: ${_sentence(act)}');
  }

  final silent = voice.label == silentLabel;
  final lang = language.english;
  final speech = dialogue.trim().replaceAll("'", '\u2019');
  final hasSpeech = speech.isNotEmpty;
  if (hasSpeech) {
    if (silent) {
      parts.add("The character is acting: '$speech'.");
    } else {
      parts.add("The character is speaking in $lang: '$speech'.");
    }
  }

  parts.add('Voice: ${voice.english}.');
  parts.add('Lighting: ${lighting.english}.');
  parts.add('Camera: ${camera.english}.');

  if (hasSpeech && !silent) {
    parts.add('${_capitalize(syncText)}.');
  }
  parts.add('${_capitalize(cleanText)}.');
  parts.add('${_capitalize(qualitySuffix)}.');

  return consistencyPrefix + parts.join(' ');
}

String _sentence(String text) {
  final last = text[text.length - 1];
  final ended = '.!?'.contains(last) ? text : '$text.';
  return _capitalize(ended);
}

String _capitalize(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
