import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image/image.dart' as img;

class ScheduleSettingsAI {
  //OpenAI comm. variables to be defined on initialization
  static late String apiUrl;
  static late String apiKey;
  static late String model;
  static late String instructions;

  static late Map<String, dynamic> params;

  //Loads and reads the open_ai.json file
  static Future<void> loadOpenAIJson() async {
    final String jsonString = await rootBundle.loadString("assets/data/open_ai.json");
    final Map<String, dynamic> json = jsonDecode(jsonString);

    //Assigns comm. values
    apiUrl = json['api_url'];
    apiKey = json['api_key'];
    model = json['model'];
    instructions = json['schedule_instructions'];

    params = json['params'];
  }

  //Converts an image of a given file path into base64
  static Future<String?> imageToBase64(String filePath, {int maxPixels = 1280*720}) async {
    final File imageFile = File(filePath);
    if (!await imageFile.exists()) {
      return null;
    }

    final Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    if(image == null){
      return null;
    }

    final int imagePixels = image.width * image.height;
    if(imagePixels > maxPixels){
      final double scaleFactor = sqrt(maxPixels / imagePixels);
      final int newWidth = (image.width * scaleFactor).round();
      final int newHeight = (image.height * scaleFactor).round();
      
      image = img.copyResize(image, width: newWidth, height: newHeight);
    }

    final List<int> encodedBytes = img.encodeJpg(image, quality: 80);
    return base64Encode(Uint8List.fromList(encodedBytes));
  }

  //Runs an http.post request to OpenAI servers
  static Future<Response> postSchedule(String filePath) async {
    final String? base64Image = await imageToBase64(filePath);

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
        ...params
      }),
    );
    return response;
  }

  //Fully scans a provided schedule image using OpenAI
  static Future<Map<String, dynamic>> scanSchedule(
      String filePath) async {
    late Response response;
    try {
      response = await postSchedule(filePath);
    } catch (_){
      return {
        'error': 513
      };
    }

    if (response.statusCode == 200) {
      final String decodedResponse = utf8.decode(response.bodyBytes).replaceAll('```', '').replaceAll('json', '').replaceAll(r'\n', '');
      try {
        final Map<String, dynamic> body = jsonDecode(decodedResponse);

        List<dynamic> choices = body['choices'] ?? [];
        if (choices.isNotEmpty) {
          return jsonDecode(choices.first['message']['content']);
        }
      } catch (e){
        return {
          'error': 415
        };
      }
    }
    return {
      'error': response.statusCode
    };
  }
}
