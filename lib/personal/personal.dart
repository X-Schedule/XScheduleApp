import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:xschedule/display/home_page.dart';
import 'package:xschedule/global_variables/dynamic_content/stream_signal.dart';
import 'package:xschedule/global_variables/static_content/extensions/build_context_extension.dart';
import 'package:xschedule/personal/credits.dart';
import 'package:xschedule/schedule/schedule_display/schedule_display.dart';

import '../global_variables/dynamic_content/schedule.dart';
import '../global_variables/static_content/global_methods.dart';
import '../schedule/schedule_settings/schedule_settings.dart';

/*
Personal Page:
Currently a glorified settings page
In the future, it will hopefully display more personal information at the digression of st x staff
 */
class Personal extends StatelessWidget {
  const Personal({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return Scaffold(
        backgroundColor: colorScheme.primaryContainer,
        appBar: PreferredSize(
            preferredSize: Size(mediaQuery.size.width, 55),
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Settings",
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Georama",
                          color: colorScheme.onSurface),
                    ),
                  ),
                  Container(
                    color: colorScheme.shadow,
                    height: 2.5,
                    width: mediaQuery.size.width - 10,
                    margin: const EdgeInsets.only(top: 5),
                  )
                ],
              ),
            )),
        body: Column(children: [
          _buildOption(context, "Customize Bell Appearances", () {
            context.pushSwipePage(const ScheduleSettings(backArrow: true));
          }),
          _buildOption(context, "Reset Local Data", () {
            localStorage.clear();
            Schedule.bellVanity = {};
            ScheduleSettings.tutorialSystem.refreshKeys();
            ScheduleSettings.bellTutorialSystem.refreshKeys();

            ScheduleDisplay.tutorialSystem.refreshKeys();
            ScheduleDisplay.tutorialDate = null;
            StreamSignal.updateStream(
                streamController: HomePage.homePageStream);
          }),
          _buildOption(context, "Credits and Copyright", () {
            context.pushPopup(Credits());
          }),
          _buildOption(context, "Submit Beta Report", () {
            GlobalMethods.visitUrl(
                "https://forms.office.com/Pages/ResponsePage.aspx?id=udgb07DszU6VE6pe_6S_QEKQcshWKqpCj4E9J0VU-BRUN1o3SlRJMzk1SkZMMklLWFc3UEVFVkIzOC4u");
          }),
        ]));
  }

  Widget _buildOption(
      BuildContext context, String text, void Function() action) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: action,
      onHorizontalDragEnd: (detail) {
        if (detail.primaryVelocity! < 0) {
          action();
        }
      },
      child: Container(
        color: colorScheme.primaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            SizedBox(
              height: 60,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: colorScheme.onSurface,
                  )
                ],
              ),
            ),
            Divider(color: Theme.of(context).colorScheme.shadow)
          ],
        ),
      ),
    );
  }
}
