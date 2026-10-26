import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/settings.dart';
import '../domain/shuffle_engine.dart';
import '../domain/word.dart';
import '../services/native_session.dart';

class SessionError {
  const SessionError(this.code, {this.language});

  final String code;
  final String? language;
}

class SessionStatus {
  const SessionStatus({
    this.running = false,
    this.paused = false,
    this.completed = false,
    this.starting = false,
    this.word,
    this.index = 0,
    this.remainingMs = 0,
    this.totalMs = 0,
    this.error,
    this.notificationsDenied = false,
  });

  final bool running;
  final bool paused;
  final bool completed;
  final bool starting;
  final String? word;
  final int index;
  final int remainingMs;
  final int totalMs;
  final SessionError? error;
  final bool notificationsDenied;

  SessionStatus copyWith({
    bool? running,
    bool? paused,
    bool? completed,
    bool? starting,
    String? word,
    bool clearWord = false,
    int? index,
    int? remainingMs,
    int? totalMs,
    SessionError? error,
    bool clearError = false,
    bool? notificationsDenied,
  }) {
    return SessionStatus(
      running: running ?? this.running,
      paused: paused ?? this.paused,
      completed: completed ?? this.completed,
      starting: starting ?? this.starting,
      word: clearWord ? null : (word ?? this.word),
      index: index ?? this.index,
      remainingMs: remainingMs ?? this.remainingMs,
      totalMs: totalMs ?? this.totalMs,
      error: clearError ? null : (error ?? this.error),
      notificationsDenied: notificationsDenied ?? this.notificationsDenied,
    );
  }
}

class SessionController extends ChangeNotifier {
  SessionController({required this.settings, NativeSession? native})
    : _native = native ?? NativeSession();

  final AppSettingsController settings;
  final NativeSession _native;
  final ShuffleEngine _engine = ShuffleEngine();

  StreamSubscription<Map<String, dynamic>>? _subscription;
  SessionStatus _status = const SessionStatus();
  bool _disposed = false;

  SessionStatus get status => _status;

  Future<void> start() async {
    if (_status.starting || _status.running) return;
    _set(_status.copyWith(starting: true, clearError: true, clearWord: true));

    var notificationsDenied = false;
    try {
      final granted = await _native.requestNotificationPermission();
      notificationsDenied = !granted;
    } on PlatformException {
      notificationsDenied = false;
    } on MissingPluginException {
      notificationsDenied = false;
    }

    try {
      final pool = await WordPool.loadAsset(settings.wordLanguage);
      final intervalMs = settings.intervalSeconds * 1000;
      final seconds = settings.timerMinutes > 0
          ? settings.timerMinutes * 60
          : 12 * 3600;
      final count = min(
        6000,
        max(30, (seconds * 1000 / intervalMs).ceil() + 10),
      );
      final cues = _engine.generate(
        pool: pool,
        count: count,
        intervalMs: intervalMs,
      );
      final payload = jsonEncode({
        'cues': cues
            .map((cue) => {'w': cue.word.word, 't': cue.atMs})
            .toList(growable: false),
        'language': settings.wordLanguage,
        'rate': settings.voiceRate,
        'speechVolume': settings.speechVolume,
        'timerMinutes': settings.timerMinutes,
        'fadeInMs': 15000,
        'fadeOutMs': settings.fadeOutSeconds * 1000,
        'noise': {
          'enabled': settings.noiseEnabled,
          'volume': settings.noiseVolume,
          'color': settings.noiseColor,
          'warmth': settings.warmth,
        },
        'keepScreenOn': settings.keepAwake,
      });

      _ensureListening();

      await _native.start(payload);
      final totalMs = settings.timerMinutes > 0
          ? settings.timerMinutes * 60 * 1000
          : 0;
      _set(
        SessionStatus(
          running: true,
          totalMs: totalMs,
          remainingMs: totalMs,
          notificationsDenied: notificationsDenied,
        ),
      );
      unawaited(_native.setKeepScreenOn(settings.keepAwake));
    } on MissingPluginException {
      _set(
        _status.copyWith(
          starting: false,
          error: const SessionError('start_failed'),
        ),
      );
    } on PlatformException catch (error) {
      _set(
        _status.copyWith(
          starting: false,
          error: SessionError(error.code, language: settings.wordLanguage),
        ),
      );
    } catch (_) {
      _set(
        _status.copyWith(
          starting: false,
          error: const SessionError('start_failed'),
        ),
      );
    }
  }

