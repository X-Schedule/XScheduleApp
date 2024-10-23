import 'package:color_hex/class/hex_to_color.dart';
import 'package:flutter/material.dart';
import 'package:xchedule/global_variables/clock.dart';
import 'package:xchedule/global_variables/gloabl_methods.dart';
import 'package:xchedule/global_variables/global_widgets.dart';
import 'package:xchedule/schedule/schedule.dart';
import 'package:xchedule/schedule/schedule_data.dart';
import 'package:xchedule/schedule/schedule_display/club_schedule_display.dart';
import 'package:xchedule/schedule/schedule_display/schedule_info_display.dart';
import 'package:xchedule/schedule/schedule_settings.dart';

/*
ScheduleDisplay:
Displays the daily schedules
 */

class ScheduleDisplay extends StatefulWidget {
  const ScheduleDisplay({super.key});

  //Gets the current date (ignoring time)
  static DateTime initialDate =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  //pageIndex of Schedule PageView
  static int pageIndex = 0;

  @override
  State<ScheduleDisplay> createState() => _ScheduleDisplayState();
}

class _ScheduleDisplayState extends State<ScheduleDisplay> {
  //Creates the controller of PageView and sets the max # of pages; controller starts in the middle
  //Set to 365*3 to allow to allow viewing of 3 years of schedules
  int maxPages = 365 * 3;
  final PageController _controller = PageController(
      initialPage: (365 * 3 / 2).round() + ScheduleDisplay.pageIndex);

