import '../global_variables/clock.dart';

/*
Schedule:
Class created to organize methods used in calculating schedules

buildSchedule: When provided with Schedule String, will break it down and output a schedule
 */

class Schedule {
  //Global Map containing all schedules; organized by dates
  static Map<DateTime, Map> calendar = {};

  //All possible bells
  static List<String> letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

  //When provided with Schedule String, will break it down and output a schedule
  static Map buildSchedule(String day) {
    //If not a schedule day, will return empty
    if (!day.contains(' Day') || day.contains('No Classes')) {
      return {};
    }

    //The order in which bells appear
    List<String> letterOrder = [];
    //The result Map returned
    Map result = {};
    //Organized LetterOrder
    Map schedule = {};

    //Deconstructing Schedule String
    bool extendedFlex = day.contains('Extended Flex');
    bool lateStart = day.contains('Late Start');
    bool allMeet = day.contains('All Meet');

    String letter = allMeet ? 'A' : day[day.indexOf(' Day') - 1];

    bool xyDay = false;

    switch (letter) {
      case 'X':
        xyDay = true;
        letter = 'A';
        break;
      case 'Y':
        xyDay = true;
        letter = 'E';
    }

    int bells = allMeet
        ? 8
        : xyDay
            ? 4
            : 6;

    //Gets the order of letters in the day
    int letterIndex = letters.indexOf(letter);
    for (int i = letterIndex; i < bells + letterIndex; i++) {
      if (i > letters.length - 1) {
        letterOrder.add(letters[i - letters.length]);
      } else {
        letterOrder.add(letters[i]);
      }
    }

    bool homeroom = true;

    //Calculating length of each bell; Clock is a custom class for this project
    Clock flexLength =
        Clock(hours: extendedFlex ? 1 : 0, minutes: extendedFlex ? 20 : 55);
    flexLength.factorMinutes();

    Clock homeroomLength = Clock(minutes: extendedFlex ? 15 : 10);

    int flexIndex = xyDay ? 2 : 3;

    //Length of regular school day
    Clock dayLength = Clock(hours: 7, minutes: 5);

    //Interval of time after 8 which school starts
    Clock delay = Clock(hours: lateStart ? 1 : 0);

    //Length of each letter bell
    Clock bellLength = Clock(
      //Gets the minute length of each bell by dividing the time of the school day (excluding flex, homeroom, and possible delay) by the number of bells
        minutes: ((dayLength.minutes -
                        flexLength.minutes -
                        homeroomLength.minutes -
                        delay.minutes) /
                    bells -
                5 +
            //... and adds it to the hour(factored as minutes) length of each bell by dividing the time of the school day (excluding flex, homeroom, and possible delay) by the number of bells
                (dayLength.hours - flexLength.hours - delay.hours) / bells * 60)
            .round());
    //Refactors minutes into hours
    bellLength.factorMinutes();

    //Clock used to keep track of accumulated time in schedule building AND the starting time of the day
    Clock totalTime = Clock(hours: lateStart ? 9 : 8);

    //Builds each bell and inserts into schedule map
    for (int i = 0; i < letterOrder.length; i++) {
      if (i == flexIndex) {
        if (homeroom) {
          schedule['Homeroom'] = {
            'name': 'Homeroom',
            'start': totalTime.instance(),
            'end': totalTime.displayAdd(deltaMinutes: homeroomLength.minutes),
            'margin': Clock(minutes: 5)
          };
          totalTime.add(deltaMinutes: homeroomLength.minutes);
        }
        schedule['Flex'] = {
          'name': 'Flex',
          'start': totalTime.instance(),
          'end': totalTime.displayAdd(
              deltaMinutes: flexLength.minutes, deltaHours: flexLength.hours),
          'margin': Clock()
        };
        totalTime.add(
            deltaHours: flexLength.hours, deltaMinutes: flexLength.minutes + 5);
      }
      schedule[letterOrder[i]] = {
        'name': letterOrder[i],
        'start': totalTime.instance(),
        'end': totalTime.displayAdd(
            deltaMinutes: bellLength.minutes, deltaHours: bellLength.hours),
        'margin': Clock(minutes: 5)
      };
      totalTime.add(
          deltaHours: bellLength.hours, deltaMinutes: bellLength.minutes + 5);
    }
    //Combines all data into result; returns result
    result.addAll(
        {'schedule': schedule, 'dayLength': dayLength, 'lateStart': lateStart});
    return result;
  }
}
