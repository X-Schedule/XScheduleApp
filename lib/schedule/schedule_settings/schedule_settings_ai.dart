import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class ScheduleSettingsAI {
  static late String apiUrl;
  static late String apiKey;
  static late String model;
  static late String instructions;

  static Future<void> loadOpenAIJson() async {
    final String jsonString = await rootBundle.loadString("assets/data/open_ai.json");
    final Map<String, dynamic> json = jsonDecode(jsonString);

    apiUrl = json['api_url']!;
    apiKey = json['api_key']!;
    model = json['model']!;
    instructions = json['schedule_instructions']!;
  }

  static Future<String?> imageToBase64(String filePath) async {
    final File imageFile = File(filePath);
    if (!await imageFile.exists()) {
      return null;
    }

    final List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  static Future<Response> postSchedule(String filePath) async {
    final String base64Image = (await imageToBase64(filePath))!;

    final Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": model,
        "messages": [
          {"role": "system", "content": instructions},
          {
            "role": "user",
            "content": [
              {
                "type": "image_url",
                "image_url": {"url": "data:image/png;base64,$base64Image"}
              }
            ]
          }
        ],
        "max_tokens": 500,
      }),
    );
    return response;
  }

  static Future<Map<String, dynamic>?> scanSchedule(
      String filePath) async {
    final Response response = await postSchedule(filePath);

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);

      List<dynamic> choices = body['choices'] ?? [];
      if (choices.isNotEmpty) {
        return jsonDecode(choices.first['message']['content'].replaceAll('```json', ''));
      }
    }
    return null;
  }
}
