/*
  * supabase_db.dart *
  Manages connection with Supabase Database
 */
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// class for managing Supabase Database communication
class SupaBaseDB {
  // bool tracking if supabase connection has completed initialization; referenced in all methods
  static bool initialized = false;

  // late variable for tracking supabase client; defined on initialization
  static late SupabaseClient supabase;

  // Values read from supabase.json on startup
  static late String apiKey;
  static late String url;

  // Loads and reads supabase.json file
  static Future<void> loadSupabaseJson() async {
    try {
      // Reads json file as String
      final String jsonString =
          await rootBundle.loadString("assets/data/supabase.json");
      // Decodes String as hashmap
      final Map<String, dynamic> json = jsonDecode(jsonString);

      // Assigns comm. values
      url = json['url'];
      apiKey = json['api_key'];
    } catch (e) {
      // Warns developer of missing supabase.json
      print("*** Supabase Json not found! ***\n${e.toString()}");
    }
  }

  // Supabase initialization method
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: url,
      //Public can only select data, so security is not a concern
      anonKey: apiKey,
    );
    // Updates supabase state variables
    initialized = true;
    supabase = Supabase.instance.client;
  }

  /// Method which returns the dailyInfo inbetween a given range of DateTimes
  static Future<List<Map<String, dynamic>>> getDailyData(
      DateTime start, DateTime end) async {
    // Ensures supabase is initialized before running; waits .1 seconds before checking again
    while (!initialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    // Fetches data from supabase via http
    final List<Map<String, dynamic>> result = await supabase
        .from("dailyInfo")
        .select()
        // Selects all rows with primary key (date) >= the given start time and <= the given end time.
        .gte("day", start.toIso8601String())
        .lte("day", end.toIso8601String());
    // Returns result
    return result;
  }
}
