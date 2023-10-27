import 'package:mobx/mobx.dart';
import 'package:momento_booth/views/base/screen_view_model_base.dart';

part 'standby_screen_view_model.g.dart';

class StandbyScreenViewModel = StandbyScreenViewModelBase with _$StandbyScreenViewModel;

abstract class StandbyScreenViewModelBase extends ScreenViewModelBase with Store {

  StandbyScreenViewModelBase({
    required super.contextAccessor,
  });

}
