part of 'settings_screen_view.dart';

Widget _getHardwareSettings(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  return FluentSettingsPage(
    title: "Hardware",
    blocks: [
      _getGeneralBlock(viewModel, controller),
      _getLiveViewBlock(viewModel, controller),
      _getPhotoCaptureBlock(viewModel, controller),
      _getPrintingBlock(viewModel, controller),
      Observer(builder: (_) => 
        switch(viewModel.printingImplementationSetting) {
          PrintingImplementation.none => const SizedBox(),
          PrintingImplementation.flutterPrinting => _getFlutterPrintingBlock(viewModel, controller),
          PrintingImplementation.cups => _getCupsBlock(viewModel, controller),
        }
      ),        
    ],
  );
}

Widget _getGeneralBlock(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  return FluentSettingsBlock(
    title: "General",
    settings: [
      ComboBoxCard(
        icon: FluentIcons.camera,
        title: "Rotate image",
        subtitle: "Whether the live view and captures will be rotated 90, 180 or 270 degrees clockwise.",
        items: viewModel.liveViewAndCaptureRotateOptions,
        value: () => viewModel.liveViewAndCaptureRotateSetting,
        onChanged: controller.onLiveViewAndCaptureRotateChanged,
      ),
      ComboBoxCard(
        icon: FluentIcons.camera,
        title: "Flip image – Live View",
        subtitle: "Whether the live view image will be flipped horizontally or vertically.",
        items: viewModel.flipOptions,
        value: () => viewModel.liveViewFlipSetting,
        onChanged: controller.onLiveViewFlipChanged,
      ),
      ComboBoxCard(
        icon: FluentIcons.camera,
        title: "Flip image – Capture",
        subtitle: "Whether the captured image will be flipped horizontally or vertically.",
        items: viewModel.flipOptions,
        value: () => viewModel.captureFlipSetting,
        onChanged: controller.onCaptureFlipChanged,
      ),
      NumberInputCard(
        icon: FluentIcons.page,
        title: "Aspect ratio",
        subtitle: 'The aspect ratio to which live view and captures are cropped.',
        value: () => viewModel.liveViewAndCaptureAspectRatioSetting,
        onFinishedEditing: controller.onLiveViewAndCaptureAspectRatioChanged,
        smallChange: 0.1,
      ),
    ],
  );
}

Widget _getLiveViewBlock(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  return FluentSettingsBlock(
    title: "Live view",
    settings: [
      ComboBoxCard(
        icon: FluentIcons.camera,
        title: "Live view method",
        subtitle: "Method used for live previewing",
        items: viewModel.liveViewMethods,
        value: () => viewModel.liveViewMethodSetting,
        onChanged: controller.onLiveViewMethodChanged,
      ),
      Observer(builder: (_) {
        if (viewModel.liveViewMethodSetting == LiveViewMethod.webcam) {
          return _getWebcamCard(viewModel, controller);
        }
        return const SizedBox();
      }),
    ],
  );
}

