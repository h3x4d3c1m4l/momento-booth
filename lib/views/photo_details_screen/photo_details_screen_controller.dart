import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:loggy/loggy.dart';
import 'package:momento_booth/utils/hardware.dart';
import 'package:momento_booth/views/base/screen_controller_base.dart';
import 'package:momento_booth/views/custom_widgets/dialogs/qr_share_dialog.dart';
import 'package:momento_booth/views/photo_details_screen/photo_details_screen_view_model.dart';

class PhotoDetailsScreenController extends ScreenControllerBase<PhotoDetailsScreenViewModel> with UiLoggy {

  // Initialization/Deinitialization

  PhotoDetailsScreenController({
    required super.viewModel,
    required super.contextAccessor,
  });

  void onClickPrev() {
    router.pop();
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
      ..printText = localizations.photoDetailsScreenPrinting;

    // Get photo and print it.
    final pdfData = await getImagePDF(await viewModel.file!.readAsBytes());
    final bool success = await printPDF(pdfData);

    viewModel.printText = success ? localizations.photoDetailsScreenPrinting : localizations.photoDetailsScreenPrintUnsuccesful;
    successfulPrints += success ? 1 : 0;
    Future.delayed(_printTextDuration, resetPrint);
  }

}
