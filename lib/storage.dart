import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Persistência local simples (personagens e cenas) via SharedPreferences.
class Storage {
  static const _charactersKey = 'characters';
  static const _scenesKey = 'scenes';

  Future<List<Map<String, dynamic>>> _load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return [for (final e in list) e as Map<String, dynamic>];
  }

  Future<void> _save(String key, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(items));
  }

  Future<List<Character>> loadCharacters() async {
    final items = await _load(_charactersKey);
    return [for (final m in items) Character.fromJson(m)];
  }

  Future<void> saveCharacters(List<Character> characters) {
    return _save(_charactersKey, [for (final c in characters) c.toJson()]);
  }

  Future<List<SavedScene>> loadScenes() async {
    final items = await _load(_scenesKey);
    return [for (final m in items) SavedScene.fromJson(m)];
  }

  Future<void> saveScenes(List<SavedScene> scenes) {
    return _save(_scenesKey, [for (final s in scenes) s.toJson()]);
  }
}
