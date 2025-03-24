/*
  * welcome.dart *
  Initial destination page of app for first-time users.
  Displays logo over background of X, with button leading to ScheduleSettings.
*/
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xschedule/schedule/schedule_settings/schedule_settings.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return Scaffold(
        body: Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          width: mediaQuery.size.width,
          height: mediaQuery.size.height,
          child: ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.asset("assets/images/x_building.jpg"),
            ),
          ),
        ),
        Container(color: colorScheme.primary.withValues(alpha: 0.7)),
        Align(
          alignment: Alignment.center,
          child: Container(
            margin: EdgeInsets.only(top: mediaQuery.size.width / 10),
            height: mediaQuery.size.height * 5 / 16,
            child: Image.asset("assets/images/xschedule_transparent.png"),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 30, top: 50),
          color: colorScheme.surface,
          child: SizedBox(
            width: mediaQuery.size.width * 4 / 5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Welcome to X-Schedule",
                    style: TextStyle(
                        fontFamily: "SansitaSwashed",
                        fontSize: 30,
                        color: colorScheme.onSurface),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context,
                            CupertinoPageRoute(builder: (context) {
                          return const ScheduleSettings();
                        }));
                      },
                      style: ElevatedButton.styleFrom(
                          overlayColor: colorScheme.onPrimary,
                          backgroundColor: colorScheme.primary),
                      child: Container(
                        alignment: Alignment.center,
                        width: mediaQuery.size.width * 3 / 5,
                        child: Text(
                          "Get Started",
                          style: TextStyle(
                              fontSize: 25, color: colorScheme.onPrimary),
                        ),
                      )),
                ),
              ],
            ),
          ),
        )
      ],
    ));
  }
}
