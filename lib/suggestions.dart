import 'prompt_builder.dart';

/// Sugestão exibida em português, com o texto em inglês para o prompt.
class Suggestion {
  const Suggestion({
    required this.group,
    required this.label,
    required this.english,
    this.portuguese = '',
  });

  /// Item "Nenhum" (usado para limpar roupa ou acessório).
  static const Suggestion none = Suggestion(group: '', label: '', english: '');

  final String group;
  final String label;
  final String english;
  final String portuguese;

  bool get isNone => label.isEmpty;
}

List<Suggestion> _parse(String data) {
  final result = <Suggestion>[];
  for (final line in data.split('\n')) {
    final parts = line.trim().split('|');
    if (parts.length < 2) continue;
    result.add(
      Suggestion(
        group: parts[0].trim(),
        label: parts[1].trim(),
        english: parts.length > 2 ? parts[2].trim() : '',
        portuguese: parts.length > 3 ? parts[3].trim() : '',
      ),
    );
  }
  return result;
}

/// Troca o texto de uma sugestão pelo inglês (quando o prompt é em inglês).
/// Textos digitados à mão entram exatamente como escritos.
String localizeText(
  String text,
  List<Suggestion> catalog,
  PromptLocale locale,
) {
  final t = text.trim();
  if (locale == PromptLocale.pt) return t;
  for (final s in catalog) {
    if (s.label == t && s.english.isNotEmpty) return s.english;
  }
  return t;
}

String localizeScene(String text, PromptLocale locale) =>
    localizeText(text, sceneSuggestions, locale);

String localizeAction(String text, PromptLocale locale) =>
    localizeText(text, actionSuggestions, locale);

// Formato das linhas: grupo|nome em português|inglês|português

final List<Suggestion> characterSuggestions = _parse(_characterData);
final List<Suggestion> outfitSuggestions = _parse(_outfitData);
final List<Suggestion> accessorySuggestions = _parse(_accessoryData);
final List<Suggestion> sceneSuggestions = _parse(_sceneData);
final List<Suggestion> actionSuggestions = _parse(_actionData);
final List<Suggestion> speechSuggestions = _parse(_speechData);

