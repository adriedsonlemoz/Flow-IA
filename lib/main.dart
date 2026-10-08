import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_page.dart';
import 'storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  themeNotifier.value = await Storage().loadThemeMode();
  runApp(const FlowIaApp());
}

class FlowIaApp extends StatelessWidget {
  const FlowIaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Flow IA',
          debugShowCheckedModeBanner: false,
          themeMode: mode,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          home: const HomePage(),
        );
      },
    );
  }
}
