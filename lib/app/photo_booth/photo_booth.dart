import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:momento_booth/app/photo_booth/widgets/activity_monitor.dart';
import 'package:momento_booth/app/photo_booth/widgets/photo_booth_hotkey_monitor.dart';
import 'package:momento_booth/app/shell/widgets/fps_monitor.dart';
import 'package:momento_booth/app_localizations.dart';
import 'package:momento_booth/main.dart';
import 'package:momento_booth/managers/settings_manager.dart';
import 'package:momento_booth/theme/momento_booth_theme.dart';
import 'package:momento_booth/theme/momento_booth_theme_data.dart';
import 'package:momento_booth/utils/custom_rect_tween.dart';
import 'package:momento_booth/utils/route_observer.dart';
import 'package:momento_booth/views/base/settings_based_transition_page.dart';
import 'package:momento_booth/views/capture_screen/capture_screen.dart';
import 'package:momento_booth/views/choose_capture_mode_screen/choose_capture_mode_screen.dart';
import 'package:momento_booth/views/collage_maker_screen/collage_maker_screen.dart';
import 'package:momento_booth/views/custom_widgets/wrappers/live_view_background.dart';
import 'package:momento_booth/views/custom_widgets/wrappers/set_scroll_configuration.dart';
import 'package:momento_booth/views/gallery_screen/gallery_screen.dart';
import 'package:momento_booth/views/manual_collage_screen/manual_collage_screen.dart';
import 'package:momento_booth/views/multi_capture_screen/multi_capture_screen.dart';
import 'package:momento_booth/views/photo_details_screen/photo_details_screen.dart';
import 'package:momento_booth/views/settings_screen/settings_screen.dart';
import 'package:momento_booth/views/share_screen/share_screen.dart';
import 'package:momento_booth/views/start_screen/start_screen.dart';

part 'photo_booth.routes.dart';

class PhotoBooth extends StatefulWidget {
  const PhotoBooth({super.key});

  @override
  State<StatefulWidget> createState() => PhotoBoothState();
}

class PhotoBoothState extends State<PhotoBooth> {
  final GoRouter _router = GoRouter(
    routes: _rootRoutes,
    observers: [
      GoRouterObserver(),
      HeroController(createRectTween: (begin, end) => CustomRectTween(begin: begin, end: end)),
    ],
    initialLocation: StartScreen.defaultRoute,
  );

  @override
  Widget build(BuildContext context) {
    return FpsMonitor(
      child: LiveViewBackground(
        router: _router,
        child: PhotoBoothHotkeyMonitor(
          router: _router,
          child: ActivityMonitor(
            router: _router,
            child: MomentoBoothTheme(
              data: MomentoBoothThemeData.defaults(),
              child: SetScrollConfiguration(
                child: Observer(
                  builder: (context) => FluentApp.router(
                    scrollBehavior: ScrollConfiguration.of(context),
                    color: getIt<SettingsManager>().settings.ui.primaryColor,
                    theme: FluentThemeData(
                      accentColor: AccentColor.swatch(
                        {'normal': getIt<SettingsManager>().settings.ui.primaryColor},
                      ),
                    ),
                    routerConfig: _router,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                      FluentLocalizations.delegate,
                    ],
                    supportedLocales: const [
                      Locale('en'), // English
                      Locale('nl'), // Dutch
                    ],
                    locale: getIt<SettingsManager>().settings.ui.language.toLocale(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }
}
