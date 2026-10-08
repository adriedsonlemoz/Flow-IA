# Flow IA

Gerador de prompts técnicos (em inglês) para Google Flow e IAs de vídeo.

## Recursos
- Personagens salvos (aparência/roupa) reutilizáveis em todas as cenas
- Campo de ação durante a fala, idioma da fala e contador de duração
- Sincronia labial e "sem legendas" incluídos automaticamente no prompt
- Lista de cenas salva no aparelho (copiar uma ou todas)
- "Melhorar com IA" (Gemini, plano gratuito): cole sua chave em Opções (engrenagem); o manual no app explica como obter a chave e conferir os limites

## Como rodar
1. `flutter create . --project-name flow_ia --org com.flowia --platforms android,ios`
   (gera as pastas de plataforma sem sobrescrever `lib/` e `pubspec.yaml`)
2. `flutter pub get`
3. `dart format .`
4. `flutter run`

## CI / APK
O workflow `.github/workflows/build.yml` roda format, analyze e testes e gera
o APK release com o nome `Flowiav<versão>.apk` (versão lida do `pubspec.yaml`,
ex.: `Flowiav1.0.4.apk`).

- Artifacts: Actions > execução > Artifacts.
- Releases: cada push na `main` publica o APK na aba Releases (tag `v<versão>`),
  mantendo todas as versões. Suba a `version` do `pubspec.yaml` a cada entrega.
