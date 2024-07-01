import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:momento_booth/app/shell/shell.dart';
import 'package:momento_booth/managers/_all.dart';
import 'package:momento_booth/managers/printing_manager.dart';
import 'package:momento_booth/repositories/secret/secret_repository.dart';
import 'package:momento_booth/repositories/secret/secure_storage_secret_repository.dart';
import 'package:momento_booth/src/rust/frb_generated.dart';
import 'package:momento_booth/utils/environment_variables.dart';
import 'package:momento_booth/utils/platform_and_app.dart';
import 'package:path/path.dart' as path;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:talker_flutter/talker_flutter.dart';

final GetIt getIt = GetIt.instance;

void main() async {
  await RustLib.init();
  _ensureGPhoto2EnvironmentVariables();

  WidgetsFlutterBinding.ensureInitialized();
  await initialize();

  getIt
    ..enableRegisteringMultipleInstancesOfOneType()

    // Log
    ..registerSingleton(Talker(
      settings: TalkerSettings(),
    ))

    // Repositories
    ..registerSingleton<SecretRepository>(const SecureStorageSecretRepository())

    // Managers
    ..registerSingleton(HelperLibraryInitializationManager())
    ..registerSingleton(StatsManager())
    ..registerSingleton(SfxManager());

  await getIt<HelperLibraryInitializationManager>().initialize();
  await SettingsManager.instance.load();
  await getIt<StatsManager>().load();
  await WindowManager.instance.initialize();
  LiveViewManager.instance.initialize();
  MqttManager.instance.initialize();
  await getIt<SfxManager>().initialize();
  NotificationsManager.instance.initialize();
  PrintingManager.instance.initialize();

  String sentryDsn = await _resolveSentryDsnOverride() ?? const String.fromEnvironment("SENTRY_DSN", defaultValue: '');
  await SentryFlutter.init(
    (options) {
      options
        ..tracesSampleRate = 1.0
        ..dsn = sentryDsn
        ..environment = const String.fromEnvironment("SENTRY_ENVIRONMENT", defaultValue: 'Development')
        ..release = const String.fromEnvironment("SENTRY_RELEASE", defaultValue: 'Development');
    },
    appRunner: () => runApp(const Shell()),
  );
}

void _ensureGPhoto2EnvironmentVariables() {
  if (!Platform.isWindows) return;

  // Read from Dart defines.
  const String iolibsDefine = String.fromEnvironment("IOLIBS");
  const String camlibsDefine = String.fromEnvironment("CAMLIBS");
  if (iolibsDefine.isEmpty || camlibsDefine.isEmpty) return;

  // Set environment overrides through the C runtime.
  // Note that this does not alter the actual environment of the application,
  // but it does makes libgphoto2 resolve them correctly through its call to `getenv`.
  putenv("IOLIBS", iolibsDefine);
  putenv("CAMLIBS", camlibsDefine);
}

Future<String?> _resolveSentryDsnOverride() async {
  String executablePath = Platform.resolvedExecutable;
  String possibleSentryDsnOverridePath = path.join(path.dirname(executablePath), "sentry_dsn_override.txt");

  File sentryDsnOverrideFile = File(possibleSentryDsnOverridePath);
  if (!sentryDsnOverrideFile.existsSync()) return null;
  return (await sentryDsnOverrideFile.readAsString()).trim();
}
