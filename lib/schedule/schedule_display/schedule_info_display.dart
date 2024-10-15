import 'package:flutter/material.dart';
import 'package:xchedule/schedule/schedule_data.dart';

import '../schedule.dart';

class ScheduleInfoDisplay {
  static Widget buildScheduleInfo(BuildContext context, DateTime date){
    Schedule schedule = ScheduleData.schedule[date] ?? Schedule.empty();
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        //When the popup is swiped, removes (or 'pops') the popup from the page
        onHorizontalDragEnd: (detail) {
          if (detail.primaryVelocity! < 0) {
            Navigator.pop(context);
          }
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 4 / 5,
          height: 160,
          child: Card(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Column(
                children: [
                  Text(schedule.name)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}