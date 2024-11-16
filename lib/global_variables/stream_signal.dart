import 'dart:async';

class StreamSignal{
  static Map<StreamController, Map<String, dynamic>> streamData = {};

  StreamSignal({required this.streamController, Map<String, dynamic>? newData}) {
    Map<String, dynamic> dataMap = newData ?? <String, dynamic>{};

    streamData[streamController] ??= dataMap;
    streamData[streamController]?.addAll(dataMap);

    data = streamData[streamController] ?? {};
  }
  final StreamController<StreamSignal> streamController;

  late final Map<String, dynamic> data;

  static void updateStream({required StreamController<StreamSignal> streamController, Map<String, dynamic>? newData}){
    streamController.add(StreamSignal(streamController: streamController, newData: newData));
  }
}