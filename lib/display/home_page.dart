import 'dart:async';

import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:localstorage/localstorage.dart';
import 'package:xchedule/global_variables/stream_signal.dart';
import 'package:xchedule/personal/welcome.dart';
import 'package:xchedule/personal/personal.dart';
import 'package:xchedule/schedule/schedule_display/schedule_display.dart';

/*
HomePage:
HomePage is the base file in charge of linking main.dart to the rest of the app

Displays the appbar, navbar, and is parent of the body
 */

//StatefulWidget: Widget capable of updating 'State's or instances
class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
    return StreamBuilder(
        stream: HomePage.homePageStream.stream,
        builder: (context, snapshot){
          if (localStorage.getItem("state") != "logged") {
            return const Welcome();
          }
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            bottomNavigationBar: _buildNavBar(context),
            body: PageView(
              controller: controller,
              //Once page changes, sets pageIndex to the new index
              onPageChanged: (i) {
                setState(() {
                  pageIndex = i;
                });
              },
              children: pages,
            ),
          );
        }
    );
  }

  //The bottom nav bar
  Widget _buildNavBar(BuildContext context) {
    Color gradient = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onHorizontalDragEnd: (detail) {
        controller.animateToPage(
            pageIndex - detail.primaryVelocity!.sign.round(),
            duration: const Duration(milliseconds: 125),
            curve: Curves.easeInOut);
      },
      child: SizedBox(
          height: 65 + MediaQuery.of(context).padding.bottom,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 62.5 + MediaQuery.of(context).padding.bottom,
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  padding: EdgeInsets.only(
                      bottom: 15 + MediaQuery.of(context).padding.bottom),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPageIcon(Icons.calendar_month, 0),
                      _buildPageIcon(Icons.person, 1),
                    ],
                  ),
                ),
              ),
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
  Widget _buildPageIcon(IconData icon, int index) {
    return TextButton(
        //When pressed, animated PageView to the selected page
        onPressed: () {
          controller.animateToPage(index,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut);
        },
        child: DecoratedIcon(
            decoration: const IconDecoration(
                border: IconBorder(width: 2, color: Colors.black)),
            icon: Icon(
              icon,
              //When page selected, icon is fully opaque and white; if not, only at 70% opacity
              color: pageIndex == index ? Colors.white : Colors.white.withOpacity(0.65),
              size: 30,
            )));
  }
}
