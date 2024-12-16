/*
GlobalVariables:
Class created to organize objects used globally in the app
 */

import 'package:package_info_plus/package_info_plus.dart';

class GlobalVariables {
  static late PackageInfo packageInfo;
  //Uniform emoji from given dress code string
  static String dressEmoji(String dressCode){
    if(dressCode.toLowerCase().contains("formal")){
      return '👔';
    } else if(dressCode.toLowerCase().contains("spirit")){
      return '🏱';
    }
    return '👕';
  }

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