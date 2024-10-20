import 'package:flutter/material.dart';

import 'global_variables.dart';

class GlobalMethods {
  static String dateText(DateTime date) {
    return '${GlobalVariables.weekdayText[date.weekday]}, ${date.month}/${date.day}';
  }

  static void showPopup(BuildContext context, Widget widget) {
    //Pushes the popup to the app navigator
    Navigator.of(context).push(PageRouteBuilder(
      //See-through 'page'
      opaque: false,
      //Builds the popup
      pageBuilder: (context, _, __) {
        return widget;
      },
      //Manages animation
      transitionsBuilder: (context, a1, a2, child) {
        //Page begins 1 page to the left of the visible screen; slides onto screen
        const begin = Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        //Animation 'Tween' which manages popup movement
        var slideTween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        //Tween which handles the background fading to 50% opacity black
        var fadeTween = Tween(begin: 0.0, end: 1.0);

        //Stacks the sliding animation on top of the fading animation
        return Stack(
          children: [
            //Container (50% opacity black) follows fade in animation
            FadeTransition(
              opacity: a1.drive(fadeTween),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
            //Popup follows sliding animation
            SlideTransition(
              position: a1.drive(slideTween),
              child: child,
            ),
          ],
        );
      },
    ));
  }
}
