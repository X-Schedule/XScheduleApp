import 'dart:async';

import 'package:color_hex/class/hex_to_color.dart';
import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:xschedule/global_variables/clock.dart';
import 'package:xschedule/global_variables/global_methods.dart';
import 'package:xschedule/global_variables/global_variables.dart';
import 'package:xschedule/global_variables/global_widgets.dart';
import 'package:xschedule/global_variables/stream_signal.dart';
import 'package:xschedule/schedule/schedule.dart';
import 'package:xschedule/schedule/schedule_data.dart';
import 'package:xschedule/schedule/schedule_display/schedule_flex_display.dart';
import 'package:xschedule/schedule/schedule_display/schedule_info_display.dart';
import 'package:xschedule/schedule/schedule_settings/schedule_settings.dart';

import '../../global_variables/tutorial_system.dart';

/*
ScheduleDisplay:
Displays the daily schedules
 */

class ScheduleDisplay extends StatefulWidget {
  const ScheduleDisplay({super.key});

  //Gets the current date (ignoring time)
  static DateTime initialDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  static DateTime displayDate = initialDate;

  //pageIndex of Schedule PageView
  static int pageIndex = 0;

  static StreamController<StreamSignal> scheduleStream =
      StreamController<StreamSignal>();

  @override
  State<ScheduleDisplay> createState() => _ScheduleDisplayState();
}

class _ScheduleDisplayState extends State<ScheduleDisplay> {
  //Creates the controller of PageView and sets the max # of pages; controller starts in the middle
  //Set to 365*3 to allow to allow viewing of 3 years of schedules
  static const int maxPages = 365 * 3;
  static const int initialPage = 547;
  final PageController _controller =
      PageController(initialPage: initialPage + ScheduleDisplay.pageIndex);

