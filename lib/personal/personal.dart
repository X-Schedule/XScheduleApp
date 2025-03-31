/*
  * personal.dart *
  Currently a sort of Settings page to provide additional options in the app.
  Simple Scaffold with a title AppBar and body Column of options.
*/
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:xschedule/display/splash_page.dart';
import 'package:xschedule/global/static_content/extensions/build_context_extension.dart';
import 'package:xschedule/global/static_content/extensions/widget_extension.dart';
import 'package:xschedule/personal/credits.dart';
import 'package:xschedule/schedule/schedule_display/schedule_display.dart';
import '../schedule/schedule_settings/schedule_settings.dart';

/// Current Settings page of the app. <p>
/// Contains title AppBar and body of Column consisting of various options (ScheduleSettings, Credits, Feedback, etc.)
class Personal extends StatelessWidget {
  const Personal({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    // Simple Scaffold with title AppBar and Column body
    return Scaffold(
        backgroundColor: colorScheme.primaryContainer,
        // Custom AppBar; features title
        appBar: PreferredSize(
            // Auto-adapts to fit device safe zone
            preferredSize: Size(mediaQuery.size.width, 55),
            child: Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Settings title
                  Text(
                    "Settings",
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Georama",
                        color: colorScheme.onSurface),
                  ).fit(),
                  // Shadow divider
                  Container(
                    color: colorScheme.shadow,
                    height: 2.5,
                    width: mediaQuery.size.width - 10,
                    margin: const EdgeInsets.only(top: 5),
                  )
                ],
              ),
            )),
        // Simple Column containing list of options
        body: Column(children: [
          // ScheduleSettings button
          _buildOption(context, "Customize Bell Appearances", () {
            context.pushSwipePage(const ScheduleSettings(backArrow: true));
          }),
          // Clear localData button
          _buildOption(context, "Reset Local Data", () => _clearCache(context)),
          // Credits popup button
          _buildOption(context, "Credits and Copyright", () {
            context.pushPopup(Credits(), begin: Offset(1, 0));
          }),
          // Beta Report Google Form button
          _buildOption(context, "Submit Beta Report", () {
            launchUrl(Uri.parse(
                "https://forms.office.com/Pages/ResponsePage.aspx?id=udgb07DszU6VE6pe_6S_QEKQcshWKqpCj4E9J0VU-BRUN1o3SlRJMzk1SkZMMklLWFc3UEVFVkIzOC4u"));
          }),
        ]));
  }

  // builds the options which appear in the body column
  static Widget _buildOption(
      BuildContext context, String text, void Function() action) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // GestureDetector to listen for tap and horizontal swipe
    return GestureDetector(
      // Runs provided action on tap or left swipe
      onTap: action,
      onHorizontalDragEnd: (detail) {
        if (detail.primaryVelocity! < 0) {
          action();
        }
      },
      // Returns Container w/ row consisting of title and icon
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
                  // Option title
                  Text(
                    text,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface),
                  ),
                  // Simple arrow icon
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 20,
                    color: colorScheme.onSurface,
                  )
                ],
              ),
            ),
            // Divider to separate from next option
            Divider(color: colorScheme.shadow)
          ],
        ),
      ),
    );
  }

  // Clears all variables and localStorage
  static void _clearCache(BuildContext context) {
    // Clears localStorage
    localStorage.clear();
    // Resets storage variables
    ScheduleSettings.resetTutorials();
    ScheduleDisplay.tutorialSystem.refreshKeys();
    ScheduleDisplay.tutorialDate = null;
    // Forward to SplashPage
    Navigator.pushAndRemoveUntil(
        context, MaterialPageRoute(builder: (_) => SplashPage()), (_) => false);
  }
}
