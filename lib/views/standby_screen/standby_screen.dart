import 'package:momento_booth/views/base/build_context_accessor.dart';
import 'package:momento_booth/views/base/screen_base.dart';
import 'package:momento_booth/views/standby_screen/standby_screen_controller.dart';
import 'package:momento_booth/views/standby_screen/standby_screen_view.dart';
import 'package:momento_booth/views/standby_screen/standby_screen_view_model.dart';

class StandbyScreen extends ScreenBase<StandbyScreenViewModel, StandbyScreenController, StandbyScreenView> {

  static const String defaultRoute = "/standby";

  const StandbyScreen({super.key});

  @override
  StandbyScreenController createController({required StandbyScreenViewModel viewModel, required BuildContextAccessor contextAccessor}) {
    return StandbyScreenController(viewModel: viewModel, contextAccessor: contextAccessor);
  }

  @override
  StandbyScreenView createView({required StandbyScreenController controller, required StandbyScreenViewModel viewModel, required BuildContextAccessor contextAccessor}) {
    return StandbyScreenView(viewModel: viewModel, controller: controller, contextAccessor: contextAccessor);
  }

  @override
  StandbyScreenViewModel createViewModel({required BuildContextAccessor contextAccessor}) {
    return StandbyScreenViewModel(contextAccessor: contextAccessor);
  }

}
