/*
  * github.dart *
  Used for communication with GitHub, such as issue reporting.
 */
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:xschedule/global/static_content/extensions/build_context_extension.dart';

/// class for managing GitHub communication. <p>
/// Contains methods for interpreting json file and posting issues to GH.
class GitHub {
  // variables TBD in json file interpretation
  static late String apiUrl;
  static late String apiKey;

  /// loads and interprets the values of github.json
  static Future<void> loadGithubJson() async {
    // Reads json file as String value
    final String jsonString =
        await rootBundle.loadString("assets/data/github.json");
    // Decodes String into hashmap
    final Map<String, dynamic> json = jsonDecode(jsonString);

    // Assigns comm. values
    apiUrl = json['api_url'];
    apiKey = json['api_key'];
  }

  /// posts an issue to the X-Schedule GitHub organization
  /// [required String title]: The title of the issue <p>
  /// [required BuildContext context]: The BuildContext to report any http issue through <p>
  /// [String? body]: Optional body of the issue
  static Future<void> postIssue(
      {required String title,
      required BuildContext context,
      String? body}) async {
    // Parse URI
    final Uri url = Uri.parse(apiUrl);

    // Gets current DateTime as string
    final String dateStamp = DateTime.now().toString();

    try {
      // Posts issue to GitHub
      await http.post(url,
          headers: {
            "Authorization": "token $apiKey",
            "Accept": "application/vnd.github.v3+json",
            "Content-Type": "application/json",
          },
          body: jsonEncode({"title": "$dateStamp: title", "body": body}));
    } catch (_) {
      // Reports http error
      if (context.mounted) {
        context.showSnackBar("Failed to publish issue report.");
      }
    }
  }
}