Widget _getPhotoCaptureBlock(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  return FluentSettingsBlock(
    title: "Photo capture",
    settings: [
      ComboBoxCard(
        icon: FluentIcons.camera,
        title: "Capture method",
        subtitle: "Method used for capturing final images",
        items: viewModel.captureMethods,
        value: () => viewModel.captureMethodSetting,
        onChanged: controller.onCaptureMethodChanged,
      ),
      Observer(builder: (_) {
        if (viewModel.captureMethodSetting == CaptureMethod.sonyImagingEdgeDesktop) {
          return NumberInputCard(
            icon: FluentIcons.timer,
            title: "Capture delay for Sony camera",
            subtitle: "Delay in [ms]. Sensible values are between 165 (manual focus) and 500 ms.",
            value: () => viewModel.captureDelaySonySetting,
            onFinishedEditing: controller.onCaptureDelaySonyChanged,
          );
        }
        return const SizedBox();
      }),
      Observer(builder: (_) {
        if (viewModel.captureMethodSetting == CaptureMethod.gPhoto2 || viewModel.liveViewMethodSetting == LiveViewMethod.gphoto2) {
            return _gPhoto2CamerasCard(viewModel, controller);
        }
        return const SizedBox();
      }),
      Observer(builder: (_) {
        if (viewModel.captureMethodSetting == CaptureMethod.gPhoto2 || viewModel.liveViewMethodSetting == LiveViewMethod.gphoto2) {
          return ComboBoxCard(
            icon: FluentIcons.camera,
            title: "Use special handling for camera",
            subtitle: "Kind of special handling used for the camera. Pick \"Nikon DSLR\" for cameras like the D-series. The \"None\" might work for most mirrorless camera as they are always in live view mode.",
            items: viewModel.gPhoto2SpecialHandlingOptions,
            value: () => viewModel.gPhoto2SpecialHandling,
            onChanged: controller.onGPhoto2SpecialHandlingChanged,
          );
        }
        return const SizedBox();
      }),
      Observer(builder: (_) {
        if (viewModel.captureMethodSetting == CaptureMethod.gPhoto2) {
          return BooleanInputCard(
            icon: FluentIcons.camera,
            title: "Download extra files (e.g. RAW) from camera",
            subtitle: "Whether to download extra files from the camera. This is useful for cameras that can create RAW files.",
            value: () => viewModel.gPhoto2DownloadExtraFilesSetting,
            onChanged: controller.onGPhoto2DownloadExtraFilesChanged,
          );
        }
        return const SizedBox();
      }),
      Observer(builder: (_) {
        if (viewModel.captureMethodSetting == CaptureMethod.gPhoto2) {
          return TextInputCard(
            icon: FluentIcons.s_d_card,
            title: "Camera capture target",
            subtitle: "Sets the camera's 'capturetarget'. When unsure, leave empty as it could cause capture issues. Values can be found in the libgphoto2 source code.",
            controller: controller.gPhoto2CaptureTargetController,
            onFinishedEditing: controller.onGPhoto2CaptureTargetChanged,
          );
        }
        return const SizedBox();
      }),
      Observer(builder: (_) {
        if (viewModel.captureMethodSetting == CaptureMethod.gPhoto2) {
          return NumberInputCard(
            icon: FluentIcons.camera,
            title: "Auto focus before capture",
            subtitle: "Time to wait for the camera to focus before capturing the image. This could be useful to improve capture speed in some cases (e.g. bad light, camera being slow with focusing). Might require the 'Special handling' setting set for some vendors. Also it might not work on some camera models. Set to 0 to disable.",
            value: () => viewModel.gPhoto2AutoFocusMsBeforeCaptureSetting,
            onFinishedEditing: controller.onGPhoto2AutoFocusMsBeforeCaptureChanged,
          );
        }
        return const SizedBox();
      }),
      Observer(builder: (_) {
        if (viewModel.captureMethodSetting == CaptureMethod.gPhoto2) {
          return NumberInputCard(
            icon: FluentIcons.timer,
            title: "Capture delay for gPhoto2 camera.",
            subtitle: "Delay in [ms].",
            value: () => viewModel.captureDelayGPhoto2Setting,
            onFinishedEditing: controller.onCaptureDelayGPhoto2Changed,
          );
        }
        return const SizedBox();
      }),
      Observer(builder: (_) {
        if (viewModel.captureMethodSetting == CaptureMethod.sonyImagingEdgeDesktop) {
          return FolderPickerCard(
            icon: FluentIcons.folder,
            title: "Capture location",
            subtitle: "Location to look for captured images.",
            controller: controller.captureLocationController,
            onChanged: controller.onCaptureLocationChanged,
          );
        }
        return const SizedBox();
      }),
      Observer(builder: (_) {
        if (viewModel.captureMethodSetting != CaptureMethod.sonyImagingEdgeDesktop) {
          return BooleanInputCard(
            icon: FluentIcons.hard_drive,
            title: "Save captures to disk",
            subtitle: "Whether to save captures to disk.",
            value: () => viewModel.saveCapturesToDiskSetting,
            onChanged: controller.onSaveCapturesToDiskChanged,
          );
        }
        return const SizedBox();
      }),
      Observer(builder: (_) {
        if (viewModel.captureMethodSetting != CaptureMethod.sonyImagingEdgeDesktop && viewModel.saveCapturesToDiskSetting) {
          return FolderPickerCard(
            icon: FluentIcons.hard_drive,
            title: "Capture storage location",
            subtitle: "Location where all captured photos (as retrieved from the capture implementation) will be saved to",
            controller: controller.captureStorageLocationController,
            onChanged: controller.onCaptureStorageLocationChanged,
          );
        }
        return const SizedBox();
      }),
    ],
  );
}

