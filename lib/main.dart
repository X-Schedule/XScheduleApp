import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xschedule/display/splash_page.dart';
import 'package:xschedule/display/themes.dart';
import 'package:xschedule/global_variables/dynamic_content/backend/github.dart';
import 'package:xschedule/global_variables/dynamic_content/backend/supabase_db.dart';
import 'package:xschedule/global_variables/static_content/global_variables.dart';
import 'package:xschedule/personal/credits.dart';
import 'package:xschedule/global_variables/dynamic_content/backend/schedule_data.dart';

import 'global_variables/dynamic_content/backend/open_ai.dart';

/*
Main:
What the app runs on startup
XScheduleApp:
The base of the app's widget tree
 */

Future<void> main() async {
  //Once app opened, builds the app itself
  SupaBaseDB.initialize();

  //Initializes localstorage
  await initLocalStorage();

  //Reads the json data for openAI communication
  GitHub.loadGithubJson();

  OpenAI.loadOpenAIJson();
  Credits.loadCreditsAIJson();

  GlobalVariables.packageInfo = await PackageInfo.fromPlatform();

  //Fetches data from supabase asynchronously on startup
  final DateTime now = DateTime.now();
  ScheduleData.addDailyData(
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 50)),
      DateTime(now.year, now.month, now.day).add(const Duration(days: 50)));
  //Also fetches asynchrously, and only fetched here; fetches all available data at once
  ScheduleData.getCoCurriculars().then((result) {
    //Assigns result to value on completion
    ScheduleData.coCurriculars = result;
  });

  runApp(const XScheduleApp());
}

class XScheduleApp extends StatelessWidget {
  const XScheduleApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.blueTheme,
      //Gets rid of that pesky debug banner
      debugShowCheckedModeBanner: false,
      title: 'X-Schedule',
      //HomePage Wrapped in DefaultTextStyle so that we don't need to specify EVERY TIME we display text
      home: const DefaultTextStyle(
        style: TextStyle(color: Colors.black, fontSize: 25, decoration: null),
        child: SplashPage(),
      ),
    );
  }
}

//Globally attaches showSnackBar() to BuildContext variables
extension ContextExtension on BuildContext {
  void showSnackBar(String message,
      {bool isError = false, bool floating = true}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message,
            overflow: TextOverflow.fade,
            style: TextStyle(
                color: isError
                    ? Theme.of(this).colorScheme.onError
                    : Theme.of(this).snackBarTheme.actionTextColor)),
        behavior: floating ? SnackBarBehavior.floating : null,
        backgroundColor: isError
            ? Theme.of(this).colorScheme.error
            : Theme.of(this).snackBarTheme.backgroundColor,
      ),
    );
  }
}
