import 'package:flutter/material.dart';
import 'package:xschedule/global/static_content/extensions/date_time_extension.dart';
import 'package:xschedule/global/static_content/global_widgets.dart';
import 'package:xschedule/global/dynamic_content/backend/schedule_data.dart';

import '../../global/dynamic_content/schedule.dart';

/*
ScheduleInfoDisplay:
Widget displayed in popup for daily info
 */

class ScheduleInfoDisplay extends StatelessWidget {
  const ScheduleInfoDisplay({super.key, required this.date});

  static String dressEmoji(String dressCode){
    if(dressCode.toLowerCase().contains("formal")){
      return '👔';
    } else if(dressCode.toLowerCase().contains("spirit")){
      return '🏱';
    }
    return '👕';
  }

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    //Gets the schedules and dailyData based on the given date
    Schedule schedule = ScheduleData.schedules[date] ?? Schedule.empty();
    Map<String, dynamic> dailyData = ScheduleData.dailyOrder[date] ?? {};
    return GlobalWidgets.popup(
        context,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              //Date Text
              Text(
                date.dateText(),
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface),
              ),
              FittedBox(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '⏰ ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface),
                    ),
                    Text(
                      schedule.name,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                          fontStyle: schedule.name.contains("No Classes")
                              ? FontStyle.italic
                              : FontStyle.normal),
                    ),
                  ],
                ),
              ),
              //Row of quarter and dress code
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (dailyData['quarter'] != null)
                    Text(
                      '🗓️ Quarter ${dailyData['quarter']}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface),
                    ),
                  //If variable is null, then replace with empty string, and checks if string is empty; detects both null and empty values
                  if ((dailyData['dressCode'] ?? '').isNotEmpty)
                    Text(
                      '${dressEmoji(dailyData['dressCode'])} ${dailyData['dressCode']}',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface),
                    ),
                ],
              ),
              //Checks to display lunch divider and header
              if ((dailyData['lunchPasta'] ?? '').isNotEmpty ||
                  (dailyData['lunchBox'] ?? '').isNotEmpty ||
                  (dailyData['lunchMain'] ?? '').isNotEmpty)
                Column(
                  children: [
                    Divider(
                      color: colorScheme.shadow,
                    ),
                    Text(
                      "Lunch",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface),
                    ),
                    if ((dailyData['lunchMain'] ?? '').isNotEmpty)
                      Text(
                        '🥘 ${dailyData['lunchMain']}',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface),
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if ((dailyData['lunchPasta'] ?? '').isNotEmpty)
                          Text(
                            '🍝 ${dailyData['lunchPasta']}',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface),
                          ),
                        if ((dailyData['lunchBox'] ?? '').isNotEmpty)
                          Text(
                            '🍱 ${dailyData['lunchBox']}',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface),
                          ),
                      ],
                    )
                  ],
                ),
              if ((dailyData['event'] ?? '').isNotEmpty)
                Column(
                  children: [
                    Divider(
                      color: colorScheme.shadow,
                    ),
                    Text(
                      '📢 Announcement',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                          color: colorScheme.onSurface),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        dailyData['event'],
                        maxLines: 10,
                        style: TextStyle(
                            fontSize: 15,
                            overflow: TextOverflow.ellipsis,
                            color: colorScheme.onSurface),
                      ),
                    ),
                  ],
                )
            ],
          ),
        ));
  }
}
