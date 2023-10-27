part of 'shell.dart';

List<GoRoute> _rootRoutes = [
  _standbyRoute,
  _photoBoothRoute,
  _settingsRoute,
];

GoRoute _standbyRoute = GoRoute(
  path: StandbyScreen.defaultRoute,
  pageBuilder: (context, state) {
    return SettingsBasedTransitionPage.fromSettings(
      key: state.pageKey,
      child: const StandbyScreen(),
    );
  },
);

GoRoute _photoBoothRoute = GoRoute(
  path: "/photo_booth",
  pageBuilder: (context, state) {
    return SettingsBasedTransitionPage.fromSettings(
      key: state.pageKey,
      enableTransitionOut: false,
      child: const PhotoBooth(),
    );
  },
);

GoRoute _settingsRoute = GoRoute(
  path: SettingsScreen.defaultRoute,
  pageBuilder: (context, state) { 
    return SettingsBasedTransitionPage.fromSettings(
      key: state.pageKey,
      opaque: false,
      child: const FullScreenPopup(
        child: SettingsScreen(),
      ),
      barrierDismissible: true,
    );
  },
);
