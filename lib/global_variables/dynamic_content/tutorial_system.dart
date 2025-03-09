import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:showcaseview/showcaseview.dart';

class TutorialSystem {
  TutorialSystem(this.tutorials) {
    generateKeys(tutorials.keys.toSet(), reference: keys);
    finished = keys.isEmpty;
  }

  final Map<String, String> tutorials;
  final Map<String, GlobalKey> keys = {};

  bool finished = false;

  static Map<String, GlobalKey> generateKeys(Set<String> tutorials,
      {Map<String, GlobalKey>? reference}) {
    reference ??= {};
    for (String key in tutorials) {
      reference[key] = GlobalKey();
    }
    return reference;
  }

  Showcase showcase(
      {required BuildContext context,
      required String tutorial,
      required Widget child,
      bool dense = false,
      bool uniqueNull = false,
      bool circular = false,
      EdgeInsets? targetPadding}) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Showcase(
        key: key(tutorial, uniqueNull: uniqueNull),
        description: tutorials[tutorial],
        onToolTipClick: simulateTap,
        toolTipSlideEndDistance: dense ? 3 : 7,
        targetPadding: targetPadding ?? EdgeInsets.zero,
        onBarrierClick: () async {
          await Future.delayed(const Duration(milliseconds: 100));
          if (tutorial != tutorials.keys.lastOrNull && context.mounted) {
            ShowCaseWidget.of(context).next();
          }
        },
        descTextStyle: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: dense ? 15 : 17,
            height: dense ? 1 : null,
            fontFamily: 'Exo2'),
        tooltipBackgroundColor: colorScheme.primary,
        targetShapeBorder: circular
            ? CircleBorder()
            : RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
        tooltipActionConfig: TooltipActionConfig(
            alignment: MainAxisAlignment.end, gapBetweenContentAndAction: 0),
        tooltipActions: [
          TooltipActionButton.custom(
              button: ElevatedButton(
                  onPressed: () async {
                    await Future.delayed(const Duration(milliseconds: 50));
                    simulateTap();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      overlayColor: colorScheme.onPrimary),
                  child: Text(
                    "Next",
                    style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: dense ? 15 : 17,
                        height: dense ? 1 : null,
                        fontFamily: 'Exo2'),
                  )))
        ],
        child: child);
  }

  void refreshKeys() {
    generateKeys(tutorials.keys.toSet(), reference: keys);
    finished = keys.isEmpty;
  }

  void removeFinished() {
    for (String tutorial in tutorials.keys) {
      if ((localStorage.getItem(tutorial) ?? '') == 'T') {
        keys.remove(tutorial);
      }
    }
    if (keys.isEmpty) {
      finished = true;
    }
  }

  void clearStorage() {
    for (String tutorial in tutorials.keys) {
      localStorage.removeItem(tutorial);
    }
  }

  GlobalKey key(String tutorial, {bool uniqueNull = false}) {
    if (!uniqueNull) {
      keys[tutorial] ??= GlobalKey();
    }
    return keys[tutorial] ?? GlobalKey();
  }

  void showTutorials(final BuildContext context,
      {final bool storeCompletion = true}) {
    final Set<String> showTutorials = {};
    if (storeCompletion) {
      showTutorials.addAll(tutorials.keys
          .where((element) => (localStorage.getItem(element) ?? '').isEmpty));
    } else {
      showTutorials.addAll(tutorials.keys);
    }
    final List<GlobalKey> tutorialKeys = [];
    for (String tutorial in showTutorials) {
      localStorage.setItem(tutorial, 'T');
      tutorialKeys.add(key(tutorial));
    }

    if (tutorialKeys.isNotEmpty) {
      ShowCaseWidget.of(context).startShowCase(tutorialKeys);
    }
  }

  void simulateTap() {
    GestureBinding.instance.handlePointerEvent(
      PointerDownEvent(
        position: Offset.zero, // Adjust if needed
      ),
    );
    GestureBinding.instance.handlePointerEvent(
      PointerUpEvent(
        position: Offset.zero,
      ),
    );
  }

  void finish() {
    finished = true;
  }
}
