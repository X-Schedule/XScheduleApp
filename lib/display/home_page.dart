import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:xchedule/chat/chat.dart';
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

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //Pages available to scroll to using PageView
  List<Widget> pages = [
    const Personal(),
    const ScheduleDisplay(),
    const Chat(),
  ];

  //Controller of the PageView; allows access to variables and methods
  final PageController controller = PageController(initialPage: 1);

  //int value representing which page the pageView is on
  int pageIndex = 1;

  //Builds the HomePage
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      bottomNavigationBar: _buildNavBar(context),
      //Body goes behind the bottom navbar
      extendBody: true,
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

  //The bottom nav bar
  Widget _buildNavBar(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
          //Gradient from blue to transparent; stops from 60% to 75% to give further opacity
          gradient: LinearGradient(
              stops: const [0.6, 0.75],
              colors: [Colors.blueAccent, Colors.blueAccent.withOpacity(0)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter)),
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPageIcon(Icons.person, 0),
          _buildPageIcon(Icons.calendar_month, 1),
          _buildPageIcon(Icons.chat, 2),
        ],
      ),
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
              color: pageIndex == index ? Colors.white : Colors.white70,
              size: 30,
            )));
  }
}
