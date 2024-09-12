import 'package:flutter/material.dart';

import '../data_processing/data_fetcher.dart';
import '../data_processing/schedule.dart';

class ScheduleDisplay extends StatefulWidget {
  const ScheduleDisplay({super.key});

  @override
  State<ScheduleDisplay> createState() => _ScheduleDisplayState();
}

class _ScheduleDisplayState extends State<ScheduleDisplay> {
  @override
  Widget build(BuildContext context) {
    double cardHeight = MediaQuery.of(context).size.height - 130;
    return DefaultTextStyle(
        style: const TextStyle(
            color: Colors.black, fontSize: 25, decoration: null),
    child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      color: Colors.white70,
      child: FutureBuilder(
          future: DataFetcher.getLetterDay(DateTime.now()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting ||
                snapshot.hasError) {
              return const CircularProgressIndicator();
            }
            if(DataFetcher.todayInfo['schedule'] == null){
              return const CircularProgressIndicator();
            }
            Map dayInfo =
                Schedule.buildSchedule(DataFetcher.todayInfo['schedule'] ?? '');
            double minuteHeight = cardHeight /
                (dayInfo['dayLength'].minutes +
                    dayInfo['dayLength'].hours * 60);
            Map schedule = dayInfo['schedule'];
                return Container(
                  margin: const EdgeInsets.all(10),
                  child: Column(
                    children: List<Widget>.generate(schedule.keys.length, (i) {
                      String key = schedule.keys.toList()[i];
                      double height = minuteHeight *
                          schedule[key]['start']
                              .findLength(schedule[key]['end']);
                      return Card(
                        color: Colors.black12,
                        margin: EdgeInsets.only(top: schedule[key]['margin'].minutes),
                        child: Container(
                          height: height,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: Text('$key${height > 50 ? '\n' : ':     '}${schedule[key]['start'].display()} - ${schedule[key]['end'].display()}'),
                          ),
                        ),
                      );
                    }),
                  ),
                );
          })),
    );
  }
}
