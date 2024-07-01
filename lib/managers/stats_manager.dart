import 'dart:async';
import 'dart:io';

import 'package:mobx/mobx.dart';
import 'package:momento_booth/models/settings.dart';
import 'package:momento_booth/models/stats.dart';
import 'package:momento_booth/utils/logger.dart';
import 'package:momento_booth/utils/subsystem.dart';
import 'package:path/path.dart' hide context;
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';
import 'package:toml/toml.dart';

part 'stats_manager.g.dart';

class StatsManager = StatsManagerBase with _$StatsManager;

abstract class StatsManagerBase with Store, Logger, Subsystem {

  @readonly
  Stats _stats = const Stats();

  @override
  Future<void> initialize() async {
    await load();
  }

  // /////////// //
  // Local stats //
  // /////////// //

  @observable
  int validLiveViewFrames = 0;

  @observable
  int invalidLiveViewFrames = 0;

  @observable
  int duplicateLiveViewFrames = 0;

  // /////// //
  // Updates //
  // /////// //

  @action
  void addTap() => _stats = _stats.copyWith(taps: _stats.taps + 1);

  @action
  void addPrintedPhoto({PrintSize size = PrintSize.normal}) {
    switch(size) {
      case PrintSize.small:
        _stats = _stats.copyWith(printedPhotos: _stats.printedPhotosSmall + 1);
      case PrintSize.tiny:
        _stats = _stats.copyWith(printedPhotos: _stats.printedPhotosTiny + 1);
      case _:
        _stats = _stats.copyWith(printedPhotos: _stats.printedPhotos + 1);
    }
  }

  @action
  void addUploadedPhoto() => _stats = _stats.copyWith(uploadedPhotos: _stats.uploadedPhotos + 1);

  @action
  void addCapturedPhoto() => _stats = _stats.copyWith(capturedPhotos: _stats.capturedPhotos + 1);

  @action
  void addCreatedSinglePhoto() => _stats = _stats.copyWith(createdSinglePhotos: _stats.createdSinglePhotos + 1);

  @action
  void addRetake() => _stats = _stats.copyWith(retakes: _stats.retakes + 1);

  @action
  void addCollageChange() => _stats = _stats.copyWith(retakes: _stats.collageChanges + 1);

  @action
  void addCreatedMultiCapturePhoto() => _stats = _stats.copyWith(createdMultiCapturePhotos: _stats.createdMultiCapturePhotos + 1);

  // /////////// //
  // Persistence //
  // /////////// //

  late File _statsFile;
  static const _fileName = "Statistics.toml";
  static const _statsSaveTimerInterval = Duration(minutes: 1);
  static final _stateSaveLock = Lock();

  @action
  Future<void> load() async {
    logDebug("Loading statistics");
    await _ensureStatsFileIsSet();

    if (!_statsFile.existsSync()) {
      // File does not exist
      _stats = const Stats();
      logWarning("Persisted statistics file not found");
    } else {
      // File does exist
      logDebug("Loading persisted statistics");
      try {
        String statsAsToml = await _statsFile.readAsString();
        TomlDocument statsDocument = TomlDocument.parse(statsAsToml);
        Map<String, dynamic> statsMap = statsDocument.toMap();
        _stats = Stats.fromJson(statsMap);
        logDebug("Loaded persisted statistics");
      } catch (_) {
        // Fixme: Failed to parse, ignore for now
        logWarning("Persisted statistics could not be loaded");
      }
    }

    Timer.periodic(_statsSaveTimerInterval, (timer) => _save());
  }

  Future<void> _save() async {
    await _stateSaveLock.synchronized(() async {
      logDebug("Saving statistics");
      await _ensureStatsFileIsSet();

      Map<String, dynamic> mapWithStringKey = _stats.toJson();
      TomlDocument statsDocument = TomlDocument.fromMap(mapWithStringKey);
      String statsAsToml = statsDocument.toString();
      await _statsFile.writeAsString(statsAsToml);

      logDebug("Saved statistics");
    });
  }

  // /////// //
  // Helpers //
  // /////// //

  Future<void> _ensureStatsFileIsSet() async {
    // Find path
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String filePath = join(storageDirectory.path, _fileName);
    _statsFile = File(filePath);
  }

}

enum StatFields {

  taps,
  liveViewFrames,
  printedPhotos,
  printedPhotosSmall,
  printedPhotosTiny,
  uploadedPhotos,
  capturedPhotos,
  createdSinglePhotos,
  retakes,
  collageChanges,
  createdMultiCapturePhotos,

}
