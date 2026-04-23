import 'package:flutter/material.dart';

/// Shows [filled] amber stars out of [total] total.
class StarRating extends StatelessWidget {
  final int filled;
  final int total;
  final double size;

  const StarRating({
    super.key,
    required this.filled,
    this.total = 3,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final isFilled = i < filled;
        return Icon(
          isFilled ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: isFilled ? Colors.amber : Colors.grey.shade400,
        );
      }),
    );
  }
}
