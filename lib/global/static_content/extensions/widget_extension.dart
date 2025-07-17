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

  /// Widget extension <p>
  /// Returns this widget wrapped in an Opacity Widget of given opacity. <p>
  /// [double opacity]: % opacity of widget <p>
  Widget withOpacity(double opacity){
    return Opacity(opacity: opacity, child: this);
  }
}
