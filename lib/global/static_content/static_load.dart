import 'package:flutter/material.dart';

class StaticLoad extends StatelessWidget {
  const StaticLoad({super.key});

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xfff4ecdb),
      body: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: mediaQuery.size.width/2,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Image.asset('assets/images/xschedule.png'),
          ),
        ),
      )
    );
  }
}