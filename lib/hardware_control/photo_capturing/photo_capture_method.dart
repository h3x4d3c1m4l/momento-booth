import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:loggy/loggy.dart' as loggy;
import 'package:momento_booth/managers/settings_manager.dart';
import 'package:momento_booth/models/photo_capture.dart';
import 'package:path/path.dart' as path;

abstract class PhotoCaptureMethod {

  Duration get captureDelay;

  Future<void> clearPreviousEvents();

  Future<PhotoCapture> captureAndGetPhoto();

  Future<void> storePhotoSafe(String filename, Uint8List fileData) async {
    if (SettingsManager.instance.settings.hardware.saveCapturesToDisk) {
      try {
        DateFormat formatter = DateFormat('yyyyMMdd_HHmmss');
        String currentDateTime = formatter.format(DateTime.now());
        String fileName = "${currentDateTime}_$filename";

        await Directory(SettingsManager.instance.settings.hardware.captureStorageLocation).create(recursive: true);

        File file = File(path.join(SettingsManager.instance.settings.hardware.captureStorageLocation, fileName));
        await file.writeAsBytes(fileData, mode: FileMode.writeOnly);
        loggy.logDebug("Stored incoming photo to disk: ${file.path}");
      } catch (exception, stacktrace) {
        loggy.logError("Could not save photo to disk", exception, stacktrace);
      }
    }
  }

}
