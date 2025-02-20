import 'package:flutter/material.dart';
import 'package:xschedule/global_variables/clock.dart';
import 'package:xschedule/global_variables/global_methods.dart';
import 'package:xschedule/global_variables/global_variables.dart';
import 'package:xschedule/global_variables/global_widgets.dart';
import 'package:xschedule/schedule/schedule_data.dart';

import '../schedule.dart';

class FlexScheduleDisplay extends StatefulWidget {
  const FlexScheduleDisplay(
      {super.key, required this.date, required this.schedule});

  final DateTime date;
  final Schedule schedule;

  @override
  State<FlexScheduleDisplay> createState() => _FlexScheduleDisplayState();
}

class _FlexScheduleDisplayState extends State<FlexScheduleDisplay> {
  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    Map<String, dynamic> dailyData = ScheduleData.dailyData[widget.date] ?? {};

    List<String> mapKeys = widget.schedule.schedule.keys.toList();
    List<String> flexKeys = mapKeys
        .where((element) =>
            element.toLowerCase().contains('flex') ||
            int.tryParse(element) != null)
        .toList();

    String title = "Flex";
    if (widget.schedule.name.toLowerCase().contains("extended flex")) {
      title = "Extended Flex";
    }
    String flexTime = "";

    for (String key in flexKeys) {
      String scheduleTime = widget.schedule.schedule[key]!;
      if (flexTime.isEmpty) {
        flexTime = scheduleTime;
      } else {
        for (String flexTimes in flexTime.split('; ')) {
          List<String> flexParts = flexTimes.split('-');
          List<String> scheduleParts = scheduleTime.split('-');
          if (flexParts.length == 2 && scheduleParts.length == 2) {
            List<Clock?> flexClocks = [
              Clock.parse(flexParts[0]),
              Clock.parse(flexParts[1])
            ];
            List<Clock?> timeClocks = [
              Clock.parse(scheduleParts[0]),
              Clock.parse(scheduleParts[1])
            ];
            if (!flexClocks.contains(null) && !timeClocks.contains(null)) {
              if (timeClocks[1]!.difference(flexClocks[0]!) >= 0 &&
                  timeClocks[1]!.difference(flexClocks[1]!) < 0) {
                timeClocks[1] = flexClocks[1]!;
              }
              if (timeClocks[0]!.difference(flexClocks[1]!) <= 1 &&
                  timeClocks[0]!.difference(flexClocks[0]!) > 0) {
                timeClocks[0] = flexClocks[0];
              }
              flexTime = flexTime.replaceAll(flexTimes,
                  "${timeClocks[0]!.display()}-${timeClocks[1]!.display()}");
            }
          }
        }
      }
    }

    List<Map<String, dynamic>> clubs =
        ScheduleData.coCurriculars[widget.date] ?? [];
    return GlobalWidgets.popup(context, Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      width: mediaQuery.size.width * 7 / 8,
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 3 / 4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              GlobalMethods.dateText(widget.date),
              style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 35,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Georama"),
            ),
          ),
          Container(
            width: mediaQuery.size.width * 7 / 8 - 20,
            height: 2.5,
            color: colorScheme.shadow,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Georama"),
                ),
                Text(
                  flexTime,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 27.5,
                  ),
                )
              ],
            ),
          ),
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
                      color: colorScheme.onSurface,
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Georama"),
                ),
                if ((dailyData['lunchMain'] ?? '').isNotEmpty)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '🥘 ${dailyData['lunchMain']}',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 22.5,
                      ),
                    ),
                  ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if ((dailyData['lunchPasta'] ?? '').isNotEmpty)
                        Text(
                          '🍝 ${dailyData['lunchPasta']}',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 22.5,
                          ),
                        ),
                      if ((dailyData['lunchBox'] ?? '').isNotEmpty)
                        Text(
                          '🍱 ${dailyData['lunchBox']}',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 22.5,
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          Divider(color: colorScheme.shadow),
          Text(
            "Extracurriculars",
            style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 30,
                fontWeight: FontWeight.w500,
                fontFamily: "Georama"),
          ),
          SingleChildScrollView(
            child: clubs.isEmpty
                ? Text(
              "No Scheduled\nExtracurriculars",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 25,
                  fontFamily: "SansitaSwashed"),
            )
                : Column(
              children: List<Widget>.generate(clubs.length, (i) {
                Map<String, dynamic> club = clubs[i];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          club['summary'],
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 17.5,
                              fontWeight: FontWeight.w500,
                              overflow: TextOverflow.ellipsis),
                        ),
                        Text(
                          club['location'],
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 17.5,
                              height: 0.9,
                              overflow: TextOverflow.ellipsis),
                        )
                      ],
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${Clock.fromDateTime(club['dtStart']).display()}-${Clock.fromDateTime(club['dtEnd']).display()}',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 20,
                            height: 0.9,
                            overflow: TextOverflow.ellipsis),
                      ),
                    )
                  ],
                );
              }),
            ),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    ));
  }
}
