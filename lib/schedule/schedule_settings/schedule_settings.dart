import 'dart:convert';
import 'dart:io';

import 'package:color_hex/color_hex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:keyboard_avoider/keyboard_avoider.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shimmer/shimmer.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:xschedule/display/home_page.dart';
import 'package:xschedule/global_variables/dynamic_content/stream_signal.dart';
import 'package:xschedule/global_variables/dynamic_content/tutorial_system.dart';
import 'package:xschedule/global_variables/static_content/global_widgets.dart';
import 'package:xschedule/main.dart';
import 'package:xschedule/schedule/schedule_display/schedule_display.dart';

import '../../global_variables/dynamic_content/backend/open_ai.dart';
import '../../global_variables/static_content/global_methods.dart';

/*
Schedule Settings:
Class created for two purposes
1) Manages local schedule settings values
2) Widget which allows user to manage settings
 */

class ScheduleSettings extends StatefulWidget {
  const ScheduleSettings({super.key, this.backArrow = false});

  final bool backArrow;

  //Map of Maps for all bell data; decoded from local storage json
  static Map bellInfo =
      json.decode(localStorage.getItem("scheduleSettings") ?? '{}');

  //Temporary values for editing
  static Map<String, HSVColor> colors = {};
  static Map<String, TextEditingController> emojis = {};
  static Map<String, TextEditingController> names = {};
  static Map<String, TextEditingController> teachers = {};
  static Map<String, TextEditingController> locations = {};


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
  static final TutorialSystem bellTutorialSystem = TutorialSystem({
    'tutorial_settings_bell': bellTutorials['tutorial_settings_bell']!,
    'tutorial_settings_bell_help':
    bellTutorials['tutorial_settings_bell_help']!,
  });

  @override
  State<ScheduleSettings> createState() => _ScheduleSettingsState();
}

class _ScheduleSettingsState extends State<ScheduleSettings> {
  final Color pickerColor = Colors.blue;

  final Map<String, FocusNode> emojiFocus = {};
  final Map<String, FocusNode> nameFocus = {};
  final Map<String, FocusNode> teacherFocus = {};
  final Map<String, FocusNode> locationFocus = {};

  File? imageFile;

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

    ScheduleSettings.tutorialSystem.refreshKeys();
    ScheduleSettings.tutorialSystem.removeFinished();

