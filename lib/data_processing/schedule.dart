class Schedule {
  static List<String> letters = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];

  static Map buildSchedule(String day) {
    List<String> letterOrder = [];
    Map result = {};

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
    Clock flexLength = Clock(hours: extendedFlex ? 1 : 0, minutes: extendedFlex ? 20 : 55);
    flexLength.factorMinutes();

    Clock homeroomLength = Clock(minutes: extendedFlex ? 15 : 10);

    int flexIndex = xyDay ? 2 : 3;

    Clock dayLength = Clock(hours: 7, minutes: 5);

    Clock bellLength = Clock(
        minutes:
            ((dayLength.minutes - flexLength.minutes - homeroomLength.minutes) / bells -
                5 + (dayLength.hours - flexLength.hours) / bells * 60).round());
    bellLength.factorMinutes();

    //Clock used to keep track of accumulated time in schedule building AND the starting time of the day
    Clock totalTime = Clock(hours: lateStart ? 9 : 8);

    //Builds each bell and inserts into result map
    for (int i = 0; i < letterOrder.length; i++) {
      if (i == flexIndex) {
        if (homeroom) {
          result['Homeroom'] =
              '${totalTime.display()} - ${totalTime.displayAdd(deltaMinutes: homeroomLength.minutes)}';
          totalTime.add(deltaMinutes: homeroomLength.minutes);
        }
        result['Flex'] =
            '${totalTime.display()} - ${totalTime.displayAdd(deltaMinutes: flexLength.minutes, deltaHours: flexLength.hours)}';
        totalTime.add(
            deltaHours: flexLength.hours, deltaMinutes: flexLength.minutes+5);
      }
      result[letterOrder[i]] =
          '${totalTime.display()} - ${totalTime.displayAdd(deltaMinutes: bellLength.minutes, deltaHours: bellLength.hours)}';
      totalTime.add(
          deltaHours: bellLength.hours, deltaMinutes: bellLength.minutes + 5);
    }
    return result;
  }
}

class Clock {
  Clock({this.hours = 0, this.minutes = 0, this.pm = false});

  int hours;
  int minutes;
  bool pm = false;

  void add({int deltaHours = 0, int deltaMinutes = 0}) {
    minutes += deltaMinutes;
    if (minutes >= 60) {
      int count = (minutes / 60).floor();
      hours += count;
      minutes -= 60 * count;
    }
    hours += deltaHours;
    if (hours > 12) {
      int count = (hours / 12).floor();
      if (count % 2 != 0) {
        pm = !pm;
      }
      hours -= count * 12;
    }
  }

  String display() {
    if (minutes.toString().length == 1) {
      return '$hours:0$minutes';
    }
    return '$hours:$minutes';
  }

  String displayAdd({int deltaHours = 0, int deltaMinutes = 0}) {
    int minuteDisplay = minutes + deltaMinutes;
    int hourDisplay = hours + deltaHours;
    if (minuteDisplay >= 60) {
      int count = (minuteDisplay / 60).floor();
      hourDisplay += count;
      minuteDisplay -= 60 * count;
    }
    bool pmDisplay = pm;
    if (hourDisplay > 12) {
      int count = (hourDisplay / 12).floor();
      if (count % 2 != 0) {
        pmDisplay = !pmDisplay;
      }
      hourDisplay -= count * 12;
    }
    if (minuteDisplay.toString().length == 1) {
      return '$hourDisplay:0$minuteDisplay';
    }
    return '$hourDisplay:$minuteDisplay';
  }

  void factorMinutes(){
    while(minutes >= 60){
      hours++;
      minutes-=60;
    }
  }
}
