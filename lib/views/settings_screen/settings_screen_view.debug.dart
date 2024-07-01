part of 'settings_screen_view.dart';

Widget _getDebugTab(SettingsScreenViewModel viewModel, SettingsScreenController controller) {
  return FluentSettingsPage(
    title: "Debug and Stats",
    blocks: [
      FluentSettingsBlock(
        title: "Stats",
        settings: [
          Observer(
            builder: (context) => TextDisplayCard(
              icon: FluentIcons.touch,
              title: "Taps",
              subtitle: "The number of taps in the app (outside settings)",
              text: getIt<StatsManager>().stats.taps.toString(),
            ),
          ),
          Observer(
            builder: (context) => TextDisplayCard(
              icon: FluentIcons.front_camera,
              title: "Live view frames",
              subtitle: "The number of live view frames processed from the start of the camera\nValue shows: Valid frames / Undecodable frames / Duplicate frames",
              text: "${getIt<StatsManager>().validLiveViewFrames} / ${getIt<StatsManager>().invalidLiveViewFrames} / ${getIt<StatsManager>().duplicateLiveViewFrames}",
            ),
          ),
          Observer(
            builder: (context) => TextDisplayCard(
              icon: FluentIcons.print,
              title: "Printed pictures – Normal size",
              subtitle: "The number of prints (e.g. 2 prints of the same pictures will count as 2 as well)",
              text: getIt<StatsManager>().stats.printedPhotos.toString(),
            ),
          ),
          Observer(
            builder: (context) => TextDisplayCard(
              icon: FluentIcons.print,
              title: "Printed pictures – Small",
              subtitle: "The number of small prints (e.g. 2 prints of the same pictures will count as 2 as well)",
              text: getIt<StatsManager>().stats.printedPhotosSmall.toString(),
            ),
          ),
          Observer(
            builder: (context) => TextDisplayCard(
              icon: FluentIcons.print,
              title: "Printed pictures – Tiny",
              subtitle: "The number of tiny prints (e.g. 2 prints of the same pictures will count as 2 as well)",
              text: getIt<StatsManager>().stats.printedPhotosTiny.toString(),
            ),
          ),
          Observer(
            builder: (context) => TextDisplayCard(
              icon: FluentIcons.print,
              title: "Printed pictures – Small",
              subtitle: "The number of small prints (e.g. 2 prints of the same pictures will count as 2 as well)",
              text: getIt<StatsManager>().stats.printedPhotosSmall.toString(),
            ),
          ),
          Observer(
            builder: (context) => TextDisplayCard(
              icon: FluentIcons.print,
              title: "Printed pictures – Tiny",
              subtitle: "The number of tiny prints (e.g. 2 prints of the same pictures will count as 2 as well)",
              text: getIt<StatsManager>().stats.printedPhotosTiny.toString(),
            ),
          ),
          Observer(
            builder: (context) => TextDisplayCard(
              icon: FluentIcons.upload,
              title: "Uploaded pictures",
              subtitle: "The number of uploaded pictures",
              text: getIt<StatsManager>().stats.uploadedPhotos.toString(),
            ),
          ),
          Observer(
            builder: (context) => TextDisplayCard(
              icon: FluentIcons.camera,
              title: "Captured photos",
              subtitle: "The number of photo captures (e.g. a multi capture picture would increase this by 4)",
              text: getIt<StatsManager>().stats.capturedPhotos.toString(),
            ),
          ),
          Observer(
            builder: (context) => TextDisplayCard(
              icon: FluentIcons.photo2,
              title: "Created single shot pictures",
              subtitle: "The number of single capture pictures created, including retakes",
              text: getIt<StatsManager>().stats.createdSinglePhotos.toString(),
            ),
          ),
          Observer(
            builder: (context) => TextDisplayCard(
              icon: FluentIcons.undo,
              title: "Retakes",
              subtitle: "The number of retakes for (single) photo captures",
              text: getIt<StatsManager>().stats.retakes.toString(),
            ),
          ),
          Observer(
            builder: (context) => TextDisplayCard(
              icon: FluentIcons.photo_collection,
              title: "Created multi shot pictures",
              subtitle: "The number of multi shot pictures created, including changes",
              text: getIt<StatsManager>().stats.createdMultiCapturePhotos.toString(),
            ),
          ),
          Observer(
            builder: (context) => TextDisplayCard(
              icon: FluentIcons.undo,
              title: "Collage changes",
              subtitle: "The number of times a user went back to change a collage",
              text: getIt<StatsManager>().stats.collageChanges.toString(),
            ),
          ),
        ],
      ),
      FluentSettingsBlock(
        title: "Debug settings",
        settings: [
          BooleanInputCard(
            icon: FluentIcons.count,
            title: "Show FPS count",
            subtitle: "Show the FPS count in the upper right corner.",
            value: () => viewModel.debugShowFpsCounter,
            onChanged: controller.onDebugShowFpsCounterChanged,
          ),
        ],
      ),
      FluentSettingsBlock(
        title: "Debug actions",
        settings: [
          ButtonCard(
            icon: FluentIcons.error,
            title: "Report fake error",
            subtitle: "Test whether error reporting (to Sentry) works",
            buttonText: "Report Fake Error",
            onPressed: () => throw Exception("This is a fake error to test error reporting"),
          ),
        ],
      ),
    ],
  );
}
