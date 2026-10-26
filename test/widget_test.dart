import 'package:cognitive_shuffler/app.dart';
import 'package:cognitive_shuffler/core/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('home renders and settings can change the language', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final settings = await AppSettingsController.load();
    await tester.pumpWidget(CognitiveShufflerApp(settings: settings));
    await tester.pumpAndSettle();

    expect(find.text('Cognitive Shuffler'), findsOneWidget);
    expect(find.text('Begin'), findsOneWidget);
    expect(find.text('Let the words drift.'), findsOneWidget);
    expect(find.text('Sleep timer · 30 min'), findsOneWidget);

    // Language and noise are Settings concerns, not Home toggles.
    expect(find.text('English'), findsNothing);
    expect(find.text('Spanish'), findsNothing);
    expect(find.text('Noise'), findsNothing);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Sleep timer'), findsNothing);

    await tester.fling(find.byType(ListView), const Offset(0, -600), 1200);
    await tester.pumpAndSettle();
    expect(find.text('App language'), findsOneWidget);

    await tester.tap(find.text('App language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Spanish'));
    await tester.pumpAndSettle();

    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Idioma de la app'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Comenzar'), findsOneWidget);
    expect(find.text('Deja que las palabras fluyan.'), findsOneWidget);
  });

  testWidgets('sleep timer is the only duration control', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = await AppSettingsController.load();
    await tester.pumpWidget(CognitiveShufflerApp(settings: settings));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sleep timer · 30 min'));
    await tester.pumpAndSettle();
    expect(find.text('15 min'), findsOneWidget);

    await tester.tap(find.text('45 min'));
    await tester.pumpAndSettle();

    expect(settings.timerMinutes, 45);
    expect(find.text('Sleep timer · 45 min'), findsOneWidget);
  });

  testWidgets('opens the step-by-step guide with its study reference', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final settings = await AppSettingsController.load();
    await tester.pumpWidget(CognitiveShufflerApp(settings: settings));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.info_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('A small exercise for a busy mind'), findsOneWidget);
    expect(find.textContaining('Lie down and dim the room'), findsOneWidget);

    await tester.fling(find.byType(ListView), const Offset(0, -800), 1200);
    await tester.pumpAndSettle();
    expect(find.textContaining('Digdon'), findsOneWidget);
  });

  testWidgets('sleep timer accepts an exact custom duration', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final settings = await AppSettingsController.load();
    await tester.pumpWidget(CognitiveShufflerApp(settings: settings));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sleep timer · 30 min'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom duration'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '37');
    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();

    expect(settings.timerMinutes, 37);
    expect(find.text('Sleep timer · 37 min'), findsOneWidget);
  });

  testWidgets('fits a compact phone without overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues({});
    final settings = await AppSettingsController.load();
    await tester.pumpWidget(CognitiveShufflerApp(settings: settings));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.fling(find.byType(ListView), const Offset(0, -500), 1200);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
