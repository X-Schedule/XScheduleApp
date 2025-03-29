/*
  * schedule.dart *
  Intended for the better management of the various variables of each day's Schedule
  (i.e. bell hashmap, firstBell, start and end times, name, etc.)
 */
import 'dart:convert';

import 'package:localstorage/localstorage.dart';

import 'clock.dart';

/// class for managing the various variables of each day's Schedule
class Schedule {
  /// Global Map (&lt;Bell, Map&lt;ValueName, value>>) of vanity values (Class name, location, color, etc.) of all bells
  static Map<String, Map<String, dynamic>> bellVanity =
      Map<String, Map<String, dynamic>>.from(
          json.decode(localStorage.getItem("scheduleSettings") ?? '{}'));

  /// Schedule from bell hashmap
  Schedule(
      {required this.bells, this.start, this.end, this.name = 'No Classes'}) {
    // Assigns firstBell and firstFlex Strings
    for (String bell in bells.keys) {
      if (bell.toLowerCase().contains('flex')) {
        firstFlex ??= bell;
      } else {
        firstBell ??= bell;
      }
    }
  }

  /// Hashmap (&lt;Bell, Map&lt;ValueName, value>>) of bells of Schedule
  final Map<String, String> bells;

  /// The String label of the Schedule (i.e. A Day)
  final String name;

  /// The DateTime for the start of the day
  final DateTime? start;
  /// The DateTime for the end of the day
  final DateTime? end;

  /// The String value of the first standard bell, if it exists (i.e. A)
  String? firstBell;
  /// The String value of the first flex bell, it it exists (i.e. Flex, Flex 1)
  String? firstFlex;

  /// Empty schedule class; used for null safety
  static Schedule empty() {
    return Schedule(bells: {});
  }

  /// Gets the absolute value of the difference of the start and end times, then returns day length
  Clock? dayLength() {
    // If start or end times are undefined, returns null
    if (start != null && end != null) {
      // Difference between start and end DateTimes
      final int? minutes = start?.difference(end!).inMinutes;
      if (minutes != null) {
        // Returns difference as Clock
        final Clock clock = Clock(minutes: minutes.abs());
        return clock;
      }
    }
    return null;
  }

  /// Returns the 'start' and 'end' times of the inputted bell
  Map<String, Clock?>? clockMap(String bell) {
    // If bell doesn't exist, return null
    if (bells[bell] != null) {
      // Splits bell into start and end
      List<String> times = bells[bell]?.split('-') ?? [];
      // If bell improperly formatted, return null
      if (times.length == 2) {
        final Clock? startClock = Clock.parse(times[0]);
        // Converts early-PM hours into military time
        startClock?.estimate24hrTime();

        final Clock? endClock = Clock.parse(times[1]);
        //Converts early-PM hours into military time
        endClock?.estimate24hrTime();
        // Returns Clocks in Map form
        return {'start': startClock, 'end': endClock};
      }
    }
    return null;
  }

  /// Converts the Schedule's start DateTime into a Clock
  Clock? startClock() {
    // If start undefined, returns null
    if (start != null) {
      final Clock startClock = Clock.fromDateTime(start!);
      // Converts early-PM hours into military time
      startClock.estimate24hrTime();
      return startClock;
    }
    return null;
  }

  /// Converts the Schedule's end DateTime into a Clock
  Clock? endClock() {
    //If end undefined, returns null
    if (end != null) {
      final Clock endClock = Clock.fromDateTime(end!);
      // Converts early-PM hours into military time
      endClock.estimate24hrTime();
      return endClock;
    }
    return null;
  }
}
