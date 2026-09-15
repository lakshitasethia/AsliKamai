import 'package:flutter/material.dart';

/// AppBar title that shrinks to fit instead of truncating with an ellipsis.
/// Needed because system font-scale settings (seen on a real Samsung device
/// during Phase 2 testing) can push long titles like "Import This Week's
/// Screenshots" past the available width — this guarantees the full title
/// stays visible on every device instead of getting cut off.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
