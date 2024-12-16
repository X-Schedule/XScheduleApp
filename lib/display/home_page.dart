import 'dart:async';

import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:localstorage/localstorage.dart';
import 'package:xschedule/global_variables/stream_signal.dart';
import 'package:xschedule/personal/welcome.dart';
import 'package:xschedule/personal/personal.dart';
import 'package:xschedule/schedule/schedule_display/schedule_display.dart';

/*
HomePage:
HomePage is the base file in charge of linking main.dart to the rest of the app

Displays the appbar, navbar, and is parent of the body
 */

//StatefulWidget: Widget capable of updating 'State's or instances
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  //Stream which allows reference to widgets across widget tree
  static StreamController<StreamSignal> homePageStream = StreamController();

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Pages available to scroll to using PageView
  List<Widget> pages = [
    const ScheduleDisplay(),
    const Personal(),
  ];

  //Controller of the PageView; allows access to variables and methods
  final PageController controller = PageController(initialPage: 0);

  //int value representing which page the pageView is on
  int pageIndex = 0;

  //Builds the HomePage
  @override
  Widget build(BuildContext context) {
    //Checks the local storage to see if app has gone through login page before
    HomePage.homePageStream = StreamController();
    //Will refresh when stream updated
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return StreamBuilder(
        stream: HomePage.homePageStream.stream,
        builder: (context, snapshot) {
          if (localStorage.getItem("state") != "logged") {
            return const Welcome();
          }
          return Scaffold(
            backgroundColor: colorScheme.primaryContainer,
            bottomNavigationBar: _buildNavBar(context),
            body: PageView(
              controller: controller,
              physics: const PageScrollPhysics(),
              //Once page changes, sets pageIndex to the new index
              onPageChanged: (i) {
                setState(() {
                  pageIndex = i;
                });
              },
              children: pages,
            ),
          );
        });
  }

  //The bottom nav bar
  Widget _buildNavBar(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    //Color used in navbar gradient
    Color gradient = colorScheme.primary;
    return GestureDetector(
      //Allows gestures on navbar to affect homepage
      onHorizontalDragEnd: (detail) {
        controller.animateToPage(
            pageIndex - detail.primaryVelocity!.sign.round(),
            duration: const Duration(milliseconds: 125),
            curve: Curves.easeInOut);
      },
      //Size of navbar
      child: SizedBox(
          height: 65,
          child: Stack(
            children: [
              //Navbar body aligned at bottom
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 62.5,
                  color: colorScheme.tertiaryContainer,
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPageIcon(context, Icons.calendar_month, 0),
                      _buildPageIcon(context, Icons.person, 1),
                    ],
                  ),
                ),
              ),
              //Navbar gradient aligned at top
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    gradient.withOpacity(0),
                    gradient.withOpacity(0.125),
                    gradient.withOpacity(0.25),
                    gradient.withOpacity(0)
                  ], begin: Alignment.bottomCenter, end: Alignment.topCenter)),
                ),
              ),
            ],
          )),
    );
  }

  //Builds the icons in the bottom NavBar
  Widget _buildPageIcon(BuildContext context, IconData icon, int index) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return TextButton(
        //When pressed, animated PageView to the selected page
        onPressed: () {
          controller.animateToPage(index,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut);
        },
        child: DecoratedIcon(
            decoration: IconDecoration(
                border: IconBorder(width: 2, color: colorScheme.onSurface)),
            icon: Icon(
              icon,
              //When page selected, icon is fully opaque and white; if not, only at 70% opacity
              color: colorScheme.onPrimary
                  .withOpacity(pageIndex == index ? 1 : 0.65),
              size: 30,
            )));
  }
}
