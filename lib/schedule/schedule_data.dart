import 'package:html/dom.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:icalendar_parser/icalendar_parser.dart';
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
    for(int i = 0; i < schedules.length; i++){
      Map instance = schedules[i];

      //Gets the base String describing the day layout
      String rawSchedule = instance['description'];
      //Splits the schedule by the raw string '\n\n\n' so that we can access the 2nd half of it, where the data is.
      List<String> splitSchedule = rawSchedule.split(r'\n\n\n');
      //Splits the 2nd half of rawSchedule into String for each bell
      List<String> scheduleParts = (splitSchedule[splitSchedule.length-1]).split(r'\n');

      //The return schedule of this for loop
      Map<String, String> forSchedule = {};
      for(int e = 0; e < scheduleParts.length; e++){
        String part = scheduleParts[e];
        //Ensures no junk strings make it into the list
        if(part.replaceAll(' -', '').replaceAll(' ', '').isNotEmpty){
          //Gets the 2nd last two values separated by ' '
          List<String> partParts = part.replaceAll(' -', '').split(' ');
          forSchedule[partParts[partParts.length-2].replaceAll('HR', 'Homeroom')] = partParts[partParts.length-1];
        }
      }
      //Date of the data
      DateTime date = instance['dtstart'].toDateTime();
      //Adds the forSchedule to our schedule data Map, under the DateTime (ignoring time)
      if(forSchedule.isNotEmpty) {
        result[DateTime(date.year, date.month, date.day)] = Schedule(
            schedule: forSchedule,
            name: instance['summary'],
            start: date,
            end: instance['dtend'].toDateTime()
        );
      }
    }
    return result;
  }
}
