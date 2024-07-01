import 'package:mobx/mobx.dart';
import 'package:momento_booth/main.dart';
import 'package:momento_booth/managers/photos_manager.dart';
import 'package:momento_booth/managers/settings_manager.dart';
import 'package:momento_booth/models/settings.dart';
import 'package:momento_booth/views/base/screen_view_model_base.dart';

part 'start_screen_view_model.g.dart';

class StartScreenViewModel = StartScreenViewModelBase with _$StartScreenViewModel;

abstract class StartScreenViewModelBase extends ScreenViewModelBase with Store {

  @computed
  List<LottieAnimationSettings> get introScreenLottieAnimations => getIt<SettingsManager>().settings.ui.introScreenLottieAnimations;

  @observable
  bool isBusy = false;

  StartScreenViewModelBase({required super.contextAccessor}) {
    // Remove images in memory
    // Fixme: maybe somewhere else is nicer, but for now it's here.
    PhotosManager.instance.reset();
  }

}
