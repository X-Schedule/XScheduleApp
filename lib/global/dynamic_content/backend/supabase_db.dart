import 'package:supabase_flutter/supabase_flutter.dart';

/*
SupaBaseDB:
Class in charge of managing supabase connection
 */

class SupaBaseDB {
  //bool tracking if supabase connection has completed initialization; referenced in all methods
  static bool initialized = false;

  //late variable for tracking supabase client; defined on initialization
  static late SupabaseClient supabase;

  //Initialization method
  static Future<void> initialize() async {
    await Supabase.initialize(
        url: "https://kpodjtamaejonpsdodor.supabase.co",
        //Public can only select data, so security is not a concern
        anonKey:
            "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtwb2RqdGFtYWVqb25wc2RvZG9yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjg5OTQ1NzcsImV4cCI6MjA0NDU3MDU3N30.xg1rCUYSE9WYRoq0JW2NFXGeU18kd1VL7yLaiMGe7VM");
    initialized = true;
    supabase = Supabase.instance.client;
  }

  //Method which returns the dailyInfo inbetween a given range of DateTimes
  static Future<List<Map<String, dynamic>>> getDailyData(
      DateTime start, DateTime end) async {
    //Ensures supabase is initialized before running; waits .1 seconds before checking again
    while (!initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    //Fetches data from supabase
    List<Map<String, dynamic>> result = await supabase
        .from("dailyInfo")
        .select()
    //Selects all rows with primary key (date) >= the given start time and <= the given end time.
        .gte("day", start.toIso8601String())
        .lte("day", end.toIso8601String());
    return result;
  }
}