  Future<void> pause() async {
    if (!_status.running || _status.paused) return;
    try {
      await _native.pause();
      _set(_status.copyWith(paused: true));
    } on PlatformException {
      // The service already reflects the real state; a resync fixes the UI.
      unawaited(sync());
    }
  }

  Future<void> resume() async {
    if (!_status.running || !_status.paused) return;
    try {
      await _native.resume();
      _set(_status.copyWith(paused: false));
    } on PlatformException {
      unawaited(sync());
    }
  }

  Future<void> stop() async {
    try {
      await _native.stop();
    } on PlatformException {
      // Ignore: the session is ending either way.
    }
    _status = _status.copyWith(
      running: false,
      paused: false,
      starting: false,
      completed: true,
      clearWord: true,
    );
    _notify();
  }

  Future<void> extend(int minutes) async {
    if (!_status.running || _status.totalMs <= 0) return;
    try {
      await _native.extend(minutes);
      final added = minutes * 60 * 1000;
      _set(
        _status.copyWith(
          totalMs: _status.totalMs + added,
          remainingMs: _status.remainingMs + added,
        ),
      );
    } on PlatformException {
      // Ignore; the notification timer remains authoritative.
    }
  }

  Future<void> setKeepScreenOn(bool enabled) async {
    try {
      await _native.setKeepScreenOn(enabled);
    } on PlatformException {
      // The Android flag is a convenience; it is not essential to playback.
    }
  }

  Future<void> updateNoise() async {
    if (!_status.running) return;
    try {
      await _native.updateNoise(
        enabled: settings.noiseEnabled,
        volume: settings.noiseVolume,
        color: settings.noiseColor,
        warmth: settings.warmth,
      );
    } on PlatformException {
      // Ignore transient channel errors while adjusting a slider.
    }
  }

  Future<void> updateSpeechVolume() async {
    if (!_status.running) return;
    try {
      await _native.updateSpeechVolume(settings.speechVolume);
    } on PlatformException {
      // Ignore transient channel errors while adjusting a slider.
    } on MissingPluginException {
      // Unsupported platform or widget test.
    }
  }

  Future<void> sync() async {
    try {
      final state = await _native.state();
      if (state.isEmpty) return;
      final running = state['running'] as bool? ?? _status.running;
      if (running) _ensureListening();
      final total = (state['totalMs'] as num?)?.toInt() ?? _status.totalMs;
      final remaining =
          (state['remainingMs'] as num?)?.toInt() ?? _status.remainingMs;
      _set(
        _status.copyWith(
          running: running,
          paused: state['paused'] as bool? ?? _status.paused,
          completed: !running && (_status.completed || _status.running),
          word: state['word'] as String?,
          index: (state['index'] as num?)?.toInt() ?? _status.index,
          remainingMs: remaining,
          totalMs: total,
        ),
      );
    } on PlatformException {
      // Nothing to do; the UI simply keeps its last known state.
    } on MissingPluginException {
      // Running in a widget test or on an unsupported platform.
    }
  }

  void _onEvent(Map<String, dynamic> event) {
    switch (event['type']) {
      case 'word':
        _set(
          _status.copyWith(
            word: event['word'] as String?,
            index: (event['index'] as num?)?.toInt() ?? _status.index,
          ),
        );
        break;
      case 'state':
        _set(
          _status.copyWith(
            running: event['running'] as bool? ?? _status.running,
            paused: event['paused'] as bool? ?? _status.paused,
          ),
        );
        break;
      case 'timer':
        _set(
          _status.copyWith(
            remainingMs:
                (event['remainingMs'] as num?)?.toInt() ?? _status.remainingMs,
            totalMs: (event['totalMs'] as num?)?.toInt() ?? _status.totalMs,
          ),
        );
        break;
      case 'finished':
        _status = _status.copyWith(
          running: false,
          paused: false,
          completed: true,
          clearWord: true,
        );
        _notify();
        break;
      case 'error':
        _status = _status.copyWith(
          running: false,
          starting: false,
          error: SessionError(
            event['code'] as String? ?? 'start_failed',
            language: event['language'] as String?,
          ),
        );
        _notify();
        break;
    }
  }

  void _ensureListening() {
    _subscription ??= _native.events.listen(_onEvent);
  }

  void _set(SessionStatus value) {
    _status = value;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_subscription?.cancel());
    super.dispose();
  }
}
