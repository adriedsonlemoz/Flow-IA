import 'dart:io';

import 'package:flow_ia/app_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('appVersion confere com o pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*([0-9.]+)',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(match?.group(1), appVersion);
  });

  test('o changelog começa pela versão atual', () {
    expect(changelog.first.version, appVersion);
  });
}
