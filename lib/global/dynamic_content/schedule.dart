import 'dart:convert';

import 'package:localstorage/localstorage.dart';

import 'clock.dart';

/*
Schedule:
Custom Class created to manage schedule data

Centralized class for various static(public) methods as well as object specific
 */

class Schedule {
  static Map<String, Map<String, dynamic>> bellVanity = Map<String, Map<String, dynamic>>.from(
      json.decode(localStorage.getItem("scheduleSettings") ?? '{}'));

  Schedule(
      {required this.bells, this.start, this.end, this.name = 'No Classes'}) {
    for (String bell in bells.keys) {
      if (bell.toLowerCase().contains('flex')) {
        firstFlex ??= bell;
      } else {
        firstBell ??= bell;
      }
    }
  }

  final Map<String, String> bells;

  final String name;

  final DateTime? start;
  final DateTime? end;

  String? firstBell;
  String? firstFlex;

  //Empty schedule class; used for null safety
  static Schedule empty() {
    return Schedule(bells: {});
  }

  //Gets the absolute value of the difference of teh start and end times, then returns day length
  Clock? dayLength() {
    //If start or end times are undefined, returns null
    if (start != null && end != null) {
      int? minutes = start?.difference(end!).inMinutes;
      if (minutes != null) {
        Clock clock = Clock(minutes: minutes.abs());
        return clock;
      }
    }
    return null;
  }

  //Returns the start and end times of the inputted bell
  Map<String, Clock>? clockMap(String bell) {
    //If bell doesn't exist, return null
    if (bells[bell] != null) {
      //Splits bell into start and end
      List<String> times = bells[bell]?.split('-') ?? [];
      //If bell improperly formatted, return null
      if (times.length == 2) {
        Clock? startClock = Clock.parse(times[0]);
        //Converts early-PM hours into military time
        if (startClock!.hours <= 3) {
          startClock.add(deltaHours: 12);
        }
        Clock? endClock = Clock.parse(times[1]);
        //Converts early-PM hours into military time
        if (endClock!.hours <= 3) {
          endClock.add(deltaHours: 12);
        }
        return {'start': startClock, 'end': endClock};
      }
    }
    return null;
  }

  //Converts the start DateTime into a Clock
  Clock? startClock() {
    //If start undefined, returns null
    if (start != null) {
      Clock startClock = Clock(hours: start!.hour, minutes: start!.minute);
      if (startClock.hours <= 3) {
        startClock.add(deltaHours: 12);
      }
      return startClock;
    }
    return null;
  }

  //Converts the end DateTime into a Clock
  Clock? endClock() {
    //If end undefined, returns null
    if (end != null) {
      Clock endClock = Clock(hours: end!.hour, minutes: end!.minute);
      if (endClock.hours <= 3) {
        endClock.add(deltaHours: 12);
      }
      return endClock;
    }
    return null;
  }
}
