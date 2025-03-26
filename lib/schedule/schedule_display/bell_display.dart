/*
  * bell_display.dart *
  Main page which displays the schedule.
  Consists of multiple Widgets which come together to form Schedule page.
  References other files under schedule_display for Widgets.
*/
import 'package:flutter/material.dart';
import 'package:xschedule/global/static_content/extensions/build_context_extension.dart';
import 'package:xschedule/global/static_content/extensions/date_time_extension.dart';
import 'package:xschedule/schedule/schedule_display/schedule_display.dart';

import '../../global/dynamic_content/backend/schedule_data.dart';
import '../../global/dynamic_content/clock.dart';
import '../../global/dynamic_content/schedule.dart';
import '../../global/static_content/extensions/color_extension.dart';
import '../../global/static_content/global_widgets.dart';
import 'flex_display.dart';

/// Class which contains Widgets for displaying bell information. <p>
/// Features bellTile (basic tile for schedule) and bellInfo (popup for additional info).
class BellDisplay {
  // Provides the tutorial ID of a given bell of a given date
  static String _tutorial(final DateTime date, final String bell) {
    // Checks if date matches selected tutorialDate
    if (date == ScheduleDisplay.tutorialDate) {
      // The Schedule of the date
      final Schedule schedule =
          ScheduleData.schedules[date] ?? Schedule.empty();
      // Checks if bell matches first bell or flex bell
      if (bell == schedule.firstBell) {
        return 'tutorial_schedule_bell';
      }
      if (bell == schedule.firstFlex) {
        return 'tutorial_schedule_flex';
      }
    }
    // ...else return error ID
    return 'no_tutorial';
  }

  // Builds the Schedule Tiles displayed on the schedule card
  static Widget bellTile(
      BuildContext context, DateTime date, String bell, double minuteHeight) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    // The Schedule the bell is in
    final Schedule schedule = ScheduleData.schedules[date] ?? Schedule.empty();

    // Vanity info of bell
    final Map vanity = Schedule.bellVanity[bell] ?? {};
    final Color color = ColorExtension.fromHex(vanity['color'] ?? '#909090');
    final bool activities = bell.toLowerCase().contains("flex");

    // Clock values of bell ('start' and 'end' primarily)
    final Map<String, Clock> times = schedule.clockMap(bell) ?? {};

    // Height of bell base don start and end times
    final double height =
        minuteHeight * times['end']!.difference(times['start']!);
    // Margin from top of schedule based on start time
    final double margin =
        times['start']!.difference(Clock(hours: 8)) * minuteHeight;

    // Time range text to be displayed
    final String timeRange =
        '${times['start']!.display()} - ${times['end']!.display()}';

