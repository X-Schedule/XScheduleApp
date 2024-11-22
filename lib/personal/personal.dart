import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:xchedule/display/home_page.dart';
import 'package:xchedule/global_variables/stream_signal.dart';

import '../global_variables/gloabl_methods.dart';
import '../schedule/schedule_settings.dart';

/*
Personal Page:
Currently a glorified settings page
In the future, it will hopefully display more personal information at the digression of st x staff
 */

class Personal extends StatelessWidget {
  const Personal({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    MediaQueryData mediaQuery = MediaQuery.of(context);
    return Scaffold(
        backgroundColor: colorScheme.primaryContainer,
        appBar: PreferredSize(
            preferredSize:
                Size(mediaQuery.size.width, 55),
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.contain,
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
            GlobalMethods.pushSwipePage(
                context, const ScheduleSettings(backArrow: true));
          }),
          _buildOption(context, "Reset Local Data", () {
            localStorage.clear();
            StreamSignal.updateStream(
                streamController: HomePage.homePageStream);
          }),
          _buildOption(context, "Submit Beta Report", () {
            GlobalMethods.visitUrl("https://forms.office.com/Pages/ResponsePage.aspx?id=udgb07DszU6VE6pe_6S_QEKQcshWKqpCj4E9J0VU-BRUN1o3SlRJMzk1SkZMMklLWFc3UEVFVkIzOC4u");
          })
        ]));
  }

  Widget _buildOption(
      BuildContext context, String text, void Function() action) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
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
