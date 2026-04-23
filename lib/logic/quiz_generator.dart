import 'dart:math';

import '../models/question.dart';

class QuizGenerator {
  static final _random = Random();

  /// Generates [count] random questions using the given [digits].
  /// Guarantees no two identical questions appear in a row.
  /// Example: digits = [3, 7], count = 10 → 10 questions where one
  /// operand is either 3 or 7, and the other is any number from 2 to 9.
  static List<Question> generate({
    required List<int> digits,
    required int count,
  }) {
    assert(digits.isNotEmpty, 'digits must not be empty');

    final questions = <Question>[];
    Question? previous;

    for (var i = 0; i < count; i++) {
      Question next;
      do {
        final a = digits[_random.nextInt(digits.length)];
        final b = 2 + _random.nextInt(8); // 2..9
        next = Question(a, b);
      } while (_sameAs(next, previous));

      questions.add(next);
      previous = next;
    }
    return questions;
  }

  static bool _sameAs(Question a, Question? b) {
    if (b == null) return false;
    return a.a == b.a && a.b == b.b;
  }
}
