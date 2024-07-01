import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:momento_booth/hardware_control/gphoto2_camera.dart';
import 'package:momento_booth/hardware_control/photo_capturing/live_view_stream_snapshot_capturer.dart';
import 'package:momento_booth/hardware_control/photo_capturing/photo_capture_method.dart';
import 'package:momento_booth/hardware_control/photo_capturing/sony_remote_photo_capture.dart';
import 'package:momento_booth/main.dart';
import 'package:momento_booth/managers/live_view_manager.dart';
import 'package:momento_booth/managers/mqtt_manager.dart';
import 'package:momento_booth/managers/photos_manager.dart';
import 'package:momento_booth/managers/settings_manager.dart';
import 'package:momento_booth/managers/stats_manager.dart';
import 'package:momento_booth/models/capture_state.dart';
import 'package:momento_booth/models/photo_capture.dart';
import 'package:momento_booth/models/settings.dart';
import 'package:momento_booth/views/base/screen_view_model_base.dart';
import 'package:momento_booth/views/collage_maker_screen/collage_maker_screen.dart';
import 'package:momento_booth/views/multi_capture_screen/multi_capture_screen.dart';

part 'multi_capture_screen_view_model.g.dart';

class MultiCaptureScreenViewModel = MultiCaptureScreenViewModelBase with _$MultiCaptureScreenViewModel;

abstract class MultiCaptureScreenViewModelBase extends ScreenViewModelBase with Store {

  late final PhotoCaptureMethod capturer;
  bool flashComplete = false;
  bool captureComplete = false;
  static const flashStartDuration = Duration(milliseconds: 50);
  static const flashEndDuration = Duration(milliseconds: 2500);
  static const minimumContinueWait = Duration(milliseconds: 1500);

  int get counterStart => getIt<SettingsManager>().settings.captureDelaySeconds;
  int get autoFocusMsBeforeCapture => getIt<SettingsManager>().settings.hardware.gPhoto2AutoFocusMsBeforeCapture;
  double get aspectRatio => getIt<SettingsManager>().settings.hardware.liveViewAndCaptureAspectRatio;

  @computed
  Duration get photoDelay => Duration(seconds: counterStart) - capturer.captureDelay + flashStartDuration;

  @computed
  Duration get autoFocusDelay => photoDelay - Duration(milliseconds: autoFocusMsBeforeCapture);

  @observable
  bool showCounter = true;

  @observable
  bool showFlash = false;

  @observable
  bool showSpinner = false;

  @computed
  double get opacity => showFlash ? 1.0 : 0.0;

  @computed
  Curve get flashAnimationCurve => Curves.easeOutQuart;

  @computed
  Duration get flashAnimationDuration => showFlash ? flashStartDuration : flashEndDuration;

  @computed
  int get photoNumber => PhotosManager.instance.photos.length+1;

  final int maxPhotos = 4;

  MultiCaptureScreenViewModelBase({
    required super.contextAccessor,
  }) {
    capturer = switch (getIt<SettingsManager>().settings.hardware.captureMethod) {
      CaptureMethod.liveViewSource => LiveViewStreamSnapshotCapturer(),
      CaptureMethod.sonyImagingEdgeDesktop => SonyRemotePhotoCapture(getIt<SettingsManager>().settings.hardware.captureLocation),
      CaptureMethod.gPhoto2 => getIt<LiveViewManager>().gPhoto2Camera!,
    };
    capturer.clearPreviousEvents();

    if (autoFocusMsBeforeCapture > 0 && autoFocusDelay > Duration.zero && capturer is GPhoto2Camera) {
      Future.delayed(autoFocusDelay).then((_) => (capturer as GPhoto2Camera).autoFocus());
    }
    Future.delayed(photoDelay).then((_) => captureAndGetPhoto());
    getIt<MqttManager>().publishCaptureState(CaptureState.countdown);
  }

  Future<void> onCounterFinished() async {
    showFlash = true;
    showCounter = false;
    await Future.delayed(flashAnimationDuration);
    showFlash = false;
    showSpinner = true;
    await Future.delayed(minimumContinueWait);
    flashComplete = true; // Flash is now not actually complete, but after this time we do not care about it anymore.
    navigateAfterCapture();
  }

  Future<void> captureAndGetPhoto() async {
    getIt<MqttManager>().publishCaptureState(CaptureState.capturing);

    try {
      final image = await capturer.captureAndGetPhoto();
      getIt<StatsManager>().addCapturedPhoto();
      PhotosManager.instance.photos.add(image);
    } catch (error) {
      logWarning(error);
      final ByteData data = await rootBundle.load('assets/bitmap/capture-error.png');
      PhotosManager.instance.photos.add(PhotoCapture(
        data: data.buffer.asUint8List(),
        filename: "capture-error.png",
      ));
    } finally {
      captureComplete = true;
      navigateAfterCapture();
      getIt<MqttManager>().publishCaptureState(CaptureState.idle);
    }
  }

  void navigateAfterCapture() {
    if (!flashComplete || !captureComplete) return;
    if (PhotosManager.instance.photos.length >= maxPhotos) {
      router.go(CollageMakerScreen.defaultRoute);
    } else {
      router.go("${MultiCaptureScreen.defaultRoute}?n=${PhotosManager.instance.photos.length}");
    }
  }

}