const String _characterData = '''
Pessoas|Apresentador tech|a confident man in his 30s with short dark hair, a trimmed beard and a friendly smile|um homem confiante na casa dos 30, cabelo curto escuro, barba aparada e sorriso simpático
Pessoas|Apresentadora moderna|a charismatic woman in her 30s with long wavy brown hair and a warm smile|uma mulher carismática na casa dos 30, cabelo castanho longo ondulado e sorriso acolhedor
Pessoas|Jovem streamer|a cheerful young adult with colorful dyed hair and an energetic expression|um jovem alegre com cabelo tingido colorido e expressão enérgica
Pessoas|Narrador veterano|an elderly man with white hair, a gray beard and kind, wise eyes|um senhor idoso de cabelo branco, barba grisalha e olhos sábios e bondosos
Pessoas|Vovó simpática|a sweet elderly woman with gray hair in a bun, round glasses and a gentle smile|uma senhora idosa simpática, cabelo grisalho em coque, óculos redondos e sorriso gentil
Pessoas|Cientista maluco|an eccentric scientist with wild white hair, thick glasses and an excited expression|um cientista excêntrico de cabelo branco bagunçado, óculos grossos e expressão empolgada
Pessoas|Chef animado|a jolly chef with a round face, a thick mustache and a big smile|um chef animado de rosto redondo, bigode grosso e sorriso largo
Pessoas|Detetive misterioso|a mysterious detective with sharp features, slicked-back hair and a serious look|um detetive misterioso de traços marcantes, cabelo penteado para trás e olhar sério
Pessoas|Repórter de TV|a polished news reporter with neat hair and a professional expression|um repórter de TV elegante, cabelo alinhado e expressão profissional
Pessoas|Atleta determinado|a fit athletic person with short hair and a determined expression|uma pessoa atlética e em forma, cabelo curto e expressão determinada
Pessoas|Músico de rua|a laid-back street musician with curly hair and a relaxed smile|um músico de rua descontraído, cabelo cacheado e sorriso tranquilo
Pessoas|Caipira simpático|a friendly countryside man with a straw hat, tanned skin and a warm laugh|um caipira simpático de chapéu de palha, pele bronzeada e risada acolhedora
Pessoas|Professora criativa|a creative teacher in her 40s with short curly hair and an encouraging smile|uma professora criativa na casa dos 40, cabelo cacheado curto e sorriso encorajador
Criaturas e ETs|Alienígena verde clássico|a classic small green alien with a big smooth head and large black almond eyes|um alienígena verde clássico, pequeno, cabeça grande e lisa e olhos pretos amendoados
Criaturas e ETs|Alienígena cinza|a tall gray alien with a thin body, large black eyes and long fingers|um alienígena cinza e alto, corpo magro, olhos pretos grandes e dedos longos
Criaturas e ETs|ET fofo e peludo|a cute fuzzy purple alien with three eyes and tiny antennae|um ET fofo e peludo roxo, com três olhos e antenas pequenas
Criaturas e ETs|Robô amigável|a friendly retro robot with a boxy metallic body and glowing blue eyes|um robô amigável retrô, corpo metálico quadrado e olhos azuis brilhantes
Criaturas e ETs|Androide futurista|a sleek futuristic android with a smooth white body and a soft light on its face|um androide futurista elegante, corpo branco liso e luz suave no rosto
Criaturas e ETs|Dragão simpático|a friendly green dragon with small wings and big kind eyes|um dragão verde simpático, asas pequenas e olhos grandes e bondosos
Criaturas e ETs|Fantasma divertido|a playful translucent ghost with a wide grin and a floating motion|um fantasma divertido e translúcido, sorriso largo e movimento flutuante
Criaturas e ETs|Monstrinho fofo|a cute round monster with blue fur, two horns and a goofy smile|um monstrinho redondo e fofo, pelo azul, dois chifres e sorriso bobo
Criaturas e ETs|Fada brilhante|a tiny fairy with shimmering wings and a sparkling glow|uma fadinha com asas cintilantes e um brilho reluzente
Criaturas e ETs|Mago sábio|an old wizard with a long white beard and a pointed hat|um mago velho de barba branca longa e chapéu pontudo
Criaturas e ETs|Vampiro teatral|a theatrical pale vampire with slicked hair and an exaggerated funny grin|um vampiro teatral e pálido, cabelo penteado e sorriso exagerado e engraçado
Criaturas e ETs|Sereia encantadora|a charming mermaid with long flowing hair and a shimmering tail|uma sereia encantadora de cabelo longo esvoaçante e cauda reluzente
Criaturas e ETs|Super-herói original|an original superhero with a confident pose and a bright colorful suit|um super-herói original, pose confiante e uniforme colorido e vibrante
Criaturas e ETs|Unicórnio mágico|a magical white unicorn with a flowing rainbow mane and a golden horn|um unicórnio branco mágico, crina de arco-íris esvoaçante e chifre dourado
Animais|Cachorro golden retriever|a friendly golden retriever dog with soft golden fur and a happy expression|um cachorro golden retriever amigável, pelo dourado macio e expressão feliz
Animais|Gato esperto|a clever tabby cat with green eyes and a curious look|um gato rajado esperto, olhos verdes e olhar curioso
Animais|Coruja sábia|a wise owl with big round amber eyes and soft brown feathers|uma coruja sábia de olhos âmbar grandes e redondos e penas marrons macias
Animais|Papagaio falante|a colorful talkative parrot with bright red, blue and yellow feathers|um papagaio falante e colorido, penas vermelhas, azuis e amarelas
Animais|Capivara tranquila|a calm capybara with brown fur and a relaxed expression|uma capivara tranquila, pelo marrom e expressão relaxada
Animais|Onça-pintada imponente|a majestic jaguar with golden spotted fur and intense eyes|uma onça-pintada imponente, pelagem dourada pintada e olhos intensos
Animais|Macaco brincalhão|a playful monkey with an expressive face and long arms|um macaco brincalhão, rosto expressivo e braços longos
Animais|Tartaruga sábia|an old wise tortoise with a wrinkled face and a patterned shell|uma tartaruga velha e sábia, rosto enrugado e casco desenhado
Animais|Raposa esperta|a sly red fox with a bushy tail and bright eyes|uma raposa ruiva esperta, cauda peluda e olhos brilhantes
Animais|Pinguim engraçado|a funny penguin with a round belly and a waddling walk|um pinguim engraçado, barriga redonda e andar desengonçado
Animais|Urso simpático|a big friendly brown bear with soft fur and a warm expression|um urso pardo grande e simpático, pelo macio e expressão acolhedora
Animais|Tucano colorido|a colorful toucan with a large orange beak and glossy black feathers|um tucano colorido, bico laranja grande e penas pretas brilhantes
Animais|Pug engraçado|a funny pug with a wrinkled face and a big tongue|um pug engraçado, rosto enrugado e língua grande
Frutas e comidas|Banana falante|a cartoon talking banana with a cheerful face, tiny arms and legs|uma banana falante de desenho, rosto alegre, bracinhos e perninhas
Frutas e comidas|Maçã falante|a cartoon talking red apple with big expressive eyes and a green leaf|uma maçã vermelha falante de desenho, olhos grandes expressivos e folha verde
Frutas e comidas|Morango falante|a cartoon talking strawberry with a smiling face and a green leafy top|um morango falante de desenho, rosto sorridente e folhinhas verdes
Frutas e comidas|Abacaxi falante|a cartoon talking pineapple with a spiky green crown and sunglasses|um abacaxi falante de desenho, coroa verde espetada e óculos escuros
Frutas e comidas|Laranja falante|a cartoon talking orange with a bright smile and a tiny leaf|uma laranja falante de desenho, sorriso brilhante e uma folhinha
Frutas e comidas|Melancia falante|a cartoon talking watermelon slice with a happy face and black seeds|uma fatia de melancia falante de desenho, rosto feliz e sementes pretas
Frutas e comidas|Cacho de uvas falante|a cartoon bunch of purple grapes with small happy faces|um cacho de uvas roxas de desenho com carinhas felizes
Frutas e comidas|Pimenta falante|a cartoon talking chili pepper with a fiery red body and a confident grin|uma pimenta falante de desenho, corpo vermelho ardente e sorriso confiante
Frutas e comidas|Cenoura falante|a cartoon talking carrot with leafy green hair and a cheerful face|uma cenoura falante de desenho, cabelo de folhas verdes e rosto alegre
Frutas e comidas|Pão de queijo falante|a cartoon talking cheese bread roll with a golden crust and a cheerful face|um pão de queijo falante de desenho, casquinha dourada e rosto alegre
Frutas e comidas|Fatia de pizza falante|a cartoon talking pizza slice with melted cheese and a funny face|uma fatia de pizza falante de desenho, queijo derretido e rosto engraçado
Frutas e comidas|Brigadeiro falante|a cartoon talking chocolate truffle covered in sprinkles with a sweet smile|um brigadeiro falante de desenho coberto de granulado, sorriso doce
Objetos|Celular falante|a cartoon talking smartphone with a glowing screen face and tiny arms|um celular falante de desenho, rosto na tela brilhante e bracinhos
Objetos|Xícara de café falante|a cartoon talking coffee cup with rising steam and a sleepy smile|uma xícara de café falante de desenho, fumaça subindo e sorriso sonolento
Objetos|Livro falante|a cartoon talking old book with expressive eyes on its cover|um livro antigo falante de desenho, olhos expressivos na capa
Objetos|Lâmpada falante|a cartoon talking light bulb with a bright idea expression|uma lâmpada falante de desenho com expressão de ideia brilhante
''';

