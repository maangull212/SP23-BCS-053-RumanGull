import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double value; // 0..1
  final double height;
  const ProgressBar({super.key, required this.value, this.height = 6});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: value.clamp(0, 1),
        minHeight: height,
        color: cs.primary,
        backgroundColor: cs.primary.withOpacity(.15),
      ),
    );
  }
}
