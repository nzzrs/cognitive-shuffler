import 'dart:async';
import 'dart:convert';

import 'package:cognitive_shuffler/core/settings.dart';
import 'package:cognitive_shuffler/playback/session_controller.dart';
import 'package:cognitive_shuffler/services/native_session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeNativeSession extends NativeSession {
  final StreamController<Map<String, dynamic>> eventsController =
      StreamController<Map<String, dynamic>>.broadcast();
  String? plan;
  int pauses = 0;
  int resumes = 0;
  int stops = 0;

  @override
  Stream<Map<String, dynamic>> get events => eventsController.stream;

  @override
  Future<void> start(String planJson) async {
    plan = planJson;
  }

  @override
  Future<bool> requestNotificationPermission() async => true;

  @override
  Future<void> pause() async => pauses += 1;

  @override
  Future<void> resume() async => resumes += 1;

  @override
  Future<void> stop() async => stops += 1;

  @override
  Future<void> extend(int minutes) async {}

  @override
  Future<void> updateNoise({
    required bool enabled,
    required double volume,
    required double color,
    required double warmth,
  }) async {}

  @override
  Future<Map<String, dynamic>> state() async => <String, dynamic>{};

  @override
  Future<void> setKeepScreenOn(bool enabled) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('builds a timed cue plan and follows service events', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = await AppSettingsController.load();
    settings.setTimerMinutes(30);
    settings.setIntervalSeconds(8);
    settings.setWordLanguage('en');

    final native = _FakeNativeSession();
    final controller = SessionController(settings: settings, native: native);
    await controller.start();

    expect(controller.status.running, isTrue);
    expect(controller.status.totalMs, 30 * 60 * 1000);
    expect(controller.status.remainingMs, 30 * 60 * 1000);
    expect(native.plan, isNotNull);

    final payload = jsonDecode(native.plan!) as Map<String, dynamic>;
    final cues = payload['cues'] as List<dynamic>;
    expect(cues.length, greaterThan(200));
    expect(payload['language'], 'en');
    expect(payload['timerMinutes'], 30);
    expect(payload['noise']['enabled'], isTrue);
    expect((cues.first as Map<String, dynamic>)['t'], 1500);

    native.eventsController.add(<String, dynamic>{
      'type': 'word',
      'word': 'house',
      'index': 4,
    });
    await Future<void>.delayed(Duration.zero);
    expect(controller.status.word, 'house');
    expect(controller.status.index, 4);

    await controller.pause();
    expect(controller.status.paused, isTrue);
    await controller.resume();
    expect(controller.status.paused, isFalse);
    expect(native.pauses, 1);
    expect(native.resumes, 1);

    native.eventsController.add(<String, dynamic>{'type': 'finished'});
    await Future<void>.delayed(Duration.zero);
    expect(controller.status.running, isFalse);
    expect(controller.status.completed, isTrue);

    await controller.stop();
    expect(native.stops, 1);
    controller.dispose();
    await native.eventsController.close();
  });
}
