import 'package:flutter/material.dart';

import '../data_processing/data_fetcher.dart';
import '../data_processing/schedule.dart';

class ScheduleDisplay extends StatefulWidget {
  const ScheduleDisplay ({super.key});

  @override
  State<ScheduleDisplay> createState() => _ScheduleDisplayState();

}

class _ScheduleDisplayState extends State<ScheduleDisplay> {
  @override
  Widget build(BuildContext context){
    return FutureBuilder(
        future: DataFetcher.getLetterDay(DateTime(2024,9,5)),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting ||
              snapshot.hasError) {
            return Container();
          }
          Map schedule =
          Schedule.buildSchedule(DataFetcher.todayInfo['schedule'] ?? '');
          return DefaultTextStyle(
              style: const TextStyle(
                  color: Colors.black, fontSize: 25, decoration: null),
              child: Column(
                children: List<Widget>.generate(schedule.keys.length, (i) {
                  String key = schedule.keys.toList()[i];
                  return Text('$key: ${schedule[key]}');
                }),
              ));
        });
  }
}