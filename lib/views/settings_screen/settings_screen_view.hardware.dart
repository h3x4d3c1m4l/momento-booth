part of 'settings_screen_view.dart';

Widget _getHardwareSettings(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  return FluentSettingsPage(
    title: "Hardware",
    blocks: [
      FluentSettingsBlock(
        title: "Live view",
        settings: [
          _getComboBoxCard(
            icon: FluentIcons.camera,
            title: "Live view method",
            subtitle: "Method used for live previewing",
            items: viewModel.liveViewMethods,
            value: () => viewModel.liveViewMethodSetting,
            onChanged: controller.onLiveViewMethodChanged,
          ),
          if (viewModel.liveViewMethodSetting == LiveViewMethod.webcam)
            _webcamCard(viewModel, controller),
          _getComboBoxCard(
            icon: FluentIcons.camera,
            title: "Flip image",
            subtitle: "Whether the image should be flipped in none, one or both axis",
            items: viewModel.liveViewFlipImageChoices,
            value: () => viewModel.liveViewFlipImage,
            onChanged: controller.onLiveViewFlipImageChanged,
          ),
        ],
      ),
      FluentSettingsBlock(
        title: "Photo capture",
        settings: [
          _getComboBoxCard(
            icon: FluentIcons.camera,
            title: "Capture method",
            subtitle: "Method used for capturing final images",
            items: viewModel.captureMethods,
            value: () => viewModel.captureMethodSetting,
            onChanged: controller.onCaptureMethodChanged,
          ),
          _getFolderPickerCard(
            icon: FluentIcons.folder,
            title: "Capture location",
            subtitle: "Location to look for captured images",
            dialogTitle: "Select location to look for captured images",
            controller: controller.captureLocationController,
            onChanged: controller.onCaptureLocationChanged,
          ),
        ],
      ),
      FluentSettingsBlock(
        title: "Printing",
        settings: [
          _printerCard(viewModel, controller),
          _getInput(
            icon: FluentIcons.page,
            title: "Page height",
            subtitle: 'Page format height used for printing [mm]',
            value: () => viewModel.pageHeightSetting,
            onChanged: controller.onPageHeightChanged,
            smallChange: 0.1,
          ),
          _getInput(
            icon: FluentIcons.page,
            title: "Page width",
            subtitle: 'Page format width used for printing [mm]',
            value: () => viewModel.pageWidthSetting,
            onChanged: controller.onPageWidthChanged,
            smallChange: 0.1,
          ),
          _printerMargins(viewModel, controller),
          _getBooleanInput(
            icon: FluentIcons.settings,
            title: "usePrinterSettings for printing",
            subtitle: "Control the usePrinterSettings property of the Flutter printing library.",
            value: () => viewModel.usePrinterSettingsSetting,
            onChanged: controller.onUsePrinterSettingsChanged,
          ),
        ],
      ),
    ],
  );
}

FluentSettingCard _printerMargins(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  const double numberWidth = 100;
  const double padding = 10;
  return FluentSettingCard(
    icon: FluentIcons.page,
    title: "Page margins used for printing",
    subtitle: "Some printers cut off some part of the image. Use this to compensate.\nOrder: top, right, bottom, left [mm]",
    child: Row(
      children: [
        SizedBox(
          width: numberWidth,
          child: Observer(builder: (_) {
            return NumberBox<double>(
              value: viewModel.printerMarginTopSetting,
              onChanged: controller.onPrinterMarginTopChanged,
              smallChange: 0.1,
            );
          }),
        ),
        SizedBox(width: padding,),
        SizedBox(
          width: numberWidth,
          child: Observer(builder: (_) {
            return NumberBox<double>(
              value: viewModel.printerMarginRightSetting,
              onChanged: controller.onPrinterMarginRightChanged,
              smallChange: 0.1,
            );
          }),
        ),
        SizedBox(width: padding,),
        SizedBox(
          width: numberWidth,
          child: Observer(builder: (_) {
            return NumberBox<double>(
              value: viewModel.printerMarginBottomSetting,
              onChanged: controller.onPrinterMarginBottomChanged,
              smallChange: 0.1,
            );
          }),
        ),
        SizedBox(width: padding,),
        SizedBox(
          width: numberWidth,
          child: Observer(builder: (_) {
            return NumberBox<double>(
              value: viewModel.printerMarginLeftSetting,
              onChanged: controller.onPrinterMarginLeftChanged,
              smallChange: 0.1,
            );
          }),
        ),
      ],
    ),
  );
}

FluentSettingCard _webcamCard(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  return FluentSettingCard(
    icon: FluentIcons.camera,
    title: "Webcam",
    subtitle: "Pick the webcam to use for live view",
    child: Row(
      children: [
        Button(
          onPressed: viewModel.setWebcamList,
          child: const Text('Refresh'),
        ),
        SizedBox(width: 10),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 150),
          child: Observer(builder: (_) {
            return ComboBox<String>(
              items: viewModel.webcams,
              value: viewModel.liveViewWebcamId,
              onChanged: controller.onLiveViewWebcamIdChanged,
            );
          }),
        ),
      ],
    ),
  );
}

FluentSettingCard _printerCard(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  return FluentSettingCard(
    icon: FluentIcons.print,
    title: "Printer",
    subtitle: "Which printer to use for printing photos",
    child: Row(
      children: [
        Button(
          onPressed: viewModel.setPrinterList,
          child: const Text('Refresh'),
        ),
        SizedBox(width: 10),
        ConstrainedBox(
          constraints: BoxConstraints(minWidth: 150),
          child: Observer(builder: (_) {
            return ComboBox<String>(
              items: viewModel.printerOptions,
              value: viewModel.printerSetting,
              onChanged: controller.onPrinterChanged,
            );
          }),
        ),
      ],
    ),
  );
}