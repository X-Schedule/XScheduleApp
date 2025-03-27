import 'package:flutter/cupertino.dart';

extension WidgetExtension on Widget {
  /// Widget extension <p>
  /// Returns a FittedBox set to scaleDown wrapping this widget.
  Widget fit() {
    return FittedBox(fit: BoxFit.scaleDown, child: this);
  }

  /// Widget extension <p>
  /// Returns a FittedBox set to scaleDown wrapping this widget wrapped in an Expanded box and at a specified alignment.
  Widget expandedFit({Alignment alignment = Alignment.center}) {
    return Expanded(
        child: Align(
            alignment: alignment,
            child: FittedBox(fit: BoxFit.scaleDown, child: this)));
  }
}
