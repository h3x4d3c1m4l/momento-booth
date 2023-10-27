import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/scheduler.dart';

class FragmentShaderView extends StatefulWidget {

  final FragmentShader fragmentShader;

  const FragmentShaderView({super.key, required this.fragmentShader});

  @override
  State<FragmentShaderView> createState() => _FragmentShaderViewState();

}

class _FragmentShaderViewState extends State<FragmentShaderView> with SingleTickerProviderStateMixin {

  late Ticker _ticker;
  double _elapsedTicks = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(
      (elapsed) => setState(() {
        _elapsedTicks = elapsed.inMilliseconds / 1000;
      }),
    )..start();
  }
  
  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      willChange: true,
      painter: _FragmentShaderPainter(
        shader: widget.fragmentShader,
        time: _elapsedTicks,
      ),
    );
  }

}

class _FragmentShaderPainter extends CustomPainter {

  final FragmentShader shader;
  final double time;

  _FragmentShaderPainter({required this.shader, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, time);
    paint.shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

}
