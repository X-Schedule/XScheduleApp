import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:xschedule/global/dynamic_content/backend/supabase_db.dart';
import 'package:xschedule/global/dynamic_content/schedule.dart';

/*
ScheduleData:
Class created to manage data gathering etc. for schedules

Primary function i sto get data via RSS
 */

class ScheduleData {
  static Map<DateTime, Schedule> schedules = {};
  static Map<DateTime, Map<String, dynamic>> dailyOrder = {};
  static Map<DateTime, List<Map<String, dynamic>>> coCurriculars = {};

  //List of ranges of prior supabase requests to remove overlap
  static List<Map<String, DateTime>> dailyDataRequests = [];

  static bool dailyOrderRequest = false;

  static late String dailyOrderUrl;
  static late String coCurricularsUrl;

  static Future<void> loadRSSJson() async {
    try {
      final String jsonString =
          await rootBundle.loadString("assets/data/rss.json");
      final Map<String, dynamic> json = jsonDecode(jsonString);

      dailyOrderUrl = json['daily_order_url'];
      coCurricularsUrl = json['cocurriculars_url'];
    } catch (e) {
      print(
          "*** RSS Json not found! This is imperative for the app to work! ***\n\n${e.toString()}");
    }
  }

  static Future<Map<DateTime, Schedule>> getDailyOrder(
      {bool limitRequests = true}) async {
    while (limitRequests && dailyOrderRequest) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!limitRequests || dailyOrder.isEmpty) {
      if (limitRequests) {
        dailyOrderRequest = true;
      }
      try {
        Map<DateTime, Schedule> result = {};

        //Gets calendarData via RSS
        final Response response = await http.get(Uri.parse(dailyOrderUrl));

        //Formats the response type (ICS) into an object we can work with
        final ICalendar iCalendar = ICalendar.fromString(response.body);

        //RegExp used for decoding schedule
        final RegExp regexp = RegExp(
            r'^\s*([\w\s]+?)\s*[:\-]?\s*(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})\s*$');

        //Gets the calendar data as a list from the iCalendar
        List<Map<String, dynamic>> schedules = iCalendar.data;

        //For each date data, inserts the schedule data Map into out schedule Map under the key of the date
        for (Map<String, dynamic> instance in schedules) {
          //Gets the base String describing the day layout
          String rawSchedule = instance['description'];
          //Splits the schedule by the raw string '\n\n\n' so that we can access the 2nd half of it, where the data is.
          List<String> splitSchedule = rawSchedule.split(r'\n\n\n');
          //Splits the 2nd half of rawSchedule into String for each bell
          List<String> scheduleParts =
              (splitSchedule[splitSchedule.length - 1]).split(r'\n');

          //The return schedule of this for loop
          Map<String, String> forSchedule = {};
          for (String part in scheduleParts) {
            //Ensures no junk strings make it into the list
            final RegExpMatch? match = regexp.firstMatch(part);
            if (match != null) {
              String title = match.group(1)!;
              if (int.tryParse(title) != null) {
                title = 'Flex $title';
              }
              forSchedule[title] = '${match.group(2)!}-${match.group(3)!}';
            }
          }
          //Date of the data
          DateTime date = instance['dtstart'].toDateTime();
          //Adds the forSchedule to our schedule data Map, under the DateTime (ignoring time)
          if (forSchedule.isNotEmpty) {
            result[DateTime(date.year, date.month, date.day)] = Schedule(
                bells: forSchedule,
                name: instance['summary'],
                start: date,
                end: instance['dtend'].toDateTime());
          }
        }
        if (limitRequests) {
          dailyOrderRequest = false;
        }
        return result;
      } catch (_) {
        if (limitRequests) {
          dailyOrderRequest = false;
        }
        rethrow;
      }
    }
    return {};
  }

  static Future<Map<DateTime, List<Map<String, dynamic>>>>
      getCoCurriculars() async {
    Map<DateTime, List<Map<String, dynamic>>> result = {};

    //Gets calendarData via RSS
    Response response = await http.get(Uri.parse(coCurricularsUrl));

    //Formats the response type (ICS) into an object we can work with
    final ICalendar iCalendar = ICalendar.fromString(response.body);

    //Gets the calendar data as a list from the iCalendar
    List<Map> clubs = iCalendar.data;

    //For each date data, inserts the schedule data Map into out schedule Map under the key of the date
    for (Map instance in clubs) {
      DateTime date = instance['dtstart'].toDateTime();
      DateTime calDate = DateTime(date.year, date.month, date.day);
      result[calDate] ??= [];
      result[calDate]!.add({
        'summary': instance['summary'],
        'dtStart': instance['dtstart'].toDateTime(),
        'dtEnd': instance['dtend'].toDateTime(),
        'location': instance['location']
      });
    }
    return result;
  }

  //Runs SupaBaseDB.getDailyData, but adds it to dailyData
  static Future<void> addDailyData(DateTime start, DateTime end) async {
    //Checks prior supabase requests, and removes overlap in times
    for (Map<String, DateTime> day in dailyDataRequests) {
      if (start.isAfter(day["start"]!) && start.isBefore(day["end"]!)) {
        start = day["end"]!;
      }
      if (end.isBefore(day["end"]!) && end.isAfter(day["start"]!)) {
        end = day["start"]!;
      }
    }
    //If range is impossible (AKA after for loop, completely inside another range), ends the method
    if (start.isAfter(end)) {
      return;
    }
    //Adds current request to map
    dailyDataRequests.add({"start": start, "end": end});

    //Runs getDailyData
    List<Map<String, dynamic>> dailyDataResult =
        await SupaBaseDB.getDailyData(start, end);
    //Adds all fetched data to dailyData
    for (Map<String, dynamic> data in dailyDataResult) {
      dailyOrder[DateTime.parse(data["day"])] = data;
    }
  }

  static Future<void> awaitCondition(bool Function() condition) async {
    while (!condition()) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
