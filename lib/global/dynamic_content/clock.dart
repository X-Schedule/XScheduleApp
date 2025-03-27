/*
Clock:
Custom Class to construct custom 'Clock' Objects

Clock objects allow for more efficient calculations when handling time
 */

import 'package:xschedule/global/static_content/extensions/int_extension.dart';

class Clock {
  //Constructor
  Clock({this.hours = 0, this.minutes = 0}) {
    while (minutes >= 60) {
      hours++;
      minutes -= 60;
    }
  }

  int hours;
  int minutes;

  //Adds minutes and/or hours to a clock; input negative to subtract
  void add({int deltaHours = 0, int deltaMinutes = 0}) {
    minutes += deltaMinutes;
    //Loops until minutes < 60; Factors minutes into hours
    while (minutes >= 60) {
      hours++;
      minutes -= 60;
    }
    hours += deltaHours;
    //Loops until hours < 24; Simplifies hour count
    while (hours >= 24) {
      hours -= 24;
    }
  }

  //Outputs temporary clock with time added to it
  String display({int deltaHours = 0, int deltaMinutes = 0, bool amPm = true}) {
    //Adds delta values to current values
    int minuteDisplay = minutes + deltaMinutes;
    int hourDisplay = hours + deltaHours;
    //Factors minutes into hours
    while (minuteDisplay >= 60) {
      hourDisplay++;
      minuteDisplay -= 60;
    }
    //Simplifies hou count
    while (hourDisplay >= 24) {
      hourDisplay -= 24;
    }
    if(amPm){
      return '${hourDisplay % 12}:${minuteDisplay.multiDecimal()}';
    }
    return '$hourDisplay:${minuteDisplay.multiDecimal()}';
  }

  //Finds the time interval between one clock and another
  int difference(Clock otherClock) {
    return (minutes - otherClock.minutes + (hours - otherClock.hours) * 60);
  }

  //Provides a copy of the clock
  Clock clone() {
    return Clock(hours: hours, minutes: minutes);
  }

  int totalMinutes() {
    return minutes + hours * 60;
  }

  //Returns a Clock from a given String
  static Clock? parse(String clockText) {
    List<String> parts = clockText.split(':');
    //If improperly formated, returns null
    if (parts.length == 2) {
      int? tryHours = int.tryParse(parts[0]);
      int? tryMinutes = int.tryParse(parts[1]);
      if (tryHours != null && tryMinutes != null) {
        return Clock(hours: tryHours, minutes: tryMinutes);
      }
    }
    return null;
  }

  //Returns a Clock from a given DateTime
  static Clock fromDateTime(DateTime date) {
    return Clock(hours: date.hour, minutes: date.minute);
  }

  //Creates a datetime, with given year, month, and day, with the current time values
  DateTime toDateTime(DateTime reference) {
    return DateTime(
        reference.year, reference.month, reference.day, hours, minutes);
  }
}