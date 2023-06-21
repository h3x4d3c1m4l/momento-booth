import 'dart:ui' as ui;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:momento_booth/managers/live_view_manager.dart';
import 'package:momento_booth/managers/notifications_manager.dart';
import 'package:momento_booth/managers/photos_manager.dart';
import 'package:momento_booth/managers/settings_manager.dart';
import 'package:momento_booth/models/settings.dart';
import 'package:momento_booth/views/base/stateless_widget_base.dart';
import 'package:patterns_canvas/patterns_canvas.dart';
import 'package:simple_animations/simple_animations.dart';

class LiveViewBackground extends StatelessWidgetBase {

  final Widget child;

  const LiveViewBackground({
    super.key,
    required this.child,
  });

  bool get _showLiveViewBackground => PhotosManager.instance.showLiveViewBackground;
  LiveViewState get _liveViewState => LiveViewManager.instance.liveViewState;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _viewState,
        LoopAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 1000),
          builder: (context, value, child) {
            return CustomPaint(
              painter: ContainerPatternPainter(
                stripeOffsetValue: value,
              ),
              willChange: true,
            );
          },
        ),
        child,
        _statusOverlay,
      ]
    );
  }
  
  Widget get _statusOverlay {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Observer(
        builder: (context) => Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (InfoBar notification in NotificationsManager.instance.notifications) ...[
              notification,
              const SizedBox(height: 8),
            ]
          ],
        ),
      ),
    );
  }

  Widget get _viewState {
    return Observer(builder: (context) {
      switch (_liveViewState) {
        
        case LiveViewState.initializing:
          return _initializingState;
        case LiveViewState.error:
          return _errorState(Colors.red, null);
        case LiveViewState.streaming:
          return _streamingState;

      }
    });
  }

  Widget get _initializingState {
    return const Center(
      child: ProgressRing(),
    );
  }

  Widget _errorState(Color color, String? message) {
    return ColoredBox(
      color: color,
      child: Center(
        child: AutoSizeText(
          message ?? "Camera could not be found\r\n\r\nor\r\n\r\nconnection broken!",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget get _streamingState {
    if (LiveViewManager.instance.lastFrameWasInvalid) {
      return _errorState(Colors.green, "Could not decode webcam data");
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: Colors.green),
        ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: const LiveView(fit: BoxFit.cover),
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showLiveViewBackground ? 1 : 0,
          curve: Curves.ease,
          child: const LiveView(),
        ),
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

  Flip get _flip => SettingsManager.instance.settings.hardware.liveViewFlipImage;

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (context) => Transform(
        transform: Matrix4.diagonal3Values(_flip.flipX ? -1.0 : 1.0, _flip.flipY ? -1.0 : 1.0, 1.0),
        alignment: Alignment.center,
        child: AspectRatio(
          aspectRatio: 3/2,
          child: FittedBox(
            fit: fit,
            child: SizedBox(
              width: 3,
              height: 2,
              child: Texture(
                textureId: LiveViewManager.instance.textureId ?? 0,
                filterQuality: SettingsManager.instance.settings.ui.liveViewFilterQuality.toUiFilterQuality(),
              ),
            ),
          ),
        ),
      ),
    );
  }

}

class ContainerPatternPainter extends CustomPainter {
  final double stripeOffsetValue;
  final double stripeFactor;

  ContainerPatternPainter({required this.stripeOffsetValue, this.stripeFactor = 3});

  @override
  void paint(Canvas canvas, Size size) {
    int stripes = size.width ~/ stripeFactor;
    double stripeWidth = size.width / stripes * 2;
    double leftOffset = -stripes + stripeOffsetValue * stripeWidth * 3;

    DiagonalStripesLight(
      bgColor: Colors.transparent,
      fgColor: Colors.black,
      featuresCount: stripes,
    ).paintOnWidget(
      canvas,
      size,
      customRect: Rect.fromLTWH(leftOffset, 0, size.width * 2, size.height),
      patternScaleBehavior: PatternScaleBehavior.customRect,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
