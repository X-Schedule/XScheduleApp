/*
GlobalVariables:
Class created to organize objects used globally in the app
 */

class GlobalVariables {
  //Converts month index into String
  static Map<int, String> monthText = {
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December'
  };

  //Converts weekday index into String
  static Map<int, String> weekdayText = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday'
  };

  //Used when working with ints with time; Ensures int is displayed with >= 2 digits. Ex: 02 or 10
  static String stringDate(int num){
    if(num.toString().length > 1){
      return num.toString();
    }
    return '0$num';
  }
}