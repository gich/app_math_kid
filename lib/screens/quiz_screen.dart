import 'dart:async';

import 'package:flutter/material.dart';

import '../logic/quiz_generator.dart';
import '../models/game_mode.dart';
import '../models/question.dart';
import '../widgets/number_keypad.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final GameMode mode;
  final List<int> digits;

  /// Only used for [GameMode.timeTest]. Ignored for training.
  final Duration? testDuration;

  const QuizScreen({
    super.key,
    required this.mode,
    required this.digits,
    this.testDuration,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const _questionCount = 10;

  late final List<Question> _questions;
  late final Duration _startRemaining;

  Timer? _ticker;
  Timer? _advanceTimer;

  int _index = 0;
  int _correct = 0;
  Duration _remaining = Duration.zero;
  String _input = '';
  bool _showHint = false;

  bool get _isTimeTest => widget.mode == GameMode.timeTest;

  @override
  void initState() {
    super.initState();
    _questions =
        QuizGenerator.generate(digits: widget.digits, count: _questionCount);

    if (_isTimeTest) {
      _startRemaining = widget.testDuration ?? const Duration(seconds: 30);
      _remaining = _startRemaining;
      _ticker = Timer.periodic(const Duration(seconds: 1), _onTick);
    } else {
      _startRemaining = Duration.zero;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _advanceTimer?.cancel();
    super.dispose();
  }

  Question get _current => _questions[_index];

  void _onTick(Timer _) {
    if (!mounted) return;
    setState(() {
      _remaining -= const Duration(seconds: 1);
    });
    if (_remaining.inSeconds <= 0) {
      _finish(timedOut: true);
    }
  }

  void _onDigit(int d) {
    if (_showHint) return;
    setState(() {
      if (_input.length < 3) _input += '$d';
    });
  }

  void _onBackspace() {
    if (_showHint) return;
    setState(() {
      if (_input.isNotEmpty) {
        _input = _input.substring(0, _input.length - 1);
      }
    });
  }

  void _onSubmit() {
    if (_showHint || _input.isEmpty) return;
    final typed = int.parse(_input);

    if (typed == _current.answer) {
      _correct++;
      _advance();
    } else if (_isTimeTest) {
      // Time test: red flash, then auto-advance — no Continue button.
      setState(() => _showHint = true);
      _advanceTimer = Timer(const Duration(milliseconds: 900), _advance);
    } else {
      // Training: show hint block, wait for Continue.
      setState(() => _showHint = true);
    }
  }

  void _advance() {
    if (!mounted) return;

    if (_index + 1 >= _questions.length) {
      _finish(timedOut: false);
      return;
    }
    setState(() {
      _showHint = false;
      _input = '';
      _index++;
    });
  }

  void _finish({required bool timedOut}) {
    _ticker?.cancel();
    _advanceTimer?.cancel();
    if (!mounted) return;

    Duration? elapsed;
    if (_isTimeTest && !timedOut) {
      elapsed = _startRemaining - _remaining;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          mode: widget.mode,
          correct: _correct,
          total: _questionCount,
          digits: widget.digits,
          elapsed: elapsed,
          timedOut: timedOut,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = _current;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isTimeTest
            ? _formatTime(_remaining)
            : 'Question ${_index + 1} of ${_questions.length}'),
        actions: _isTimeTest
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Text(
                      'Q${_index + 1}/${_questions.length}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: (_index + 1) / _questions.length),
            const SizedBox(height: 24),
            Text(
              '${q.a} × ${q.b} = ?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _AnswerBox(text: _input, isError: _showHint),
            const SizedBox(height: 16),
            if (_showHint && !_isTimeTest)
              _HintBlock(q: q, onContinue: _advance),
            if (_showHint && _isTimeTest)
              _WrongFlash(correctAnswer: q.answer),
            const Spacer(),
            NumberKeypad(
              onDigitPressed: _onDigit,
              onBackspace: _onBackspace,
              onSubmit: _onSubmit,
              canSubmit: _input.isNotEmpty && !_showHint,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(Duration d) {
    final s = d.inSeconds.clamp(0, 9999);
    if (s >= 60) {
      final minutes = s ~/ 60;
      final seconds = s % 60;
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return '0:${s.toString().padLeft(2, '0')}';
  }
}

class _AnswerBox extends StatelessWidget {
  final String text;
  final bool isError;

  const _AnswerBox({required this.text, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(
          color: isError ? Colors.red : Colors.grey,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.isEmpty ? '?' : text,
        style: TextStyle(
          fontSize: 36,
          color: isError ? Colors.red : null,
        ),
      ),
    );
  }
}

class _WrongFlash extends StatelessWidget {
  final int correctAnswer;

  const _WrongFlash({required this.correctAnswer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red),
      ),
      child: Text(
        'Wrong! Answer: $correctAnswer',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 20, color: Colors.red),
      ),
    );
  }
}

class _HintBlock extends StatelessWidget {
  final Question q;
  final VoidCallback onContinue;

  const _HintBlock({required this.q, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    final addition = List.filled(q.b, '${q.a}').join(' + ');
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        children: [
          Text(
            '${q.a} × ${q.b} = $addition = ${q.answer}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: onContinue,
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
