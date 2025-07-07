import 'package:flutter/material.dart';

class PopupMenu extends StatelessWidget {
  const PopupMenu({super.key, this.backgroundColor, required this.child});

  final Color? backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context){
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // Returns child wrapped in card aligned at center
    return Align(
      alignment: Alignment.center,
      child: Card(
        color: backgroundColor ?? colorScheme.surface,
        child: child,
      ),
    );
  }
}