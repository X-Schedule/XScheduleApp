/*
  * open_ai.dart *
  Used for communication with OpenAI, specifically ChatGPT.
 */
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:image/image.dart' as img;

/// class for managing OpenAI communication. <p>
/// Contains method for communication with ChatGPT and http image compression and encoding.
class OpenAI {
  // OpenAI comm. variables to be defined on initialization
  static late String apiUrl;
  static late String apiKey;
  static late String model;
  static late String instructions;
  static late Map<String, dynamic> params;

  // Loads and reads the open_ai.json file
  static Future<void> loadOpenAIJson() async {
    try {
      // Reads json file as String
      final String jsonString =
          await rootBundle.loadString("assets/data/open_ai.json");
      // Decodes String as hashmap
      final Map<String, dynamic> json = jsonDecode(jsonString);

      // Assigns comm. values
      apiUrl = json['api_url'];
      apiKey = json['api_key'];
      model = json['model'];
      instructions = json['schedule_instructions'];
      params = json['params'];
    } catch (e) {
      // Warns developer of missing open_ai.json
      print("*** OpenAI Json not found! ***\n${e.toString()}");
    }
  }

  // Converts an image of a given file path into base64
  static Future<String?> imageToBase64(String filePath,
      {int maxPixels = 1280 * 720}) async {
    // Finds file from filePath and exits if not found.
    final File imageFile = File(filePath);
    if (!await imageFile.exists()) {
      return null;
    }

    // Reads image
    final Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);

    // Exits if error interpreting
    if (image == null) {
      return null;
    }

    // Converts image aspect ratio to specified ratio

    // Total number of pictures in image; continues only if image is larger than specified aspect ratio
    final int imagePixels = image.width * image.height;
    if (imagePixels > maxPixels) {
      // Converts image through conversion of quadrilaterals from given area
      final double scaleFactor = sqrt(maxPixels / imagePixels);
      final int newWidth = (image.width * scaleFactor).round();
      final int newHeight = (image.height * scaleFactor).round();

      // Sets new image variable
      image = img.copyResize(image, width: newWidth, height: newHeight);
    }

    // Encodes and returns image in base64
    final List<int> encodedBytes = img.encodeJpg(image, quality: 80);
    return base64Encode(Uint8List.fromList(encodedBytes));
  }

  // Runs an http.post request to OpenAI servers
  static Future<Response> postSchedule(String filePath) async {
    // gets base64 bytes from provided image filePath
    final String? base64Image = await imageToBase64(filePath);

    // Posts request to OpenAI and records response
    final Response response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        // Authorization form API key
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        // Messages containing instructions and input image
        "model": model,
        "messages": [
          // Provided instructions makes ChatGPT serve as custom AI GPT
          {"role": "system", "content": instructions},
          {
            "role": "user",
            "content": [
              {
                "type": "image_url",
                // Provided image bytes which http will accept
                "image_url": {"url": "data:image/png;base64,$base64Image"}
              }
            ]
          }
        ],
        ...params
      }),
    );
    // Returns response
    return response;
  }

  // Fully scans a provided schedule image using OpenAI
  static Future<Map<String, dynamic>> scanSchedule(String filePath) async {
    late Response response;
    // Attempts to gain response
    try {
      response = await postSchedule(filePath);
    } catch (_) {
      // If error at this level, must be connection error (513)
      return {'error': 513};
    }

    // If response contains success
    if (response.statusCode == 200) {
      // Decodes String from response body
      final String decodedResponse = utf8
          .decode(response.bodyBytes)
          .replaceAll('```', '')
          .replaceAll('json', '')
          .replaceAll(r'\n', '');
      try {
        // Attempts to interpret body as hashmap
        final Map<String, dynamic> body = jsonDecode(decodedResponse);

        // Breaks response down into individual responses
        List<dynamic> choices = body['choices'] ?? [];
        if (choices.isNotEmpty) {
          // Returns first choice no matter what.
          return jsonDecode(choices.first['message']['content']);
        }
      } catch (e) {
        // Unsupported Media Type http error
        return {'error': 415};
      }
    }
    // Returns unique error code
    return {'error': response.statusCode};
  }
}
