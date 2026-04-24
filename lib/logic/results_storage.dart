import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/quiz_result.dart';

class ResultsStorage {
  static const _key = 'quiz_results';
  static const maxKept = 10;

  Future<List<QuizResult>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];

    final list = jsonDecode(raw) as List;
    return list
        .map((e) => QuizResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(QuizResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await loadAll();

    // Put newest first, keep at most [maxKept] entries.
    final updated = [result, ...existing].take(maxKept).toList();

    final encoded = jsonEncode(updated.map((r) => r.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