const String _outfitData = '''
Roupas|Terno azul-marinho|wearing a navy blue suit and white shirt|vestindo terno azul-marinho e camisa branca
Roupas|Camiseta e jeans|wearing a casual t-shirt and jeans|vestindo camiseta e calça jeans
Roupas|Moletom com capuz|wearing a cozy hoodie|vestindo um moletom com capuz
Roupas|Jaleco de laboratório|wearing a white lab coat|vestindo jaleco branco de laboratório
Roupas|Traje espacial|wearing a white astronaut space suit|vestindo traje espacial branco de astronauta
Roupas|Capa de super-herói|wearing a flowing superhero cape and a bold suit|vestindo capa de super-herói esvoaçante e uniforme marcante
Roupas|Uniforme de chef|wearing a white chef uniform and apron|vestindo uniforme branco e avental de chef
Roupas|Armadura medieval|wearing shining medieval armor|vestindo armadura medieval reluzente
Roupas|Roupa de cowboy|wearing a western outfit with a leather vest|vestindo roupa de cowboy com colete de couro
Roupas|Camisa esportiva|wearing a sports jersey and shorts|vestindo camisa esportiva e bermuda
Roupas|Capa de chuva amarela|wearing a bright yellow raincoat|vestindo capa de chuva amarela
Roupas|Pijama|wearing comfy pajamas|vestindo pijama confortável
Roupas|Smoking elegante|wearing an elegant black tuxedo|vestindo smoking preto elegante
Roupas|Roupa de festa junina|wearing a colorful festa junina outfit with patched clothes|vestindo roupa colorida de festa junina, com remendos
Roupas|Jaqueta de couro|wearing a black leather jacket|vestindo jaqueta de couro preta
Roupas|Roupa futurista|wearing a sleek futuristic outfit with glowing lines|vestindo roupa futurista com linhas luminosas
Roupas|Túnica de mago|wearing a long starry wizard robe|vestindo longa túnica de mago estrelada
''';

