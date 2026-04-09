import 'package:flutter/material.dart';

class Label extends StatelessWidget {
  final String text;
  const Label(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelLarge?.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.9),
      fontSize: 13,
    ),
  );
}
