import 'dart:convert';

import 'package:color_hex/color_hex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:xschedule/display/home_page.dart';
import 'package:xschedule/global_variables/stream_signal.dart';
import 'package:xschedule/schedule/schedule_display/schedule_display.dart';

import '../global_variables/gloabl_methods.dart';

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

  @override
  State<ScheduleSettings> createState() => _ScheduleSettingsState();
}

class _ScheduleSettingsState extends State<ScheduleSettings> {
  Color pickerColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: colorScheme.primaryContainer,
      //Top Bar
      appBar: AppBar(
        leading: widget.backArrow ? null : Container(),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        title: FittedBox(
          fit: BoxFit.contain,
          child: Text(
            "Customize Bell Appearance",
            style: TextStyle(
                //Custom font Goerama
                fontFamily: "Georama",
                fontSize: 25,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface),
          ),
        ),
      ),
      //Extends the body behind the bottom bar
      extendBody: true,
      //Bottom bar; the done button
      bottomNavigationBar: Container(
        height: 40,
        margin: EdgeInsets.symmetric(
            vertical: 15, horizontal: mediaQuery.size.width * .35),
        child: ElevatedButton(
            onPressed: () {
              localStorage.setItem(
                  "scheduleSettings", json.encode(ScheduleSettings.bellInfo));
              localStorage.setItem("state", "logged");
              Navigator.pop(context);
              StreamSignal.updateStream(
                  streamController: HomePage.homePageStream);
              StreamSignal.updateStream(
                  streamController: ScheduleDisplay.scheduleStream);
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
            child: Container(
              alignment: Alignment.center,
              width: mediaQuery.size.width * 3 / 5,
              child: Icon(
                Icons.check,
                color: colorScheme.onPrimary,
              ),
            )),
      ),
      //Body is a scroll view of seperate tiles
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            _buildBellTile(context, 'A'),
            _buildBellTile(context, 'B'),
            _buildBellTile(context, 'C'),
            _buildBellTile(context, 'D'),
            _buildBellTile(context, 'E'),
            _buildBellTile(context, 'F'),
            _buildBellTile(context, 'G'),
            _buildBellTile(context, 'H'),
            //So that with the bottom bar, you can still scorll to view last item
            const SizedBox(height: 55)
          ],
        ),
      ),
    );
  }

  //Ensures no bell values are null
  void _defineBells(String bell) {
    // ??= means if null, then define as this value
    ScheduleSettings.bellInfo[bell] ??= {};
    ScheduleSettings.bellInfo[bell]!['color'] ??= "#006aff";
    ScheduleSettings.colors[bell] ??= HSVColor.fromColor(
        hexToColor(ScheduleSettings.bellInfo[bell]!['color']!));

    ScheduleSettings.bellInfo[bell]!['emoji'] ??= bell;
    ScheduleSettings.emojis[bell] ??=
        TextEditingController(text: ScheduleSettings.bellInfo[bell]!['emoji']);

    ScheduleSettings.bellInfo[bell]!['name'] ??= '$bell Bell';
    ScheduleSettings.names[bell] ??=
        TextEditingController(text: ScheduleSettings.bellInfo[bell]!['name']);

    ScheduleSettings.bellInfo[bell]!['teacher'] ??= '';
    ScheduleSettings.teachers[bell] ??= TextEditingController(
        text: ScheduleSettings.bellInfo[bell]!['teacher']);

    ScheduleSettings.bellInfo[bell]!['location'] ??= '';
    ScheduleSettings.locations[bell] ??= TextEditingController(
        text: ScheduleSettings.bellInfo[bell]!['location']);
  }

  //Builds the tiles displayed in the scroll view
  Widget _buildBellTile(BuildContext context, String bell) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    //Ensures no null values
    _defineBells(bell);
    //For brevity purposes
    Map settings = ScheduleSettings.bellInfo[bell];
    //Tile very similar to those displayed in the schedule
    return Container(
      margin: const EdgeInsets.all(10),
      width: mediaQuery.size.width * .95,
      height: 100,
      child: GestureDetector(
        onTap: () {
          GlobalMethods.showPopup(context, _buildBellSettings(bell));
        },
        child: Card(
          color: colorScheme.surface,
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
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Displays class name, bell name, or nothing (if null)
                            Text(
                              settings['name']!,
                              style: TextStyle(
                                  height: 0.9,
                                  fontSize: 25,
                                  overflow: TextOverflow.ellipsis,
                                  //bold
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface),
                            ),
                            Text(
                              settings['teacher']!,
                              style: TextStyle(
                                  fontSize: 18,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface),
                            ),
                            Text(
                              settings['location']!,
                              style: TextStyle(
                                  fontSize: 18,
                                  overflow: TextOverflow.ellipsis,
                                  fontWeight: FontWeight.w500,
                                  color: colorScheme.onSurface),
                            ),
                          ],
                        ),
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

    //Radius of colorWheel; also used in other measurements
    double size = mediaQuery.size.width * 5 / 6;
    //Allows for "setState" to be called, and only effect this popup
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setLocalState) {
      //Aligns card in center
      return Align(
        alignment: Alignment.center,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      //Solid Color circle
                      CircleAvatar(
                        backgroundColor:
                            //Color in variable type "HSVColor"; needs to be converted
                            ScheduleSettings.colors[bell]!.toColor(),
                        radius: 95,
                      ),
                      WheelPicker(
                        showPalette: false,
                        color: ScheduleSettings.colors[bell]!,
                        onChanged: (HSVColor value) {
                          setLocalState(() {
                            ScheduleSettings.colors[bell] = value;
                          });
                        },
                      ),
                      //Emoji Picker
                      Container(
                        width: 125,
                        height: 125,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 10),
                        child: IntrinsicWidth(
                          child: TextField(
                            controller: ScheduleSettings.emojis[bell],
                            decoration: const InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              // Removes the underline
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.0), // Optional: adjust padding
                            ),
                            style: TextStyle(
                                fontSize: 120, // Large font size
                                color: colorScheme.onSurface),
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
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                //Column of text forms
                _buildTextForm(
                    context, ScheduleSettings.names[bell]!, "Bell Name"),
                _buildTextForm(
                    context, ScheduleSettings.teachers[bell]!, "Teacher"),
                _buildTextForm(
                    context, ScheduleSettings.locations[bell]!, "Location"),
                //Submits
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        //Sets global value to correspond to new variables
                        ScheduleSettings.bellInfo[bell] = {
                          'name': ScheduleSettings.names[bell]!.text,
                          'teacher': ScheduleSettings.teachers[bell]!.text,
                          'location': ScheduleSettings.locations[bell]!.text,
                          'emoji': ScheduleSettings.emojis[bell]!.text,
                          'color': colorToHex(
                                  ScheduleSettings.colors[bell]!.toColor())
                              .hex
                        };
                      });
                      //Pops popup
                      Navigator.pop(context);
                    },
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 3 / 5,
                      child: Icon(
                        Icons.check,
                        color: colorScheme.onPrimary,
                      ),
                    )),
              ],
            ),
          ),
        ),
      );
    });
  }

  //The text form displayed in the settings page
  Widget _buildTextForm(
      BuildContext context, TextEditingController controller, String display) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    double size = mediaQuery.size.width * 5 / 6;
    return Container(
      margin: const EdgeInsets.only(top: 5),
      height: size * 2 / 15,
      width: size,
      child: TextFormField(
        keyboardType: TextInputType.text,
        controller: controller,
        maxLength: 50,
        maxLines: 1,
        decoration: InputDecoration(
          labelText: display,
          isDense: true,
          counterText: '',
          labelStyle: TextStyle(
              color: colorScheme.onSurface,
              overflow: TextOverflow.ellipsis),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: colorScheme.shadow, width: 1),
          ),
        ),
      ),
    );
  }
}
