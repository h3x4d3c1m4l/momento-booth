import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';
import 'package:momento_booth/main.dart';
import 'package:momento_booth/managers/_all.dart';
import 'package:momento_booth/utils/hardware.dart';

part 'notifications_manager.g.dart';

class NotificationsManager = NotificationsManagerBase with _$NotificationsManager;

/// Class containing global state for photos in the app
abstract class NotificationsManagerBase with Store {

  static const _printerStatusCheckPeriod = Duration(seconds: 5);

  @observable
  ObservableList<InfoBar> notifications = ObservableList<InfoBar>();

  void initialize() {
    Timer.periodic(_printerStatusCheckPeriod, (_) => _statusCheck());
  }

  Future<void> _statusCheck() async {
    final printerNames = getIt<SettingsManager>().settings.hardware.flutterPrintingPrinterNames;
    final printersStatus = await compute(checkPrintersStatus, printerNames);
    notifications.clear();
    printersStatus.forEachIndexed((index, element) {
      final hasErrorNotification = InfoBar(title: const Text("Printer error"), content: Text("Printer ${index+1} has an error."), severity: InfoBarSeverity.warning);
      final paperOutNotification = InfoBar(title: const Text("Printer out of paper"), content: Text("Printer ${index+1} is out of paper."), severity: InfoBarSeverity.warning);
      final longQueueNotification = InfoBar(title: const Text("Long printing queue"), content: Text("Printer ${index+1} has a long queue (${element.jobs} jobs). It might take a while for your print to appear."), severity: InfoBarSeverity.info);
      if (element.jobs >= getIt<SettingsManager>().settings.hardware.printerQueueWarningThreshold) {
        notifications.add(longQueueNotification);
      }
      if (element.hasError) {
        notifications.add(hasErrorNotification);
      }
      if (element.paperOut) {
        notifications.add(paperOutNotification);
      }
    });
  }

}