const String _accessoryData = '''
Acessórios|Óculos escuros|wearing sunglasses|usando óculos escuros
Acessórios|Fone de ouvido grande|wearing large headphones|usando fones de ouvido grandes
Acessórios|Chapéu de palha|wearing a straw hat|usando chapéu de palha
Acessórios|Óculos redondos|wearing round glasses|usando óculos redondos
Acessórios|Cachecol colorido|wearing a colorful scarf|usando cachecol colorido
Acessórios|Boné virado para trás|wearing a backwards cap|usando boné virado para trás
Acessórios|Microfone de lapela|with a small lapel microphone clipped on|com microfone de lapela preso na roupa
Acessórios|Mochila|carrying a backpack|carregando uma mochila
Acessórios|Coroa dourada|wearing a golden crown|usando coroa dourada
Acessórios|Gravata borboleta|wearing a bow tie|usando gravata borboleta
''';

const String _sceneData = '''
Estúdio e escritório|Estúdio de podcast moderno|a modern podcast studio with microphones, soft LED lights and acoustic panels
Estúdio e escritório|Estúdio tech com telas|a futuristic tech studio with glowing screens and neon accents
Estúdio e escritório|Escritório moderno|a bright modern office with large windows and plants
Estúdio e escritório|Sala de aula colorida|a colorful classroom with a chalkboard and wooden desks
Estúdio e escritório|Laboratório de ciências|a science laboratory with glass beakers, colorful liquids and glowing equipment
Casa|Sala de estar aconchegante|a cozy living room with a warm sofa, soft lamps and bookshelves
Casa|Cozinha iluminada|a bright kitchen with wooden counters and fresh ingredients
Casa|Quarto gamer|a gamer bedroom with RGB lights, a big monitor and posters
Natureza|Floresta amazônica|a lush Amazon rainforest with tall trees, mist and exotic birds
Natureza|Praia ao pôr do sol|a tropical beach at sunset with golden light and gentle waves
Natureza|Campo com montanhas|a green countryside with rolling hills and mountains in the distance
Natureza|Fazenda brasileira|a Brazilian farm with a wooden fence, a barn and open fields
Cidade|Rua movimentada à noite|a busy city street at night with neon signs and reflections on wet pavement
Cidade|Cidade cyberpunk|a rainy cyberpunk city with towering holographic billboards
Cidade|Praça de cidade pequena|a charming small-town square with a church and colorful houses
Cidade|Feira livre|a lively open-air market with colorful stalls of fruit and vegetables
Fantasia e espaço|Nave espacial|the inside of a spaceship with glowing control panels and stars outside the window
Fantasia e espaço|Planeta alienígena|an alien planet with a purple sky, two moons and strange glowing plants
Fantasia e espaço|Castelo medieval|a grand medieval castle hall with stone walls and torches
Fantasia e espaço|Floresta mágica|an enchanted forest with glowing mushrooms and floating lights
''';

const String _actionData = '''
Gestos|Aponta para a tela e sorri|points at the screen and smiles
Gestos|Acena para a câmera|waves at the camera with a friendly smile
Gestos|Gesticula enquanto explica|gestures expressively with both hands while explaining
Gestos|Mostra um produto na mão|holds up a product and shows it to the camera
Gestos|Faz sinal de joinha|gives a thumbs up to the camera
Gestos|Ri e balança a cabeça|laughs and shakes their head
Movimento|Caminha em direção à câmera|walks slowly toward the camera
Movimento|Caminha olhando ao redor|walks while looking around with curiosity
Movimento|Dá um pulo de empolgação|jumps with excitement
Movimento|Dança de forma divertida|dances in a fun, energetic way
Movimento|Senta e cruza os braços|sits down and crosses their arms with a thoughtful look
Expressões|Olha surpreso para o céu|looks up at the sky with a surprised expression
Expressões|Sussurra de forma misteriosa|leans in and whispers mysteriously
Expressões|Coça o queixo pensativo|scratches their chin thoughtfully
Expressões|Franze a testa preocupado|frowns with a worried expression
Expressões|Respira fundo e sorri aliviado|takes a deep breath and smiles with relief
''';

const String _speechData = '''
Abertura|Olá, pessoal! Sejam muito bem-vindos ao nosso canal!
Abertura|E aí, galera! Hoje eu trouxe uma novidade incrível pra vocês.
Abertura|Você já parou para pensar em como isso é possível?
Explicação|Vou te explicar de um jeito simples, em poucos passos.
Explicação|Presta atenção, porque essa dica vai mudar o seu dia.
Explicação|A verdade é que ninguém te contou essa parte da história.
Humor|Ninguém acredita, mas isso aconteceu de verdade!
Humor|Calma, calma, não é o que você está pensando!
Suspense|Algo estranho está acontecendo aqui, e eu preciso descobrir o que é.
Suspense|Silêncio… acho que ouvi alguma coisa lá fora.
Emoção|Eu não acredito que a gente conseguiu! Que dia incrível!
Encerramento|Se gostou, deixa o seu like e se inscreve no canal!
Encerramento|Obrigado por assistir, e até o próximo vídeo!
''';
