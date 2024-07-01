import 'dart:async';

import 'package:mobx/mobx.dart';
import 'package:momento_booth/src/rust/api/initialization.dart';
import 'package:momento_booth/src/rust/helpers.dart';
import 'package:momento_booth/utils/logger.dart';

part 'helper_library_initialization_manager.g.dart';

class HelperLibraryInitializationManager = HelperLibraryInitializationManagerBase with _$HelperLibraryInitializationManager;

/// Class containing global state for photos in the app
abstract class HelperLibraryInitializationManagerBase with Store, Logger {

  final Completer<bool> _nokhwaInitializationResultCompleter = Completer<bool>();
  final Completer<bool> _gphoto2InitializationResultCompleter = Completer<bool>();

  Future<bool> get nokhwaInitializationResult => _nokhwaInitializationResultCompleter.future;
  Future<bool> get gphoto2InitializationResult => _gphoto2InitializationResultCompleter.future;

  @readonly
  String? _nokhwaInitializationMessage;

  @readonly
  String? _gphoto2InitializationMessage;

  Future initialize() async {
    initializeLog().listen(_processLogEvent);
    initializeHardware().listen(_processHardwareInitEvent);
  }

  void _processLogEvent(LogEvent event) {
    switch (event.level) {
      case LogLevel.debug:
        logDebug("Lib: ${event.message}");
      case LogLevel.info:
        logInfo("Lib: ${event.message}");
      case LogLevel.warning:
        logWarning("Lib: ${event.message}");
      case LogLevel.error:
        logError("Lib: ${event.message}");
    }
  }

  void _processHardwareInitEvent(HardwareInitializationFinishedEvent event) {
    switch (event.step) {
      case HardwareInitializationStep.nokhwa:
        _nokhwaInitializationMessage = event.message;
        _nokhwaInitializationResultCompleter.complete(event.hasSucceeded);
        logInfo("Nokhwa initialization finished with result: ${event.hasSucceeded} and message: ${event.message}");
      case HardwareInitializationStep.gphoto2:
        _gphoto2InitializationMessage = event.message;
        _gphoto2InitializationResultCompleter.complete(event.hasSucceeded);
        logInfo("gPhoto2 initialization finished with result: ${event.hasSucceeded} and message: ${event.message}");
    }
  }

}
