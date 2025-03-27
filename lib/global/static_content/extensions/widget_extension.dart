import 'package:flutter/material.dart';

extension WidgetExtension on Widget {
  static Widget iconCircle(
      {required IconData icon,
      void Function()? onTap,
      double radius = 15,
      double padding = 5,
      Color? color,
      Color? iconColor}) {
    return InkWell(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: color,
          ),
          Icon(
            icon,
            size: radius * 2 - padding,
            color: iconColor,
          )
        ],
      ),
    );
  }

  static Widget popup(BuildContext context, Widget child) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.center,
      child: Card(
        color: colorScheme.surface,
        child: child,
      ),
    );
  }

  static Widget textBubble(BuildContext context,
      {String text = '',
      IconData? icon,
      Color? color,
      Color? textColor,
      Color? iconColor,
      Color? borderColor,
      EdgeInsets? spacing,
      EdgeInsets? padding,
      double? width,
      double? height,
      double? textSize,
      double curve = 20,
      void Function()? onPressed}) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    Widget buildBubble() {
      return Container(
          width: width,
          height: height,
          margin: spacing,
          padding: padding,
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: colorScheme.shadow, blurRadius: 1)],
              borderRadius: BorderRadius.circular(curve),
              border: borderColor != null
                  ? Border.all(
                      color: borderColor,
                      width: 3.5,
                      strokeAlign: BorderSide.strokeAlignOutside)
                  : null,
              color: color ?? colorScheme.primary),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 1),
              if (icon != null)
                Icon(icon,
                    color: iconColor ?? colorScheme.onPrimary, size: textSize),
              if (text.isNotEmpty)
                Text(' $text ',
                    style: TextStyle(
                        fontSize: textSize ?? 20,
                        fontFamily: 'Inter',
                        color: textColor ?? colorScheme.onPrimary))
            ],
          ).fit());
    }

    if (onPressed != null) {
      return TextButton(
          onPressed: () {
            onPressed();
          },
          child: buildBubble());
    }
    return buildBubble();
  }

  /// Widget extension <p>
  /// Returns a FittedBox set to scaleDown wrapping this widget.
  Widget fit() {
    return FittedBox(fit: BoxFit.scaleDown, child: this);
  }

  /// Widget extension <p>
  /// Returns a FittedBox set to scaleDown wrapping this widget wrapped in an Expanded box and at a specified alignment.
  Widget expandedFit(
      {Alignment alignment = Alignment.center,
      EdgeInsets padding = EdgeInsets.zero}) {
    return Expanded(
        child: Container(
            margin: padding,
            alignment: alignment,
            child: FittedBox(fit: BoxFit.scaleDown, child: this)));
  }
}
