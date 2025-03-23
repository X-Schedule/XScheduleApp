import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../global_variables/static_content/global_variables.dart';
import '../global_variables/static_content/global_widgets.dart';

class Credits extends StatelessWidget {
  const Credits({super.key});

  static final Map<String, List<dynamic>> credits = {};

  static Future<void> loadCreditsJson() async {
    final String jsonString =
        await rootBundle.loadString("assets/data/credits.json");
    final Map<String, dynamic> json = jsonDecode(jsonString);
    credits.addAll(json.cast());
  }

  static Widget _buildTextList(BuildContext context, String key) {
    final List<dynamic> list = credits[key] ?? [];

    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            key,
            style: TextStyle(
                fontSize: 20,
                fontFamily: "Georama",
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface),
          ),
          Column(
            children: List<Widget>.generate((list.length / 2).round(), (r) {
              return Row(
                children: List<Widget>.generate(2, (c) {
                  final int index = 2 * r + c;
                  if (index >= list.length) {
                    return Container();
                  }
                  return Expanded(
                      child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        list[index],
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Georama",
                            color: colorScheme.onSurface),
                      ),
                    ),
                  ));
                }),
              );
            }),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final PackageInfo packageInfo = GlobalVariables.packageInfo;

    return GlobalWidgets.popup(
        context,
        SizedBox(
          width: mediaQuery.size.width * 4 / 5,
          height: mediaQuery.size.height * 2 / 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 125,
                margin: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset("assets/images/xschedule.png"),
                ),
              ),
              Text(
                "X-Schedule",
                style: TextStyle(
                    fontSize: 25,
                    fontFamily: "Georama",
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface),
              ),
              Text(
                "Contributors",
                style: TextStyle(
                    fontSize: 22.5,
                    height: 1,
                    fontFamily: "Georama",
                    color: colorScheme.onSurface,
                    decoration: TextDecoration.underline),
              ),
              Expanded(
                  child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List<Widget>.generate(credits.length, (i) {
                        final String key = credits.keys.elementAt(i);
                        return _buildTextList(context, key);
                      })),
                ),
              )),
              Text(
                "© 2024 St. Xavier HS\nAvailable under MIT license.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    height: 0.975,
                    fontSize: 17.5,
                    fontFamily: "Georama",
                    color: colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "v${packageInfo.version} Build ${packageInfo.buildNumber}",
                  style: TextStyle(
                      fontSize: 14,
                      height: 0.9,
                      fontFamily: "Georama",
                      color: colorScheme.onSurface),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ));
  }
}
