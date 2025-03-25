/*
  * main.dart *
  Entry point of XSchedule app. Runs initialization processes and builds the app.
*/

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:xschedule/display/splash_page.dart';
import 'package:xschedule/display/themes.dart';
import 'package:xschedule/global/dynamic_content/backend/github.dart';
import 'package:xschedule/global/dynamic_content/backend/schedule_data.dart';
import 'package:xschedule/global/dynamic_content/backend/supabase_db.dart';
import 'package:xschedule/global/dynamic_content/schedule.dart';
import 'package:xschedule/global/static_content/extensions/date_time_extension.dart';
import 'package:xschedule/global/static_content/global_variables.dart';
import 'package:xschedule/personal/credits.dart';

import 'global/dynamic_content/backend/open_ai.dart';

Future<void> main() async {
  // Initializes several processes in the app
  await init();

  // Creates the Flutter app itself
  runApp(const XScheduleApp());
}

/// App Initialization Process. <p>
/// Interprets json file data, initializes communication with backend
Future<void> init() async {
  // Initializes communication with the Supabase database
  SupaBaseDB.initialize();

  // Initializes local storage; Runs synchronously since local storage is essential
  await initLocalStorage();

  // Reads the various data from local json files asynchronously
  GitHub.loadGithubJson();
  OpenAI.loadOpenAIJson();
  Credits.loadCreditsJson();
  await ScheduleData.loadRSSJson();

  // Fetches information about the build of the app
  GlobalVariables.packageInfo = await PackageInfo.fromPlatform();

  // Fetches schedule info from X via RSS and database for closest 101 days
  final DateTime now = DateTime.now();
  ScheduleData.addDailyData(now.addDay(-50), now.addDay(50));

  // Fetches co-curricular data from X via RSS
  ScheduleData.getCoCurriculars().then((result) {
    ScheduleData.coCurriculars = result;
  });
}

/// The base Flutter app <p>
/// Sets the theme, default text style, and default destination
class XScheduleApp extends StatelessWidget {
  const XScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Returns the Flutter App
    return MaterialApp(
      theme: Themes.blueTheme,
      debugShowCheckedModeBanner: false,
      title: 'X-Schedule',
      // Sets the default text styling of the app
      home: const DefaultTextStyle(
        style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            decoration: null,
            // Any overflowing text fades out
            overflow: TextOverflow.fade),
        // Directs to the app's splash page to determine destination
        child: SplashPage(),
      ),
    );
  }
}
