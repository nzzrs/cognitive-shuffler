import 'dart:async';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/settings.dart';
import 'l10n/generated/app_localizations.dart';
import 'ui/home_screen.dart';
import 'ui/theme.dart';

class CognitiveShufflerApp extends StatefulWidget {
  const CognitiveShufflerApp({super.key, required this.settings});

  final AppSettingsController settings;

  @override
  State<CognitiveShufflerApp> createState() => _CognitiveShufflerAppState();
}

class _CognitiveShufflerAppState extends State<CognitiveShufflerApp> {
  ColorScheme? _dynamicLight;
  ColorScheme? _dynamicDark;
  bool _dynamicColorAvailable = false;

  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () {
        unawaited(
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
        );
        unawaited(_refreshDynamicColors());
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
      );
    });
    _refreshDynamicColors();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refreshDynamicColors() async {
    try {
      final palette = await DynamicColorPlugin.getCorePalette();
      if (!mounted) return;
      setState(() {
        _dynamicColorAvailable = palette != null;
        _dynamicLight = palette?.toColorScheme();
        _dynamicDark = palette?.toColorScheme(brightness: Brightness.dark);
      });
    } on Exception {
      // No palette on this device; the brand scheme is used instead.
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final settings = widget.settings;
        final useDynamic =
            settings.dynamicColor &&
            _dynamicLight != null &&
            _dynamicDark != null;
        final light = useDynamic
            ? _dynamicLight!
            : fallbackScheme(Brightness.light);
        final dark = useDynamic
            ? _dynamicDark!
            : fallbackScheme(Brightness.dark);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: buildAppTheme(scheme: light),
          darkTheme: buildAppTheme(scheme: dark),
          themeMode: settings.materialThemeMode,
          home: HomeScreen(
            settings: settings,
            dynamicColorAvailable: _dynamicColorAvailable,
          ),
        );
      },
    );
  }
}
