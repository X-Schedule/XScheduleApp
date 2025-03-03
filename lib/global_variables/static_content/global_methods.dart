import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'global_variables.dart';

class GlobalMethods {
  static void visitUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
    throw Exception('Could not launch $url');
    }
  }

  static int monthDiff(DateTime date1, DateTime date2) {
    return (date1.year * 12 + date1.month) - (date2.year * 12 + date2.month);
  }

  static int amPmHour(int hour) {
    if (hour > 12) {
      return hour - 12;
    }
    return hour;
  }

  static DateTime addDay(DateTime date, int days) {
    DateTime result = date.add(Duration(days: days));
    //Fuck daylight savings!
    if (result.hour > 12) {
      while (result.hour != 0) {
        result = result.add(const Duration(hours: 1));
      }
    } else {
      while (result.hour != 0) {
        result = result.subtract(const Duration(hours: 1));
      }
    }
    return result;
  }

  static String dateText(DateTime date) {
    return '${GlobalVariables.weekdayText[date.weekday]}, ${date.month}/${date.day}';
  }

  static void pushSwipePage(BuildContext context, Widget page) {
    Navigator.of(context).push(CupertinoPageRoute(builder: (context) {
      return GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.pop(context);
          }
        },
        child: page,
      );
    }));
  }

  static void showPopup(BuildContext context, Widget widget, {Offset? begin}) {
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
        begin ??= Offset(-1.0, 0.0);
        const Offset end = Offset.zero;
        const Curve curve = Curves.easeInOut;

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
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }
                },
                onHorizontalDragEnd: (detail){
                  if(detail.primaryVelocity!.sign == begin!.dx.sign){
                    Navigator.of(context).pop();
                  }
                },
                onVerticalDragEnd: (detail){
                  if(detail.primaryVelocity!.sign == begin!.dy.sign){
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
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
