/*
  * schedule_settings.dart *
  Settings page which allows the user to configure their bell vanity.
  Contains maps for temporary settings values
*/
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:xschedule/display/home_page.dart';
import 'package:xschedule/global/dynamic_content/stream_signal.dart';
import 'package:xschedule/global/dynamic_content/tutorial_system.dart';
import 'package:xschedule/global/static_content/extensions/build_context_extension.dart';
import 'package:xschedule/global/static_content/extensions/color_extension.dart';
import 'package:xschedule/global/static_content/extensions/widget_extension.dart';
import 'package:xschedule/schedule/schedule_display/schedule_display.dart';

import '../../global/dynamic_content/backend/open_ai.dart';
import '../../global/dynamic_content/schedule.dart';

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

  // All tutorials used in bell customization page; recalled when help button pressed
  static const Map<String, String> bellTutorials = {
    'tutorial_settings_bell':
        "In this menu, you'll be able to customize any individual bell on your schedule.",
    'tutorial_settings_bell_color_wheel':
        "You can give each bell a distinctive color using the color wheel.",
    'tutorial_settings_bell_color_row':
        "...or by selecting one from the available options.",
    'tutorial_settings_bell_icon':
        "Additionally, you can select an icon to represent each bell.",
    'tutorial_settings_bell_info':
        "As well, you can input the information about your class so that you can remember it later.",
    'tutorial_settings_bell_alternate':
        '...and if your class changes daily, you can add an "alternate" class for the bell.',
    'tutorial_settings_bell_complete':
        "When you've finished customizing the bell, press this button to save your changes and exit.",
    'tutorial_settings_bell_help':
        'If you ever need help, press this button here.'
  };

  static const Map<String, String> bellAltTutorials = {
    // Cheat and have same ID for two texts to re-use Widget
    'tutorial_settings_bell':
        "In this menu, you'll be able to specify an alternate bell dependent on the day.",
    'tutorial_settings_bell_alt_day':
        "Down here, you can scroll through all the days this bell appears on and select when to replace the normal settings for this bell.",
    'tutorial_settings_bell_alt_vanity':
        "Up here, you can customize the alternate bell using the same settings as normal.",
    'tutorial_settings_bell_alt_alternate':
        "When you're done, tap this button up here to return to the standard bell settings.",
    'tutorial_settings_bell_alt_help':
        "...and if you ever need help, press this button here.",
  };

  static final TutorialSystem bellTutorialSystem = TutorialSystem({
    'tutorial_settings_bell': bellTutorials['tutorial_settings_bell']!,
    'tutorial_settings_bell_help':
        bellTutorials['tutorial_settings_bell_help']!,
  });

  /// Refreshes the keys and tutorial text of Setting's tutorial systems.
  static void resetTutorials() {
    tutorialSystem.refreshKeys();
    bellTutorialSystem.set({
      'tutorial_settings_bell': bellTutorials['tutorial_settings_bell']!,
      'tutorial_settings_bell_help':
          bellTutorials['tutorial_settings_bell_help']!,
    });
    bellTutorialSystem.refreshKeys();
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

  // FocusNodes used for bell customization UI elements; <Bell, FocusNode>
  final Map<String, FocusNode> emojiFocus = {};
  final Map<String, FocusNode> nameFocus = {};
  final Map<String, FocusNode> teacherFocus = {};
  final Map<String, FocusNode> locationFocus = {};

  // Image file uploaded to AI; null by default
  File? imageFile;

  // List of color options in color scroll
  static const List<String> hexColorOptions = [
    '#ff0000',
    '#ff6600',
    '#ffbb00',
    '#ffff00',
    '#88ff00',
    '#00ff00',
    '#00bb00',
    '#00bb88',
    '#00eeff',
    '#0000ff',
    '#0000aa',
    '#8800ff',
    '#dd00ff',
    '#ff00aa',
    '#ff8888',
    '#ffffff',
    '#bbbbbb',
    '#884400',
    '#666666',
    '#000000'
  ];

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
                    tutorial: 'tutorial_settings_ai',
                    // OpenAI button
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_outlined,
                        size: 35,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () {
                        // Pushes the OpenAI popup to the Navigator
                        context.pushPopup(_buildPicPopup(context));
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
                      _saveBells();
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
                // A Bell Tile wrapped in ShowCase Widget
                ScheduleSettings.tutorialSystem.showcase(
                    context: context,
                    tutorial: 'tutorial_settings_button',
                    child: _buildBellTile(context, 'A')),
                // Remaining bell tiles; B-H, HR
                _buildBellTile(context, 'B'),
                _buildBellTile(context, 'C'),
                _buildBellTile(context, 'D'),
                _buildBellTile(context, 'E'),
                _buildBellTile(context, 'F'),
                _buildBellTile(context, 'G'),
                _buildBellTile(context, 'H'),
                _buildBellTile(context, 'HR'),
                _buildBellTile(context, 'FLEX'),
                // Bottom padding og 60px to add blank space for button to rest
                const SizedBox(height: 60)
              ],
            ),
          ));
    });
  }

  // Method which ensures no bell variables are undefined
  void _defineBell(String bell, {bool alternate = false}) {
    late Map<String, dynamic> reference;

    // If not alternate bell, define vanity defaults
    if (!alternate) {
      // Defines bellVanity map
      Schedule.bellVanity[bell] ??= {};
      Schedule.bellVanity[bell]!['alt'] ??= {};
      Schedule.bellVanity[bell]!['alt_days'] ??= [];
      // Defines color values
      if (bell == "FLEX") {
        Schedule.bellVanity[bell]!['color'] ??= "#888888";
      } else {
        Schedule.bellVanity[bell]!['color'] ??= "#006aff";
      }
      // Defines emoji values
      if (bell == "FLEX" || bell == "HR") {
        Schedule.bellVanity[bell]!['emoji'] ??= '📚';
      } else {
        Schedule.bellVanity[bell]!['emoji'] ??= bell;
      }
      // Defines name values
      Schedule.bellVanity[bell]!['name'] ??=
          '$bell Bell'.replaceAll('HR Bell', 'Homeroom').replaceAll('FLEX Bell', 'FLEX');
      // Defines teacher values
      Schedule.bellVanity[bell]!['teacher'] ??= '';
      // Defines location values
      Schedule.bellVanity[bell]!['location'] ??= '';

      reference = Schedule.bellVanity[bell]!;

      ScheduleSettings.altDays[bell] ??=
          List<String>.from(reference['alt_days']);
    } else {
      // ...else set as any existing alt vanity values
      reference = Map<String, dynamic>.from(Schedule.bellVanity[bell]!['alt']);
      Schedule.bellVanity[bell]!.forEach((key, value) {
        reference[key] ??= value;
      });
      // set bell id as alt id
      bell = "${bell}_alt";
    }

    // Null-aware assignments of bell variables
    ScheduleSettings.colors[bell] ??=
        HSVColor.fromColor(ColorExtension.fromHex(reference['color']));
    ScheduleSettings.emojis[bell] ??=
        TextEditingController(text: reference['emoji'].replaceAll('HR', '📚'));
    emojiFocus[bell] ??= FocusNode();
    ScheduleSettings.names[bell] ??=
        TextEditingController(text: reference['name']);
    nameFocus[bell] ??= FocusNode();
    ScheduleSettings.teachers[bell] ??=
        TextEditingController(text: reference['teacher']);
    teacherFocus[bell] ??= FocusNode();
    ScheduleSettings.locations[bell] ??=
        TextEditingController(text: reference['location']);
    locationFocus[bell] ??= FocusNode();
  }

  // Saves the temporary selected bell values to the bellVanity
  void _saveBell(String bell) {
    // The ID of the alt bell values
    final String altBell = "${bell}_alt";

    Schedule.bellVanity[bell] = {
      'name': ScheduleSettings.names[bell]!.text,
      'teacher': ScheduleSettings.teachers[bell]!.text,
      'location': ScheduleSettings.locations[bell]!.text,
      'emoji': ScheduleSettings.emojis[bell]!.text,
      'color': ScheduleSettings.colors[bell]!.toColor().toHex(),
      'alt_days': ScheduleSettings.altDays[bell],
      'alt': {
        'name': ScheduleSettings.names[altBell]!.text,
        'teacher': ScheduleSettings.teachers[altBell]!.text,
        'location': ScheduleSettings.locations[altBell]!.text,
        'emoji': ScheduleSettings.emojis[altBell]!.text,
        'color': ScheduleSettings.colors[altBell]!.toColor().toHex(),
      }
    };
  }

  void _saveBells() {
    // Saves the schedule vanity data to local storage
    localStorage.setItem("scheduleSettings", json.encode(Schedule.bellVanity));
    // Confirms that the user's progress is marked as "logged"
    localStorage.setItem("state", "logged");
    // Refreshed HomePage stream
    StreamSignal.updateStream(streamController: ScheduleDisplay.scheduleStream);
  }

  // Builds the bell tiles displayed in ScrollView
  Widget _buildBellTile(BuildContext context, String bell) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    // Ensures no null values
    _defineBell(bell);

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
            context.pushPopup(_buildBellPopup(context, bell));
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

  // Restarts the tutorial of the bell configuration menu
  void _startBellTutorial(BuildContext context, bool alt,
      {bool storeCompletion = false}) {
    // Clears tutorialSystem of tutorial values and Re-adds all tutorials to tutorialSystem
    if (alt) {
      ScheduleSettings.bellTutorialSystem
          .set(ScheduleSettings.bellAltTutorials);
    } else {
      ScheduleSettings.bellTutorialSystem.set(ScheduleSettings.bellTutorials);
    }
    // Starts tutorial
    ScheduleSettings.bellTutorialSystem
        .showTutorials(context, storeCompletion: storeCompletion);
  }

  // Builds the bell configuration popup
  Widget _buildBellPopup(BuildContext context, String bell) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double width = min(mediaQuery.size.width, 500);

    // Allows remote calling of FlipCard
    final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

    // Determines the hint text to be displayed at the top of the popup
    String hint = bell;
    if (hint.length == 1) {
      hint = '$hint Bell';
    } else if (hint == 'HR') {
      hint = 'Homeroom';
    }

    // bool for if day picker is displayed for alternate side
    bool dayPicker = true;

    // Refreshes the GlobalKeys of the bell tutorial system.
    ScheduleSettings.bellTutorialSystem.refreshKeys();

    // Returns the popup wrapped in a StatefulBuilder
    return StatefulBuilder(
        // Allows for "setState" to be called, and only effect this popup (i.e. a StatefulWidget)
        builder: (BuildContext context, StateSetter setLocalState) {
      // Prevents the popup from being overlapped by the keyboard
      return KeyboardAvoider(
          autoScroll: true,
          // Aligns the popup at the center of the page
          child: Align(
              alignment: Alignment.center,
              // Popup wrapped in Showcase View Widget
              child: ShowCaseWidget(onFinish: () {
                ScheduleSettings.bellTutorialSystem.finish();
              }, builder: (context) {
                // Schedules the showcase to start after the Widget is built
                if (!ScheduleSettings.bellTutorialSystem.finished) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScheduleSettings.bellTutorialSystem.showTutorials(context);
                  });
                }
                // Returns the popup wrapped in a Showcase
                return ScheduleSettings.bellTutorialSystem.showcase(
                    context: context,
                    tutorial: 'tutorial_settings_bell',
                    onTap: () async {
                      setLocalState(() {
                        dayPicker = true;
                      });
                      await Future.delayed(const Duration(milliseconds: 150));
                    },
                    // The popup as a flippable card with Columns of content
                    child: FlipCard(
                        key: cardKey,
                        flipOnTouch: false,
                        direction: FlipDirection.HORIZONTAL,
                        front: Card(
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                width: width * .95,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Row of set size at the top for misc. actions
                                    SizedBox(
                                        width: width * .9,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          // Items spaced evenly
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Help icon wrapped in Showcase
                                            ScheduleSettings.bellTutorialSystem
                                                .showcase(
                                              context: context,
                                              tutorial:
                                                  "tutorial_settings_bell_help",
                                              circular: true,
                                              child: IconButton(
                                                  // Restarts bell tutorial
                                                  onPressed: () =>
                                                      _startBellTutorial(
                                                          context, false),
                                                  // Help Icon
                                                  icon: Icon(
                                                      Icons
                                                          .help_outline_rounded,
                                                      size: 30,
                                                      color: colorScheme
                                                          .onSurface)),
                                            ),
                                            // Hint text widget
                                            Text(hint,
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    height: 1,
                                                    fontFamily: 'Exo2',
                                                    color: colorScheme.onSurface
                                                        .withAlpha(128))),
                                            // Alternate-schedule configuration button wrapped in SHowcase
                                            ScheduleSettings.bellTutorialSystem
                                                .showcase(
                                              context: context,
                                              tutorial:
                                                  "tutorial_settings_bell_alternate",
                                              circular: true,
                                              child: Schedule
                                                      .sampleDays['All Meet']!
                                                      .contains(bell)
                                                  ? IconButton(
                                                      onPressed: () async {
                                                        cardKey.currentState
                                                            ?.toggleCard();
                                                        await Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    1000));
                                                        if (context.mounted) {
                                                          _startBellTutorial(
                                                              context, true,
                                                              storeCompletion:
                                                                  true);
                                                        }
                                                      },
                                                      // Tuning Icon
                                                      icon: Icon(
                                                          Icons.autorenew,
                                                          size: 30,
                                                          color: colorScheme
                                                              .onSurface))
                                                  : CircleAvatar(
                                                      radius: 20,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                    ),
                                            )
                                          ],
                                        )),
                                    _buildBellSettings(
                                        context, bell, setLocalState, false),
                                    // Submit Button wrapped in Showcase w/ padding
                                    Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: ScheduleSettings
                                            .bellTutorialSystem
                                            .showcase(
                                                context: context,
                                                tutorial:
                                                    'tutorial_settings_bell_complete',
                                                child: ElevatedButton(
                                                    onPressed: () {
                                                      // Resets state of settings page to include new values
                                                      setState(() {
                                                        // Sets global bellVanity values to match selected ones
                                                        _saveBell(bell);
                                                        _saveBells();
                                                      });
                                                      // Pops popup, returning to settings page
                                                      Navigator.pop(context);
                                                    },
                                                    // Button styles to be green
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                            overlayColor:
                                                                colorScheme
                                                                    .onPrimary,
                                                            backgroundColor:
                                                                Colors.green),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              3 /
                                                              5,
                                                      // Simple Check Icon
                                                      child: Icon(
                                                        Icons.check,
                                                        color: colorScheme
                                                            .onPrimary,
                                                      ),
                                                    )))),
                                  ],
                                ))),
                        back: Card(
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                width: width * .95,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Row of set size at the top for misc. actions
                                    SizedBox(
                                        width: width * .9,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          // Items spaced evenly
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Help icon wrapped in Showcase
                                            ScheduleSettings.bellTutorialSystem
                                                .showcase(
                                              context: context,
                                              tutorial:
                                                  "tutorial_settings_bell_alt_help",
                                              circular: true,
                                              child: IconButton(
                                                  // Restarts bell tutorial
                                                  onPressed: () =>
                                                      _startBellTutorial(
                                                          context, true),
                                                  // Help Icon
                                                  icon: Icon(
                                                      Icons
                                                          .help_outline_rounded,
                                                      size: 30,
                                                      color: colorScheme
                                                          .onSurface)),
                                            ),
                                            // Hint text widget
                                            Text('$hint - Alternate',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    height: 1,
                                                    fontFamily: 'Exo2',
                                                    color: colorScheme.onSurface
                                                        .withAlpha(128))),
                                            // Alternate-schedule configuration button wrapped in SHowcase
                                            ScheduleSettings.bellTutorialSystem
                                                .showcase(
                                              context: context,
                                              tutorial:
                                                  "tutorial_settings_bell_alt_alternate",
                                              circular: true,
                                              child: IconButton(
                                                  onPressed: () {
                                                    cardKey.currentState
                                                        ?.toggleCard();
                                                  },
                                                  // Tuning Icon
                                                  icon: Icon(Icons.autorenew,
                                                      size: 30,
                                                      color: colorScheme
                                                          .onSurface)),
                                            )
                                          ],
                                        )),
                                    ScheduleSettings.bellTutorialSystem
                                        .showcase(
                                            context: context,
                                            tutorial:
                                                "tutorial_settings_bell_alt_vanity",
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 250),
                                              curve: Curves.easeInOut,
                                              constraints: BoxConstraints(
                                                  maxHeight: dayPicker
                                                      ? 50
                                                      : mediaQuery.size.height *
                                                          .75),
                                              child: SingleChildScrollView(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        setLocalState(() {
                                                          dayPicker =
                                                              !dayPicker;
                                                        });
                                                      },
                                                      child: Container(
                                                        height: 50,
                                                        alignment:
                                                            Alignment.center,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text("Appearance",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            25,
                                                                        color: colorScheme
                                                                            .onSurface,
                                                                        fontFamily:
                                                                            "Georama",
                                                                        fontWeight:
                                                                            FontWeight.w600))
                                                                .expandedFit(),
                                                            Icon(
                                                              dayPicker
                                                                  ? Icons
                                                                      .keyboard_arrow_up
                                                                  : Icons
                                                                      .keyboard_arrow_down,
                                                              color: colorScheme
                                                                  .onSurface,
                                                              size: 32,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    _buildBellSettings(
                                                        context,
                                                        bell,
                                                        setLocalState,
                                                        true),
                                                  ],
                                                ),
                                              ),
                                            )),
                                    Divider(
                                        color: colorScheme.onSurface,
                                        height: 8),
                                    ScheduleSettings.bellTutorialSystem
                                        .showcase(
                                            context: context,
                                            tutorial:
                                                "tutorial_settings_bell_alt_day",
                                            onTap: () async {
                                              setLocalState(() {
                                                dayPicker = false;
                                              });
                                              await Future.delayed(
                                                  const Duration(
                                                      milliseconds: 150));
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 250),
                                              curve: Curves.easeInOut,
                                              constraints: BoxConstraints(
                                                  maxHeight: dayPicker
                                                      ? mediaQuery.size.height *
                                                          .75
                                                      : 50),
                                              child: SingleChildScrollView(
                                                physics:
                                                    NeverScrollableScrollPhysics(),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    InkWell(
                                                      onTap: () {
                                                        setLocalState(() {
                                                          dayPicker =
                                                              !dayPicker;
                                                        });
                                                      },
                                                      child: Container(
                                                        height: 50,
                                                        alignment:
                                                            Alignment.center,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text("Program",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            25,
                                                                        fontFamily:
                                                                            "Georama",
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color: colorScheme
                                                                            .onSurface))
                                                                .expandedFit(),
                                                            Icon(
                                                              dayPicker
                                                                  ? Icons
                                                                      .keyboard_arrow_down
                                                                  : Icons
                                                                      .keyboard_arrow_up,
                                                              color: colorScheme
                                                                  .onSurface,
                                                              size: 32,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    _buildDaySelector(context,
                                                        bell, setLocalState)
                                                  ],
                                                ),
                                              ),
                                            )),
                                  ],
                                )))));
              })));
    });
  }

  // Builds the base vanity settings Widget
  Widget _buildBellSettings(BuildContext context, String bell,
      StateSetter setLocalState, bool alternate) {
    _defineBell(bell, alternate: alternate);

    final String tutorialKey = alternate ? "_alt" : '';
    bell = "$bell$tutorialKey";

    return Column(
      children: [
        // Color Wheel w/ Emoji Picker wrapped in Showcase
        ScheduleSettings.bellTutorialSystem.showcase(
            context: context,
            tutorial: 'tutorial_settings_bell${tutorialKey}_color_wheel',
            child: _buildColorWheel(context, bell, setLocalState, alternate)),
        // Color Scroll wrapped in Showcase
        ScheduleSettings.bellTutorialSystem.showcase(
          context: context,
          tutorial: 'tutorial_settings_bell${tutorialKey}_color_row',
          child: _buildColorSelection(
              context, bell, setLocalState, hexColorOptions),
        ),
        // Spacing of 16px
        const SizedBox(height: 16),
        // Column of text forms wrapped in Showcase
        ScheduleSettings.bellTutorialSystem.showcase(
            context: context,
            tutorial: 'tutorial_settings_bell${tutorialKey}_info',
            targetPadding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Name TextField
                _buildTextForm(
                    context, ScheduleSettings.names[bell]!, "Bell Name",
                    focusNode: nameFocus[bell]),
                // Teacher TextField
                _buildTextForm(
                    context, ScheduleSettings.teachers[bell]!, "Teacher",
                    focusNode: teacherFocus[bell]),
                // Location TextField
                _buildTextForm(
                    context, ScheduleSettings.locations[bell]!, "Location",
                    focusNode: locationFocus[bell]),
              ],
            )),
      ],
    );
  }

  // Builds the Color Wheel displayed in the bell configuration menu
  Widget _buildColorWheel(BuildContext context, String bell,
      StateSetter setLocalState, bool alternate) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final String tutorialKey = alternate ? "_alt" : "";

    // Color Wheel and Emoji Selector Stack
    return SizedBox(
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Solid Color circle to display selected color
          CircleAvatar(
            backgroundColor:
                // Color in variable type "HSVColor"; needs to be converted
                ScheduleSettings.colors[bell]!.toColor(),
            radius: 95,
          ),
          // Color Wheel picker
          WheelPicker(
            showPalette: false,
            color: ScheduleSettings.colors[bell]!,
            onChanged: (HSVColor value) {
              setLocalState(() {
                // Stores the selected color at 100% saturation and value (ensures color is actually displayed on wheel)
                ScheduleSettings.colors[bell] =
                    value.withValue(1).withSaturation(1);
              });
            },
          ),
          // Emoji Picker wrapped in Showcase
          ScheduleSettings.bellTutorialSystem.showcase(
              context: context,
              tutorial: 'tutorial_settings_bell${tutorialKey}_icon',
              circular: true,
              // Container w/ Emoji TextField
              child: Container(
                  width: 125,
                  height: 125,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(bottom: 10),
                  // IntrinsicWidth which serves as a Container of the smallest size possible based on child (TextField)
                  child: TextField(
                    controller: ScheduleSettings.emojis[bell],
                    enableInteractiveSelection: false,
                    focusNode: emojiFocus[bell],
                    showCursor: false,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      // Removes the underline
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0), // Optional: adjust padding
                    ),
                    style: TextStyle(
                        fontSize: 120,
                        // Large font size
                        color: colorScheme.onSurface),
                    onTapOutside: (_) {
                      emojiFocus[bell]?.unfocus();
                    },
                    onChanged: (String text) {
                      //Ensured no empty values
                      if (text.isEmpty) {
                        text = '_';
                      }
                      //Ensures no values greater than one character; will use 2nd char so that you can quickly type
                      //Use characters to ensure emojis work
                      if (text.characters.length > 1) {
                        text = text.characters.last;
                      }
                      setLocalState(() {
                        ScheduleSettings.emojis[bell]!.text = text;
                      });
                    },
                  ).intrinsicFit()))
        ],
      ),
    );
  }

  // Builds the Color Scroll displayed in the bell configuration menu
  Widget _buildColorSelection(BuildContext context, String bell,
      StateSetter setLocalState, List<String> hexColors) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double width = min(mediaQuery.size.width, 500);

    // ScrollController of the Color ScrollView
    final ScrollController controller = ScrollController();

    // Row containing arrow indicators and constrained ScrollView
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Left Arrow IconButton
        IconButton(
            onPressed: () {
              // Scrolls the ScrollView 3 tiles left
              controller.animateTo(controller.offset - 46 * 3,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            },
            // Simple Left Arrow
            icon: Icon(
              Icons.arrow_back_ios,
              color: colorScheme.onSurface.withAlpha(128),
              size: 12,
            )).expandedFit(),
        // ScrollView constrained within set-width container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          width: width * .7,
          // Stack containing ScrollView and edge-fading overlays
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Color ScrollView
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: controller,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  // Builds list of color selecting tiles based on provided list
                  children: List<Widget>.generate(hexColors.length, (i) {
                    // Returns colored button
                    return InkWell(
                      onTap: () {
                        // Sets the color and refreshes the popup
                        setLocalState(() {
                          ScheduleSettings.colors[bell] = HSVColor.fromColor(
                              ColorExtension.fromHex(hexColors[i]));
                        });
                      },
                      // Colored container
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        width: 30,
                        height: 30,
                        // Rounded edges, shadow, and color
                        decoration: BoxDecoration(
                            color: ColorExtension.fromHex(hexColors[i]),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                  color: colorScheme.shadow, blurRadius: 1)
                            ]),
                      ),
                    );
                  }),
                ),
              ),
              // Fading container which ignores touch (aligned left by default)
              IgnorePointer(
                  child: Container(
                      width: 12,
                      height: 46,
                      // Decorated by LinearGradient of surfaceColor from left to right
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                            colorScheme.surface,
                            colorScheme.surface.withAlpha(0),
                          ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight)))),
              // Fading container which ignores touch aligned right
              Align(
                alignment: Alignment.centerRight,
                child: IgnorePointer(
                    child: Container(
                        width: 12,
                        height: 46,
                        // Decorated by LinearGradient of surfaceColor from right to left
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                              colorScheme.surface,
                              colorScheme.surface.withAlpha(0),
                            ],
                                end: Alignment.centerLeft,
                                begin: Alignment.centerRight)))),
              )
            ],
          ),
        ),
        // Right Arrow IconButton
        IconButton(
            onPressed: () {
              // Scrolls the ScrollView 3 tiles right
              controller.animateTo(controller.offset + 46 * 3,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            },
            // Simple Right Arrow
            icon: Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.onSurface.withAlpha(128),
              size: 12,
            )).expandedFit(),
      ],
    );
  }

  // Builds a text form displayed in the bell configuration menu
  Widget _buildTextForm(
      BuildContext context, TextEditingController controller, String display,
      {FocusNode? focusNode}) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double size = min(mediaQuery.size.width, 500) * 5 / 6;

    // Returns a TextFormField constrained by a set-width Container
    return Container(
      margin: const EdgeInsets.only(top: 5),
      height: size * 2 / 15,
      width: size,
      child: TextFormField(
        keyboardType: TextInputType.text,
        focusNode: focusNode,
        controller: controller,
        maxLength: 50,
        maxLines: 1,
        // Decorated by basic border w/ hint text
        decoration: InputDecoration(
          labelText: display,
          isDense: true,
          counterText: '',
          labelStyle: TextStyle(
              color: colorScheme.onSurface, overflow: TextOverflow.ellipsis),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.shadow, width: 1),
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector(
      BuildContext context, String bell, StateSetter setLocalState) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final List<String> meetDays = [];
    Schedule.sampleDays.forEach((key, value) {
      if (value.contains(bell)) {
        meetDays.add(key);
      }
    });

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List<Widget>.generate(meetDays.length, (i) {
              final String dayTitle = meetDays[i];
              final List<String> day = Schedule.sampleDays[dayTitle] ?? [];
              final double bellHeight = 150 / (day.length - 1);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 90,
                child: InkWell(
                  onTap: () {
                    setLocalState(() {
                      if (ScheduleSettings.altDays[bell]!.contains(dayTitle)) {
                        ScheduleSettings.altDays[bell]!.remove(dayTitle);
                      } else {
                        ScheduleSettings.altDays[bell]!.add(dayTitle);
                      }
                    });
                  },
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(dayTitle,
                            style: TextStyle(
                                fontSize: 24,
                                color: colorScheme.onSurface,
                                fontFamily: "Exo_2"))
                        .fit(),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: List<Widget>.generate(day.length, (e) {
                          final String dayBell = day[e];
                          return Container(
                            height: dayBell == "FLEX" ? 25 : bellHeight,
                            color: dayBell == bell
                                ? colorScheme.primary
                                : colorScheme.onSurface
                                    .withAlpha(dayBell == "FLEX" ? 64 : 96),
                          );
                        }),
                      ),
                    ),
                    Checkbox(
                        activeColor: colorScheme.primary,
                        value:
                            ScheduleSettings.altDays[bell]!.contains(dayTitle),
                        onChanged: (_) {})
                  ]),
                ),
              );
            }),
          ),
        ),
        IgnorePointer(
          child: Container(
            width: 8,
            height: 230,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              colorScheme.surface,
              colorScheme.surface.withAlpha(0)
            ], begin: Alignment.centerLeft, end: Alignment.centerRight)),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IgnorePointer(
            child: Container(
              width: 8,
              height: 230,
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                colorScheme.surface,
                colorScheme.surface.withAlpha(0)
              ], begin: Alignment.centerRight, end: Alignment.centerLeft)),
            ),
          ),
        )
      ],
    );
  }

  // Allows the user to select an image from their camera roll
  Future<void> selectImage(StateSetter setLocalState) async {
    // Requests image to be picked and stored selection
    FilePickerResult? pickedImage = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);

    // If image was selected, stores image file path
    if (pickedImage != null) {
      if (pickedImage.xFiles.isNotEmpty) {
        // The file selected
        final File pickedFile = File(pickedImage.xFiles.first.path);
        // If the file exists, refresh the page to account for the selection
        if (await pickedFile.exists() && context.mounted) {
          setLocalState(() {
            imageFile = pickedFile;
          });
        }
      }
    }
  }

  // Builds the popup for selecting and uploading an image
  Widget _buildPicPopup(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double width = min(mediaQuery.size.width, 500);

    // Status booleans
    bool uploaded = false;
    bool isLoading = false;

    // Returns popup wrapped in StatefulBuilder
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setLocalState) {
      // Refreshes uploaded status
      uploaded = imageFile != null;

      // Returns popup
      return WidgetExtension.popup(
          context,
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                  // Title wrapped in FittedBox
                  child: Text(
                    "Schedule from Image",
                    style: TextStyle(
                        fontFamily: "Exo2",
                        fontSize: 35,
                        fontWeight: FontWeight.w600),
                  ).fit()),
              // Image display wrapped in button
              InkWell(
                highlightColor: colorScheme.onSurface,
                onTap: () async {
                  // Requests image through camera roll selection
                  if (!isLoading) {
                    await selectImage(setLocalState);
                  }
                },
                // Image display Stack
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Image wrapped in Container w/ border
                    Container(
                        width: width * 3 / 5,
                        height: width * 3 / 5,
                        // 5px border
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: colorScheme.onSurface.withAlpha(128),
                                width: 5)),
                        padding: const EdgeInsets.all(2.5),
                        margin: const EdgeInsets.all(15),
                        alignment: Alignment.center,
                        // If image has been selected, display it; if not, display selection Icon
                        child: uploaded
                            // Image which covers given space
                            ? SizedBox(
                                width: width * 3 / 5,
                                height: width * 3 / 5,
                                child: ClipRect(
                                    child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: Image.file(imageFile!),
                                )),
                              )
                            // Image selection icon
                            : Icon(
                                Icons.photo_outlined,
                                size: width * 1 / 2,
                                color: colorScheme.onSecondary,
                              )),
                    // If image has been uploaded, display icon as reminder that new image can be selected
                    if (uploaded && !isLoading)
                      Opacity(
                        opacity: 0.1,
                        child: Icon(
                          Icons.photo_outlined,
                          size: width * 1 / 2,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    // If is loading, display Shimmer effect to represent loading
                    if (isLoading)
                      Opacity(
                        opacity: 0.75,
                        child: Shimmer.fromColors(
                            baseColor: colorScheme.surface.withAlpha(128),
                            highlightColor: colorScheme.onPrimary,
                            child: Container(
                                width: width * 3 / 5 - 15,
                                height: width * 3 / 5 - 15,
                                color: colorScheme.surface)),
                      )
                  ],
                ),
              ),
              // Progress button wrapped in Container w/ padding and sizing
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: EdgeInsets.symmetric(horizontal: width * .08),
                width: width * 4 / 5,
                child: ElevatedButton(
                    onPressed: () async {
                      // If image has not been selected, request one
                      if (!uploaded) {
                        await selectImage(setLocalState);
                        // ...else begin uploading process, if not already loading
                      } else if (!isLoading) {
                        // Refresh page to begin loading animation
                        setLocalState(() {
                          isLoading = true;
                        });
                        if (await imageFile!.exists()) {
                          // Send http.get request to OpenAI, interpret, and store result
                          final Map<String, dynamic> aiScan =
                              await OpenAI.scanSchedule(imageFile!.path);
                          if (context.mounted) {
                            // If error detected, display error and exit
                            if (aiScan['error'] != null) {
                              context.showSnackBar(
                                  'Request Failed: Error Code ${aiScan['error']}',
                                  isError: true);
                              // Refresh page to end loading animation
                              setLocalState(() {
                                isLoading = false;
                              });
                              return;
                            }
                            // If error not detected, refresh entire page to include AI results
                            setState(() {
                              Schedule.bellVanity =
                                  Map<String, Map<String, dynamic>>.from(
                                      aiScan);

                              // Clear all temporary values to be reset later
                              ScheduleSettings.names.clear();
                              ScheduleSettings.teachers.clear();
                              ScheduleSettings.locations.clear();
                              ScheduleSettings.colors.clear();
                              ScheduleSettings.emojis.clear();
                            });
                            // Pops popup, returning to settings page
                            Navigator.pop(context);
                          }
                        }
                      }
                    },
                    // Button styled dependent on status
                    style: ElevatedButton.styleFrom(
                        overlayColor: colorScheme.onPrimary,
                        // If image is selected, primary button, else secondary button color scheme
                        backgroundColor: uploaded
                            ? colorScheme.primary
                            : colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15)))),
                    // Displays Shimmer dependent on status w/ text
                    child: Container(
                        alignment: Alignment.center,
                        height: 37.5,
                        child: Shimmer.fromColors(
                            baseColor: colorScheme.onPrimary,
                            highlightColor: colorScheme.onSecondary,
                            // Shimmer dependent on loading status
                            enabled: isLoading,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Icon hint dependent on status
                                Icon(
                                  // If image has been selected, display scan icon, else image upload icon
                                  uploaded
                                      ? Icons.document_scanner_outlined
                                      : Icons.add_photo_alternate_outlined,
                                  size: 25,
                                  color: colorScheme.onPrimary,
                                ),
                                // Hint text dependent on status
                                Text(
                                  // If image has been selected, display scan image text, else upload image text
                                  uploaded ? "  Scan Image" : "  Upload Image",
                                  style: TextStyle(
                                      fontSize: 25, fontFamily: "Georama"),
                                )
                              ],
                            ))).fit()),
              )
            ],
          ));
    });
  }
}
