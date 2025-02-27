import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xschedule/display/home_page.dart';
import 'package:xschedule/global_variables/static_content/global_variables.dart';
import 'package:xschedule/global_variables/static_content/global_widgets.dart';
import 'package:xschedule/global_variables/dynamic_content/stream_signal.dart';

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
            GlobalMethods.pushSwipePage(
                context, const ScheduleSettings(backArrow: true));
          }),
          _buildOption(context, "Reset Local Data", () {
            ScheduleSettings.bellInfo = {};
            localStorage.clear();
            StreamSignal.updateStream(
                streamController: HomePage.homePageStream);
          }),
          _buildOption(context, "Credits and Copyright", () {
            GlobalMethods.showPopup(context, _buildInfo(context));
          }),
          _buildOption(context, "Submit Beta Report", () {
            GlobalMethods.visitUrl(
                "https://forms.office.com/Pages/ResponsePage.aspx?id=udgb07DszU6VE6pe_6S_QEKQcshWKqpCj4E9J0VU-BRUN1o3SlRJMzk1SkZMMklLWFc3UEVFVkIzOC4u");
          }),
        ]));
  }

  Widget _buildInfo(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final PackageInfo packageInfo = GlobalVariables.packageInfo;

    return GlobalWidgets.popup(
        context,
        SizedBox(
          width: mediaQuery.size.width * 4 / 5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 125,
                margin: const EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset("assets/images/xschedule.png"),
                ),
              ),
              Text(
                "X-Schedule",
                style: TextStyle(
                    fontSize: 25,
                    fontFamily: "Georama",
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface),
              ),
              Text(
                "Created by John Daniher",
                style: TextStyle(
                    fontSize: 20,
                    height: 0.9,
                    fontFamily: "Georama",
                    color: colorScheme.onSurface),
              ),
              const SizedBox(height: 10),
              Text(
                "© 2024 St. Xavier HS\nAvailable under MIT license.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    height: 0.975,
                    fontSize: 17.5,
                    fontFamily: "Georama",
                    color: colorScheme.onSurface),
              ),
              const SizedBox(height: 5),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "v${packageInfo.version} Build ${packageInfo.buildNumber}",
                  style: TextStyle(
                      fontSize: 14,
                      height: 0.9,
                      fontFamily: "Georama",
                      color: colorScheme.onSurface),
                ),
              ),
              const SizedBox(height: 5),
            ],
          ),
        ));
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
