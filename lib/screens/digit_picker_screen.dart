import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import 'quiz_screen.dart';

class DigitPickerScreen extends StatefulWidget {
  final GameMode mode;

  const DigitPickerScreen({super.key, required this.mode});

  @override
  State<DigitPickerScreen> createState() => _DigitPickerScreenState();
}

class _DigitPickerScreenState extends State<DigitPickerScreen> {
  static const _availableDigits = [2, 3, 4, 5, 6, 7, 8, 9];

  final Set<int> _selected = {};

  bool get _isMultiSelect => widget.mode == GameMode.timeTest;

  void _toggle(int digit) {
    setState(() {
      if (_isMultiSelect) {
        if (!_selected.add(digit)) {
          _selected.remove(digit);
        }
      } else {
        _selected
          ..clear()
          ..add(digit);
      }
    });
  }

  void _onStart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          mode: widget.mode,
          digits: _selected.toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _isMultiSelect ? 'Pick digits' : 'Pick a digit';
    final hint = _isMultiSelect
        ? 'Select one or more tables to practice'
        : 'Select the table you want to practice';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(hint, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _availableDigits.map((digit) {
                return FilterChip(
                  label: Text('× $digit',
                      style: const TextStyle(fontSize: 20)),
                  selected: _selected.contains(digit),
                  onSelected: (_) => _toggle(digit),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                );
              }).toList(),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _selected.isEmpty ? null : _onStart,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
              ),
              child: const Text('Start', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      ),
    );
  }
}
