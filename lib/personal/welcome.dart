import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xchedule/schedule/schedule_settings.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: ClipRect(
            child: FittedBox(
              fit: BoxFit.fitHeight,
              child: Image.asset("assets/images/x_building.jpg"),
            ),
          ),
        ),
        Container(color: Colors.blueAccent.withOpacity(0.75)),
        Align(
          alignment: Alignment.center,
          child: Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.width / 10),
            height: MediaQuery.of(context).size.height * 5 / 16,
            child: Image.asset("assets/images/xchedule_transparent.png"),
          ),
        ),
        Card(
          margin: const EdgeInsets.only(bottom: 30, top: 50),
          color: Theme.of(context).colorScheme.surface,
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 4 / 5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Welcome to Xchedule",
                  style: TextStyle(
                    fontFamily: "SansitaSwashed",
                    fontSize: 30,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, CupertinoPageRoute(builder: (context){
                            return const ScheduleSettings();
                      }));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary),
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 3 / 5,
                        child: Text(
                          "Get Started",
                          style: TextStyle(
                              fontSize: 25,
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      )),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