Widget _getPrintingBlock(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  return FluentSettingsBlock(
    title: "Printing",
    settings: [
      ComboBoxCard(
        icon: FluentIcons.camera,
        title: "Print method",
        subtitle: "Method used for printing photos",
        items: viewModel.printingImplementations,
        value: () => viewModel.printingImplementationSetting,
        onChanged: controller.onPrintingImplementationChanged,
      ),
      _printerMargins(viewModel, controller),
      NumberInputCard(
        icon: FluentIcons.queue_advanced,
        title: "Queue warning threshold",
        subtitle: "Number of photos in the OS's printer queue before a warning is shown (Windows only for now).",
        value: () => viewModel.printerQueueWarningThresholdSetting,
        onFinishedEditing: controller.onPrinterQueueWarningThresholdChanged,
      ),
    ],
  );
}

Widget _getCupsBlock(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  return FluentSettingsBlock(
    title: "CUPS",
    settings: [
      TextInputCard(
        icon: FluentIcons.server,
        title: "CUPS URI",
        subtitle: "The URI of the CUPS server",
        controller: controller.cupsUriController,
        onFinishedEditing: controller.onCupsUriChanged,
      ),
      BooleanInputCard(
        icon: FluentIcons.server,
        title: "Ignore TLS errors",
        subtitle: "Whether to ignore TLS errors when connecting to the CUPS server. This is useful for self-signed certificates which are used by default by the CUPS service.",
        value: () => viewModel.cupsIgnoreTlsErrors,
        onChanged: controller.onCupsIgnoreTlsErrorsChanged,
      ),
      TextInputCard(
        icon: FluentIcons.text_field,
        title: "CUPS username",
        subtitle: "The username for the CUPS server",
        controller: controller.cupsUsernameController,
        onFinishedEditing: controller.onCupsUsernameChanged,
      ),
      TextInputCard(
        icon: FluentIcons.password_field,
        title: "CUPS password",
        subtitle: "The password for the CUPS server",
        controller: controller.cupsPasswordController,
        onFinishedEditing: controller.onCupsPasswordChanged,
      ),
      Observer(builder: (_) => _cupsPageSizeCard(viewModel, controller, "Media size: Normal", FluentIcons.grid_view_large, PrintSize.normal, viewModel.mediaSizeNormal)),
      Observer(builder: (_) => _cupsPageSizeCard(viewModel, controller, "Media size: Split", FluentIcons.cell_split_vertical, PrintSize.split, viewModel.mediaSizeSplit)),
      Observer(builder: (_) => _cupsPageSizeCard(viewModel, controller, "Media size: Small", FluentIcons.grid_view_medium, PrintSize.small, viewModel.mediaSizeSmall)),
      Observer(builder: (_) => _gridPrint(viewModel, controller, "small", PrintSize.small, viewModel.gridSmall)),
      Observer(builder: (_) => _cupsPageSizeCard(viewModel, controller, "Media size: Tiny", FluentIcons.grid_view_small, PrintSize.tiny, viewModel.mediaSizeTiny)),
      Observer(builder: (_) => _gridPrint(viewModel, controller, "tiny", PrintSize.tiny, viewModel.gridTiny)),
      Observer(
        builder: (context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i <= viewModel.cupsPrinterQueuesSetting.length; i++)
              _cupsQueuesCard(viewModel, controller, "Printer ${i + 1}", i),
          ],
        ),
      ),
    ],
  );
}

