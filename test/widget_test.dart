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

    expect(find.text('COGNITIVE SHUFFLER'), findsOneWidget);
    expect(find.text('Begin'), findsOneWidget);
    expect(find.text('Let the words drift.'), findsOneWidget);
    expect(find.text('Sleep timer'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('APP LANGUAGE'), findsOneWidget);

    await tester.tap(find.text('Spanish').first);
    await tester.pumpAndSettle();

    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('IDIOMA DE LA APP'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Comenzar'), findsOneWidget);
    expect(find.text('Deja que las palabras fluyan.'), findsOneWidget);
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

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.fling(find.byType(ListView), const Offset(0, -500), 1200);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
