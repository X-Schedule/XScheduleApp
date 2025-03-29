/*
  * stream_signal.dart *
  Manages signals sent across streams of app
 */
import 'dart:async';

import 'package:flutter/cupertino.dart';

/// class for managing streams across app
class StreamSignal{
  /// Hashmap for history of stream signals (&lt;StreamController, data>)
  static Map<StreamController, Map<String, dynamic>> streamData = {};

  // Constructor
  StreamSignal({required this.streamController, Map<String, dynamic>? data}) {
    // Assigns values to undefined variables
    Map<String, dynamic> dataMap = data ?? <String, dynamic>{};

    streamData[streamController] ??= dataMap;
    streamData[streamController]?.addAll(dataMap);

    data = streamData[streamController] ?? {};
  }

  /// The StreamController the StreamSignal is sent through
  final StreamController<StreamSignal> streamController;

  /// Data transmitted through StreamSignal
  late final Map<String, dynamic> data;

  /// Sends a StreamSignal through a StreamController
  static void updateStream({required StreamController<StreamSignal> streamController, Map<String, dynamic>? newData}){
    newData ??= {};
    newData['key'] = GlobalKey();
    streamController.add(StreamSignal(streamController: streamController, data: newData));
  }
}