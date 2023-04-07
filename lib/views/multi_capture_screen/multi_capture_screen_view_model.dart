import 'dart:io';

import 'package:flutter/animation.dart';
import 'package:flutter_rust_bridge_example/managers/photos_manager.dart';
import 'package:flutter_rust_bridge_example/managers/settings_manager.dart';
import 'package:flutter_rust_bridge_example/utils/capture_method.dart' as x;
import 'package:flutter_rust_bridge_example/utils/fake_capture_method.dart';
import 'package:flutter_rust_bridge_example/utils/sony_remote_photo_capture.dart';
import 'package:flutter_rust_bridge_example/views/base/screen_view_model_base.dart';
import 'package:flutter_rust_bridge_example/models/settings.dart';
import 'package:mobx/mobx.dart';

part 'multi_capture_screen_view_model.g.dart';

class MultiCaptureScreenViewModel = MultiCaptureScreenViewModelBase with _$MultiCaptureScreenViewModel;

abstract class MultiCaptureScreenViewModelBase extends ScreenViewModelBase with Store {

  late final x.CaptureMethod capturer;
  bool flashComplete = false;
  bool captureComplete = false;

  int get counterStart => SettingsManagerBase.instance.settings.captureDelaySeconds;

  @computed
  Duration get photoDelay => Duration(seconds: counterStart) - capturer.captureDelay;

  @observable
  bool showCounter = true;

  @observable
  bool showFlash = false;

  @computed
  double get opacity => showFlash ? 1.0 : 0.0;

  @computed
  Curve get flashAnimationCurve => Curves.easeOutQuart;

  @computed
  Duration get flashAnimationDuration => showFlash ? const Duration(milliseconds: 50) : const Duration(milliseconds: 2500);

  MultiCaptureScreenViewModelBase({
    required super.contextAccessor,
  }) {
    if (SettingsManagerBase.instance.settings.hardware.captureMethod == CaptureMethod.sonyImagingEdgeDesktop){
      capturer = SonyRemotePhotoCapture(SettingsManagerBase.instance.settings.hardware.captureLocation);
  	} else {
      capturer = FakeCaptureMethod();
    }
    Future.delayed(photoDelay).then((_) => captureAndGetPhoto());
  }

  void onCounterFinished() async {
    showFlash = true;
    showCounter = false;
    await Future.delayed(flashAnimationDuration);
    showFlash = false;
    await Future.delayed(flashAnimationDuration);
    flashComplete = true;
    navigateAfterCapture();
  }

  void captureAndGetPhoto() async {
    final image = await capturer.captureAndGetPhoto();
    PhotosManagerBase.instance.photos.add(image);
    captureComplete = true;
    navigateAfterCapture();
  }

  void navigateAfterCapture() {
    if (!flashComplete || !captureComplete) { return; }
    if (PhotosManagerBase.instance.photos.length >= 4) {
      router.push("/collage-maker");
    } else {
      router.push("/multi-capture");
    }
  }

}