/*
GlobalVariables:
Class created to organize objects used globally in the app
 */

import 'package:package_info_plus/package_info_plus.dart';

class GlobalVariables {
  static late PackageInfo packageInfo;

  //Used when working with ints with time; Ensures int is displayed with >= 2 digits. Ex: 02 or 10
  static String stringDate(int num){
    if(num.toString().length > 1){
      return num.toString();
    }
    return '0$num';
  }
}