class GlobalVariables {
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

  static String stringDate(int num){
    if(num.toString().length > 1){
      return num.toString();
    }
    return '0$num';
  }
}