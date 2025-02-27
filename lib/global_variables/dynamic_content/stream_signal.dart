import 'dart:async';

import 'package:flutter/cupertino.dart';

class StreamSignal{
  static Map<StreamController, Map<String, dynamic>> streamData = {};

  StreamSignal({required this.streamController, Map<String, dynamic>? data}) {
    Map<String, dynamic> dataMap = data ?? <String, dynamic>{};

    streamData[streamController] ??= dataMap;
    streamData[streamController]?.addAll(dataMap);

    data = streamData[streamController] ?? {};
  }
  final StreamController<StreamSignal> streamController;

  late final Map<String, dynamic> data;

  static void updateStream({required StreamController<StreamSignal> streamController, Map<String, dynamic>? newData}){
    newData ??= {};
    newData['key'] = GlobalKey();
    streamController.add(StreamSignal(streamController: streamController, data: newData));
  }
}