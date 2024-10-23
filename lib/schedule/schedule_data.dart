import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
import 'package:xchedule/global_variables/supabase_db.dart';
import 'package:xchedule/schedule/schedule.dart';

/*
ScheduleData:
Class created to manage data gathering etc. for schedules

Primary function i sto get data via RSS
 */

class ScheduleData {
  //HTML Doc variable; temporarily defined when working with website
  static Document? calDoc;

  static Map<DateTime, Schedule> schedule = {};
  static Map<DateTime, Map<String, dynamic>> dailyData = {};
  static Map<DateTime, List<Map<String, dynamic>>> coCurriculars = {};

  //List of ranges of prior supabase requests to remove overlap
  static List<Map<String, DateTime>> dailyDataRequests = [];

  static Future<Map<DateTime, Schedule>> getDailyOrder() async {
    Map<DateTime, Schedule> result = {};
    //The Base URL for the RSS request. When updating, see St. X Calendar RSS icon or ST X IT Department.
    String baseUrl = 'https://www.stxavier.org/calendar/calendar_27.ics';

    //Gets calendarData via RSS
    Response response = await http.get(Uri.parse(baseUrl));

    //Formats the response type (ICS) into an object we can work with
    final ICalendar iCalendar = ICalendar.fromString(response.body);

    //Gets the calendar data as a list from the iCalendar
    List<Map> schedules = iCalendar.data;

    //For each date data, inserts the schedule data Map into out schedule Map under the key of the date
    for (Map instance in schedules) {
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
        if (part.replaceAll(' -', '').replaceAll(' ', '').isNotEmpty) {
          //Gets the 2nd last two values separated by ' '
          List<String> partParts = part.replaceAll(' -', '').split(' ');
          forSchedule[partParts[partParts.length - 2]
              .replaceAll('HR', 'Homeroom')] = partParts[partParts.length - 1];
        }
      }
      //Date of the data
      DateTime date = instance['dtstart'].toDateTime();
      //Adds the forSchedule to our schedule data Map, under the DateTime (ignoring time)
      if (forSchedule.isNotEmpty) {
        result[DateTime(date.year, date.month, date.day)] = Schedule(
            schedule: forSchedule,
            name: instance['summary'],
            start: date,
            end: instance['dtend'].toDateTime());
      }
    }
    return result;
  }

  static Future<Map<DateTime, List<Map<String, dynamic>>>> getCoCurriculars() async {
    Map<DateTime, List<Map<String, dynamic>>> result = {};
    //The Base URL for the RSS request. When updating, see St. X Calendar RSS icon or ST X IT Department.
    String baseUrl = 'https://www.stxavier.org/calendar/calendar_242.ics';

    //Gets calendarData via RSS
    Response response = await http.get(Uri.parse(baseUrl));

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
      result[calDate]!.add({
        'summary': 'RobotX',
        'dtStart': instance['dtstart'].toDateTime().add(const Duration(minutes: 10)),
        'dtEnd': instance['dtend'].toDateTime(),
        'location': 'The Robolab'
      });
      result[calDate]!.add({
        'summary': 'More RobotX',
        'dtStart': instance['dtstart'].toDateTime().add(const Duration(minutes: 20)),
        'dtEnd': instance['dtend'].toDateTime().subtract(const Duration(minutes: 10)),
        'location': 'The Robolab'
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
      dailyData[DateTime.parse(data["day"])] = data;
    }
  }

  static Future<void> awaitCondition(bool Function() condition) async {
    while(!condition()){
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }
}
