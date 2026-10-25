import 'package:flutter/material.dart';

import 'core/settings.dart';
import 'l10n/generated/app_localizations.dart';
import 'services/native_session.dart';
import 'ui/home_screen.dart';
import 'ui/theme.dart';

class CognitiveShufflerApp extends StatelessWidget {
  const CognitiveShufflerApp({
    super.key,
    required this.settings,
    this.systemAccent,
  });

  final AppSettingsController settings;
  final int? systemAccent;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        final seed = settings.dynamicColor && systemAccent != null
            ? Color(systemAccent! & 0xFFFFFFFF)
            : kFallbackSeed;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: buildAppTheme(seed: seed, brightness: Brightness.light),
          darkTheme: buildAppTheme(seed: seed, brightness: Brightness.dark),
          themeMode: settings.materialThemeMode,
          home: HomeScreen(settings: settings),
        );
      },
    );
  }
}

Future<int?> loadSystemAccent() => SystemAccent.load();
