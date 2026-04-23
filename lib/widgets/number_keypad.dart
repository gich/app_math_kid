import 'package:flutter/material.dart';

/// Calculator-style keypad: digits 0-9, backspace, submit.
/// The widget is "dumb": it does not hold any answer state.
/// The parent decides what happens on each key press.
class NumberKeypad extends StatelessWidget {
  final ValueChanged<int> onDigitPressed;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;
  final bool canSubmit;

  const NumberKeypad({
    super.key,
    required this.onDigitPressed,
    required this.onBackspace,
    required this.onSubmit,
    this.canSubmit = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _digitsRow(const [1, 2, 3]),
        _digitsRow(const [4, 5, 6]),
        _digitsRow(const [7, 8, 9]),
        _bottomRow(),
      ],
    );
  }

  Widget _digitsRow(List<int> digits) {
    return SizedBox(
      height: 72,
      child: Row(
        children: digits
            .map((d) => Expanded(
                  child: _KeyButton(
                    label: '$d',
                    onPressed: () => onDigitPressed(d),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _bottomRow() {
    return SizedBox(
      height: 72,
      child: Row(
        children: [
          Expanded(
            child: _KeyButton(
              icon: Icons.backspace_outlined,
              onPressed: onBackspace,
            ),
          ),
          Expanded(
            child: _KeyButton(
              label: '0',
              onPressed: () => onDigitPressed(0),
            ),
          ),
          Expanded(
            child: _KeyButton(
              icon: Icons.check,
              background: Colors.green,
              foreground: Colors.white,
              onPressed: canSubmit ? onSubmit : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? foreground;

  const _KeyButton({
    this.label,
    this.icon,
    this.onPressed,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: icon != null
            ? Icon(icon, size: 28)
            : Text(label!, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}
