import 'package:flutter/material.dart';
import 'package:xchedule/global_variables/gloabl_methods.dart';
import 'package:xchedule/global_variables/global_variables.dart';
import 'package:xchedule/schedule/schedule_data.dart';

import '../schedule.dart';

/*
ScheduleInfoDisplay:
Widget displayed in popup for daily info
 */

class ScheduleInfoDisplay extends StatelessWidget {
  const ScheduleInfoDisplay({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    //Gets the schedules and dailyData based on the given date
    Schedule schedule = ScheduleData.schedule[date] ?? Schedule.empty();
    Map<String, dynamic> dailyData = ScheduleData.dailyData[date] ?? {};
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
          child: Card(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //Date Text
                  Text(
                    GlobalMethods.dateText(date),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '⏰ ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        schedule.name,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            fontStyle: schedule.name.contains("No Classes")
                                ? FontStyle.italic
                                : FontStyle.normal),
                      ),
                    ],
                  ),
                  //Row of quarter and dress code
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (dailyData['quarter'] != null)
                        Text(
                          '🗓️ Quarter ${dailyData['quarter']}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                      //If variable is null, then replace with empty string, and checks if string is empty; detects both null and empty values
                      if ((dailyData['dressCode'] ?? '').isNotEmpty)
                        Text(
                          '${GlobalVariables.dressEmoji(dailyData['dressCode'])} ${dailyData['dressCode']}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                  //Checks to display lunch divider and header
                  if ((dailyData['lunchPasta'] ?? '').isNotEmpty ||
                      (dailyData['lunchBox'] ?? '').isNotEmpty ||
                      (dailyData['lunchMain'] ?? '').isNotEmpty)
                    Column(
                      children: [
                        const Divider(
                          color: Colors.black,
                        ),
                        const Text(
                          "Lunch",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        if ((dailyData['lunchMain'] ?? '').isNotEmpty)
                          Text(
                            '🥘 ${dailyData['lunchMain']}',
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w500),
                          ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if ((dailyData['lunchPasta'] ?? '').isNotEmpty)
                              Text(
                                '🍝 ${dailyData['lunchPasta']}',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                            if ((dailyData['lunchBox'] ?? '').isNotEmpty)
                              Text(
                                '🍱 ${dailyData['lunchBox']}',
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w500),
                              ),
                          ],
                        )
                      ],
                    ),
                  if ((dailyData['event'] ?? '').isNotEmpty)
                    Column(
                      children: [
                        const Divider(
                          color: Colors.black,
                        ),
                        const Text(
                          '📢 Announcement',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 20),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            dailyData['event'],
                            maxLines: 10,
                            style: const TextStyle(
                                fontSize: 15, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
