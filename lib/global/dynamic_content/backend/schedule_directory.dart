/*
  * schedule_directory.dart *
  In charge of managing schedule data from various sources.
  See supabase_db.dart for more db comm. methods.
 */
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:xschedule/global/dynamic_content/backend/supabase_db.dart';
import 'package:xschedule/global/dynamic_content/schedule.dart';
import 'package:xschedule/global/static_content/extensions/date_time_extension.dart';

/// class for managing schedule data from various different sources. <p>
/// See SupabaseDB for more methods.
class ScheduleDirectory {
  /// Schedule objects of each date
  static Map<DateTime, Schedule> schedules = {};

  static void writeSchedule(DateTime date,
      {String? name, Map<String, String>? bells, Map<String, dynamic>? info}) {
    schedules[date] ??= Schedule();
    schedules[date]!.writeInfo(info);
    schedules[date]!.writeBells(bells);
    schedules[date]!.writeName(name);
  }

  static Schedule readSchedule(DateTime date) {
    schedules[date] ??= Schedule();
    return schedules[date]!;
  }

  /// Co-curriculars of each date
  static Map<DateTime, List<Map<String, dynamic>>> coCurriculars = {};

  // List of ranges of prior supabase requests to remove overlap
  static List<Map<String, DateTime>> dailyInfoRequests = [];

  // If http request for dailyOrder is currently being processed
  static bool dailyOrderRequest = false;

  // rss.json variables TBD
  static late String dailyOrderUrl;
  static late String coCurricularsUrl;

  // Reads and interprets rss.json
  static Future<void> loadRSSJson() async {
    // Reads json as String
    final String jsonString =
        await rootBundle.loadString("assets/data/rss.json");
    // Interprets json String as hashmap
    final Map<String, dynamic> json = jsonDecode(jsonString);

    // Maps comm. variables
    dailyOrderUrl = json['daily_order_url'];
    coCurricularsUrl = json['cocurriculars_url'];
  }

  /// Reads dailyOrder RSS via http. <p>
  /// [bool limitRequests = true]: Limits the number of active http requests to 1.
  static Future<Map<DateTime, Schedule>> getDailyOrder(
      {bool limitRequests = true}) async {
    // If restricted and request running, wait
    while (limitRequests && dailyOrderRequest) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    // If not restricted or prior request failed, run request
    if (!limitRequests || schedules.isEmpty) {
      // Sets request state to active
      if (limitRequests) {
        dailyOrderRequest = true;
      }
      try {
        final Map<DateTime, Schedule> result = {};

        // Read dailyOrder RSS via http
        final Response response = await http.get(Uri.parse(dailyOrderUrl));

        // Formats the response type (ICS) into an object we can work with
        final ICalendar iCalendar = ICalendar.fromString(response.body);

        // RegExp used for decoding schedule
        final RegExp regexp = RegExp(
          r"""\s*""" // Portion of preceding white space.
          r"""([A-Za-z0-9\- ]*?[A-Za-z0-9])""" // Group 1: Portion of any length containing and ending with only alphanumeric characters (i.e. A, HR, Flex 1)
          r"""[\s\-:]*""" // Portion of white space, dashes, and/or colons.
          r"""(\d{1,2}:\d{2})""" // Group 2: Portion of text in following formats : H:MM or HH:MM (i.e. 7:30, 3:05)
          r"""\s*-\s*""" // Portion of text containing dash (-) w/ optional whitespace on either side
          r"""(\d{1,2}:\d{2})""", // Group 3: Portion of text in following formats : H:MM or HH:MM (i.e. 7:30, 3:05)
          multiLine: true,
        );

        // Gets the calendar data as a list from the iCalendar
        final List<Map<String, dynamic>> schedules = iCalendar.data;

        // For each date data, inserts the schedule data Map into our schedule Map under the key of the date
        for (Map<String, dynamic> instance in schedules) {
          if (instance['type'] == "VEVENT") {
            // Gets the base String describing the day layout
            final String rawSchedule = instance['description'];
            // The return schedule of this for loop
            final Map<String, String> bells = {};
            // Analyzes string to find all instances of regexp matching, and stores as result
            for (RegExpMatch match
                in regexp.allMatches(rawSchedule.replaceAll(r'\n', '_').replaceAll("Bell", ""))) {
              // Title of bell
              String title = match.group(1)!;
              // If title is int, specify as Flex bell
              if (int.tryParse(title) != null) {
                title = 'Flex $title';
              }
              // Store bell in result
              bells[title] = '${match.group(2)!}-${match.group(3)!}';
            }
            // Date of the data
            final DateTime date = instance['dtstart'].toDateTime();
            // Adds the forSchedule to our schedule data Map, under the DateTime (ignoring time)
            if (bells.isNotEmpty) {
              writeSchedule(date.dateOnly(),
                  bells: bells, name: instance['summary']);
            }
          }
        }
        // Sets request state to completed
        if (limitRequests) {
          dailyOrderRequest = false;
        }
        return result;
      } catch (_) {
        // On error, set request state to inactive and rethrow error
        if (limitRequests) {
          dailyOrderRequest = false;
        }
        rethrow;
      }
    }
    // Return empty if request not needed
    return {};
  }

  /// Reads Co-curriculars RSS via http
  static Future<Map<DateTime, List<Map<String, dynamic>>>>
      getCoCurriculars() async {
    // Result map tbd
    final Map<DateTime, List<Map<String, dynamic>>> result = {};

    // Reads calendarData RSS via http
    final Response response = await http.get(Uri.parse(coCurricularsUrl));

    // Formats the response type (ICS) into an object we can work with
    final ICalendar iCalendar = ICalendar.fromString(response.body);

    // Gets the calendar data as a list from the iCalendar
    final List<Map> clubs = iCalendar.data;

    // For each date data, inserts the schedule data Map into out schedule Map under the key of the date
    for (Map instance in clubs) {
      DateTime date = instance['dtstart'].toDateTime();
      result[date.dateOnly()] ??= [];
      result[date.dateOnly()]!.add({
        'summary': instance['summary'],
        'dtStart': instance['dtstart'].toDateTime(),
        'dtEnd': instance['dtend'].toDateTime(),
        'location': instance['location']
      });
    }
    // Returns result
    return result;
  }

  /// Fetches and stores supabase data in efficient manner
  static Future<void> addDailyData(DateTime start, DateTime end) async {
    // Checks prior supabase requests, and removes overlap in times
    for (Map<String, DateTime> day in dailyInfoRequests) {
      if (start.isAfter(day["start"]!) && start.isBefore(day["end"]!)) {
        start = day["end"]!;
      }
      if (end.isBefore(day["end"]!) && end.isAfter(day["start"]!)) {
        end = day["start"]!;
      }
    }
    // If range is impossible (AKA after for loop, completely inside another range), ends the method
    if (start.isAfter(end)) {
      return;
    }
    // Adds current request to map
    dailyInfoRequests.add({"start": start, "end": end});

    // Runs getDailyData
    final List<Map<String, dynamic>> dailyInfoResult =
        await SupaBaseDB.getDailyData(start, end);
    // Adds all fetched data to dailyInfo
    for (Map<String, dynamic> info in dailyInfoResult) {
      // Gets the DateTime from the date String in the hashmap
      final DateTime date = DateTime.parse(info["day"]);
      writeSchedule(date, info: info);
    }
  }

  /// Method which doesn't complete until a provided condition is true.
  static Future<void> awaitCondition(bool Function() condition) async {
    while (!condition()) {
      // Delay .1 seconds to avoid over-usage
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
