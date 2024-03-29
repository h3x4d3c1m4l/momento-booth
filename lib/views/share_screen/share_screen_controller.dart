import 'dart:async';

import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:loggy/loggy.dart';
import 'package:momento_booth/managers/photos_manager.dart';
import 'package:momento_booth/managers/sfx_manager.dart';
import 'package:momento_booth/managers/stats_manager.dart';
import 'package:momento_booth/utils/hardware.dart';
import 'package:momento_booth/views/base/printer_status_dialog_mixin.dart';
import 'package:momento_booth/views/base/screen_controller_base.dart';
import 'package:momento_booth/views/capture_screen/capture_screen.dart';
import 'package:momento_booth/views/collage_maker_screen/collage_maker_screen.dart';
import 'package:momento_booth/views/custom_widgets/dialogs/qr_share_dialog.dart';
import 'package:momento_booth/views/share_screen/share_screen_view_model.dart';
import 'package:momento_booth/views/start_screen/start_screen.dart';

class ShareScreenController extends ScreenControllerBase<ShareScreenViewModel>
    with UiLoggy, PrinterStatusDialogMixin<ShareScreenViewModel> {
  // Initialization/Deinitialization

  ShareScreenController({
    required super.viewModel,
    required super.contextAccessor,
  }) {
    SfxManager.instance.playShareScreenSound();
  }

  void onClickNext() {
    router.go(StartScreen.defaultRoute);
  }

  void onClickPrev() {
    loggy.debug("Clicked prev");
    if (PhotosManager.instance.captureMode == CaptureMode.single) {
      PhotosManager.instance.reset(advance: false);
      StatsManager.instance.addRetake();
      router.go(CaptureScreen.defaultRoute);
    } else {
      router.go(CollageMakerScreen.defaultRoute);
    }
  }

  void onClickGetQR() {
    viewModel.uploadPhotoToSend();
    showUserDialog(
      barrierDismissible: false,
      dialog: Observer(builder: (_) {
        return QrShareDialog(
          state: viewModel.uploadFailed
              ? ShareDialogState.error
              : viewModel.uploadProgress != null
                  ? ShareDialogState.uploading
                  : ShareDialogState.uploaded,
          uploadProgress: (viewModel.uploadProgress ?? 0) * 100,
          qrText: viewModel.qrUrl,
          onDismiss: () => navigator.pop(),
          onRedoUpload: viewModel.uploadPhotoToSend,
        );
      }),
    );
  }

  int successfulPrints = 0;
  static const _printTextDuration = Duration(seconds: 4);

  void resetPrint() {
    viewModel
      ..printText = successfulPrints > 0 ? "${localizations.genericPrintButton} +1" : localizations.genericPrintButton
      ..printEnabled = true;
  }

  Future<void> onClickPrint() async {
    if (!viewModel.printEnabled) return;

    loggy.debug("Printing photo");

    viewModel
      ..printEnabled = false
      ..printText = localizations.shareScreenPrinting;

    // Get photo and print it.
    final pdfData = await PhotosManager.instance.getOutputPDF();
    final bool success = await printPDF(pdfData);

    viewModel.printText = success ? localizations.shareScreenPrinting : localizations.shareScreenPrintUnsuccesful;
    successfulPrints += success ? 1 : 0;
    Future.delayed(_printTextDuration, resetPrint);

    await checkPrintersAndShowWarnings();
  }
}
