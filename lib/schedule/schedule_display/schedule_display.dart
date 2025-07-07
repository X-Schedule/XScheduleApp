/*
  * schedule_display.dart *
  Main page which displays the schedule.
  Consists of multiple Widgets which come together to form Schedule page.
  References other files under schedule_display for Widgets.
*/
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:xschedule/global/dynamic_content/backend/schedule_directory.dart';
import 'package:xschedule/global/dynamic_content/schedule.dart';
import 'package:xschedule/global/dynamic_content/stream_signal.dart';
import 'package:xschedule/global/static_content/extensions/build_context_extension.dart';
import 'package:xschedule/global/static_content/extensions/date_time_extension.dart';
import 'package:xschedule/global/static_content/extensions/int_extension.dart';
import 'package:xschedule/global/static_content/extensions/widget_extension.dart';
import 'package:xschedule/global/static_content/xschedule_materials/styled_button.dart';
import 'package:xschedule/schedule/schedule_display/schedule_info_display.dart';
import 'package:xschedule/schedule/schedule_settings/schedule_settings.dart';

import '../../global/dynamic_content/tutorial_system.dart';
import 'bell_display/bell_tile.dart';

/// Main page which displays the schedules. <p>
/// Features an AppBar with navigation and info and a PageView for all different schedules.
class ScheduleDisplay extends StatefulWidget {
  const ScheduleDisplay({super.key});

  // The current date, ignoring time
  static DateTime initialDate = DateTime.now().dateOnly();

  // A date verified to have a schedule for the tutorial; TBD
  static DateTime? tutorialDate;

  // pageIndex of Schedule PageView
  static int pageIndex = 0;

  // ScheduleDisplay Stream
  static StreamController<StreamSignal> scheduleStream =
      StreamController<StreamSignal>();

  // TutorialSystem used in ScheduleDisplay
  static final TutorialSystem tutorialSystem = TutorialSystem({
    'tutorial_schedule':
        "In this menu, you'll be able to see the schedule of any school day out of the year.",
    'tutorial_schedule_bell':
        'Each individual bell is set to match the information you provided about your class schedule, and clicking on any bell will display more information about it.',
    'tutorial_schedule_flex':
        'Additionally, you can tap the Flex bell to view information about lunch, clubs, and more!',
    'tutorial_schedule_date':
        "Up top, you'll find the date you're currently viewing. You can use the buttons or simple swiping gestures to flip between days.",
    'tutorial_schedule_calendar':
        "... or click this button to quickly navigate through the school days of the year.",
    'tutorial_schedule_info':
        "Tap this button to view important information about a school day, if available.",
    'tutorial_schedule_settings':
        'Lastly, if you ever want to edit your class information, you can do so by clicking this button.'
  });

  @override
  State<ScheduleDisplay> createState() => _ScheduleDisplayState();
}

class _ScheduleDisplayState extends State<ScheduleDisplay> {
  // Page uses PageController system with set amount of pages, starting in the middle to provide a "negative index" scroll effect
  // # of pages to display on PageView (3 years)
  static const int maxPages = 1095;

  // Starting page (middle of PageView; 1.5 years in)
  static const int initialPage = 547;

  // PageView controller; initial page with set index from "0"
  final PageController _controller =
      PageController(initialPage: initialPage + ScheduleDisplay.pageIndex);

  // Timer used to update current time indicator
  Timer? timer;

