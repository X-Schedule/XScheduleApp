/*
Clock:
Custom Class to construct custom 'Clock' Objects

Clock objects allow for more efficient calculations when handling time
 */

import 'package:xchedule/global_variables/gloabl_methods.dart';
import 'package:xchedule/global_variables/global_variables.dart';

class Clock {
  //Constructor
  Clock({this.hours = 0, this.minutes = 0});

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

  //Outputs the clock as a string in a HOUR:MINUTE 24hr format
  String display({bool amPm = true}) {
    if(amPm){
      return '${GlobalMethods.amPmHour(hours)}:${GlobalVariables.stringDate(minutes)}';
    }
    return '$hours:${GlobalVariables.stringDate(minutes)}';
  }

  //Outputs temporary clock with time added to it
  Clock displayAdd({int deltaHours = 0, int deltaMinutes = 0}) {
    //Adds delta values to current values
    int minuteDisplay = minutes + deltaMinutes;
    int hourDisplay = hours + deltaHours;
    //Factors minutes into hours
    while (minuteDisplay >= 60) {
      hourDisplay++;
      minuteDisplay -= 60;
    }
    //Simplifies hou count
    while (hours >= 24) {
      hours -= 24;
    }
    return Clock(hours: hourDisplay, minutes: minuteDisplay);
  }

  //Method which factors minutes into hours; used after declaring
  void factorMinutes() {
    while (minutes >= 60) {
      hours++;
      minutes -= 60;
    }
  }

  //Finds the time interval between one clock and another
  int difference(Clock otherClock) {
    return (otherClock.minutes - minutes + (otherClock.hours - hours) * 60)
        .abs();
  }

  //Provides a copy of the clock
  Clock instance() {
    return Clock(hours: hours, minutes: minutes);
  }
  int totalMinutes(){
    return minutes + hours*60;
  }

  //Returns a Clock from a given String
  static Clock? parse(String clockText){
    List<String> parts = clockText.split(':');
    //If improperly formated, returns null
    if(parts.length == 2) {
      int? tryHours = int.tryParse(parts[0]);
      int? tryMinutes = int.tryParse(parts[1]);
      if(tryHours != null && tryMinutes != null){
        return Clock(hours: tryHours, minutes: tryMinutes);
      }
    }
    return null;
  }

  //Creates a datetime, with given year, month, and day, with the current time values
  DateTime toDateTime(DateTime reference){
    return DateTime(reference.year, reference.month, reference.day, hours, minutes);
  }
}