import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:xschedule/global/static_content/extensions/color_extension.dart';

import '../../schedule.dart';
import '../../../global/dynamic_content/stream_signal.dart';
import '../../schedule_display/schedule_display.dart';

class BellSettings {
  // Maps of temporary values used in editing bell vanity (<Bell, Value>)
  static final Map<String, HSVColor> colors = {};
  static final Map<String, TextEditingController> emojis = {};
  static final Map<String, TextEditingController> names = {};
  static final Map<String, TextEditingController> teachers = {};
  static final Map<String, TextEditingController> locations = {};
  static final Map<String, List<String>> altDays = {};

  /// Clears all temporary bell values from settings
  static void clearSettings() {
    colors.clear();
    emojis.clear();
    names.clear();
    teachers.clear();
    locations.clear();
    altDays.clear();
  }

  static void saveBells() {
    // Saves the schedule vanity data to local storage
    localStorage.setItem("bellVanity", json.encode(Schedule.bellVanity));
    // Confirms that the user's progress is marked as "logged"
    localStorage.setItem("state", "logged");
    // Refreshed HomePage stream
    ScheduleDisplay.scheduleStream.updateStream();
  }

  static void writeBell(String bell, Map<String, dynamic> bellVanity) {
    defineBell(bell);
    if (bellVanity['color'] != null) {
      colors[bell] =
          HSVColor.fromColor(ColorExtension.fromHex(bellVanity['color']));
    }
    if(bellVanity['emoji'] != null) {
      emojis[bell]!.text = bellVanity['emoji'];
    }
    if(bellVanity['name'] != null) {
      names[bell]!.text = bellVanity['name'];
    }
    if(bellVanity['teacher'] != null) {
      teachers[bell]!.text = bellVanity['teacher'];
    }
    if(bellVanity['location'] != null) {
      locations[bell]!.text = bellVanity['location'];
    }
    if(bellVanity['alt_days'] != null) {
      altDays[bell] = bellVanity['alt_days'].cast<String>();
    }
    if(bellVanity['alt'] != null){
      String altBell = "${bell}_alt";
      Map<String, dynamic> altBellVanity = bellVanity['alt'];
      defineBell(bell, alternate: true);


      if (altBellVanity['color'] != null) {
        colors[altBell] =
            HSVColor.fromColor(ColorExtension.fromHex(altBellVanity['color']));
      }
      if(altBellVanity['emoji'] != null) {
        emojis[altBell]!.text = altBellVanity['emoji'];
      }
      if(altBellVanity['name'] != null) {
        names[altBell]!.text = altBellVanity['name'];
      }
      if(altBellVanity['teacher'] != null) {
        teachers[altBell]!.text = altBellVanity['teacher'];
      }
      if(altBellVanity['location'] != null) {
        locations[altBell]!.text = altBellVanity['location'];
      }
    }
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

      altDays[bell] ??= List<String>.from(reference['alt_days']);
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
    colors[bell] ??=
        HSVColor.fromColor(ColorExtension.fromHex(reference['color']));
    emojis[bell] ??=
        TextEditingController(text: reference['emoji'].replaceAll('HR', '📚'));
    names[bell] ??= TextEditingController(text: reference['name']);
    teachers[bell] ??= TextEditingController(text: reference['teacher']);
    locations[bell] ??= TextEditingController(text: reference['location']);
  }
}
