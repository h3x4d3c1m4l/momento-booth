part of 'settings_screen_view.dart';


Widget _getTemplatingSettings(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  const buttonMargin = SizedBox(width: 10,);
  const columnMargin = SizedBox(height: 10,);
  return FluentSettingsPage(
    title: "Templating",
    blocks: [
      _getTemplateSettings(viewModel, controller),
      FluentSettingsBlock(
        title: "Template preview",
        settings: [
          Row(
            children: [
              _getTemplateButton(viewModel, controller, "No photo", 0),
              buttonMargin,
              _getTemplateButton(viewModel, controller, "1 photo", 1),
              buttonMargin,
              _getTemplateButton(viewModel, controller, "2 photos", 2),
              buttonMargin,
              _getTemplateButton(viewModel, controller, "3 photos", 3),
              buttonMargin,
              _getTemplateButton(viewModel, controller, "4 photos", 4),
              buttonMargin,
              FilledButton(
                onPressed: controller.exportTemplate,
                child: const Text("Export"),
              ),
              buttonMargin,
              Observer(builder: (context) =>
                ToggleSwitch(
                  checked: viewModel.previewTemplateShowBack,
                  onChanged: (v) => viewModel.previewTemplateShowBack = v,
                  content: const Text("Show background"),
                )
              ),
              buttonMargin,
              Observer(builder: (context) =>
                ToggleSwitch(
                  checked: viewModel.previewTemplateShowFront,
                  onChanged: (v) => viewModel.previewTemplateShowFront = v,
                  content: const Text("Show foreground"),
                )
              ),
            ],
          ),
          columnMargin,
          const Text("Explanation:\nRed border = padding for printing, will be cut-off if set correctly\nWhite border = gap size"),
          columnMargin,
          Observer(builder: (context) => Text("Selected template images for n=${viewModel.previewTemplate}:\nFront template file: ${viewModel.selectedFrontTemplate}\nBack template file: ${viewModel.selectedBackTemplate}")),
          columnMargin,
          _getTemplateExampleRow(viewModel, controller),
        ]
      ),
    ],
  );
}

Widget _getTemplateButton(SettingsScreenViewModel viewModel, SettingsScreenController controller, String text, int index) {
  return Observer(
    builder: (context) => Button(
      onPressed: viewModel.previewTemplate == index ? null : () => viewModel.previewTemplate = index,
      child: Text(text),
    )
  );
}

Widget _getTemplateExampleRow(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  const double height = 800;
  return Row(
    children: [
      const SizedBox(height: height,),
      Observer(
        builder: (context) => RotatedBox(
          quarterTurns: -1 * viewModel.previewTemplateRotation,
          child: SizedBox(
            height: height,
            child: PhotoCollage(
              key: viewModel.collageKey,
              debug: viewModel.previewTemplate,
              aspectRatio: 1/viewModel.collageAspectRatioSetting,
              padding: viewModel.collagePaddingSetting,
              showBackground: viewModel.previewTemplateShowBack,
              showForeground: viewModel.previewTemplateShowFront,
            ),
          ),
        )
      ),
    ],
  );
}

Widget _getTemplateSettings(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  return FluentSettingsBlock(
    title: "Creative",
    settings: [
      FolderPickerCard(
        icon: FluentIcons.fabric_report_library,
        title: "Collage background templates location",
        subtitle: "Location to look for template files",
        controller: controller.templatesFolderSettingController,
        onChanged: controller.onTemplatesFolderChanged,
      ),
      NumberInputCard(
        icon: FluentIcons.aspect_ratio,
        title: "Collage aspect ratio",
        subtitle: "Controls the aspect ratio of the generated collages. Think about this together with paper print size.",
        smallChange: 0.1,
        value: () => viewModel.collageAspectRatioSetting,
        onFinishedEditing: controller.onCollageAspectRatioChanged,
      ),
      NumberInputCard(
        icon: FluentIcons.field_filled,
        title: "Collage padding",
        subtitle: "Controls the padding around the aspect ratio of the generated collages. Think about this together with paper print size.",
        value: () => viewModel.collagePaddingSetting,
        onFinishedEditing: controller.onCollagePaddingChanged,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Observer(
          builder: (context) => Text("→ Padding will be ${(viewModel.pageHeightSetting/1000 * viewModel.collagePaddingSetting).toStringAsPrecision(3)} mm with ${viewModel.pageHeightSetting} mm page height.")
        ),
      ),
      NumberInputCard(
        icon: FluentIcons.picture_stretch,
        title: "Output resolution multiplier     (same setting as output tab)",
        subtitle: 'Controls image resolution',
        value: () => viewModel.resolutionMultiplier,
        onFinishedEditing: controller.onResolutionMultiplierChanged,
        smallChange: 0.1,
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Observer(
          builder: (context) => Text("→ Output (and template) resolution based on aspect ratio (${viewModel.collageAspectRatioSetting}) and padding (${viewModel.collagePaddingSetting}) and multiplier will be ${viewModel.outputResHeightExcl.round()}×${viewModel.outputResWidthExcl.round()} without and ${viewModel.outputResHeightIncl.round()}×${viewModel.outputResWidthIncl.round()} with padding"),
        )
      ),
    ],
  );
}
