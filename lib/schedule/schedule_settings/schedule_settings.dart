/*
  * schedule_settings.dart *
  Settings page which allows the user to configure their bell vanity.
  Contains maps for temporary settings values
*/
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:xschedule/display/home_page.dart';
import 'package:xschedule/global/dynamic_content/tutorial_system.dart';
import 'package:xschedule/global/static_content/extensions/build_context_extension.dart';
import 'package:xschedule/global/static_content/extensions/color_extension.dart';
import 'package:xschedule/global/static_content/extensions/widget_extension.dart';

import '../../global/dynamic_content/schedule.dart';
import 'bell_settings.dart';

/// Settings page which allows the user to configure bell vanity. <p>
/// Contains Appbar with title and AI option, ScrollView of bell tiles, and submission button. <p>
/// [bool backArrow]: Boolean for whether or not the option to leave the menu should appear in the top left.
class ScheduleSettings extends StatefulWidget {
  const ScheduleSettings({super.key, this.backArrow = false});

  // Parameter which specifies if an arrow should appear to back out of the page
  final bool backArrow;

  // Maps of temporary values used in editing bell vanity (<Bell, Value>)
  static final Map<String, HSVColor> colors = {};
  static final Map<String, TextEditingController> emojis = {};
  static final Map<String, TextEditingController> names = {};
  static final Map<String, TextEditingController> teachers = {};
  static final Map<String, TextEditingController> locations = {};
  static final Map<String, List<String>> altDays = {};

  // Tutorial systems used on ScheduleSettings page
  static final TutorialSystem tutorialSystem = TutorialSystem({
    'tutorial_settings':
        "In this menu, you'll be able to customize your schedule to match the classes you have.",
    'tutorial_settings_button':
        "Click on any individual bell to change its name, information, and appearance.",
    'tutorial_settings_ai':
        "... or try uploading a picture of your schedule to let AI interpret it for you!",
    'tutorial_settings_complete':
        "Once you're satisfied with your schedule, tap the button down here to move on."
  });

  /// Refreshes the keys and tutorial text of Setting's tutorial systems.
  static void resetTutorials() {
    tutorialSystem.refreshKeys();
  }

  /// Clears all temporary bell values from settings
  static void clearSettings() {
    colors.clear();
    emojis.clear();
    names.clear();
    teachers.clear();
    locations.clear();
    altDays.clear();
  }

  @override
  State<ScheduleSettings> createState() => _ScheduleSettingsState();
}

class _ScheduleSettingsState extends State<ScheduleSettings> {
  // Default color of color wheels.
  final Color pickerColor = Colors.blue;




  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    // Refreshes the global keys of each tutorial element
    ScheduleSettings.tutorialSystem.refreshKeys();
    ScheduleSettings.tutorialSystem.removeFinished();

    // Showcase View which returns page Scaffold
    return ShowCaseWidget(builder: (context) {
      // Schedules tutorial start after widget has been built
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Wait .25 seconds for page animation
        await Future.delayed(const Duration(milliseconds: 250));
        // If tutorial has not been run, run tutorial system
        if (!ScheduleSettings.tutorialSystem.finished && context.mounted) {
          ScheduleSettings.tutorialSystem.showTutorials(context);
          ScheduleSettings.tutorialSystem.finish();
        }
      });

