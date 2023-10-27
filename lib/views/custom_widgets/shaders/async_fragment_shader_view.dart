import 'dart:async';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:momento_booth/views/custom_widgets/indicators/centered_progress_ring.dart';
import 'package:momento_booth/views/custom_widgets/shaders/fragment_shader_view.dart';

class AsyncFragmentShaderView extends StatefulWidget {

  final String assetPath;

  const AsyncFragmentShaderView({super.key, required this.assetPath});

  @override
  State<AsyncFragmentShaderView> createState() => _AsyncFragmentShaderViewState();

}

class _AsyncFragmentShaderViewState extends State<AsyncFragmentShaderView> with SingleTickerProviderStateMixin {

  final Completer<FragmentShader> _shaderCompleter = Completer();
  Future<FragmentShader> get _shader => _shaderCompleter.future;

  @override
  void initState() {
    super.initState();
    _shaderCompleter.complete(_loadShader());
  }

  @override
  void dispose() {
    _shader.then((shader) => shader.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _shader,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        } else if (!snapshot.hasData) {
          return const CenteredProgressRing();
        } else {
          return FragmentShaderView(fragmentShader: snapshot.data!);
        }
      },
    );
  }

  Future<FragmentShader> _loadShader() async {
    var program = await FragmentProgram.fromAsset(widget.assetPath);
    return program.fragmentShader();
  }

}

class _ShaderPainter extends CustomPainter {

  final FragmentShader shader;
  final double time;

  _ShaderPainter({required this.shader, required this.time});

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
