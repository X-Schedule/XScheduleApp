import 'package:flutter/material.dart';

/*
GlobalWidgets:
Class created to organize widgets used globally across the app
 */

class GlobalWidgets {
  //Xchedule logo
  static Widget xchedule({double height = 50}) {
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
                fontSize: height/2,
                color: Colors.white,
                shadows: const [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 10
                  )
                ]
              ),
            )
          ],
        )
      ],
    );
  }
}
