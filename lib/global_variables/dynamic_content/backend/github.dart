import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class GitHub {
  static late String apiUrl;
  static late String apiKey;

  static Future<void> loadGithubJson() async {
    final String jsonString =
        await rootBundle.loadString("assets/data/github.json");
    final Map<String, dynamic> json = jsonDecode(jsonString);

    //Assigns comm. values
    apiUrl = json['api_url'];
    apiKey = json['api_key'];
  }

  static Future<void> postIssue(
      {required String title,
      String? body}) async {
    final Uri url = Uri.parse(apiUrl);

    final String dateStamp = DateTime.now().toString();

    final http.Response response = await http.post(url,
        headers: {
          "Authorization": "token $apiKey",
          "Accept": "application/vnd.github.v3+json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"title": "$dateStamp: title", "body": body}));
    print(response.body);
  }
}
