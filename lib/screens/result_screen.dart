import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../logic/player_storage.dart';
import '../logic/results_storage.dart';
import '../models/game_mode.dart';
import '../models/quiz_result.dart';
import '../widgets/star_rating.dart';

class ResultScreen extends StatefulWidget {
  final GameMode mode;
  final int correct;
  final int total;
  final List<int> digits;
  final Duration? elapsed;

  /// True when a time test ran out before all questions were answered.
  /// Timed-out attempts are NOT saved to history and show a "time's up" view
  /// instead of the regular result.
  final bool timedOut;

  const ResultScreen({
    super.key,
    required this.mode,
    required this.correct,
    required this.total,
    required this.digits,
    this.elapsed,
    this.timedOut = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final ConfettiController _confetti;
  late final QuizResult _result;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    _result = QuizResult(
      mode: widget.mode,
      correct: widget.correct,
      total: widget.total,
      digits: widget.digits,
      completedAt: DateTime.now(),
      elapsed: widget.elapsed,
    );
    if (!widget.timedOut) {
      // Only time test results go to history — training is practice, not a record.
      if (widget.mode == GameMode.timeTest) {
        _save();
      }
      if (_result.stars == 3) {
        _confetti.play();
      }
    }
  }

  Future<void> _save() async {
    final playerName = await PlayerStorage().getCurrent();
    final toSave = QuizResult(
      mode: _result.mode,
      correct: _result.correct,
      total: _result.total,
      digits: _result.digits,
      completedAt: _result.completedAt,
      elapsed: _result.elapsed,
      playerName: playerName,
    );
    await ResultsStorage().add(toSave);
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.timedOut ? _buildTimedOut(context) : _buildResult(context);
  }

  Widget _buildTimedOut(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time\'s up'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_off,
                  size: 96, color: Colors.redAccent),
              const SizedBox(height: 16),
              const Text(
                "Time's up!",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'You answered ${widget.correct} of ${widget.total} before the timer ran out.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'This attempt is not saved to history — try again!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: () =>
                    Navigator.popUntil(context, (r) => r.isFirst),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                ),
                child: const Text('Back to menu',
                    style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final percent = (widget.correct / widget.total * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StarRating(filled: _result.stars, size: 72),
                  const SizedBox(height: 24),
                  Text(
                    '${widget.correct} of ${widget.total} correct',
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('$percent%', style: const TextStyle(fontSize: 24)),
                  if (widget.elapsed != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Time: ${_formatDuration(widget.elapsed!)}',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ],
                  const SizedBox(height: 48),
                  FilledButton(
                    onPressed: () =>
                        Navigator.popUntil(context, (r) => r.isFirst),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                    ),
                    child: const Text('Back to menu',
                        style: TextStyle(fontSize: 20)),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirection: pi / 2,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              maxBlastForce: 20,
              minBlastForce: 8,
              gravity: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return minutes > 0 ? '${minutes}m ${seconds}s' : '${seconds}s';
  }
}
