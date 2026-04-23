import 'package:flutter_test/flutter_test.dart';

import 'package:app_math_kid/logic/quiz_generator.dart';

void main() {
  group('QuizGenerator.generate', () {
    test('returns exactly the requested number of questions', () {
      final qs = QuizGenerator.generate(digits: const [3, 7], count: 10);
      expect(qs.length, 10);
    });

    test('first operand is always one of the provided digits', () {
      final qs = QuizGenerator.generate(digits: const [3, 7], count: 100);
      for (final q in qs) {
        expect(const [3, 7].contains(q.a), true,
            reason: '${q.a} is not in [3, 7]');
      }
    });

    test('second operand is always between 2 and 9', () {
      final qs = QuizGenerator.generate(digits: const [5], count: 100);
      for (final q in qs) {
        expect(q.b, greaterThanOrEqualTo(2));
        expect(q.b, lessThanOrEqualTo(9));
      }
    });

    test('no two consecutive questions are identical', () {
      // A small pool (one digit × 8 possible b values = 8 unique questions)
      // makes duplicates likely if the generator forgets to guard against them.
      final qs = QuizGenerator.generate(digits: const [3], count: 100);
      for (var i = 1; i < qs.length; i++) {
        final sameA = qs[i].a == qs[i - 1].a;
        final sameB = qs[i].b == qs[i - 1].b;
        expect(sameA && sameB, false,
            reason: 'Duplicate at index $i: ${qs[i - 1]} then ${qs[i]}');
      }
    });

    test('throws when digits list is empty', () {
      expect(
        () => QuizGenerator.generate(digits: const [], count: 10),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
