import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_rust_bridge_example/managers/live_view_manager.dart';
import 'package:flutter_rust_bridge_example/managers/photos_manager.dart';
import 'package:flutter_rust_bridge_example/managers/settings_manager.dart';
import 'package:flutter_rust_bridge_example/models/settings.dart';
import 'package:flutter_rust_bridge_example/views/base/stateless_widget_base.dart';

class LiveViewBackground extends StatelessWidgetBase {

  final Widget child;

  const LiveViewBackground({
    super.key,
    required this.child,
  });

  bool get _showLiveViewBackground => PhotosManagerBase.instance.showLiveViewBackground;
  LiveViewState get _liveViewState => LiveViewManagerBase.instance.liveViewState;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _viewState,
        child,
      ]
    );
  }

  Widget get _viewState {
    return Observer(builder: (context) {
      switch (_liveViewState) {
        
        case LiveViewState.initializing:
          return _initializingState;
        case LiveViewState.error:
          return _errorState;
        case LiveViewState.streaming:
          return _streamingState;

      }
    });
  }

  Widget get _initializingState {
    return FluentTheme(
      data: FluentThemeData(),
      child: Center(
        child: ProgressRing(),
      ),
    );
  }

  Widget get _errorState {
    return ColoredBox(
      color: Colors.green,
      child: Center(
        child: AutoSizeText(
          "Camera could not be found\r\n\r\nor\r\n\r\nconnection broken!",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget get _streamingState {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Colors.green),
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: LiveView(fit: BoxFit.cover),
        ),
        if (_showLiveViewBackground)
          LiveView(),
      ],
    );
  }

}

class LiveView extends StatelessWidgetBase {

  final BoxFit fit;

  const LiveView({
    super.key,
    this.fit = BoxFit.contain,
  });

  Flip get _flip => SettingsManagerBase.instance.settings.hardware.liveViewFlipImage;
  ui.Image? get _lastFrameImage => LiveViewManagerBase.instance.lastFrameImage;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => Transform(
        transform: Matrix4.diagonal3Values(_flip.flipX ? -1.0 : 1.0, _flip.flipY ? -1.0 : 1.0, 1.0),
        alignment: Alignment.center,
        child: RawImage(
          image: _lastFrameImage,
          fit: fit,
        ),
      ),
    );
  }

}