import 'package:html/dom.dart';
import 'package:http/http.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;
import 'package:xchedule/global_variables.dart';

class DataFetcher {
  static Document? calDoc;

  static Map<String, String> todayInfo = {};

  static Future<void> getCalDoc(DateTime date) async {
    String baseUrl =
        'https://www.stxavier.org/about/calendar?cal_date=${date.year}-${GlobalVariables.stringDate(date.month)}-${GlobalVariables.stringDate(date.day)}';
    print(baseUrl);
    Response response = await http.get(Uri.parse(baseUrl));
    calDoc = parse(response.body);
  }

  static Future<void> getLetterDay(DateTime date) async {
    await getCalDoc(date);

    List<Element> dates =
        calDoc?.getElementsByClassName('fsCalendarDate') ?? [];

    int? calIndex;

    for (int i = 0; i < dates.length; i++) {
      if (dates[i].outerHtml.contains('data-day="${date.day}"') &&
          dates[i].outerHtml.contains('data-month="${date.month - 1}"')) {
        calIndex = i;
        break;
      }
    }
    if (calIndex != null) {
      Element? today = dates[calIndex].parent;
      List<Element>? todayData = today?.getElementsByClassName('fsCalendarInfo');
      String? schedule;
      for(int i = 0; i < todayData!.length; i++){
        List<Element> icon = todayData[i].getElementsByClassName('fsElementEventIcon');
        if(icon.isNotEmpty){
          if(icon[0].outerHtml.contains('src="/uploaded/calendar_icons/zzzclock.gif"')){
            schedule = icon[0].parent?.getElementsByClassName('fsCalendarEventTitle fsCalendarEventLink')[0].text;
          }
        }
      }
      todayInfo['schedule'] = schedule ?? 'No Data';
    }
  }
}