      // Returns page scaffold with top bar and body containing scroll view of bells
      return Scaffold(
          backgroundColor: colorScheme.primaryContainer,
          appBar: AppBar(
            // If back arrow is selected to be displayed, return null (allows default button to be displayed)
            leading: widget.backArrow ? null : Container(),
            centerTitle: true,
            backgroundColor: colorScheme.surface,
            // List of Widgets to be displayed in top right
            actions: [
              // IconButton leading to OpenAI popup padded 10px from right
              Padding(
                padding: const EdgeInsets.only(right: 10),
                // Showcase target for OpenAI button
                child: ScheduleSettings.tutorialSystem.showcase(
                    context: context,
                    circular: true,
                    tutorial: 'tutorial_settings_qr',
                    // OpenAI button
                    child: IconButton(
                      icon: Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 35,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () {
                        // Pushes the OpenAI popup to the Navigator
                        context.pushPopup(_buildQrPopup(context));
                      },
                    )),
              )
            ],
            // Showcase target for title
            title: ScheduleSettings.tutorialSystem.showcase(
              context: context,
              tutorial: 'tutorial_settings',
              // Title fitted to width
              child: Text(
                "Customize Bell Appearance",
                style: TextStyle(
                    //Custom font Goerama
                    fontFamily: "Georama",
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface),
              ).fit(),
            ),
          ),
          // Extends the body behind the bottom bar
          extendBody: true,
          // "Done" button on the bottom of the page
          bottomNavigationBar: Container(
            height: 40,
            // Offset from bottom corresponding to device "safety zone"
            margin: EdgeInsets.symmetric(
                vertical: 20, horizontal: mediaQuery.size.width * .325),
            // Showcase target for "Done" button
            child: ScheduleSettings.tutorialSystem.showcase(
                context: context,
                tutorial: 'tutorial_settings_complete',
                // "Done" button
                child: ElevatedButton(
                    onPressed: () {
                      BellSettings.saveBells();
                      // Returns to HomePage
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => HomePage()),
                          (_) => false);
                    },
                    // Button styled to fit theme colors
                    style: ElevatedButton.styleFrom(
                        overlayColor: colorScheme.onPrimary,
                        backgroundColor: colorScheme.primary),
                    // Check Mark Icon aligned at center of button
                    child: Container(
                      alignment: Alignment.center,
                      width: mediaQuery.size.width * 3 / 5,
                      child: Icon(
                        Icons.check,
                        color: colorScheme.onPrimary,
                      ),
                    ))),
          ),
          // ScrollView of individual bell tiles
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                ...List<Widget>.generate(Schedule.sampleBells.length, (i) {
                  if (i == 0) {
                    return ScheduleSettings.tutorialSystem.showcase(
                        context: context,
                        tutorial: 'tutorial_settings_button',
                        child:
                            _buildBellTile(context, Schedule.sampleBells[i]));
                  }
                  return _buildBellTile(context, Schedule.sampleBells[i]);
                }),
                // Bottom padding og 60px to add blank space for button to rest
                const SizedBox(height: 60)
              ],
            ),
          ));
    });
  }

  // Builds the bell tiles displayed in ScrollView
  Widget _buildBellTile(BuildContext context, String bell) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    // Ensures no null values
    BellSettings.defineBell(bell);

    // Vanity map of provided bell
    final Map<String, dynamic> vanity = Schedule.bellVanity[bell] ?? {};

    // Returns "Settings Tile", which displays current bell info and ability to edit bell
    return Container(
      margin: const EdgeInsets.all(10),
      width: mediaQuery.size.width * .95,
      height: 100,
      // Tap-able card leading to bell config menu
      child: Card(
        color: colorScheme.surface,
        child: InkWell(
          highlightColor: colorScheme.onPrimary,
          onTap: () {
            // Pushes the bell configuration popup
            context.pushPopup(BellSettings(bell: bell, setState: setState));
          },
          child: Row(
            children: [
              // Left color nib w/ rounded edges; selected color of bell
              Container(
                decoration: BoxDecoration(
                  // Rounds the left edges to match the Card
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(10)),
                  color: ColorExtension.fromHex(vanity['color']!),
                ),
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                // Column w/ two rows
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Stacks the emoji on top of a shadowed circle
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: colorScheme.surfaceContainer,
                          radius: 35,
                        ),
                        Text(
                          vanity['emoji'],
                          style: TextStyle(
                              fontSize: 40, color: colorScheme.onSurface),
                        )
                      ],
                    ),
                    // Container including all text widgets
                    Container(
                      width: mediaQuery.size.width * .95 - 180,
                      height: 70,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 5),
                      // Column of Text Widgets w/ height divided equally among them, and wrapped in individual FittedBoxes to prevent overflow.
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text set to fit Expanded container
                          Text(
                            vanity['name'],
                            style: TextStyle(
                                height: 1,
                                fontSize: 25,
                                overflow: TextOverflow.ellipsis,
                                //bold
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface),
                          ).expandedFit(alignment: Alignment.centerLeft),
                          Text(
                            vanity['teacher'],
                            style: TextStyle(
                                fontSize: 18,
                                height: 1,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface),
                          ).expandedFit(alignment: Alignment.centerLeft),
                          Text(
                            vanity['location'],
                            style: TextStyle(
                                fontSize: 18,
                                height: 1,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface),
                          ).expandedFit(alignment: Alignment.centerLeft)
                        ],
                      ),
                    ),
                    // Settings icon to indicate the ability to configure by tapping tile
                    Container(
                      alignment: Alignment.center,
                      width: 70,
                      child: Icon(Icons.settings,
                          size: 45, color: colorScheme.onSurface),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builds the popup for selecting and uploading an image
  Widget _buildQrPopup(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double width = min(mediaQuery.size.width, 500);

    // Returns popup wrapped in StatefulBuilder
    return WidgetExtension.popup(
        context,
        Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: width * .75,
              child: QrImageView(
                  data: jsonEncode(Schedule.bellVanity['A']),
                  embeddedImage:
                      AssetImage("assets/images/xschedule_transparent.png")),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              padding: EdgeInsets.symmetric(horizontal: width * .08),
              width: width * 4 / 5,
              child: ElevatedButton(
                  onPressed: () async {},
                  // Button styled dependent on status
                  style: ElevatedButton.styleFrom(
                      overlayColor: colorScheme.onPrimary,
                      // If image is selected, primary button, else secondary button color scheme
                      backgroundColor: colorScheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)))),
                  // Displays Shimmer dependent on status w/ text
                  child: Container(
                      alignment: Alignment.center,
                      height: 37.5,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon hint dependent on status
                          Icon(
                            Icons.download,
                            size: 25,
                            color: colorScheme.onPrimary,
                          ),
                          // Hint text dependent on status
                          Text(
                            // If image has been selected, display scan image text, else upload image text
                            "  Import from QR Code",
                            style: TextStyle(
                                fontSize: 25,
                                fontFamily: "Georama",
                                color: colorScheme.onPrimary),
                          )
                        ],
                      )).fit()),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              padding: EdgeInsets.symmetric(horizontal: width * .08),
              width: width * 4 / 5,
              child: ElevatedButton(
                  onPressed: () async {},
                  // Button styled dependent on status
                  style: ElevatedButton.styleFrom(
                      overlayColor: colorScheme.onPrimary,
                      // If image is selected, primary button, else secondary button color scheme
                      backgroundColor: colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)))),
                  // Displays Shimmer dependent on status w/ text
                  child: Container(
                      alignment: Alignment.center,
                      height: 37.5,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon hint dependent on status
                          Icon(
                            Icons.publish,
                            size: 25,
                            color: colorScheme.onPrimary,
                          ),
                          // Hint text dependent on status
                          Text(
                            // If image has been selected, display scan image text, else upload image text
                            "  Export as QR Code",
                            style: TextStyle(
                                fontSize: 25,
                                fontFamily: "Georama",
                                color: colorScheme.onPrimary),
                          )
                        ],
                      )).fit()),
            )
          ],
        ));
  }
}