  final TutorialSystem tutorialSystem = TutorialSystem({
    'tutorial_schedule',
    'tutorial_schedule_bell',
    'tutorial_schedule_flex',
    'tutorial_schedule_date',
    'tutorial_schedule_calendar',
    'tutorial_schedule_info',
    'tutorial_schedule_settings'
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    tutorialSystem.refreshKeys();
    tutorialSystem.removeFinished();

    //Runs addDailyData asynchronously on page moved; may do nothing at all if ranges overlap
    ScheduleData.addDailyData(
        GlobalMethods.addDay(
            ScheduleDisplay.initialDate, ScheduleDisplay.pageIndex - 25),
        GlobalMethods.addDay(
            ScheduleDisplay.initialDate, ScheduleDisplay.pageIndex + 25));
    ScheduleDisplay.scheduleStream = StreamController();
    return StreamBuilder(
        stream: ScheduleDisplay.scheduleStream.stream,
        builder: (context, snapshot) {
          return ShowCaseWidget(onComplete: (_, __) {
            tutorialSystem.finish();
          }, builder: (context) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              while (ScheduleData.schedule.isEmpty) {
                await Future.delayed(Duration(milliseconds: 100));
              }
              if (!tutorialSystem.finished) {
                int index = 0;
                while (index <= 25 &&
                    ScheduleDisplay.displayDate ==
                        ScheduleDisplay.initialDate) {
                  if (_schedule(
                      GlobalMethods.addDay(ScheduleDisplay.initialDate, index),
                      tutorial: true)) {
                    break;
                  }
                  if (_schedule(
                      GlobalMethods.addDay(ScheduleDisplay.initialDate, -index),
                      tutorial: true)) {
                    index = -index;
                    break;
                  }
                  index++;
                }

                if (index != 26) {
                  ScheduleDisplay.pageIndex = index;
                  ScheduleDisplay.displayDate =
                      GlobalMethods.addDay(ScheduleDisplay.initialDate, index);
                  _controller.animateToPage(initialPage + index,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                  if (context.mounted) {
                    tutorialSystem.showTutorials(context);
                  }
                }
              }
            });
            return Scaffold(
                backgroundColor: colorScheme.primaryContainer,
                body: Column(
                  children: [
                    SizedBox(height: mediaQuery.padding.top),
                    //The top day text display
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      height: 50,
                      alignment: Alignment.center,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: tutorialSystem.showcase(
                                context: context,
                                circular: true,
                                message: "... or click this button to quickly navigate through the school days of the year.",
                                tutorial: 'tutorial_schedule_calendar',
                                child: GlobalWidgets.iconCircle(
                                    icon: Icons.calendar_month,
                                    iconColor: colorScheme.onTertiary,
                                    color: colorScheme.tertiary
                                        .withValues(alpha: 0.4),
                                    radius: 20,
                                    padding: 10,
                                    onTap: () {
                                      GlobalMethods.showPopup(
                                          context,
                                          _buildCalendarNav(
                                              context,
                                              GlobalMethods.addDay(
                                                  ScheduleDisplay.initialDate,
                                                  ScheduleDisplay.pageIndex)));
                                    })),
                          ),
                          tutorialSystem.showcase(
                              context: context,
                              message: "Up top, you'll find the date you're currently viewing. You can use the buttons or simple swiping gestures to flip between days.",
                              tutorial: 'tutorial_schedule_date',
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildNavButton(context, -1),
                                  SizedBox(
                                    width: mediaQuery.size.width - 220,
                                    child: FittedBox(
                                      fit: BoxFit.contain,
                                      child: Text(
                                        GlobalMethods.dateText(
                                            GlobalMethods.addDay(
                                                ScheduleDisplay.initialDate,
                                                ScheduleDisplay.pageIndex)),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 32.5,
                                            color: colorScheme.onSurface),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  _buildNavButton(context, 1),
                                ],
                              )),
                          Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: tutorialSystem.showcase(
                                context: context,
                                circular: true,
                                message: "Tap this button to view important information about a school day, if available.",
                                tutorial: 'tutorial_schedule_info',
                                child: _buildInfoButton(context)),
                          ),
                        ],
                      ),
                    ),
                    //The schedule card viewer
                    Expanded(child: _buildPageView(context)),
                    //Button which leads to ScheduleSettings
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: mediaQuery.size.width * .3),
                      height: 30,
                      child: tutorialSystem.showcase(context: context, message: 'Lastly, if you every want to edit your class information, you can do so by clicking this button.', tutorial: 'tutorial_schedule_settings', child: ElevatedButton(
                          onPressed: () {
                            GlobalMethods.pushSwipePage(
                                context,
                                const ScheduleSettings(
                                  backArrow: true,
                                ));
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondary),
                          child: Container(
                            alignment: Alignment.center,
                            width: mediaQuery.size.width * 3 / 5,
                            child: Icon(
                              Icons.settings,
                              color: colorScheme.onSecondary,
                            ),
                          ))),
                    ),
                    const SizedBox(height: 5)
                  ],
                ));
          });
        });
  }

  //Loading wheel which appears while fetching data
  Widget _buildLoading(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    double cardHeight = mediaQuery.size.height -
        18 -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    return Container(
      height: cardHeight,
      alignment: Alignment.center,
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  //Pseudo-PageView which displays all schedule cards
  Widget _buildPageView(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return PageView.builder(
        controller: _controller,
        physics: const PageScrollPhysics(),
        //When page index is changes, updates pageIndex variable
        onPageChanged: (i) {
          setState(() {
            ScheduleDisplay.pageIndex = i - initialPage;
          });
        },
        itemCount: maxPages,
        //Builds the schedules based on given index(i)
        itemBuilder: (_, i) {
          //The date of the schedule (currentDate+index)
          DateTime date = GlobalMethods.addDay(
              ScheduleDisplay.initialDate, i - initialPage);

          //Schedule card wrapped in gestureDetector
          return GestureDetector(
            onLongPress: () {
              setState(() {
                _controller.animateToPage(
                    (_controller.page! - ScheduleDisplay.pageIndex).floor(),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
                ScheduleDisplay.pageIndex = 0;
              });
            },
            onVerticalDragEnd: (detail) {
              _controller.animateToPage(
                  (_controller.page! - (detail.primaryVelocity!).sign).floor(),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut);
              ScheduleDisplay.pageIndex +=
                  (detail.primaryVelocity!).sign.floor();
            },
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: colorScheme.surfaceContainer,
                        blurRadius: 3,
                        spreadRadius: 1),
                    //Fancy little shadow
                    BoxShadow(
                        color: colorScheme.surfaceContainer,
                        offset: const Offset(2.25, 2.25))
                  ]),
              child: ScheduleData.schedule.isEmpty
                  //FutureBuilder: will run async methods while displaying loading/placeholder widget; then replaces with widget once data fully fetched
                  ? FutureBuilder(
                      future: ScheduleData.getDailyOrder(),
                      //Runs once progress updates in the async method
                      builder: (context, snapshot) {
                        //Checks to see if method is still loading/an error occurred (if error occurred, eternal hell of loading wheel)
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            snapshot.hasError) {
                          return _buildLoading(context);
                        }

                        ScheduleData.schedule.addAll(snapshot.data ?? {});
                        //Returns full schedule card
                        return _buildSchedule(context, date);
                      })
                  : _buildSchedule(context, date),
            ),
          );
        });
  }

  //Builds the schedule card based on given date
  Widget _buildSchedule(BuildContext context, DateTime date) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    Schedule dayInfo = ScheduleData.schedule[date] ?? Schedule.empty();
    double cardHeight = mediaQuery.size.height -
        190 -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    if (!_schedule(date)) {
      //i.e. no schedule/classes
      return _buildEmpty(context, cardHeight);
    }

    DateTime currentTime = DateTime.now();
    double timeMargin = currentTime.hour * 60 + currentTime.minute - 480;

    //Schedule data
    Map schedule = dayInfo.schedule;
    //The height (in pxs) that each minute will be on the screen, based on the devices screen size etc.
    double minuteHeight = cardHeight / 430;
    return tutorialSystem.showcase(
        context: context,
        message: "In this menu, you'll be able to see the schedule of any school day out of the year.",
        tutorial: date == ScheduleDisplay.displayDate
            ? 'tutorial_schedule'
            : 'no_tutorial',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 5, right: 15),
                height: cardHeight,
                child: Row(
                  children: [
                    //Column of time references to the left
                    Stack(
                      children: List<Widget>.generate(8, (i) {
                        return Padding(
                            padding:
                                EdgeInsets.only(top: minuteHeight * i * 60),
                            child: Text(
                              '${GlobalVariables.stringDate(GlobalMethods.amPmHour(i + 8))} - ',
                              style: TextStyle(
                                  fontSize: 15,
                                  height: 0.9,
                                  color: colorScheme
                                      .onSurface), //Text px height = 18
                            ));
                      }),
                    ),
                    //Expanded Box (as much width as possible) wrapping sized box (set height of card) wrapping stack of bell tiles
                    Expanded(
                        child: Container(
                      padding: const EdgeInsets.only(top: 6.5),
                      height: cardHeight,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children:
                            List<Widget>.generate(schedule.keys.length, (i) {
                          //Returns Schedule 'Tile' based on schedule info
                          String key = schedule.keys.toList()[i];
                          return _buildTile(context, date, key, minuteHeight);
                        }),
                      ),
                    )),
                  ],
                ),
              ),
              if (timeMargin >= 0 &&
                  timeMargin <= 425 &&
                  date == ScheduleDisplay.initialDate)
                Opacity(
                  opacity: 0.6,
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 25, top: timeMargin * cardHeight / 425),
                    child: Row(
                      children: [
                        Container(
                          height: 1.5,
                          width: mediaQuery.size.width - 80,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.arrow_back_ios,
                          size: 10,
                          color: colorScheme.secondary,
                        )
                      ],
                    ),
                  ),
                )
            ],
          ),
        ));
  }

  //Checks that all info of the schedule of a given date is proper
  bool _schedule(DateTime date, {bool tutorial = false}) {
    Schedule dayInfo = ScheduleData.schedule[date] ?? Schedule.empty();
    if (tutorial) {
      if (dayInfo.schedule.length < 2 || dayInfo.firstFlex == null) {
        return false;
      }
    }
    if (dayInfo.schedule.isEmpty || dayInfo.schedule.containsKey('-')) {
      return false;
    }
    List<String> keys = dayInfo.schedule.keys.toList();
    for (String key in keys) {
      if (dayInfo.clockMap(key) == null) {
        ScheduleData.schedule[date]!.schedule.remove(key);
      }
    }
    return true;
  }

  String _tutorial(final DateTime date, final String bell) {
    if (date == ScheduleDisplay.displayDate) {
      final Schedule schedule = ScheduleData.schedule[date] ?? Schedule.empty();
      if (bell == schedule.firstBell) {
        return 'tutorial_schedule_bell';
      }
      if (bell == schedule.firstFlex) {
        return 'tutorial_schedule_flex';
      }
    }

    return 'no_tutorial';
  }

  //Builds the 'Schedule Tile's displayed on the schedule card
  Widget _buildTile(
      BuildContext context, DateTime date, String bell, double minuteHeight) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final Schedule schedule = ScheduleData.schedule[date] ?? Schedule.empty();

    //Gets Map from schedule_settings.dart
    Map settings = ScheduleSettings.bellInfo[bell] ?? {};

    bool activities = bell.toLowerCase().contains("flex");

    Map times = schedule.clockMap(bell) ?? {};
    //Gets the height (in pxs) of the tile, based on minuteHeight (see _buildSchedule)
    double height = minuteHeight * times['end'].difference(times['start']);

    double margin = times['start'].difference(Clock(hours: 8)) * minuteHeight;
    //Returns Tile Wrapped in GestureDetector
    return GestureDetector(
        //When Tile is tapped, will display popup with more info
        onTap: () {
          if (activities) {
            GlobalMethods.showPopup(
                context,
                FlexScheduleDisplay(
                    date: GlobalMethods.addDay(
                        ScheduleDisplay.initialDate, ScheduleDisplay.pageIndex),
                    schedule: schedule));
          } else {
            GlobalMethods.showPopup(
                context, _buildBellInfo(context, schedule, bell));
          }
        },
        //Tile
        child: Container(
            height: height,
            margin: EdgeInsets.only(top: margin),
            color: colorScheme.surfaceContainer,
            child: tutorialSystem.showcase(
              context: context,
              message: bell == schedule.firstFlex ? 'Additionally, you can tap the Flex bell to view information about lunch, clubs, and more!' : 'Each individual bell is set to match the information you provided about your class schedule, and clicking on any bell will display more information about it.',
              tutorial: _tutorial(date, bell),
              child: Row(
                children: [
                  //Left color nib; if no setting set, displays as grey
                  Container(
                    width: 10,
                    color: hexToColor(settings['color'] ?? '#999999'),
                  ),
                  //spacer
                  const SizedBox(width: 7.5),
                  //If tile is not too short, displays emoji circle
                  if (height > 25)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: .2),
                          radius: height * 3 / 7 - 5,
                        ),
                        Text(
                          //If no emoji set in settings, displays default book emoji
                          settings['emoji'] ?? '📚',
                          style: TextStyle(
                              fontSize: height * 3 / 7,
                              color: colorScheme.onSurface),
                        )
                      ],
                    ),
                  //Text (with line skips) wrapped in FittedBox
                  Container(
                    margin: const EdgeInsets.only(left: 7.5),
                    alignment: Alignment.centerLeft,
                    width: mediaQuery.size.width - 135 - (height * 6 / 7 - 10),
                    child: FittedBox(
                      //If text overflows the tile, will shrink to fully include it
                      fit: BoxFit.contain,
                      //Displays the class name (if null, then bell name), line skip, then time range
                      child: Text(
                        '${(settings['name'] ?? bell) ?? ''}${height > 50 ? '\n' : ':     '}${times['start'].display()} - ${times['end'].display()}',
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: colorScheme.onSurface),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }

  //Builds the display for a day with no classes
  Widget _buildEmpty(BuildContext context, double cardHeight) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: cardHeight,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 5, right: 10, top: 10, bottom: 10),
      child: Text(
        'No Classes',
        style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface),
      ),
    );
  }

  //Builds the bell info popup
  Widget _buildBellInfo(BuildContext context, Schedule schedule, String bell) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    //Gets settings from schedule_settings.dart
    Map settings = ScheduleSettings.bellInfo[bell] ?? {};
    Map times = schedule.clockMap(bell) ?? {};
    //Aligns on center of screen
    return GlobalWidgets.popup(
        context,
        SizedBox(
          width: mediaQuery.size.width * 4 / 5,
          height: 160,
          child: Row(
            children: [
              //Left color nib w/ rounded edges
              Container(
                decoration: BoxDecoration(
                  //rounds the left edges to match the Card
                  borderRadius:
                      const BorderRadius.horizontal(left: Radius.circular(10)),
                  //Converts hex color string to flutter color object
                  color: hexToColor(settings['color'] ?? '#999999'),
                ),
                width: 10,
              ),
              Padding(
                  padding: const EdgeInsets.all(10),
                  //Column w/ two rows
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //Uppermost row; emoji and title
                      Row(
                        children: [
                          //Stacks the emoji on top of a shadowed circle
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: colorScheme.surfaceContainer,
                                radius: 45,
                              ),
                              Text(
                                settings['emoji'] ?? '📚',
                                style: TextStyle(
                                    fontSize: 50, color: colorScheme.onSurface),
                              )
                            ],
                          ),
                          //Title Container
                          Container(
                            width: mediaQuery.size.width * 4 / 5 - 130,
                            height: 90,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 5),
                            //FittedBox to ensure text doesn't overflow card
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  //Displays class name, bell name, or nothing (if null)
                                  Text(
                                    settings['name'] ??
                                        '$bell${bell.length <= 1 ? ' Bell' : ''}',
                                    style: TextStyle(
                                        height: 0.9,
                                        fontSize: 25,
                                        color: colorScheme.onSurface,
                                        //bold
                                        fontWeight: FontWeight.w600),
                                  ),
                                  //Displays teacher or nothing (if null)
                                  if (settings['teacher'] != null)
                                    Text(
                                      settings['teacher'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  //Displays the location of the class or nothing (if null)
                                  if (settings['location'] != null)
                                    Text(
                                      settings['location'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.w500),
                                    ),
                                ],
                              ),
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
                                '${times['start'].display()} - ${times['end'].display()}',
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

  //Builds the calendar navigation popup
  Widget _buildCalendarNav(BuildContext context, DateTime date) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    int monthIndex = GlobalMethods.monthDiff(date, ScheduleDisplay.initialDate);
    PageController calController = PageController(initialPage: 18 + monthIndex);
    double height = mediaQuery.size.width * 24 / 35;
    double width = mediaQuery.size.width * 4 / 5;
    //Aligns on center of screen
    return StatefulBuilder(builder: (context, setState) {
      DateTime newMonth = DateTime(ScheduleDisplay.initialDate.year,
          ScheduleDisplay.initialDate.month + monthIndex);
      return Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: width,
          height: 69 + height,
          child: Card(
            color: colorScheme.surface,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          iconSize: 25,
                          onPressed: () {
                            if (monthIndex > -18) {
                              setState(() {
                                monthIndex--;
                              });
                              calController.animateToPage(
                                  calController.page!.round() - 1,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut);
                            }
                          },
                          icon: Icon(Icons.arrow_back_ios,
                              color: colorScheme.onSurface)),
                      SizedBox(
                        width: width - 200,
                        height: 50,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Text(
                            "${GlobalVariables.monthText[newMonth.month]} ${newMonth.year}",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                color: colorScheme.onSurface),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                          ),
                        ),
                      ),
                      IconButton(
                          iconSize: 25,
                          onPressed: () {
                            if (monthIndex < 18) {
                              setState(() {
                                monthIndex++;
                              });
                              calController.animateToPage(
                                  calController.page!.round() + 1,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeInOut);
                            }
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: colorScheme.onSurface,
                          )),
                    ],
                  ),
                  GestureDetector(
                    onLongPress: () {
                      setState(() {
                        monthIndex = 0;
                      });
                      calController.animateToPage(18,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut);
                    },
                    onHorizontalDragEnd: (details) {
                      if ((details.primaryVelocity!.sign > 0 &&
                              monthIndex > -18) ||
                          (details.primaryVelocity!.sign < 0 &&
                              monthIndex < 18)) {
                        setState(() {
                          monthIndex -= details.primaryVelocity!.sign.round();
                        });
                        calController.animateToPage(
                            calController.page!.round() -
                                details.primaryVelocity!.sign.round(),
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut);
                      }
                    },
                    child: Container(
                      color: colorScheme.surfaceContainer,
                      height: height,
                      width: width,
                      child: PageView(
                        controller: calController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: List<Widget>.generate(37, (i) {
                          int d = i - (monthIndex + 18);
                          DateTime iMonth =
                              DateTime(newMonth.year, newMonth.month + d);
                          double radius = (width - 10) / 28;
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List<Widget>.generate(6, (e) {
                              if (DateTime(iMonth.year, iMonth.month,
                                              e * 7 - iMonth.weekday + 1)
                                          .month !=
                                      iMonth.month &&
                                  DateTime(iMonth.year, iMonth.month,
                                              (e + 1) * 7 - iMonth.weekday)
                                          .month !=
                                      iMonth.month) {
                                return Container();
                              }
                              return Row(
                                children: List<Widget>.generate(7, (n) {
                                  DateTime dotDate = DateTime(
                                      iMonth.year,
                                      iMonth.month,
                                      n + e * 7 - iMonth.weekday + 1);
                                  double opacity = 0;
                                  if (dotDate.month == iMonth.month) {
                                    opacity += 0.05;
                                  }
                                  if (ScheduleData.schedule[dotDate] != null) {
                                    if (!ScheduleData.schedule[dotDate]!.name
                                        .contains("No Classes")) {
                                      opacity += 0.15;
                                    }
                                  }
                                  Color dotColor = Colors.black
                                      .withValues(alpha: 0.05 + opacity);
                                  Color textColor = Colors.black;
                                  if (dotDate == date) {
                                    dotColor = colorScheme.primary
                                        .withValues(alpha: 0.60 + opacity);
                                    textColor = colorScheme.onPrimary;
                                  } else if (dotDate ==
                                      ScheduleDisplay.initialDate) {
                                    dotColor = colorScheme.secondary
                                        .withValues(alpha: 0.60 + opacity);
                                    textColor = colorScheme.onSecondary;
                                  }
                                  return GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                        int change = GlobalMethods.addDay(
                                                ScheduleDisplay.initialDate,
                                                ScheduleDisplay.pageIndex)
                                            .difference(dotDate)
                                            .inDays;
                                        _controller.animateToPage(
                                            _controller.page!.round() - change,
                                            duration: Duration(
                                                milliseconds: change.abs() < 10
                                                    ? 250
                                                    : 1000),
                                            curve: Curves.easeInOut);
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(radius),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: dotColor,
                                              radius: radius,
                                            ),
                                            Text(dotDate.day.toString(),
                                                style:
                                                    TextStyle(color: textColor))
                                          ],
                                        ),
                                      ));
                                }),
                              );
                            }),
                          );
                        }),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  //Builds the arrow buttons for swapping between pages
  Widget _buildNavButton(BuildContext context, int direction) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    //Returns Arrow Icon Button
    return IconButton(
      //When pressed, animates to new page
      onPressed: () {
        //If forwards == true, animates to next page, if not, animates backwards
        _controller.animateToPage(_controller.page!.round() + direction,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      },
      //If forwards == true, displays forward arrow, if not, backwards arrow
      icon:
          Icon(direction > 0 ? Icons.arrow_forward_ios : Icons.arrow_back_ios),
      color: colorScheme.onSurface,
    );
  }

  //Builds the info popup button
  Widget _buildInfoButton(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder(future: ScheduleData.awaitCondition(() {
      return ScheduleData.dailyData[GlobalMethods.addDay(
              ScheduleDisplay.initialDate, ScheduleDisplay.pageIndex)] !=
          null;
    }), builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Opacity(
          opacity: 0.4,
          child: GlobalWidgets.iconCircle(
              icon: Icons.info_outline,
              iconColor: colorScheme.onSurface,
              color: colorScheme.tertiary,
              radius: 20,
              padding: 5,
              onTap: () {
                GlobalMethods.showPopup(
                    context,
                    ScheduleInfoDisplay(
                        date: GlobalMethods.addDay(ScheduleDisplay.initialDate,
                            ScheduleDisplay.pageIndex)));
              }),
        );
      }
      return GlobalWidgets.iconCircle(
          icon: Icons.info_outline,
          iconColor: colorScheme.onSurface,
          color: colorScheme.tertiary.withValues(alpha: 0.4),
          radius: 20,
          padding: 5,
          onTap: () {
            GlobalMethods.showPopup(
                context,
                ScheduleInfoDisplay(
                    date: GlobalMethods.addDay(ScheduleDisplay.initialDate,
                        ScheduleDisplay.pageIndex)));
          });
    });
  }
}