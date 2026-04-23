import 'game_mode.dart';

/// A single completed quiz session, stored in history.
class QuizResult {
  final GameMode mode;
  final int correct;
  final int total;
  final List<int> digits;
  final DateTime completedAt;
  final Duration? elapsed;

  const QuizResult({
    required this.mode,
    required this.correct,
    required this.total,
    required this.digits,
    required this.completedAt,
    this.elapsed,
  });

  /// 0..3 stars based on accuracy.
  /// 100% = 3 stars, 80-99% = 2, 60-79% = 1, below = 0.
  int get stars {
    if (total == 0) return 0;
    final ratio = correct / total;
    if (ratio >= 1.0) return 3;
    if (ratio >= 0.8) return 2;
    if (ratio >= 0.6) return 1;
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'mode': mode.name,
        'correct': correct,
        'total': total,
        'digits': digits,
        'completedAt': completedAt.toIso8601String(),
        'elapsedMs': elapsed?.inMilliseconds,
      };

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      mode: GameMode.values.firstWhere((m) => m.name == json['mode']),
      correct: json['correct'] as int,
      total: json['total'] as int,
      digits: (json['digits'] as List).cast<int>(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      elapsed: json['elapsedMs'] == null
          ? null
          : Duration(milliseconds: json['elapsedMs'] as int),
    );
  }
}