  @override
  Widget build(BuildContext context) {
    //Runs addDailyData asynchronously on page moved; may do nothing at all if ranges overlap
    ScheduleData.addDailyData(
        ScheduleDisplay.initialDate
            .add(Duration(days: ScheduleDisplay.pageIndex - 25)),
        ScheduleDisplay.initialDate
            .add(Duration(days: ScheduleDisplay.pageIndex + 25)));
    return Column(
      children: [
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
                child: GlobalWidgets.iconCircle(
                    icon: Icons.calendar_month,
                    color: Colors.blueGrey.withOpacity(0.4),
                    radius: 20,
                    padding: 10,
                    onTap: () {}),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNavButton(false),
                  SizedBox(
                    width: 250,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Text(
                        GlobalMethods.dateText(ScheduleDisplay.initialDate
                            .add(Duration(days: ScheduleDisplay.pageIndex))),
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 32.5),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                  _buildNavButton(true),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: _buildInfoButton(),
              ),
            ],
          ),
        ),
        //The schedule card viewer
        Expanded(child: _buildPageView()),
        //Button which leads to ScheduleSettings
        Container(
          margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * .3),
          height: 25,
          child: ElevatedButton(
              onPressed: () {
                GlobalMethods.pushSwipePage(
                    context,
                    const ScheduleSettings(
                      backArrow: true,
                    ));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary),
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 3 / 5,
                child: Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              )),
        ),
        const SizedBox(height: 80)
      ],
    );
  }

  //Loading wheel which appears while fetching data
  Widget _buildLoading(BuildContext context) {
    double cardHeight = MediaQuery.of(context).size.height - 200.5;
    return Container(
      height: cardHeight,
      alignment: Alignment.center,
      child: const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(),
      ),
    );
  }

  //Pseudo-PageView which displays all schedule cards
  Widget _buildPageView() {
    return PageView.builder(
        controller: _controller,
        //Removes default scrolling functionality
        physics: const NeverScrollableScrollPhysics(),
        //When page index is changes, updates pageIndex variable
        onPageChanged: (i) {
          setState(() {
            ScheduleDisplay.pageIndex = i - (maxPages / 2).round();
          });
        },
        itemCount: maxPages,
        //Builds the schedules based on given index(i)
        itemBuilder: (context, i) {
          //The date of the schedule (currentDate+index)
          DateTime date = ScheduleDisplay.initialDate
              .add(Duration(days: i - (maxPages / 2).round()));

          //Schedule card wrapped in gestureDetector
          return GestureDetector(
              //When user swiped card, animated to schedule card
              onHorizontalDragEnd: (detail) {
                //The sign (-1 or +1) of the swipe velocity
                int direction = (detail.primaryVelocity ?? 0).sign.round();
                //Animates to page-1 or page+1
                _controller.animateToPage(i - direction,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut);
              },
              //Schedule card
              child: Card(
                  margin:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  color: Theme.of(context).colorScheme.surface,
                  //If schedule data has been gathered, displays as usual; if not, used future builder to get it
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
                            return _buildSchedule(date, context);
                          })
                      : _buildSchedule(date, context)));
        });
  }

  //Builds the schedule card based on given date
  Widget _buildSchedule(DateTime date, BuildContext context) {
    Schedule dayInfo = ScheduleData.schedule[date] ?? Schedule.empty();
    double cardHeight = MediaQuery.of(context).size.height - 197;
    if (!_schedule(date)) {
      //i.e. no schedule/classes
      return _buildEmpty(cardHeight);
    }
    //Schedule data
    Map schedule = dayInfo.schedule;
    //The height (in pxs) that each minute will be on the screen, based on the devices screen size etc.
    double minuteHeight = cardHeight / 430;
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 10),
      height: cardHeight - 20,
      child: Row(
        children: [
          //Column of time references to the left
          Stack(
            children: List<Widget>.generate((dayInfo.end!.difference(dayInfo.start!).inHours)+1, (i) {
              return Padding(
                  padding: EdgeInsets.only(top: minuteHeight * i * 60),
                  child: Text(
                    '${i + 8 < 10 ? '0${i + 8}' : i + 8} - ',
                    style: const TextStyle(
                        fontSize: 15, height: 0.9), //Text px height = 18
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
              children: List<Widget>.generate(schedule.keys.length, (i) {
                //Returns Schedule 'Tile' based on schedule info
                String key = schedule.keys.toList()[i];
                return _buildTile(context, dayInfo, key, minuteHeight);
              }),
            ),
          )),
        ],
      ),
    );
  }

  //Checks that all info of the schedule of a given date is proper
  bool _schedule(DateTime date) {
    Schedule dayInfo = ScheduleData.schedule[date] ?? Schedule.empty();
    if (dayInfo.schedule.isEmpty || dayInfo.schedule.containsKey('-')) {
      return false;
    }
    List<String> keys = dayInfo.schedule.keys.toList();
    for (String key in keys) {
      if (dayInfo.clockMap(key) == null) {
        return false;
      }
    }
    return true;
  }

  //Builds the 'Schedule Tile's displayed on the schedule card
  Widget _buildTile(BuildContext context, Schedule schedule, String bell,
      double minuteHeight) {
    //Gets Map from schedule_settings.dart
    Map settings = ScheduleSettings.bellInfo[bell] ?? {};

    bool activities = bell.toLowerCase().contains("flex");

    Map times = schedule.clockMap(bell) ?? {};
    //Gets the height (in pxs) of the tile, based on minuteHeight (see _buildSchedule)
    double height = minuteHeight * times['start']?.difference(times['end']);

    double margin = Clock(hours: 8).difference(times['start']) * minuteHeight;
    //Returns Tile Wrapped in GestureDetector
    return GestureDetector(
        //When Tile is tapped, will display popup with more info
        onTap: () {
          GlobalMethods.showPopup(
              context, _buildBellInfo(context, schedule, bell));
        },
        //Tile
        child: Container(
          height: height,
          margin: EdgeInsets.only(top: margin),
          color: activities
              ? Theme.of(context).colorScheme.surfaceContainer
              : Theme.of(context).colorScheme.shadow,
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
                      backgroundColor: Colors.black26,
                      radius: height * 3 / 7 - 5,
                    ),
                    Text(
                      //If no emoji set in settings, displays default book emoji
                      settings['emoji'] ?? '📚',
                      style: TextStyle(fontSize: height * 3 / 7),
                    )
                  ],
                ),
              //Text (with line skips) wrapped in FittedBox
              Container(
                margin: const EdgeInsets.only(left: 7.5),
                alignment: Alignment.centerLeft,
                width: MediaQuery.of(context).size.width -
                    110 -
                    (activities ? 70 : 0) -
                    (height * 6 / 7 - 10),
                child: FittedBox(
                  //If text overflows the tile, will shrink to fully include it
                  fit: BoxFit.contain,
                  //Displays the class name (if null, then bell name), line skip, then time range
                  child: Text(
                      '${(settings['name'] ?? bell) ?? ''}${height > 50 ? '\n' : ':     '}${times['start'].display()} - ${times['end'].display()}'),
                ),
              ),
              if (activities)
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    iconSize: 35,
                    onPressed: () {
                      GlobalMethods.showPopup(
                          context,
                          ClubScheduelDsiplay(
                              date: ScheduleDisplay.initialDate.add(
                                  Duration(days: ScheduleDisplay.pageIndex)),
                              schedule: schedule));
                    },
                    icon: const Icon(Icons.sports_soccer),
                  ),
                )
            ],
          ),
        ));
  }

  //Builds the display for a day with no classes
  Widget _buildEmpty(double cardHeight) {
    return Container(
      height: cardHeight,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(left: 5, right: 10, top: 10, bottom: 10),
      child: const Text(
        'No Classes',
        style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
      ),
    );
  }

  //Builds the bell info popup
  Widget _buildBellInfo(BuildContext context, Schedule schedule, String bell) {
    //Gets settings from schedule_settings.dart
    Map settings = ScheduleSettings.bellInfo[bell] ?? {};
    Map times = schedule.clockMap(bell) ?? {};
    //Aligns on center of screen
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
            child: Row(
              children: [
                //Left color nib w/ rounded edges
                Container(
                  decoration: BoxDecoration(
                    //rounds the left edges to match the Card
                    borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(10)),
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
                                  backgroundColor:
                                      Theme.of(context).colorScheme.shadow,
                                  radius: 45,
                                ),
                                Text(
                                  settings['emoji'] ?? '📚',
                                  style: const TextStyle(fontSize: 50),
                                )
                              ],
                            ),
                            //Title Container
                            Container(
                              width: MediaQuery.of(context).size.width * 4 / 5 -
                                  130,
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
                                      style: const TextStyle(
                                          height: 0.9,
                                          fontSize: 25,
                                          //bold
                                          fontWeight: FontWeight.w600),
                                    ),
                                    //Displays teacher or nothing (if null)
                                    if (settings['teacher'] != null)
                                      Text(
                                        settings['teacher'],
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    //Displays the location of the class or nothing (if null)
                                    if (settings['location'] != null)
                                      Text(
                                        settings['location'],
                                        style: const TextStyle(
                                            fontSize: 18,
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
                                  style: const TextStyle(
                                      height: 0.9,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500),
                                ),
                                //Displays the time length (time length cannot be null)
                                Text(
                                  '${times['start'].display()} - ${times['end'].display()}',
                                  style: const TextStyle(
                                      height: 0.9,
                                      fontSize: 25,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ))
                      ],
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Builds the arrow buttons for swapping between pages
  Widget _buildNavButton(bool forwards) {
    //Returns Arrow Icon Button
    return IconButton(
        //When pressed, animates to new page
        onPressed: () {
          //If forwards == true, animates to next page, if not, animates backwards
          _controller.animateToPage(
              _controller.page!.round() + (forwards ? 1 : -1),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut);
        },
        //If forwards == true, displays forward arrow, if not, backwards arrow
        icon: Icon(forwards ? Icons.arrow_forward_ios : Icons.arrow_back_ios));
  }

  //Builds the info popup button
  Widget _buildInfoButton() {
    return FutureBuilder(future: ScheduleData.awaitCondition(() {
      return ScheduleData.dailyData[ScheduleDisplay.initialDate
              .add(Duration(days: ScheduleDisplay.pageIndex))] !=
          null;
    }), builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Opacity(
          opacity: 0.4,
          child: GlobalWidgets.iconCircle(
              icon: Icons.info_outline,
              color: Colors.blueGrey.withOpacity(0.4),
              radius: 20,
              padding: 5,
              onTap: () {
                GlobalMethods.showPopup(
                    context,
                    ScheduleInfoDisplay(
                        date: ScheduleDisplay.initialDate
                            .add(Duration(days: ScheduleDisplay.pageIndex))));
              }),
        );
      }
      return GlobalWidgets.iconCircle(
          icon: Icons.info_outline,
          color: Colors.blueGrey.withOpacity(0.4),
          radius: 20,
          padding: 5,
          onTap: () {
            GlobalMethods.showPopup(
                context,
                ScheduleInfoDisplay(
                    date: ScheduleDisplay.initialDate
                        .add(Duration(days: ScheduleDisplay.pageIndex))));
          });
    });
  }
}
