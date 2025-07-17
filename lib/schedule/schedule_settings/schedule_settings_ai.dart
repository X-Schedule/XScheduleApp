import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:xschedule/global/static_content/extensions/build_context_extension.dart';
import 'package:xschedule/global/static_content/extensions/widget_extension.dart';
import 'package:xschedule/schedule/schedule_settings/bell_settings/bell_settings.dart';

import '../../global/dynamic_content/backend/open_ai.dart';
import '../../global/dynamic_content/schedule.dart';
import '../../global/static_content/xschedule_materials/popup_menu.dart';

class ScheduleSettingsAi extends StatefulWidget {
  const ScheduleSettingsAi({super.key});

  @override
  State<ScheduleSettingsAi> createState() => _ScheduleSettingsAiState();
}

class _ScheduleSettingsAiState extends State<ScheduleSettingsAi> {
  // Image file uploaded to AI; null by default
  File? imageFile;
  bool isLoading = false;
  bool uploaded = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final MediaQueryData mediaQuery = MediaQuery.of(context);

    final double width = min(mediaQuery.size.width, 500);

    // Status booleans
    uploaded = imageFile != null;
    isLoading = false;

    // Returns popup wrapped in StatefulBuilder
    return PopupMenu(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                // Title wrapped in FittedBox
                child: Text(
                  "Schedule from Image",
                  style: TextStyle(
                      fontFamily: "Exo2",
                      fontSize: 35,
                      fontWeight: FontWeight.w600),
                ).fit()),
            // Image display wrapped in button
            InkWell(
              highlightColor: colorScheme.onSurface,
              onTap: () async {
                // Requests image through camera roll selection
                if (!isLoading) {
                  await selectImage(setState);
                }
              },
              // Image display Stack
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Image wrapped in Container w/ border
                  Container(
                      width: width * 3 / 5,
                      height: width * 3 / 5,
                      // 5px border
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: colorScheme.onSurface.withAlpha(128),
                              width: 5)),
                      padding: const EdgeInsets.all(2.5),
                      margin: const EdgeInsets.all(15),
                      alignment: Alignment.center,
                      // If image has been selected, display it; if not, display selection Icon
                      child: uploaded
                          // Image which covers given space
                          ? SizedBox(
                              width: width * 3 / 5,
                              height: width * 3 / 5,
                              child: ClipRect(
                                  child: FittedBox(
                                fit: BoxFit.cover,
                                child: Image.file(imageFile!),
                              )),
                            )
                          // Image selection icon
                          : Icon(
                              Icons.photo_outlined,
                              size: width * 1 / 2,
                              color: colorScheme.onSecondary,
                            )),
                  // If image has been uploaded, display icon as reminder that new image can be selected
                  if (uploaded && !isLoading)
                    Opacity(
                      opacity: 0.1,
                      child: Icon(
                        Icons.photo_outlined,
                        size: width * 1 / 2,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  // If is loading, display Shimmer effect to represent loading
                  if (isLoading)
                    Opacity(
                      opacity: 0.75,
                      child: Shimmer.fromColors(
                          baseColor: colorScheme.surface.withAlpha(128),
                          highlightColor: colorScheme.onPrimary,
                          child: Container(
                              width: width * 3 / 5 - 15,
                              height: width * 3 / 5 - 15,
                              color: colorScheme.surface)),
                    )
                ],
              ),
            ),
            // Progress button wrapped in Container w/ padding and sizing
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: EdgeInsets.symmetric(horizontal: width * .08),
              width: width * 4 / 5,
              child: ElevatedButton(
                  onPressed: () async {
                    // If image has not been selected, request one
                    if (!uploaded) {
                      await selectImage(setState);
                      // ...else begin uploading process, if not already loading
                    } else if (!isLoading) {
                      // Refresh page to begin loading animation
                      setState(() {
                        isLoading = true;
                      });
                      if (await imageFile!.exists()) {
                        // Send http.get request to OpenAI, interpret, and store result
                        final Map<String, dynamic> aiScan =
                            await OpenAI.scanSchedule(imageFile!.path);
                        if (context.mounted) {
                          // If error detected, display error and exit
                          if (aiScan['error'] != null) {
                            context.showSnackBar(
                                'Request Failed: Error Code ${aiScan['error']}',
                                isError: true);
                            // Refresh page to end loading animation
                            setState(() {
                              isLoading = false;
                            });
                            return;
                          }
                          // If error not detected, refresh entire page to include AI results
                          setState(() {
                            Schedule.bellVanity =
                                Map<String, Map<String, dynamic>>.from(aiScan);

                            // Clear all temporary values to be reset later
                            BellSettings.clearSettings();
                          });
                          // Pops popup, returning to settings page
                          Navigator.pop(context);
                        }
                      }
                    }
                  },
                  // Button styled dependent on status
                  style: ElevatedButton.styleFrom(
                      overlayColor: colorScheme.onPrimary,
                      // If image is selected, primary button, else secondary button color scheme
                      backgroundColor: uploaded
                          ? colorScheme.primary
                          : colorScheme.secondary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)))),
                  // Displays Shimmer dependent on status w/ text
                  child: Container(
                      alignment: Alignment.center,
                      height: 37.5,
                      child: Shimmer.fromColors(
                          baseColor: colorScheme.onPrimary,
                          highlightColor: colorScheme.onSecondary,
                          // Shimmer dependent on loading status
                          enabled: isLoading,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Icon hint dependent on status
                              Icon(
                                // If image has been selected, display scan icon, else image upload icon
                                uploaded
                                    ? Icons.document_scanner_outlined
                                    : Icons.add_photo_alternate_outlined,
                                size: 25,
                                color: colorScheme.onPrimary,
                              ),
                              // Hint text dependent on status
                              Text(
                                // If image has been selected, display scan image text, else upload image text
                                uploaded ? "  Scan Image" : "  Upload Image",
                                style: TextStyle(
                                    fontSize: 25, fontFamily: "Georama"),
                              )
                            ],
                          ))).fit()),
            )
          ],
        ));
  }


  // Allows the user to select an image from their camera roll
  Future<void> selectImage(StateSetter setLocalState) async {
    // Requests image to be picked and stored selection
    FilePickerResult? pickedImage = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);

    // If image was selected, stores image file path
    if (pickedImage != null) {
      if (pickedImage.xFiles.isNotEmpty) {
        // The file selected
        final File pickedFile = File(pickedImage.xFiles.first.path);
        // If the file exists, refresh the page to account for the selection
        if (await pickedFile.exists() && context.mounted) {
          setLocalState(() {
            imageFile = pickedFile;
          });
        }
      }
    }
  }
}
