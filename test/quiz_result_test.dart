import 'package:flutter_test/flutter_test.dart';

import 'package:app_math_kid/models/game_mode.dart';
import 'package:app_math_kid/models/quiz_result.dart';

QuizResult _result({required int correct, required int total}) {
  return QuizResult(
    mode: GameMode.training,
    correct: correct,
    total: total,
    digits: const [2],
    completedAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('QuizResult.stars', () {
    test('100% correct gives 3 stars', () {
      expect(_result(correct: 10, total: 10).stars, 3);
    });

    test('80% and 90% give 2 stars', () {
      expect(_result(correct: 8, total: 10).stars, 2);
      expect(_result(correct: 9, total: 10).stars, 2);
    });

    test('60% and 70% give 1 star', () {
      expect(_result(correct: 6, total: 10).stars, 1);
      expect(_result(correct: 7, total: 10).stars, 1);
    });

    test('below 60% gives 0 stars', () {
      expect(_result(correct: 5, total: 10).stars, 0);
      expect(_result(correct: 0, total: 10).stars, 0);
    });

    test('empty total gives 0 stars (no division by zero)', () {
      expect(_result(correct: 0, total: 0).stars, 0);
    });
  });

  group('QuizResult JSON round-trip', () {
    test('encode and decode produce the same data', () {
      final original = QuizResult(
        mode: GameMode.timeTest,
        correct: 8,
        total: 10,
        digits: const [3, 7],
        completedAt: DateTime(2026, 4, 23, 15, 30),
        elapsed: const Duration(seconds: 25),
        playerName: 'Alex',
      );

      final json = original.toJson();
      final restored = QuizResult.fromJson(json);

      expect(restored.mode, original.mode);
      expect(restored.correct, original.correct);
      expect(restored.total, original.total);
      expect(restored.digits, original.digits);
      expect(restored.completedAt, original.completedAt);
      expect(restored.elapsed, original.elapsed);
      expect(restored.playerName, 'Alex');
    });

    test('fromJson defaults playerName when missing (backward compat)', () {
      // An older QuizResult JSON from before the playerName field existed.
      final legacyJson = {
        'mode': 'timeTest',
        'correct': 7,
        'total': 10,
        'digits': [5],
        'completedAt': '2026-01-15T12:00:00.000',
        'elapsedMs': 45000,
      };

      final restored = QuizResult.fromJson(legacyJson);
      expect(restored.playerName, 'unknown');
      expect(restored.correct, 7); // sanity-check
    });
  });
}
