import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:xchedule/global_variables/clock.dart';
import 'package:xchedule/schedule/schedule_data.dart';

import '../schedule.dart';

class ClubScheduelDsiplay extends StatefulWidget {
  const ClubScheduelDsiplay(
      {super.key, required this.date, required this.schedule});

  final DateTime date;
  final Schedule schedule;

  @override
  State<ClubScheduelDsiplay> createState() => _ClubScheduleDisplayState();
}

class _ClubScheduleDisplayState extends State<ClubScheduelDsiplay> {
  @override
  Widget build(BuildContext context) {
    List<String> mapKeys = widget.schedule.schedule.keys.toList();
    List<String> flexKeys = mapKeys
        .where((element) => element.toLowerCase().contains('flex'))
        .toList();

    Clock startTime = widget.schedule.clockMap(flexKeys[0])!['start']!;
    Clock endTime = widget.schedule.clockMap(flexKeys[0])!['end']!;

    double minutes = startTime.difference(
            widget.schedule.clockMap(flexKeys[flexKeys.length - 1])!['end'])
        as double;

    List<Map<String, dynamic>> clubs =
        ScheduleData.coCurriculars[widget.date] ?? [];
    return Align(
      alignment: Alignment.center,
      child: Card(
        color: Theme.of(context).colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: minutes * 4 + 40,
          width: MediaQuery.of(context).size.width * 3 / 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Extracurriculars",
                style: TextStyle(fontFamily: "Georama", fontSize: 25),
              ),
              Row(
                children: [
                  Stack(
                    alignment: Alignment.topLeft,
                    children:
                        List<Widget>.generate((minutes / 10).floor(), (i) {
                      return Padding(
                          padding: EdgeInsets.only(top: 4 * i * 10),
                          child: Text(
                            '${startTime.displayAdd(deltaMinutes: i * 10).display()} -',
                            style: const TextStyle(
                                fontSize: 15,
                                height: 0.9), //Text px height = 18
                          ));
                    }),
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width * 3 / 4 - 70,
                      color: Theme.of(context).colorScheme.shadow,
                      child: clubs.isEmpty
                          ? const Align(
                              alignment: Alignment.center,
                              child: Text(
                                "No Scheduled Extracurriculars",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: "SansitaSwashed",
                                    fontWeight: FontWeight.w200,
                                    fontSize: 25),
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List<Widget>.generate(
                                    clubs.length + 1, (i) {
                                  if (i == clubs.length) {
                                    return SizedBox(height: minutes * 4);
                                  }
                                  Map club = clubs[i];
                                  //Ensures clubs outside of range are not displayed
                                  if (club['dtStart']
                                      .difference(
                                      startTime.toDateTime(
                                          club['dtStart']))
                                      .inMinutes <
                                          0 ||
                                      endTime
                                              .toDateTime(club['dtEnd']!)
                                              .difference(club['dtEnd'])
                                              .inMinutes <
                                          0) {
                                    return Container();
                                  }
                                  return Container(
                                      margin: EdgeInsets.only(
                                          left: 5,
                                          right: 5,
                                          top: club['dtStart']
                                                  .difference(
                                                      startTime.toDateTime(
                                                          club['dtStart']))
                                                  .inMinutes *
                                              4),
                                      height: club['dtEnd']
                                              .difference(club['dtStart'])
                                              .inMinutes *
                                          4,
                                      color: Colors.black.withOpacity(0.1),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 10),
                                          child: Column(
                                            children: [
                                              Text(
                                                club['summary'],
                                                style: const TextStyle(
                                                    fontSize: 12.5,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Text(
                                                '${Clock(hours: club['dtStart'].hour, minutes: club['dtStart'].minute).display()} - ${Clock(hours: club['dtEnd'].hour, minutes: club['dtEnd'].minute).display()}',
                                                style: const TextStyle(
                                                    fontSize: 12.5),
                                              ),
                                              Text(
                                                club['location'],
                                                style: const TextStyle(
                                                    fontSize: 12.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ));
                                }),
                              ),
                            ))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
