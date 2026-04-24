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

  static const _durations = [
    Duration(minutes: 1),
    Duration(seconds: 45),
    Duration(seconds: 30),
    Duration(seconds: 20),
    Duration(seconds: 15),
  ];

  final Set<int> _selected = {};
  Duration _duration = const Duration(seconds: 30);

  bool get _isMultiSelect => widget.mode == GameMode.timeTest;

  bool get _areAllSelected => _selected.length == _availableDigits.length;

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

  void _toggleAll() {
    setState(() {
      if (_areAllSelected) {
        _selected.clear();
      } else {
        _selected.addAll(_availableDigits);
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
          testDuration: _isMultiSelect ? _duration : null,
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
            Row(
              children: [
                Expanded(
                  child: Text(hint, style: const TextStyle(fontSize: 16)),
                ),
                if (_isMultiSelect)
                  TextButton(
                    onPressed: _toggleAll,
                    child: Text(_areAllSelected ? 'Clear' : 'Select all'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
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
            if (_isMultiSelect) ...[
              const SizedBox(height: 32),
              const Text(
                'Test duration',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _durations.map((d) {
                  return ChoiceChip(
                    label: Text(_formatDuration(d),
                        style: const TextStyle(fontSize: 18)),
                    selected: _duration == d,
                    onSelected: (_) => setState(() => _duration = d),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  );
                }).toList(),
              ),
            ],
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

  String _formatDuration(Duration d) {
    if (d.inMinutes >= 1 && d.inSeconds % 60 == 0) {
      return '${d.inMinutes} min';
    }
    return '${d.inSeconds} s';
  }
}
