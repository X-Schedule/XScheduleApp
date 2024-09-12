import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:xchedule/global_variables/global_variables.dart';

class DataFetcher {
  static Document? calDoc;

  static Map<String, String> todayInfo = {};

  static Future<void> getCalDoc(DateTime date) async {
    //Base http url
    String baseUrl = 'https://www.stxavier.org/about/calendar';
    //Adds the cal_date parameter and value to end of the url
    String paramsUrl =
        '$baseUrl?cal_date=${date.year}-${GlobalVariables.stringDate(date.month)}-${GlobalVariables.stringDate(date.day)}';

    //Loads the calendar webpage in hidden browser; extracts html code after init
    Response response = await http.get(Uri.parse(baseUrl));
    //Parses html code into an Element Object
    calDoc = parse(response.body);
  }

  static Future<void> getLetterDay(DateTime date) async {
    await getCalDoc(date);

    //Int in top right of calendar box representing date
    List<Element> dates =
        calDoc?.getElementsByClassName('fsCalendarDate') ?? [];

    //Finds the index of the fsCalendarDate which = requested date
    int? calIndex;

    for (int i = 0; i < dates.length; i++) {
      if (dates[i].outerHtml.contains('data-day="${date.day}"') &&
          dates[i].outerHtml.contains('data-month="${date.month - 1}"')) {
        calIndex = i;
        break;
      }
    }

    if (calIndex != null) {
      //Gets the parent of the fsCalendarDate (the box itself)
      Element? today = dates[calIndex].parent;

      //Gets all information of that box
      List<Element>? todayData =
          today?.getElementsByClassName('fsCalendarInfo');
      String? schedule;

      //Goes through all fsCalendarInfo(s) until it finds one with the schedule(clock) icon
      for (int i = 0; i < todayData!.length; i++) {
        List<Element> icon =
            todayData[i].getElementsByClassName('fsElementEventIcon');
        if (icon.isNotEmpty) {
          if (icon[0]
              .outerHtml
              .contains('src="/uploaded/calendar_icons/zzzclock.gif"')) {
            //sets the schedule string to the fsCalendarEventTitle of the icon's parent(fsCalendarInfo)
            schedule = icon[0]
                .parent
                ?.getElementsByClassName(
                    'fsCalendarEventTitle fsCalendarEventLink')[0]
                .text;
            break;
          }
        }
      }
      todayInfo['schedule'] = schedule ?? 'No Data';
    }
  }
}
