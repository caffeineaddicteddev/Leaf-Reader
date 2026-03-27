import 'package:flutter/material.dart';

class ShimmerBlock extends StatelessWidget {
  const ShimmerBlock({super.key, this.height = 16});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
