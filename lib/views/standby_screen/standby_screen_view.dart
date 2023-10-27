import 'package:flutter/widgets.dart';
import 'package:momento_booth/views/base/screen_view_base.dart';
import 'package:momento_booth/views/custom_widgets/shaders/async_fragment_shader_view.dart';
import 'package:momento_booth/views/standby_screen/standby_screen_controller.dart';
import 'package:momento_booth/views/standby_screen/standby_screen_view_model.dart';

class StandbyScreenView extends ScreenViewBase<StandbyScreenViewModel, StandbyScreenController> {

  const StandbyScreenView({
    required super.viewModel,
    required super.controller,
    required super.contextAccessor,
  });
  
  @override
  Widget get body {
    return const AsyncFragmentShaderView(assetPath: "assets/shaders/plasma_waves.frag");
  }

}
