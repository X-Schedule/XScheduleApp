import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:xchedule/display/schedule_display.dart';

import '../data_processing/data_fetcher.dart';
import '../data_processing/schedule.dart';

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
        title: Text('Xchedule', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.blueAccent,
      ),
      backgroundColor: Colors.blueGrey,
      body: ScheduleDisplay(),
    );
  }
}