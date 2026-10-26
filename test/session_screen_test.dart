import 'package:cognitive_shuffler/core/settings.dart';
import 'package:cognitive_shuffler/l10n/generated/app_localizations.dart';
import 'package:cognitive_shuffler/playback/session_controller.dart';
import 'package:cognitive_shuffler/services/native_session.dart';
import 'package:cognitive_shuffler/ui/session_screen.dart';
import 'package:cognitive_shuffler/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNative extends NativeSession {
  @override
  Stream<Map<String, dynamic>> get events =>
      const Stream<Map<String, dynamic>>.empty();

  int pauses = 0;
  int resumes = 0;
  int stops = 0;

  @override
  Future<void> pause() async => pauses += 1;

  @override
  Future<void> resume() async => resumes += 1;

  @override
  Future<void> stop() async => stops += 1;

  @override
  Future<void> setKeepScreenOn(bool enabled) async {}

  @override
  Future<Map<String, dynamic>> state() async => <String, dynamic>{
    'running': true,
    'paused': false,
    'word': 'harbor',
    'index': 4,
    'remainingMs': 1500000,
    'totalMs': 1800000,
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OLED mode shows only the word and pause button', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final settings = await AppSettingsController.load();
    settings.setOledMode(true);
    final native = _FakeNative();
    final controller = SessionController(settings: settings, native: native);
    await controller.sync();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: buildAppTheme(scheme: fallbackScheme(Brightness.dark)),
        home: SessionScreen(controller: controller, settings: settings),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('harbor'), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(
      find.text('Tap to pause. Double tap to show controls.'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.close_rounded), findsNothing);
    expect(find.byIcon(Icons.tune_rounded), findsNothing);
    expect(find.text('25 min'), findsNothing);

    await tester.tapAt(tester.getCenter(find.text('harbor')));
    await tester.pump(const Duration(milliseconds: 350));
    expect(native.pauses, 1);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    await tester.tapAt(const Offset(195, 320));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(const Offset(195, 320));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    expect(find.byIcon(Icons.contrast_rounded), findsOneWidget);
    expect(find.text('25 min'), findsOneWidget);
    expect(native.pauses, 1);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });

  testWidgets('double tap enters OLED from the full session', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final settings = await AppSettingsController.load();
    final native = _FakeNative();
    final controller = SessionController(settings: settings, native: native);
    await controller.sync();

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: buildAppTheme(scheme: fallbackScheme(Brightness.dark)),
        home: SessionScreen(controller: controller, settings: settings),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byIcon(Icons.tune_rounded), findsOneWidget);
    await tester.tapAt(tester.getCenter(find.text('harbor')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tapAt(tester.getCenter(find.text('harbor')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.byIcon(Icons.tune_rounded), findsNothing);
    expect(
      find.text('Tap to pause. Double tap to show controls.'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
  });
}
