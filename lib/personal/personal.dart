import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xchedule/global_variables/gloabl_methods.dart';
import 'package:xchedule/schedule/schedule_settings.dart';

/*
Personal Page:
Currently a glorified settings page
In the future, it will hopefully display more personal information at the digression of st x staff
 */

class Personal extends StatelessWidget {
  const Personal({super.key});

  @override
  Widget build(BuildContext context){
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //Button that leads to ScheduleSettings
          ElevatedButton(
              onPressed: () {
                GlobalMethods.pushSwipePage(context, const ScheduleSettings(backArrow: true));
              },
              style:
              ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 3 / 5,
                child: Text(
                  "Customize Bell Appearances",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary
                  ),
                ),
              )),
        ],
      ),
    );
  }
}