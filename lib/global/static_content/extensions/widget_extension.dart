/*
  * widget_extension *
  Extension on Widget which provides static Widgets and better fitting methods.
 */
import 'package:flutter/material.dart';

/// Widget extension <p>
/// Provided static Widgets and fit methods for existing widgets.
extension WidgetExtension on Widget {
  /// Widget extension <p>
  /// static Widget which provides an Icon with a filled, circular border around it. <p>
  /// [required IconData icon]: The icon to be displayed <p>
  /// [void Function()? onTap]: The method to run once the icon is tapped <p>
  /// [double radius = 15]: The radius of the circle <p>
  /// [double padding 5]: The padding of the circle and its icon <p>
  /// [Color? color]: The color of the circle <p>
  /// [Color? iconColor]: The color of the icon
  static Widget iconCircle(
      {required IconData icon,
      void Function()? onTap,
      double radius = 15,
      double padding = 5,
      Color? color,
      Color? iconColor}) {
    // Returns an InkWell w/ a Stack of circle on Icon
    return InkWell(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CircleAvatar(
            radius: radius,
            backgroundColor: color,
          ),
          // Icon
          Icon(
            icon,
            // Size decreases w/ padding increase
            size: radius * 2 - padding,
            color: iconColor,
          )
        ],
      ),
    );
  }

  /// Widget extension <p>
  /// Widget which wraps a provided child Widget in a card aligned at the center of a screen.
  static Widget popup(BuildContext context, Widget child) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    // Returns child wrapped in card aligned at center
    return Align(
      alignment: Alignment.center,
      child: Card(
        color: colorScheme.surface,
        child: child,
      ),
    );
  }

  /// Widget extension <p>
  /// static Widget which provides an Icon and/or text wrapped in a bubble. <p>
  /// [String text = '']: String displayed in bubble <p>
  /// [IconData? icon]: Icon displayed in bubble <p>
  /// [Color? color]: Color of bubble <p>
  /// [Color? textColor]: Color of text <p>
  /// [Color? iconColor]: Color of icon <p>
  /// [Color? borderColor]: Color of border <p>
  /// [EdgeInsets? margin]: Margin between bubble and external Widgets <p>
  /// [EdgeInsets? padding]: Padding between bubble and its contents <p>
  /// [double? width]: Set width of bubble <p>
  /// [double? height]: Set height of bubble <p>
  /// [double? textSize]: Size of text/icon displayed <p>
  /// [double curve = 20]: Circular radius of rounded corners <p>
  /// [void Function()? onPressed]: Method to run on tap <p>
  static Widget textBubble(BuildContext context,
      {String text = '',
      IconData? icon,
      Color? color,
      Color? textColor,
      Color? iconColor,
      Color? borderColor,
      EdgeInsets? margin,
      EdgeInsets? padding,
      double? width,
      double? height,
      double? textSize,
      double curve = 20,
      void Function()? onPressed}) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Returns decorated container wrapped in InkWell
    return InkWell(
      onTap: onPressed,
      child: Container(
          width: width,
          height: height,
          margin: margin,
          padding: padding,
          // Decoration w/ shadows and rounded edges
          decoration: BoxDecoration(
              boxShadow: [BoxShadow(color: colorScheme.shadow, blurRadius: 1)],
              borderRadius: BorderRadius.circular(curve),
              // If borderColor not specified, use no border
              border: borderColor != null
                  ? Border.all(
                  color: borderColor,
                  width: 3.5,
                  strokeAlign: BorderSide.strokeAlignOutside)
                  : null,
              color: color ?? colorScheme.primary),
          // Row containing icon and text
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Small padding
              const SizedBox(width: 1),
              // If icon specified displayed
              if (icon != null)
                Icon(icon,
                    color: iconColor ?? colorScheme.onPrimary, size: textSize),
              // If text isn't empty, display
              if (text.isNotEmpty)
                // Artificial padding through text spacing
                Text(' $text ',
                    style: TextStyle(
                        fontSize: textSize ?? 20,
                        fontFamily: 'Inter',
                        color: textColor ?? colorScheme.onPrimary))
            ],
          ).fit()),
    );
  }

  /// Widget extension <p>
  /// Returns a FittedBox set to scaleDown wrapping this widget.
  Widget fit() {
    // Returns child wrapped in FittedBox
    return FittedBox(fit: BoxFit.scaleDown, child: this);
  }

  /// Widget extension <p>
  /// Returns a FittedBox set to scaleDown wrapping this widget wrapped in an Expanded box and at a specified alignment.
  /// [Alignment alignment = Alignment.center]: Alignment of widget in Expanded <p>
  /// [EdgeInsets padding = EdgeInsets.zero]: Padding from edges of Expanded <p>
  Widget expandedFit(
      {Alignment alignment = Alignment.center,
      EdgeInsets padding = EdgeInsets.zero}) {
    // Returns child wrapped in FittedBox w/ padding wrapped in Expanded
    return Expanded(
        child: Container(
            margin: padding,
            alignment: alignment,
            child: FittedBox(fit: BoxFit.scaleDown, child: this)));
  }

  /// Widget extension <p>
  /// Returns this widget wrapped in an IntrinsicWidth widget. IntrinsicWidth matches teh size of its child.
  Widget intrinsicFit() {
    return IntrinsicWidth(child: this);
  }

  /// Widget extension <p>
  /// Returns this widget wrapped in a ClipRRECT Widget.
  Widget clip({BorderRadius borderRadius = BorderRadius.zero}){
    return ClipRRect(borderRadius: borderRadius, clipBehavior: Clip.hardEdge, child: this);
  }
}
