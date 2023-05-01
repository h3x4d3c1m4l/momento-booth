import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:momento_booth/views/base/screen_view_base.dart';
import 'package:momento_booth/views/custom_widgets/image_with_loader_fallback.dart';
import 'package:momento_booth/views/custom_widgets/wrappers/slider_widget.dart';
import 'package:momento_booth/views/photo_details_screen/photo_details_screen_controller.dart';
import 'package:momento_booth/views/photo_details_screen/photo_details_screen_view_model.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class PhotoDetailsScreenView extends ScreenViewBase<PhotoDetailsScreenViewModel, PhotoDetailsScreenController> {

  const PhotoDetailsScreenView({
    required super.viewModel,
    required super.controller,
    required super.contextAccessor,
  });
  
  @override
  Widget get body {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.all(30),
          child: Center(
            // This SizedBox is only necessary when the image used is smaller than what would be displayed.
            child: SizedBox(
              height: double.infinity,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF0F0F0),
                  border: theme.captureCounterContainerBorder,
                  boxShadow: [theme.captureCounterContainerShadow],
                ),
                child: ImageWithLoaderFallback.file(viewModel.file, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: _foregroundElements,
        ),
        SizedBox.expand(child: _qrCodeBackdrop),
        _qrCode
      ],
    );
  }

  Widget get _foregroundElements {
    return Column(
      children: [
        Flexible(
          fit: FlexFit.tight,
          child: AutoSizeText(
            "Photo Details",
            style: theme.titleStyle,
          ),
        ),
        Expanded(
          flex: 3,
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              // Next button
              onTap: controller.onClickPrev,
              behavior: HitTestBehavior.translucent,
              child: AutoSizeText(
                " ← Back",
                style: theme.subTitleStyle,
              ),
            ),
          ),
        ),
        Flexible(
          fit: FlexFit.tight,
          child: _getBottomRow(),
        ),
      ],
    );
  }

  Widget _getBottomRow() {
    return Row(
      children: [
        Flexible(
          child: Center(
            child: GestureDetector(
              // Get QR button
              onTap: controller.onClickGetQR,
              behavior: HitTestBehavior.translucent,
              child: Observer(
                builder: (context) => AutoSizeText(
                  viewModel.qrText,
                  style: theme.titleStyle,
                ),
              ),
            ),
          ),
        ),
        Flexible(
          child: GestureDetector(
            // Print button
            onTap: controller.onClickPrint,
            behavior: HitTestBehavior.translucent,
            child: Center(
              child: Observer(
                builder: (context) => AnimatedOpacity(
                  duration: Duration(milliseconds: 300),
                  opacity: viewModel.printEnabled ? 1 : 0.5,
                  child: AutoSizeText(
                    viewModel.printText,
                    style: theme.titleStyle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget get _qrCodeBackdrop {
    return Observer(builder: (_) {
      return IgnorePointer(
        ignoring: !viewModel.qrShown,
        child: GestureDetector(
          onTap: controller.onClickCloseQR,
          child: AnimatedOpacity(
            opacity: viewModel.qrShown ? 0.5 : 0.0,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: ColoredBox(color: Color(0xFF000000)),
          ),
        ),
      );
    });
  }

  Widget get _qrCode {
    return Observer(builder: (context) {
      return SliderWidget(
        key: viewModel.sliderKey,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            borderRadius: BorderRadius.circular(10),
            border: theme.captureCounterContainerBorder,
            boxShadow: [theme.captureCounterContainerShadow],
          ),
          child: PrettyQr(
            size: 500,
            data: viewModel.qrUrl,
            errorCorrectLevel: QrErrorCorrectLevel.L,
            roundEdges: true,
          ),
        ),
      );
    });
  }

}