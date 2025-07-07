import 'dart:convert';
import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:localstorage/localstorage.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:xschedule/global/static_content/extensions/color_extension.dart';
import 'package:xschedule/global/static_content/extensions/widget_extension.dart';
import 'package:xschedule/global/static_content/xschedule_materials/styled_button.dart';
import 'package:xschedule/schedule/schedule_settings/schedule_settings.dart';

import '../../global/dynamic_content/schedule.dart';
import '../../global/dynamic_content/stream_signal.dart';
import '../../global/dynamic_content/tutorial_system.dart';
import '../schedule_display/schedule_display.dart';

class BellSettings extends StatefulWidget {
  BellSettings({super.key, required this.bell, required this.setState}) {
    // Refreshes the GlobalKeys of the bell tutorial system.
    bellTutorialSystem.refreshKeys();
  }

  final String bell;
  final StateSetter setState;

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
    bellTutorialSystem.set({
      'tutorial_settings_bell': bellTutorials['tutorial_settings_bell']!,
      'tutorial_settings_bell_help':
          bellTutorials['tutorial_settings_bell_help']!,
    });
    bellTutorialSystem.refreshKeys();
  }

  static void saveBells() {
    // Saves the schedule vanity data to local storage
    localStorage.setItem("scheduleSettings", json.encode(Schedule.bellVanity));
    // Confirms that the user's progress is marked as "logged"
    localStorage.setItem("state", "logged");
    // Refreshed HomePage stream
    StreamSignal.updateStream(streamController: ScheduleDisplay.scheduleStream);
  }

  // Method which ensures no bell variables are undefined
  static void defineBell(String bell, {bool alternate = false}) {
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
      Schedule.bellVanity[bell]!['name'] ??= '$bell Bell'
          .replaceAll('HR Bell', 'Homeroom')
          .replaceAll('FLEX Bell', 'FLEX');
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
    ScheduleSettings.names[bell] ??=
        TextEditingController(text: reference['name']);
    ScheduleSettings.teachers[bell] ??=
        TextEditingController(text: reference['teacher']);
    ScheduleSettings.locations[bell] ??=
        TextEditingController(text: reference['location']);
  }

  @override
  State<BellSettings> createState() => _BellSettingsState();
}

class _BellSettingsState extends State<BellSettings> {
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

  // FocusNodes used for bell customization UI elements; <Bell, FocusNode>
  final FocusNode emojiFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();
  final FocusNode teacherFocus = FocusNode();
  final FocusNode locationFocus = FocusNode();

  // Allows remote calling of FlipCard
  final GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  // bool for if day picker is displayed for alternate side
  bool dayPicker = true;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double width = min(mediaQuery.size.width, 500);

    // Determines the hint text to be displayed at the top of the popup
    String hint = widget.bell;
    if (hint.length == 1) {
      hint = '$hint Bell';
    } else if (hint == 'HR') {
      hint = 'Homeroom';
    }

