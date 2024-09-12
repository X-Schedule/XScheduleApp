import 'package:flutter/material.dart';
import 'package:xchedule/display/schedule_display.dart';
import 'package:xchedule/global_variables/global_widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: GlobalWidgets.xchedule(),
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.blueGrey,
      body: const ScheduleDisplay(),
    );
  }
}