    //Returns Tile Wrapped in GestureDetector
    return InkWell(
        // When Tile is tapped, will display popup with more info
        onTap: () {
          // If bell has activities (i.e. flex), push Flex menu
          if (activities) {
            context.pushPopup(FlexScheduleDisplay(
                date: ScheduleDisplay.initialDate
                    .addDay(ScheduleDisplay.pageIndex),
                schedule: schedule));
          } else {
            // ...else push bell info popup
            context.pushPopup(bellInfo(context, schedule, bell));
          }
        },
        // Bell Info Tile itself
        child: Container(
            height: height,
            margin: EdgeInsets.only(top: margin),
            // Transparent background matching vanity color
            color: color.withAlpha(40),
            // Tile contents wrapped in Showcase
            child: ScheduleDisplay.tutorialSystem.showcase(
              context: context,
              tutorial: _tutorial(date, bell),
              uniqueNull: true,
              child: Row(
                children: [
                  // Left color nib; if no setting set, displays as grey
                  Container(
                    width: 10,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  // If tile is not too short, displays emoji circle as Stack
                  if (height > 25)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background colored circle
                        CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: .2),
                          radius: height * 3 / 7 - 5,
                        ),
                        // Emoji Text
                        Text(
                          // If no emoji set in settings, displays default book emoji
                          vanity['emoji'] ?? '📚',
                          style: TextStyle(
                              fontSize: height * 3 / 7,
                              color: colorScheme.onSurface),
                        )
                      ],
                    ),
                  // Text (with line skips) wrapped in FittedBox
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    width: mediaQuery.size.width - 136 - (height * 6 / 7 - 10),
                    alignment: Alignment.centerLeft,
                    // Column of expanded components (name and time range)
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name Text Widget fitted to Expanded box
                        Expanded(
                            child: Container(
                          // Forces close to second row
                          alignment: Alignment.bottomLeft,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              // If there won't be room for time range line, include it in this line
                              '${(vanity['name'] ?? bell) ?? ''}${height <= 50 ? ':     $timeRange' : ''}',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Inter",
                                  color: colorScheme.onSurface),
                            ),
                          ),
                        )),
                        // If there is space, display time range as separate line
                        if (height > 50)
                          Expanded(
                              child: Container(
                            margin: const EdgeInsets.only(top: 2),
                            // Forces close to top row
                            alignment: Alignment.topLeft,
                            child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  timeRange,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Inter",
                                      color: colorScheme.onSurface),
                                )),
                          ))
                      ],
                    ),
                  ),
                ],
              ),
            )));
  }

  // Builds the bell info popup
  static Widget bellInfo(
      BuildContext context, Schedule schedule, String bell) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    // Gets vanity data of bell
    final Map<String, dynamic> vanity = Schedule.bellVanity[bell] ?? {};
    // Clock Map of bell ('start' and 'end')
    final Map<String, Clock> times = schedule.clockMap(bell) ?? {};
    // Aligns on center of screen w/ shadowed background
    return GlobalWidgets.popup(
        context,
        SizedBox(
          width: mediaQuery.size.width * 4 / 5,
          height: 160,
          child: Row(
            children: [
              // Left color nib w/ rounded edges
              Container(
                decoration: BoxDecoration(
                  // rounds the left edges to match the Card
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(10)),
                  // Converts hex color string to flutter color object
                  color: ColorExtension.fromHex(vanity['color'] ?? '#999999'),
                ),
                width: 10,
              ),
              Padding(
                  padding: const EdgeInsets.all(10),
                  // Column w/ two rows containing vanity components
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Uppermost row; emoji and title components
                      Row(
                        children: [
                          // Stacks the emoji on top of a shadowed circle
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: colorScheme.surfaceContainer,
                                radius: 45,
                              ),
                              Text(
                                vanity['emoji'] ?? '📚',
                                style: TextStyle(
                                    fontSize: 50, color: colorScheme.onSurface),
                              )
                            ],
                          ),
                          // Information Vanity Container
                          Container(
                            width: mediaQuery.size.width * 4 / 5 - 130,
                            height: 90,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    vanity['name'] ??
                                        '$bell${bell.length <= 1 ? ' Bell' : ''}',
                                    style: TextStyle(
                                        height: 0.9,
                                        fontSize: 25,
                                        color: colorScheme.onSurface,
                                        //bold
                                        fontWeight: FontWeight.w600),
                                  ),
                                )),
                                if (vanity['teacher'] != null)
                                  Expanded(
                                      child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      vanity['teacher'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )),
                                if (vanity['location'] != null)
                                  Expanded(
                                      child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      vanity['location'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )),
                              ],
                            ),
                          )
                        ],
                      ),
                      //Bottom 'Row'; Displays bell name and time range
                      Container(
                          height: 40,
                          padding: const EdgeInsets.only(left: 12.5),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              //Displays bell name or nothing (if null)
                              Text(
                                '$bell${bell.length <= 1 ? ' Bell' : ''}:   ',
                                style: TextStyle(
                                    height: 0.9,
                                    fontSize: 25,
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w500),
                              ),
                              //Displays the time length (time length cannot be null)
                              Text(
                                '${times['start']?.display()} - ${times['end']?.display()}',
                                style: TextStyle(
                                    height: 0.9,
                                    fontSize: 25,
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ))
                    ],
                  )),
            ],
          ),
        ));
  }
}