  // On Widget disposed, also dispose of timer and PageController
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    timer?.cancel();
  }

  // Method which begins the ScheduleDisplay tutorial
  Future<void> _showTutorial(BuildContext context) async {
    // awaits the fetching of schedule data before starting
    while (ScheduleDirectory.schedules.isEmpty) {
      // wait .1 seconds before checking again for Thread resting
      await Future.delayed(Duration(milliseconds: 100));
    }
    // Verify that >= .25 seconds have been waited for any page animation to finish
    await Future.delayed(const Duration(milliseconds: 250));
    if (!ScheduleDisplay.tutorialSystem.finished) {
      // Temporary counting int for determining tutorialDate
      int index = 0;
      if (ScheduleDisplay.tutorialDate == null) {
        while (index <= 25 && ScheduleDisplay.tutorialDate == null) {
          // Checks dates of both positive and negative count index from starting date for schedule
          if (_schedule(ScheduleDisplay.initialDate.addDay(index),
              tutorial: true)) {
            break;
          }
          if (_schedule(ScheduleDisplay.initialDate.addDay(-index),
              tutorial: true)) {
            index = -index;
            break;
          }
          // Increment index
          index++;
        }
        // If index = 26, no schedule was found, so exit
        if (index == 26) {
          return;
        }
        // ...else set tutorialDate to found schedule
        setState(() {
          ScheduleDisplay.tutorialDate =
              ScheduleDisplay.initialDate.addDay(index);
        });
        return;
      }
      // if animation needs to occur, run it and end
      if (index != ScheduleDisplay.pageIndex && index != 0) {
        // Set pageIndex to determined index, then animate page
        ScheduleDisplay.pageIndex = index;
        _controller.animateToPage(initialPage + index,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut);
      } else if (context.mounted) {
        // ...else begin tutorial
        ScheduleDisplay.tutorialSystem.showTutorials(context);
        ScheduleDisplay.tutorialSystem.finish();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    // Refreshes tutorialSystem GlobalKeys
    ScheduleDisplay.tutorialSystem.refreshKeys();
    ScheduleDisplay.tutorialSystem.removeFinished();

    // Runs addDailyData asynchronously on page moved; may do nothing at all if ranges overlap
    ScheduleDirectory.addDailyData(
        ScheduleDisplay.initialDate.addDay(ScheduleDisplay.pageIndex - 25),
        ScheduleDisplay.initialDate.addDay(ScheduleDisplay.pageIndex + 25));
    // Refreshes stream
    ScheduleDisplay.scheduleStream = StreamController();
    // ScheduleDisplay wrapped in StreamBuilder
    return StreamBuilder(
        stream: ScheduleDisplay.scheduleStream.stream,
        builder: (context, snapshot) {
          // ScheduleDisplay wrapped in Showcase View
          return ShowCaseWidget(onComplete: (_, __) {
            ScheduleDisplay.tutorialSystem.finish();
          }, builder: (context) {
            // Schedule tutorial to begin after widget finished building
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              await _showTutorial(context);
            });
            // ScheduleDisplay
            return Scaffold(
                backgroundColor: colorScheme.primaryContainer,
                // Body as Column w/ TopBar, PageView, and settings button
                body: Column(
                  children: [
                    // The TopBar containing calendar button, current viewing date, and info button
                    Container(
                      // Row w/ margin set to compensate for device safeZone
                      margin: EdgeInsets.only(
                          top: 8 + mediaQuery.padding.top, bottom: 8),
                      height: 50,
                      alignment: Alignment.center,
                      // TopBar
                      child: _buildTopBar(context),
                    ),
                    // Schedule PageView set to take up remaining column space
                    Expanded(child: _buildPageView(context)),
                    // ScheduleSettings Button
                    Container(
                      margin: EdgeInsets.symmetric(
                          horizontal: mediaQuery.size.width * .3),
                      height: 30,
                      // Button wrapped in ShowCase
                      child: ScheduleDisplay.tutorialSystem.showcase(
                          context: context,
                          tutorial: 'tutorial_schedule_settings',
                          child: StyledButton(
                            width: mediaQuery.size.width * .6,
                            icon: Icons.settings,
                            backgroundColor: colorScheme.secondary,
                            contentColor: colorScheme.onSecondary,
                            onTap: () {
                              // Push animated page of ScheduleSettings
                              context.pushSwipePage(const ScheduleSettings(
                                backArrow: true,
                              ));
                            },
                          )),
                    ),
                    // Bottom padding of 8px
                    const SizedBox(height: 8)
                  ],
                ));
          });
        });
  }

  // Builds the TopBar containing the calendar button, date title, and info button
  Widget _buildTopBar(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    // Simple row of buttons and title
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Calendar button w/ padding
        Padding(
          padding: const EdgeInsets.only(left: 16),
          // Calendar button wrapped in Showcase
          child: ScheduleDisplay.tutorialSystem.showcase(
              context: context,
              circular: true,
              tutorial: 'tutorial_schedule_calendar',
              // Calendar IconCircle (serves as button)
              child: WidgetExtension.iconCircle(
                  icon: Icons.calendar_month,
                  iconColor: colorScheme.onTertiary,
                  color: colorScheme.tertiary.withValues(alpha: 0.4),
                  radius: 20,
                  padding: 10,
                  onTap: () {
                    // Pushes the calendar navigation popup
                    context.pushPopup(
                        _buildCalendarNav(
                            context,
                            ScheduleDisplay.initialDate
                                .addDay(ScheduleDisplay.pageIndex)),
                        begin: Offset(0, -1));
                  })),
        ),
        // Current Date Navigator wrapped in Showcase
        ScheduleDisplay.tutorialSystem.showcase(
            context: context,
            tutorial: 'tutorial_schedule_date',
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Arrow IconButton
                _buildNavButton(context, -1),
                // Date Title is SizedBox
                SizedBox(
                  width: mediaQuery.size.width - 220,
                  child: Text(
                    ScheduleDisplay.initialDate
                        .addDay(ScheduleDisplay.pageIndex)
                        .dateText(),
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 32.5,
                        color: colorScheme.onSurface),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ).fit(),
                ),
                // Right Arrow IconButton
                _buildNavButton(context, 1),
              ],
            )),
        // Info button w/ padding
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: ScheduleDisplay.tutorialSystem.showcase(
              context: context,
              circular: true,
              tutorial: 'tutorial_schedule_info',
              // Info Button
              child: _buildInfoButton(context)),
        ),
      ],
    );
  }

  // Loading wheel which appears while fetching data
  Widget _buildLoading(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    // Remaining height on page for card
    final double cardHeight = mediaQuery.size.height -
        200 -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;
    // Returns Loading Wheel of set size aligned at center of space
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

  // Pseudo-PageView which displays all schedule cards
  Widget _buildPageView(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Returns PageView which builds schedule cards by index
    return PageView.builder(
        controller: _controller,
        physics: const PageScrollPhysics(),
        // When page index changes, updates pageIndex variable
        onPageChanged: (i) {
          setState(() {
            ScheduleDisplay.pageIndex = i - initialPage;
          });
        },
        // # of pages to ~1000, creating pseudo-endless scrolling effect in both directions
        itemCount: maxPages,
        // Builds the schedules based on given index (i)
        itemBuilder: (_, i) {
          // The date of the schedule by index (currentDate+index)
          final DateTime date =
              ScheduleDisplay.initialDate.addDay(i - initialPage);

          // Schedule card wrapped in GestureDetector
          return GestureDetector(
            // On long tap, animate to current date schedule
            onLongPress: () {
              _controller.animateToPage(
                  (_controller.page! - ScheduleDisplay.pageIndex).floor(),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut);
              ScheduleDisplay.pageIndex = 0;
            },
            // Vertical swipe listener
            onVerticalDragEnd: (detail) {
              // If swipe up, animate to next page (to correct people who try and do that fsr)
              if (detail.primaryVelocity! < 0) {
                _controller.animateToPage((_controller.page! + 1).floor(),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut);
                ScheduleDisplay.pageIndex++;
              } else {
                // If swipe down, bring up calendar navigation popup
                context.pushPopup(
                    _buildCalendarNav(
                        context,
                        ScheduleDisplay.initialDate
                            .addDay(ScheduleDisplay.pageIndex)),
                    begin: Offset(0, -1));
              }
            },
            // Schedule Builder wrapped in Decoration Container
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              // Decoration with simple offset shadow
              decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: colorScheme.surfaceContainer,
                        blurRadius: 3,
                        spreadRadius: 1),
                    BoxShadow(
                        color: colorScheme.surfaceContainer,
                        offset: const Offset(2.25, 2.25))
                  ]),
              // If schedule data is empty, return FutureBuilder for schedule, else simply display schedule
              child: ScheduleDirectory.schedules.isEmpty
                  // FutureBuilder, which displays placeholder (loading wheel) while data is fetched asynchronously, then replaced by schedule
                  ? FutureBuilder(
                      // Fetches schedule data (limited by default so single request)
                      future: ScheduleDirectory.getDailyOrder(),
                      // Builder which updates on method status change
                      builder: (context, snapshot) {
                        // If method loading, display loading wheel
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildLoading(context);
                        }
                        // If method fails (has error), display loading and error message
                        if (snapshot.hasError) {
                          context.showSnackBar(
                              "An error occurred. Please try again later.");
                          return _buildLoading(context);
                        }
                        // If no failure, add schedule data and return schedule card
                        ScheduleDirectory.schedules.addAll(snapshot.data ?? {});
                        return _buildSchedule(context, date);
                      })
                  // ...else simply display schedule
                  : _buildSchedule(context, date),
            ),
          );
        });
  }

  // Builds the schedule card based on given date
  Widget _buildSchedule(BuildContext context, DateTime date) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    // Determines remaining height for card on page
    final double cardHeight = mediaQuery.size.height -
        200 -
        mediaQuery.padding.top -
        mediaQuery.padding.bottom;

    // If schedule does not exist for date, display "No Classes"
    if (!_schedule(date)) {
      //i.e. no schedule/classes
      return _buildEmpty(context, cardHeight);
    }

    // Schedule variables from date (by now, schedule cannot be null)
    final Schedule schedule = ScheduleDirectory.schedules[date]!;
    final Map<String, String> bells = schedule.bells;

    // The height (in pxs) that each minute will be on the screen, based on the devices screen size etc.
    final double minuteHeight = cardHeight / 430;

    // Returns the schedule wrapped in Showcase
    return ScheduleDisplay.tutorialSystem.showcase(
        context: context,
        uniqueNull: true,
        tutorial: date == ScheduleDisplay.tutorialDate
            ? 'tutorial_schedule'
            : 'no_tutorial',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          // Stack containing schedule and current-time overlay
          child: Stack(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 5, right: 15),
                height: cardHeight,
                // Row containing timeline and schedule
                child: Row(
                  children: [
                    // Column timeline aligned left (technically a Stack)
                    Stack(
                      // Generated list of Text widgets
                      children: List<Widget>.generate(8, (i) {
                        int hour = (i + 8) % 12;
                        if (hour == 0) {
                          hour = 12;
                        }
                        // Vertical padding incremental to index
                        return Padding(
                            padding:
                                EdgeInsets.only(top: minuteHeight * i * 60),
                            child: Text(
                              // Time text incremental to index
                              '${hour.multiDecimal()} - ',
                              style: TextStyle(
                                  fontSize: 15,
                                  height: 0.9,
                                  color: colorScheme
                                      .onSurface), //Text px height = 18
                            ));
                      }),
                    ),
                    // Expanded Box (as much width as possible) wrapping sized box (set height of card) wrapping stack of bell tiles
                    Expanded(
                        child: Container(
                      padding: const EdgeInsets.only(top: 6.5),
                      height: cardHeight,
                      // Schedule column generated by schedule order (technically a Stack)
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: List<Widget>.generate(bells.keys.length, (i) {
                          // Returns Schedule 'Tile' based on schedule info, cycling through bell keys
                          final String key = bells.keys.toList()[i];
                          return BellTile(
                              date: date,
                              bell: key,
                              minuteHeight: minuteHeight);
                        }),
                      ),
                    )),
                  ],
                ),
              ),
              // Current Time Indicator
              StatefulBuilder(builder: (context, setTimeState) {
                // Timer set to refresh time indicator every
                timer = Timer.periodic(const Duration(minutes: 1), (timer) {
                  timer.cancel();
                  if (context.mounted) {
                    setTimeState(() {});
                  }
                });

                // Calculates the margin, from the top of the schedule, at which the current time indicator is placed
                final DateTime currentTime = DateTime.now();
                final double timeMargin =
                    currentTime.hour * 60 + currentTime.minute - 480;

                // If time isn't to be displayed, return empty Container
                if (timeMargin < 0 ||
                    timeMargin > 425 ||
                    date != ScheduleDisplay.initialDate) {
                  return Container();
                }

                // Return translucent overlay of time indicator
                return Opacity(
                  opacity: 0.6,
                  // Padding from top corresponding to current time
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 25, top: timeMargin * cardHeight / 425),
                    // Row containing blue line and arrow icon
                    child: Row(
                      children: [
                        Container(
                          height: 1.5,
                          width: mediaQuery.size.width - 83,
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_back_ios,
                          size: 10,
                          color: colorScheme.secondary,
                        )
                      ],
                    ),
                  ),
                );
              })
            ],
          ),
        ));
  }

  // Checks that all info of the schedule of a given date is proper
  bool _schedule(DateTime date, {bool tutorial = false}) {
    final Schedule schedule = ScheduleDirectory.readSchedule(date);
    // If checking for tutorial, ensure that there is a flex and standard bell
    if (tutorial) {
      if (schedule.firstBell == null || schedule.firstFlex == null) {
        return false;
      }
    }
    // Checks if schedule has bells
    if (schedule.bells.isEmpty) {
      return false;
    }
    // Removes any bells with fault Clocks
    List<String> keys = schedule.bells.keys.toList();
    for (String key in keys) {
      if (schedule.clockMap(key) == null) {
        ScheduleDirectory.schedules[date]!.bells.remove(key);
      }
    }
    return true;
  }

  // Builds the display for a day with no classes
  Widget _buildEmpty(BuildContext context, double cardHeight) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Returns "No Classes" text centered
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

  // Builds the calendar navigation popup
  Widget _buildCalendarNav(BuildContext context, DateTime date) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    // Sizing of popup
    final double height = mediaQuery.size.width * 24 / 35;
    final double width = mediaQuery.size.width * 4 / 5;
    // Radius of date dot
    final double radius = (width - 10) / 28;

    // Variables handling the page of the calendar PageView
    int monthIndex = date.monthDiff(ScheduleDisplay.initialDate);
    final PageController calController =
        PageController(initialPage: 18 + monthIndex);

    // Returns popup wrapped in StatefulBuilder
    return StatefulBuilder(builder: (context, setState) {
      DateTime newMonth = DateTime(ScheduleDisplay.initialDate.year,
          ScheduleDisplay.initialDate.month + monthIndex);
      // Popup of fixed size card aligned at center
      return Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: width,
          height: 69 + height,
          child: Card(
              color: colorScheme.surface,
              // Forces contents to match Card border shape
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title row consisting of month text amd navigator buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Left Arrow IconButton
                      IconButton(
                          iconSize: 25,
                          onPressed: () {
                            // Assuming destination within bounds, animates page one to teh left
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
                          // Simple left arrow icon
                          icon: Icon(Icons.arrow_back_ios,
                              color: colorScheme.onSurface)),
                      // Month text fitted to set size
                      SizedBox(
                        width: width - 200,
                        height: 50,
                        child: Text(
                          // Text in Month Year format
                          "${newMonth.monthText()} ${newMonth.year}",
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 24,
                              color: colorScheme.onSurface),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                        ).fit(),
                      ),
                      // Right Arrow IconButton
                      IconButton(
                          iconSize: 25,
                          onPressed: () {
                            // If destination within bounds, animate one page right
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
                          // Simple right arrow icon
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: colorScheme.onSurface,
                          )),
                    ],
                  ),
                  // Calendar view wrapped in GestureDetector
                  GestureDetector(
                    // On long tap, return to starting month (similar to schedule PageView)
                    onLongPress: () {
                      setState(() {
                        monthIndex = 0;
                      });
                      calController.animateToPage(18,
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut);
                    },
                    // On horizontal swipe, animate to next/last month
                    onHorizontalDragEnd: (details) {
                      // If destination within bounds, animate to 1 page away
                      if ((details.primaryVelocity!.sign > 0 &&
                              monthIndex > -18) ||
                          (details.primaryVelocity!.sign < 0 &&
                              monthIndex < 18)) {
                        setState(() {
                          monthIndex -= details.primaryVelocity!.sign.round();
                        });
                        // Animates to page -sign() away from current page
                        calController.animateToPage(
                            calController.page!.round() -
                                details.primaryVelocity!.sign.round(),
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut);
                      }
                    },
                    // Calendar view (generative PageView of set dimensions)
                    child: Container(
                      color: colorScheme.surfaceContainer,
                      height: height,
                      width: width,
                      child: PageView(
                        controller: calController,
                        // Ignore standard scrolling; use GestureDetector for snappier physics
                        physics: const NeverScrollableScrollPhysics(),
                        // Generates pages of columns and rows of date dots
                        children: List<Widget>.generate(37, (i) {
                          // Month index from current month
                          final int d = i - (monthIndex + 18);
                          // DT month of page
                          final DateTime iMonth =
                              DateTime(newMonth.year, newMonth.month + d);

                          // Returns column of generated rows
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            // Generated rows within column
                            children: List<Widget>.generate(6, (e) {
                              // DT month of row start
                              final eMonth = DateTime(iMonth.year, iMonth.month,
                                  e * 7 - iMonth.weekday + 1);
                              // Checks if week row being generated contains >= 1 date within the page's month
                              if (eMonth.month != iMonth.month &&
                                  eMonth.addDay(6).month != iMonth.month) {
                                return Container();
                              }
                              return Row(
                                children: List<Widget>.generate(7, (n) {
                                  // DT of date dot
                                  DateTime dotDate = eMonth.addDay(n);

                                  // Determines opacity of date dot
                                  double opacity = 0;
                                  // If date in main month, add 5%
                                  if (dotDate.month == iMonth.month) {
                                    opacity += 0.05;
                                  }
                                  // If date has schedule, add 15%
                                  if (_schedule(dotDate)) {
                                    opacity += 0.15;
                                  }

                                  // Determines color of date dot
                                  Color dotColor = Colors.black
                                      .withValues(alpha: 0.05 + opacity);
                                  Color textColor = Colors.black;
                                  // Primary for selected date
                                  if (dotDate == date) {
                                    dotColor = colorScheme.primary
                                        .withValues(alpha: 0.60 + opacity);
                                    textColor = colorScheme.onPrimary;
                                    // Secondary for current date
                                  } else if (dotDate ==
                                      ScheduleDisplay.initialDate) {
                                    dotColor = colorScheme.secondary
                                        .withValues(alpha: 0.60 + opacity);
                                    textColor = colorScheme.onSecondary;
                                  }
                                  // Returns Date Dot
                                  return InkWell(
                                      // Pops popup and animates schedule to selected date
                                      onTap: () {
                                        Navigator.pop(context);
                                        final int change = ScheduleDisplay
                                            .initialDate
                                            .addDay(ScheduleDisplay.pageIndex)
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
                                      // Date Dot
                                      child: Padding(
                                        padding: EdgeInsets.all(radius),
                                        // Stack of background dot and date text
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
              ).clip(borderRadius: BorderRadius.circular(12))),
        ),
      );
    });
  }

  // Builds the arrow buttons for swapping between pages
  Widget _buildNavButton(BuildContext context, int direction) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Returns Arrow Icon Button
    return IconButton(
      // When pressed, animates to new page
      onPressed: () {
        // If forwards == true, animates to next page, if not, animates backwards
        _controller.animateToPage(_controller.page!.round() + direction,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut);
      },
      // If forwards == true, displays forward arrow, if not, backwards arrow
      icon:
          Icon(direction > 0 ? Icons.arrow_forward_ios : Icons.arrow_back_ios),
      color: colorScheme.onSurface,
    );
  }

  // Builds the info popup button
  Widget _buildInfoButton(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    // Returns FutureBuilder, changing opacity of button as more info becomes available
    return FutureBuilder(future: ScheduleDirectory.awaitCondition(() {
      return ScheduleDirectory.readSchedule(
              ScheduleDisplay.initialDate.addDay(ScheduleDisplay.pageIndex))
          .info
          .isEmpty;
    }), builder: (context, snapshot) {
      // Returns IconCircle of info button
      return WidgetExtension.iconCircle(
          // Simple info icon
          icon: Icons.info_outline,
          // Icon opacity changes w/ info available
          iconColor: colorScheme.onSurface.withAlpha(
              snapshot.connectionState == ConnectionState.waiting ? 102 : 255),
          color: colorScheme.tertiary.withAlpha(102),
          radius: 20,
          padding: 5,
          // OnTap, pushes info popup
          onTap: () {
            context.pushPopup(ScheduleInfoDisplay(
                date: ScheduleDisplay.initialDate
                    .addDay(ScheduleDisplay.pageIndex)));
          });
    });
  }
}