    return KeyboardAvoider(
        autoScroll: true,
        // Aligns the popup at the center of the page
        child: Align(
            alignment: Alignment.center,
            // Popup wrapped in Showcase View Widget
            child: ShowCaseWidget(onFinish: () {
              BellSettings.bellTutorialSystem.finish();
            }, builder: (context) {
              // Schedules the showcase to start after the Widget is built
              if (!BellSettings.bellTutorialSystem.finished) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  BellSettings.bellTutorialSystem.showTutorials(context);
                });
              }
              // Returns the popup wrapped in a Showcase
              return BellSettings.bellTutorialSystem.showcase(
                  context: context,
                  tutorial: 'tutorial_settings_bell',
                  onTap: () async {
                    setState(() {
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
                                          BellSettings.bellTutorialSystem
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
                                                    Icons.help_outline_rounded,
                                                    size: 30,
                                                    color:
                                                        colorScheme.onSurface)),
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
                                          BellSettings.bellTutorialSystem
                                              .showcase(
                                            context: context,
                                            tutorial:
                                                "tutorial_settings_bell_alternate",
                                            circular: true,
                                            child: Schedule
                                                    .sampleDays['All Meet']!
                                                    .contains(widget.bell)
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
                                                    icon: Icon(Icons.autorenew,
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
                                      context, widget.bell, false),
                                  // Submit Button wrapped in Showcase w/ padding
                                  Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: BellSettings.bellTutorialSystem
                                          .showcase(
                                              context: context,
                                              tutorial:
                                                  'tutorial_settings_bell_complete',
                                              child: StyledButton(
                                                icon: Icons.check,
                                                backgroundColor: Colors.green,
                                                width:
                                                    mediaQuery.size.width * .6,
                                                onTap: () {
                                                  // Resets state of settings page to include new values
                                                  widget.setState(() {
                                                    // Sets global bellVanity values to match selected ones
                                                    _saveBell(widget.bell);
                                                    BellSettings.saveBells();
                                                  });
                                                  // Pops popup, returning to settings page
                                                  Navigator.pop(context);
                                                },
                                              ))),
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
                                          BellSettings.bellTutorialSystem
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
                                                    Icons.help_outline_rounded,
                                                    size: 30,
                                                    color:
                                                        colorScheme.onSurface)),
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
                                          BellSettings.bellTutorialSystem
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
                                                    color:
                                                        colorScheme.onSurface)),
                                          )
                                        ],
                                      )),
                                  BellSettings.bellTutorialSystem.showcase(
                                      context: context,
                                      tutorial:
                                          "tutorial_settings_bell_alt_vanity",
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        constraints: BoxConstraints(
                                            maxHeight: dayPicker
                                                ? 50
                                                : mediaQuery.size.height * .75),
                                        child: SingleChildScrollView(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    dayPicker = !dayPicker;
                                                  });
                                                },
                                                child: Container(
                                                  height: 50,
                                                  alignment: Alignment.center,
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
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
                                                                  fontSize: 25,
                                                                  color: colorScheme
                                                                      .onSurface,
                                                                  fontFamily:
                                                                      "Georama",
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600))
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
                                                  context, widget.bell, true),
                                            ],
                                          ),
                                        ),
                                      )),
                                  Divider(
                                      color: colorScheme.onSurface, height: 8),
                                  BellSettings.bellTutorialSystem.showcase(
                                      context: context,
                                      tutorial:
                                          "tutorial_settings_bell_alt_day",
                                      onTap: () async {
                                        setState(() {
                                          dayPicker = false;
                                        });
                                        await Future.delayed(
                                            const Duration(milliseconds: 150));
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        constraints: BoxConstraints(
                                            maxHeight: dayPicker
                                                ? mediaQuery.size.height * .75
                                                : 50),
                                        child: SingleChildScrollView(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    dayPicker = !dayPicker;
                                                  });
                                                },
                                                child: Container(
                                                  height: 50,
                                                  alignment: Alignment.center,
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 8),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text("Program",
                                                              style: TextStyle(
                                                                  fontSize: 25,
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
                                              _buildDaySelector(
                                                  context, widget.bell)
                                            ],
                                          ),
                                        ),
                                      )),
                                ],
                              )))));
            })));
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

  // Restarts the tutorial of the bell configuration menu
  void _startBellTutorial(BuildContext context, bool alt,
      {bool storeCompletion = false}) {
    // Clears tutorialSystem of tutorial values and Re-adds all tutorials to tutorialSystem
    if (alt) {
      BellSettings.bellTutorialSystem.set(BellSettings.bellAltTutorials);
    } else {
      BellSettings.bellTutorialSystem.set(BellSettings.bellTutorials);
    }
    // Starts tutorial
    BellSettings.bellTutorialSystem
        .showTutorials(context, storeCompletion: storeCompletion);
  }

  // Builds the base vanity settings Widget
  Widget _buildBellSettings(BuildContext context, String bell, bool alternate) {
    BellSettings.defineBell(bell, alternate: alternate);

    final String tutorialKey = alternate ? "_alt" : '';
    bell = "$bell$tutorialKey";

    return Column(
      children: [
        // Color Wheel w/ Emoji Picker wrapped in Showcase
        BellSettings.bellTutorialSystem.showcase(
            context: context,
            tutorial: 'tutorial_settings_bell${tutorialKey}_color_wheel',
            child: _buildColorWheel(context, bell, alternate)),
        // Color Scroll wrapped in Showcase
        BellSettings.bellTutorialSystem.showcase(
          context: context,
          tutorial: 'tutorial_settings_bell${tutorialKey}_color_row',
          child: _buildColorSelection(context, bell, hexColorOptions),
        ),
        // Spacing of 16px
        const SizedBox(height: 16),
        // Column of text forms wrapped in Showcase
        BellSettings.bellTutorialSystem.showcase(
            context: context,
            tutorial: 'tutorial_settings_bell${tutorialKey}_info',
            targetPadding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Name TextField
                _buildTextForm(
                    context, ScheduleSettings.names[bell]!, "Bell Name",
                    focusNode: nameFocus),
                // Teacher TextField
                _buildTextForm(
                    context, ScheduleSettings.teachers[bell]!, "Teacher",
                    focusNode: teacherFocus),
                // Location TextField
                _buildTextForm(
                    context, ScheduleSettings.locations[bell]!, "Location",
                    focusNode: locationFocus),
              ],
            )),
      ],
    );
  }

  // Builds the Color Wheel displayed in the bell configuration menu
  Widget _buildColorWheel(BuildContext context, String bell, bool alternate) {
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
              setState(() {
                // Stores the selected color at 100% saturation and value (ensures color is actually displayed on wheel)
                ScheduleSettings.colors[bell] =
                    value.withValue(1).withSaturation(1);
              });
            },
          ),
          // Emoji Picker wrapped in Showcase
          BellSettings.bellTutorialSystem.showcase(
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
                    focusNode: emojiFocus,
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
                      emojiFocus.unfocus();
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
                      setState(() {
                        ScheduleSettings.emojis[bell]!.text = text;
                      });
                    },
                  ).intrinsicFit()))
        ],
      ),
    );
  }

  // Builds the Color Scroll displayed in the bell configuration menu
  Widget _buildColorSelection(
      BuildContext context, String bell, List<String> hexColors) {
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
                        setState(() {
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

  Widget _buildDaySelector(BuildContext context, String bell) {
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
                    setState(() {
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
}
