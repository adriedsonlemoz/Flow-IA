import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'gemini_service.dart';
import 'models.dart';

/// Persistência local simples (personagens, cenas, chave e uso da IA).
class Storage {
  static const _charactersKey = 'characters';
  static const _scenesKey = 'scenes';
  static const _apiKeyKey = 'gemini_api_key';
  static const _modelKey = 'gemini_model';
  static const _usageDateKey = 'usage_date';
  static const _usageCountKey = 'usage_count';
  static const _learnedLimitKey = 'learned_limit';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> _load(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return [for (final e in list) e as Map<String, dynamic>];
  }

  Future<void> _save(String key, List<Map<String, dynamic>> items) async {
    final prefs = await _prefs;
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

  // --- Chave e modelo do Gemini ---

  Future<String> loadApiKey() async {
    final prefs = await _prefs;
    return prefs.getString(_apiKeyKey) ?? '';
  }

  Future<void> saveApiKey(String key) async {
    final prefs = await _prefs;
    if (key.isEmpty) {
      await prefs.remove(_apiKeyKey);
    } else {
      await prefs.setString(_apiKeyKey, key);
    }
  }

  Future<String> loadModel() async {
    final prefs = await _prefs;
    return prefs.getString(_modelKey) ?? defaultModel;
  }

  Future<void> saveModel(String model) async {
    final prefs = await _prefs;
    await prefs.setString(_modelKey, model);
  }

  // --- Contador local de uso da IA (aproximado) ---

  String _today() {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    return '${now.year}-$month-$day';
  }

  Future<int> loadTodayUsage() async {
    final prefs = await _prefs;
    if (prefs.getString(_usageDateKey) != _today()) return 0;
    return prefs.getInt(_usageCountKey) ?? 0;
  }

  Future<int> incrementUsage() async {
    final prefs = await _prefs;
    final count = await loadTodayUsage() + 1;
    await prefs.setString(_usageDateKey, _today());
    await prefs.setInt(_usageCountKey, count);
    return count;
  }

  // --- Último limite informado pela API (após um erro 429) ---

  Future<String> loadLearnedLimit() async {
    final prefs = await _prefs;
    return prefs.getString(_learnedLimitKey) ?? '';
  }

  Future<void> saveLearnedLimit(String text) async {
    final prefs = await _prefs;
    await prefs.setString(_learnedLimitKey, text);
  }
}
