import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:xschedule/display/home_page.dart';

import '../personal/welcome.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  // 
  static void determineDestination(BuildContext context) {
    if (localStorage.getItem("state") != "logged") {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const Welcome()), (_) => false);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const HomePage()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_){
      determineDestination(context);
    });
    return Container();
  }
}
