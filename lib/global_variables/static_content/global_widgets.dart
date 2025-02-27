import 'package:flutter/material.dart';

/*
GlobalWidgets:
Class created to organize widgets used globally across the app
 */

class GlobalWidgets {
  //Icon Button with Circle
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
            size: radius*2-padding,
            color: iconColor,
          )
        ],
      ),
    );
  }

  //X-Schedule logo
  static Widget xschedule({double height = 50}) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        //Gets the St. X logo from locally stored assets (see pubspec.yaml)
        SizedBox(
            height: height,
            child: Image.asset(
              'assets/images/x.png',
              fit: BoxFit.fitHeight,
            )),
        //...and slaps 'chedule' on the end!
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(width: height),
            Text(
              'chedule',
              style: TextStyle(
                  fontSize: height / 2,
                  color: Colors.white,
                  shadows: const [Shadow(color: Colors.black, blurRadius: 10)]),
            )
          ],
        )
      ],
    );
  }

  static Widget popup(BuildContext context, Widget child){
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onHorizontalDragEnd: (detail) {
          if (detail.primaryVelocity! < 0) {
            Navigator.pop(context);
          }
        },
        child: Card(
          color: colorScheme.surface,
          child: child,
        ),
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
            boxShadow: [
              BoxShadow(color: colorScheme.shadow, blurRadius: 1)
            ],
            borderRadius: BorderRadius.circular(curve),
            border: borderColor != null
                ? Border.all(
                color: borderColor,
                width: 3.5,
                strokeAlign: BorderSide.strokeAlignOutside)
                : null,
            color: color ?? colorScheme.primary),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 1),
              if (icon != null)
                Icon(icon,
                    color: iconColor ?? colorScheme.onPrimary,
                    size: textSize),
              if (text.isNotEmpty)
                Text(' $text ',
                    style: TextStyle(
                        fontSize: textSize ?? 20,
                        fontFamily: 'Inter',
                        color: textColor ?? colorScheme.onPrimary))
            ],
          ),
        ),
      );
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
}