Widget _getFlutterPrintingBlock(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  return FluentSettingsBlock(
    title: "Flutter Printing",
    settings: [
      Observer(builder: (context) =>
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i <= viewModel.flutterPrintingPrinterNamesSetting.length; i++)
              _printerCard(viewModel, controller, "Printer ${i+1}", i),
          ],
        ),
      ),
      NumberInputCard(
        icon: FluentIcons.page,
        title: "Page height",
        subtitle: 'Page format height used for printing [mm]',
        value: () => viewModel.pageHeightSetting,
        onFinishedEditing: controller.onPageHeightChanged,
        smallChange: 0.1,
      ),
      NumberInputCard(
        icon: FluentIcons.page,
        title: "Page width",
        subtitle: 'Page format width used for printing [mm]',
        value: () => viewModel.pageWidthSetting,
        onFinishedEditing: controller.onPageWidthChanged,
        smallChange: 0.1,
      ),
      BooleanInputCard(
        icon: FluentIcons.settings,
        title: "usePrinterSettings for printing",
        subtitle: "Control the usePrinterSettings property of the Flutter printing library.",
        value: () => viewModel.usePrinterSettingsSetting,
        onChanged: controller.onUsePrinterSettingsChanged,
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
        const SizedBox(width: padding),
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
        const SizedBox(width: padding),
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
        const SizedBox(width: padding),
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

FluentSettingCard _getWebcamCard(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
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
        const SizedBox(width: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 150),
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

FluentSettingCard _gPhoto2CamerasCard(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  return FluentSettingCard(
    icon: FluentIcons.camera,
    title: "Camera",
    subtitle: "Pick the camera to use for capturing still frames",
    child: Row(
      children: [
        Button(
          onPressed: viewModel.setCameraList,
          child: const Text('Refresh'),
        ),
        const SizedBox(width: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 150),
          child: Observer(builder: (_) {
            return ComboBox<String>(
              items: viewModel.gPhoto2Cameras,
              value: viewModel.gPhoto2CameraId,
              onChanged: controller.onGPhoto2CameraIdChanged,
            );
          }),
        ),
      ],
    ),
  );
}

FluentSettingCard _printerCard(SettingsScreenViewModel viewModel, SettingsScreenController controller, String title, int index) {
  return FluentSettingCard(
    icon: FluentIcons.print,
    title: title,
    subtitle: "Which printer(s) to use for printing photos",
    child: Row(
      children: [
        Button(
          onPressed: viewModel.setFlutterPrintingQueueList,
          child: const Text('Refresh'),
        ),
        const SizedBox(width: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 150),
          child: Observer(builder: (_) {
            return ComboBox<String>(
              items: viewModel.flutterPrintingQueues,
              value: index < viewModel.flutterPrintingPrinterNamesSetting.length ? viewModel.flutterPrintingPrinterNamesSetting[index] : viewModel.unusedPrinterValue,
              onChanged: (name) => controller.onFlutterPrintingPrinterChanged(name, index),
            );
          }),
        ),
      ],
    ),
  );
}

FluentSettingCard _cupsQueuesCard(SettingsScreenViewModel viewModel, SettingsScreenController controller, String title, int index) {
  return FluentSettingCard(
    icon: FluentIcons.print,
    title: title,
    subtitle: "Which printer(s) to use for printing photos",
    child: Row(
      children: [
        Button(
          onPressed: viewModel.setCupsQueueList,
          child: const Text('Refresh'),
        ),
        const SizedBox(width: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 150),
          child: Observer(builder: (_) {
            return ComboBox<String>(
              items: viewModel.cupsQueues,
              value: index < viewModel.cupsPrinterQueuesSetting.length ? viewModel.cupsPrinterQueuesSetting[index] : viewModel.unusedPrinterValue,
              onChanged: (name) => controller.onCupsPrinterQueuesQueueChanged(name, index),
            );
          }),
        ),
      ],
    ),
  );
}
FluentSettingCard _cupsPageSizeCard(SettingsScreenViewModel viewModel, SettingsScreenController controller, String title, IconData icon, PrintSize size, MediaSettings currentSettings) {
  return FluentSettingCard(
    icon: icon,
    title: title,
    subtitle: size.name,
    child: ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 150),
      child: ComboBox<String>(
        items: viewModel.cupsPaperSizes,
        value: currentSettings.mediaSizeString,
        onChanged: (value) => controller.onCupsPageSizeChanged(value, size),
      ),
    ),
  );
}


FluentSettingCard _gridPrint(SettingsScreenViewModel viewModel, SettingsScreenController controller, String sizeName, PrintSize size, GridSettings grid) {
  const double numberWidth = 100;
  const double padding = 10;
  return FluentSettingCard(
    icon: FluentIcons.snap_to_grid,
    title: "Grid for $sizeName print",
    subtitle: "Set what grid to create for creating $sizeName prints. A grid of X by Y images is generated.\nOrder: X, Y, rotate images.",
    child: Row(
      children: [
        SizedBox(
          width: numberWidth,
          child: NumberBox<int>(
            value: grid.x,
            onChanged: (value) => controller.onCupsGridXChanged(value, size),
          ),
        ),
        const SizedBox(width: padding),
        SizedBox(
          width: numberWidth,
          child: NumberBox<int>(
            value: grid.y,
            onChanged: (value) => controller.onCupsGridYChanged(value, size),
          ),
        ),
        const SizedBox(width: padding),
        ToggleSwitch(
          checked: grid.rotate,
          onChanged: (value)  => controller.onCupsGridRotateChanged(value, size),
        ),
        
      ],
    ),
  );
}
