import 'package:url_launcher/url_launcher.dart';

class GlobalMethods {
  static void visitUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
    throw Exception('Could not launch $url');
    }
  }

  static int amPmHour(int hour) {
    if (hour > 12) {
      return hour - 12;
    }
    return hour;
  }
}
