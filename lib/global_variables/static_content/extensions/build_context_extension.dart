import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

extension BuildContextExtension on BuildContext {
  /// BuildContext extension <p>
  /// Pushes a SnackBar of given text to the ScaffoldMessenger of the BuildContext
  void showSnackBar(String message,
      {bool isError = false, bool floating = true}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message,
            overflow: TextOverflow.fade,
            style: TextStyle(
                color: isError
                    ? Theme.of(this).colorScheme.onError
                    : Theme.of(this).snackBarTheme.actionTextColor)),
        behavior: floating ? SnackBarBehavior.floating : null,
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).snackBarTheme.backgroundColor,
      ),
    );
  }

  /// BuildContext extension <p>
  /// Pushes a gesture-dismissible page to the NavigatorState of the BuildContext
  void pushSwipePage(Widget page) {
    Navigator.of(this).push(CupertinoPageRoute(builder: (context) {
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

  /// BuildContext extension <p>
  /// Pushes an animated popup to the NavigatorState of the BuildContext
  void pushPopup(Widget widget, {Offset? begin}) {
    //Pushes the popup to the app navigator
    Navigator.of(this).push(PageRouteBuilder(
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