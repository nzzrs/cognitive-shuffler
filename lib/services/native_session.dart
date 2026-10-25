import 'dart:async';

import 'package:flutter/services.dart';

class NativeSession {
  static const MethodChannel _channel = MethodChannel(
    'io.github.nzrs.cognitiveshuffler/session',
  );
  static const EventChannel _events = EventChannel(
    'io.github.nzrs.cognitiveshuffler/session_events',
  );

  Stream<Map<String, dynamic>> get events => _events
      .receiveBroadcastStream()
      .map((event) => Map<String, dynamic>.from(event as Map));

  Future<void> start(String planJson) =>
      _channel.invokeMethod<void>('start', {'plan': planJson});

  Future<void> pause() => _channel.invokeMethod<void>('pause');

  Future<void> resume() => _channel.invokeMethod<void>('resume');

  Future<void> stop() => _channel.invokeMethod<void>('stop');

  Future<void> extend(int minutes) =>
      _channel.invokeMethod<void>('extend', {'minutes': minutes});

  Future<void> updateNoise({
    required bool enabled,
    required double volume,
    required double color,
    required double warmth,
  }) => _channel.invokeMethod<void>('updateNoise', {
    'enabled': enabled,
    'volume': volume,
    'color': color,
    'warmth': warmth,
  });

  Future<Map<String, dynamic>> state() async {
    final value = await _channel.invokeMethod<dynamic>('getState');
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  Future<bool> requestNotificationPermission() async {
    final granted = await _channel.invokeMethod<bool>(
      'requestNotificationPermission',
    );
    return granted ?? false;
  }

  Future<void> setKeepScreenOn(bool enabled) =>
      _channel.invokeMethod<void>('setKeepScreenOn', {'enabled': enabled});
}

class SystemAccent {
  static const MethodChannel _channel = MethodChannel(
    'io.github.nzrs.cognitiveshuffler/theme',
  );

  static Future<int?> load() async {
    try {
      return await _channel.invokeMethod<int>('getAccentColor');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
