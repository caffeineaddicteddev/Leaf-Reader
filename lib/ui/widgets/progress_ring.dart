import 'package:flutter/material.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({required this.progress, super.key});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      value: progress.clamp(0, 1),
      strokeWidth: 4,
      backgroundColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.12),
    );
  }
}