    return ShowCaseWidget(builder: (context) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Future.delayed(const Duration(milliseconds: 250));
        if (!ScheduleSettings.tutorialSystem.finished && context.mounted) {
          ScheduleSettings.tutorialSystem.showTutorials(context);
          ScheduleSettings.tutorialSystem.finish();
        }
      });

      return Scaffold(
          backgroundColor: colorScheme.primaryContainer,
          //Top Bar
          appBar: AppBar(
            leading: widget.backArrow ? null : Container(),
            centerTitle: true,
            backgroundColor: colorScheme.surface,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: ScheduleSettings.tutorialSystem.showcase(
                    context: context,
                    circular: true,
                    tutorial: 'tutorial_settings_ai',
                    child: IconButton(
                      icon: Icon(
                        Icons.camera_outlined,
                        size: 35,
                        color: colorScheme.onSurface,
                      ),
                      onPressed: () {
                        GlobalMethods.showPopup(
                            context, _buildPicPopup(context));
                      },
                    )),
              )
            ],
            title: ScheduleSettings.tutorialSystem.showcase(
              context: context,
              tutorial: 'tutorial_settings',
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Customize Bell Appearance",
                    style: TextStyle(
                        //Custom font Goerama
                        fontFamily: "Georama",
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface),
                  )),
            ),
          ),
          //Extends the body behind the bottom bar
          extendBody: true,
          //Bottom bar; the done button
          bottomNavigationBar: Container(
            height: 40,
            margin: EdgeInsets.symmetric(
                vertical: 20, horizontal: mediaQuery.size.width * .325),
            child: ScheduleSettings.tutorialSystem.showcase(
                context: context,
                tutorial: 'tutorial_settings_complete',
                child: ElevatedButton(
                    onPressed: () {
                      localStorage.setItem("scheduleSettings",
                          json.encode(ScheduleSettings.bellInfo));
                      localStorage.setItem("state", "logged");
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => HomePage()),
                          (_) => false);
                      StreamSignal.updateStream(
                          streamController: ScheduleDisplay.scheduleStream);
                    },
                    style: ElevatedButton.styleFrom(
                        overlayColor: colorScheme.onPrimary,
                        backgroundColor: colorScheme.primary),
                    child: Container(
                      alignment: Alignment.center,
                      width: mediaQuery.size.width * 3 / 5,
                      child: Icon(
                        Icons.check,
                        color: colorScheme.onPrimary,
                      ),
                    ))),
          ),
          //Body is a scroll view of seperate tiles
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                ScheduleSettings.tutorialSystem.showcase(
                    context: context,
                    tutorial: 'tutorial_settings_button',
                    child: _buildBellTile(context, 'A')),
                _buildBellTile(context, 'B'),
                _buildBellTile(context, 'C'),
                _buildBellTile(context, 'D'),
                _buildBellTile(context, 'E'),
                _buildBellTile(context, 'F'),
                _buildBellTile(context, 'G'),
                _buildBellTile(context, 'H'),
                _buildBellTile(context, 'HR'),
                //So that with the bottom bar, you can still scorll to view last item
                const SizedBox(height: 60)
              ],
            ),
          ));
    });
  }

  //Ensures no bell values are null
  void _defineBell(final String bell) {
    // ??= means if null, then define as this value
    ScheduleSettings.bellInfo[bell] ??= {};
    ScheduleSettings.bellInfo[bell]!['color'] ??= "#006aff";
    ScheduleSettings.colors[bell] ??= HSVColor.fromColor(
        hexToColor(ScheduleSettings.bellInfo[bell]!['color']!));

    ScheduleSettings.bellInfo[bell]!['emoji'] ??= bell.replaceAll('HR', '📚');
    ScheduleSettings.emojis[bell] ??= TextEditingController(
        text: ScheduleSettings.bellInfo[bell]!['emoji'].replaceAll('HR', '📚'));
    emojiFocus[bell] ??= FocusNode();

    ScheduleSettings.bellInfo[bell]!['name'] ??=
        '$bell Bell'.replaceAll('HR Bell', 'Homeroom');
    ScheduleSettings.names[bell] ??=
        TextEditingController(text: ScheduleSettings.bellInfo[bell]!['name']);
    nameFocus[bell] ??= FocusNode();

    ScheduleSettings.bellInfo[bell]!['teacher'] ??= '';
    ScheduleSettings.teachers[bell] ??= TextEditingController(
        text: ScheduleSettings.bellInfo[bell]!['teacher']);
    teacherFocus[bell] ??= FocusNode();

    ScheduleSettings.bellInfo[bell]!['location'] ??= '';
    ScheduleSettings.locations[bell] ??= TextEditingController(
        text: ScheduleSettings.bellInfo[bell]!['location']);
    locationFocus[bell] ??= FocusNode();
  }

  //Builds the tiles displayed in the scroll view
  Widget _buildBellTile(BuildContext context, String bell) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    //Ensures no null values
    _defineBell(bell);
    //For brevity purposes
    Map settings = ScheduleSettings.bellInfo[bell];
    //Tile very similar to those displayed in the schedule
    return Container(
      margin: const EdgeInsets.all(10),
      width: mediaQuery.size.width * .95,
      height: 100,
      child: Card(
        color: colorScheme.surface,
        child: InkWell(
          highlightColor: colorScheme.onPrimary,
          onTap: () {
            GlobalMethods.showPopup(context, _buildBellSettings(bell));
          },
          child: Row(
            children: [
              //Left color nib w/ rounded edges
              Container(
                decoration: BoxDecoration(
                  //rounds the left edges to match the Card
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(10)),
                  color: hexToColor(settings['color']!),
                ),
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                //Column w/ two rows
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    //Stacks the emoji on top of a shadowed circle
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: colorScheme.surfaceContainer,
                          radius: 35,
                        ),
                        Text(
                          settings['emoji'],
                          style: TextStyle(
                              fontSize: 40, color: colorScheme.onSurface),
                        )
                      ],
                    ),
                    //Title Container
                    Container(
                      width: mediaQuery.size.width * .95 - 180,
                      height: 70,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 5),
                      //FittedBox to ensure text doesn't overflow card
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //Displays class name, bell name, or nothing (if null)
                          Expanded(
                              child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              settings['name']!,
                              style: TextStyle(
                                  height: 1,
                                  fontSize: 25,
                                  overflow: TextOverflow.ellipsis,
                                  //bold
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface),
                            ),
                          )),
                          Expanded(
                              child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              settings['teacher']!,
                              style: TextStyle(
                                  fontSize: 18,
                                  height: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface),
                            ),
                          )),
                          Expanded(
                              child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              settings['location']!,
                              style: TextStyle(
                                  fontSize: 18,
                                  height: 1,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface),
                            ),
                          )),
                        ],
                      ),
                    ),
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

  //Builds the setting popup
  Widget _buildBellSettings(String bell) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    String hint = bell;
    if (hint.length == 1) {
      hint = '$hint Bell';
    } else if (hint == 'HR') {
      hint = 'Homeroom';
    }

    ScheduleSettings.bellTutorialSystem.refreshKeys();

    //Allows for "setState" to be called, and only effect this popup
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setLocalState) {
      //Aligns card in center
      return KeyboardAvoider(
          autoScroll: true,
          child: Align(
              alignment: Alignment.center,
              child: ShowCaseWidget(onFinish: () {
                ScheduleSettings.bellTutorialSystem.finish();
              }, builder: (context) {
                if (!ScheduleSettings.bellTutorialSystem.finished) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScheduleSettings.bellTutorialSystem.showTutorials(context);
                  });
                }
                return ScheduleSettings.bellTutorialSystem.showcase(
                  context: context,
                  tutorial: 'tutorial_settings_bell',
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: mediaQuery.size.width * .9,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ScheduleSettings.bellTutorialSystem.showcase(
                                    context: context,
                                    tutorial: "tutorial_settings_bell_help",
                                    circular: true,
                                    child: IconButton(
                                        onPressed: () {
                                          ScheduleSettings.bellTutorialSystem.tutorials.clear();
                                          ScheduleSettings.bellTutorialSystem.tutorials
                                              .addAll(ScheduleSettings.bellTutorials);
                                          ScheduleSettings.bellTutorialSystem.showTutorials(
                                              context,
                                              storeCompletion: false);
                                        },
                                        icon: Icon(Icons.help_outline_rounded,
                                            size: 30,
                                            color: colorScheme.onSurface)),
                                  ),
                                  Text(hint,
                                      style: TextStyle(
                                          fontSize: 25,
                                          height: 1,
                                          fontFamily: 'Exo2',
                                          color: colorScheme.onSurface
                                              .withAlpha(128))),
                                  ScheduleSettings.bellTutorialSystem.showcase(
                                    context: context,
                                    tutorial:
                                        "tutorial_settings_bell_alternate",
                                    circular: true,
                                    child: IconButton(
                                        onPressed: () {},
                                        icon: Icon(Icons.tune,
                                            size: 30,
                                            color: colorScheme.onSurface)),
                                  )
                                ],
                              )),
                          ScheduleSettings.bellTutorialSystem.showcase(
                              context: context,
                              tutorial: 'tutorial_settings_bell_color_wheel',
                              child: SizedBox(
                                width: 200,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    //Solid Color circle
                                    CircleAvatar(
                                      backgroundColor:
                                          //Color in variable type "HSVColor"; needs to be converted
                                          ScheduleSettings.colors[bell]!
                                              .toColor(),
                                      radius: 95,
                                    ),
                                    WheelPicker(
                                      showPalette: false,
                                      color: ScheduleSettings.colors[bell]!,
                                      onChanged: (HSVColor value) {
                                        setLocalState(() {
                                          ScheduleSettings.colors[bell] = value
                                              .withValue(1)
                                              .withSaturation(1);
                                        });
                                      },
                                    ),
                                    ScheduleSettings.bellTutorialSystem.showcase(
                                        context: context,
                                        tutorial: 'tutorial_settings_bell_icon',
                                        circular: true,
                                        child: Container(
                                          width: 125,
                                          height: 125,
                                          alignment: Alignment.center,
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          child: IntrinsicWidth(
                                            child: TextField(
                                              controller:
                                                  ScheduleSettings.emojis[bell],
                                              enableInteractiveSelection: false,
                                              focusNode: emojiFocus[bell],
                                              showCursor: false,
                                              decoration: const InputDecoration(
                                                isDense: true,
                                                border: InputBorder.none,
                                                // Removes the underline
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        vertical:
                                                            10.0), // Optional: adjust padding
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
                                                if (text.characters.length >
                                                    1) {
                                                  text = text.characters.last;
                                                }
                                                setLocalState(() {
                                                  ScheduleSettings.emojis[bell]!
                                                      .text = text;
                                                });
                                              },
                                            ),
                                          ),
                                        ))
                                  ],
                                ),
                              )),
                          ScheduleSettings.bellTutorialSystem.showcase(
                            context: context,
                            tutorial: 'tutorial_settings_bell_color_row',
                            child: _buildColorSelection(
                                context, bell, setLocalState, hexColorOptions),
                          ),
                          const SizedBox(height: 16),
                          //Column of text forms
                          ScheduleSettings.bellTutorialSystem.showcase(
                              context: context,
                              tutorial: 'tutorial_settings_bell_info',
                              targetPadding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  _buildTextForm(
                                      context,
                                      ScheduleSettings.names[bell]!,
                                      "Bell Name",
                                      focusNode: nameFocus[bell]),
                                  _buildTextForm(
                                      context,
                                      ScheduleSettings.teachers[bell]!,
                                      "Teacher",
                                      focusNode: teacherFocus[bell]),
                                  _buildTextForm(
                                      context,
                                      ScheduleSettings.locations[bell]!,
                                      "Location",
                                      focusNode: locationFocus[bell]),
                                ],
                              )),
                          //Submits
                          Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: ScheduleSettings.bellTutorialSystem.showcase(
                                  context: context,
                                  tutorial: 'tutorial_settings_bell_complete',
                                  child: ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          //Sets global value to correspond to new variables
                                          ScheduleSettings.bellInfo[bell] = {
                                            'name': ScheduleSettings
                                                .names[bell]!.text,
                                            'teacher': ScheduleSettings
                                                .teachers[bell]!.text,
                                            'location': ScheduleSettings
                                                .locations[bell]!.text,
                                            'emoji': ScheduleSettings
                                                .emojis[bell]!.text,
                                            'color': colorToHex(ScheduleSettings
                                                    .colors[bell]!
                                                    .toColor())
                                                .hex
                                          };
                                        });
                                        //Pops popup
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          overlayColor: colorScheme.onPrimary,
                                          backgroundColor: Colors.green),
                                      child: Container(
                                        alignment: Alignment.center,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                3 /
                                                5,
                                        child: Icon(
                                          Icons.check,
                                          color: colorScheme.onPrimary,
                                        ),
                                      )))),
                        ],
                      ),
                    ),
                  ),
                );
              })));
    });
  }

  Widget _buildColorSelection(BuildContext context, String bell,
      StateSetter setState, List<String> hexColors) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final ScrollController controller = ScrollController();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
            onPressed: () {
              controller.animateTo(controller.offset - 46 * 3,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: colorScheme.onSurface.withAlpha(128),
              size: 12,
            )),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          width: mediaQuery.size.width * .7,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                controller: controller,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(hexColors.length, (i) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          ScheduleSettings.colors[bell] =
                              HSVColor.fromColor(hexToColor(hexColors[i]));
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                            color: hexToColor(hexColors[i]),
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
              IgnorePointer(
                  child: Container(
                      width: 12,
                      height: 46,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                            colorScheme.surface,
                            colorScheme.surface.withAlpha(0),
                          ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight)))),
              Align(
                alignment: Alignment.centerRight,
                child: IgnorePointer(
                    child: Container(
                        width: 12,
                        height: 46,
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
        IconButton(
            onPressed: () {
              controller.animateTo(controller.offset + 46 * 3,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut);
            },
            icon: Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.onSurface.withAlpha(128),
              size: 12,
            )),
      ],
    );
  }

  //The text form displayed in the settings page
  Widget _buildTextForm(
      BuildContext context, TextEditingController controller, String display,
      {FocusNode? focusNode}) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    double size = mediaQuery.size.width * 5 / 6;
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

  Future<void> selectImage(StateSetter setState) async {
    FilePickerResult? pickedImage = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);
    if (pickedImage != null) {
      if (pickedImage.xFiles.isNotEmpty) {
        final File pickedFile = File(pickedImage.xFiles.first.path);
        if (await pickedFile.exists() && context.mounted) {
          setState(() {
            imageFile = pickedFile;
          });
        }
      }
    }
  }

  Widget _buildPicPopup(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double width = mediaQuery.size.width;

    bool uploaded = false;
    bool isLoading = false;

    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setLocalState) {
      uploaded = imageFile != null;
      //Aligns card in center
      return GlobalWidgets.popup(
          context,
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 5),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "Schedule from Image",
                      style: TextStyle(
                          fontFamily: "Exo2",
                          fontSize: 35,
                          fontWeight: FontWeight.w600),
                    ),
                  )),
              GestureDetector(
                onTap: () async {
                  if (!isLoading) {
                    await selectImage(setLocalState);
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                        width: width * 3 / 5,
                        height: width * 3 / 5,
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: colorScheme.onSurface.withAlpha(128),
                                width: 5)),
                        padding: const EdgeInsets.all(2.5),
                        margin: const EdgeInsets.all(15),
                        alignment: Alignment.center,
                        child: uploaded
                            ? SizedBox(
                                width: width * 3 / 5,
                                height: width * 3 / 5,
                                child: ClipRect(
                                    child: FittedBox(
                                  fit: BoxFit.cover,
                                  child: Image.file(imageFile!),
                                )),
                              )
                            : Icon(
                                Icons.photo_outlined,
                                size: width * 1 / 2,
                                color: colorScheme.onSecondary,
                              )),
                    if (uploaded && !isLoading)
                      Opacity(
                        opacity: 0.1,
                        child: Icon(
                          Icons.photo_outlined,
                          size: width * 1 / 2,
                          color: colorScheme.onSurface,
                        ),
                      ),
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
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: EdgeInsets.symmetric(horizontal: width * .08),
                width: width * 4 / 5,
                child: ElevatedButton(
                    onPressed: () async {
                      if (!uploaded) {
                        await selectImage(setLocalState);
                      } else if (!isLoading) {
                        setLocalState(() {
                          isLoading = true;
                        });
                        if (await imageFile!.exists()) {
                          final Map<String, dynamic> aiScan =
                              await OpenAI.scanSchedule(
                                  imageFile!.path);
                          if (context.mounted) {
                            if (aiScan['error'] != null) {
                              context.showSnackBar(
                                  'Request Failed: Error Code ${aiScan['error']}',
                                  isError: true);
                              setLocalState(() {
                                isLoading = false;
                              });
                              return;
                            }
                            setState(() {
                              ScheduleSettings.bellInfo = aiScan;

                              ScheduleSettings.names.clear();
                              ScheduleSettings.teachers.clear();
                              ScheduleSettings.locations.clear();
                              ScheduleSettings.colors.clear();
                              ScheduleSettings.emojis.clear();

                              for (String bell
                                  in ScheduleSettings.bellInfo.keys) {
                                _defineBell(bell);
                              }
                            });
                            //Pops popup
                            Navigator.pop(context);
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        overlayColor: colorScheme.onPrimary,
                        backgroundColor: uploaded
                            ? colorScheme.primary
                            : colorScheme.secondary,
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15)))),
                    child: Container(
                        alignment: Alignment.center,
                        height: 37.5,
                        child: Shimmer.fromColors(
                            baseColor: colorScheme.onPrimary,
                            highlightColor: colorScheme.onSecondary,
                            enabled: isLoading,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  uploaded
                                      ? Icons.document_scanner_outlined
                                      : Icons.add_photo_alternate_outlined,
                                  size: 25,
                                  color: colorScheme.onPrimary,
                                ),
                                Text(
                                  uploaded ? "  Scan Image" : "  Upload Image",
                                  style: TextStyle(
                                      fontSize: 25, fontFamily: "Georama"),
                                )
                              ],
                            )))),
              )
            ],
          ));
    });
  }
}
