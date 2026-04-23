import 'package:flutter/material.dart';

import '../logic/quiz_generator.dart';
import '../models/game_mode.dart';
import '../models/question.dart';
import '../widgets/number_keypad.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  final GameMode mode;
  final List<int> digits;

  const QuizScreen({
    super.key,
    required this.mode,
    required this.digits,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const _totalQuestions = 10;

  late final List<Question> _questions;
  late final DateTime _startTime;

  int _index = 0;
  int _correct = 0;
  String _input = '';
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _questions = QuizGenerator.generate(
      digits: widget.digits,
      count: _totalQuestions,
    );
    _startTime = DateTime.now();
  }

  Question get _current => _questions[_index];
  bool get _isTimeTest => widget.mode == GameMode.timeTest;

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
      _goNext(wasCorrect: true);
    } else {
      setState(() => _showHint = true);
    }
  }

  void _goNext({required bool wasCorrect}) {
    if (wasCorrect) _correct++;

    if (_index + 1 >= _questions.length) {
      final elapsed = DateTime.now().difference(_startTime);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            mode: widget.mode,
            correct: _correct,
            total: _totalQuestions,
            digits: widget.digits,
            elapsed: _isTimeTest ? elapsed : null,
          ),
        ),
      );
      return;
    }

    setState(() {
      _showHint = false;
      _input = '';
      _index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _current;
    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${_index + 1} of $_totalQuestions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (_index + 1) / _totalQuestions,
            ),
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
            _AnswerBox(
              text: _input,
              isError: _showHint,
            ),
            const SizedBox(height: 16),
            if (_showHint)
              _HintBlock(
                q: q,
                onContinue: () => _goNext(wasCorrect: false),
              ),
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
