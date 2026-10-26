import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-visible preferences, persisted as simple key/value pairs.
///
/// The cue language is deliberately independent from the interface language:
/// someone may want an English UI with Spanish words, or the other way around.
class AppSettingsController extends ChangeNotifier {
  AppSettingsController._(this._prefs);

  static const _kUiLanguage = 'ui_language';
  static const _kWordLanguage = 'word_language';
  static const _kTimer = 'timer_minutes';
  static const _kInterval = 'interval_seconds';
  static const _kVoiceRate = 'voice_rate';
  static const _kSpeechVolume = 'speech_volume';
  static const _kNoiseEnabled = 'noise_enabled';
  static const _kNoiseVolume = 'noise_volume';
  static const _kNoiseColor = 'noise_color';
  static const _kWarmth = 'warmth';
  static const _kFadeOut = 'fade_out_seconds';
  static const _kKeepAwake = 'keep_awake';
  static const _kShowWords = 'show_words';
  static const _kThemeMode = 'theme_mode';
  static const _kDynamicColor = 'dynamic_color';
  static const _kOledMode = 'oled_mode';

  final SharedPreferences _prefs;

  late String uiLanguage;
  late String wordLanguage;
  late int timerMinutes;
  late int intervalSeconds;
  late double voiceRate;
  late double speechVolume;
  late bool noiseEnabled;
  late double noiseVolume;
  late double noiseColor;
  late double warmth;
  late int fadeOutSeconds;
  late bool keepAwake;
  late bool showWords;
  late String themeMode;
  late bool dynamicColor;
  late bool oledMode;

  static Future<AppSettingsController> load() async {
    final prefs = await SharedPreferences.getInstance();
    final controller = AppSettingsController._(prefs);
    final systemIsSpanish =
        PlatformDispatcher.instance.locale.languageCode == 'es';
    controller.uiLanguage = prefs.getString(_kUiLanguage) ?? 'system';
    controller.wordLanguage =
        prefs.getString(_kWordLanguage) ?? (systemIsSpanish ? 'es' : 'en');
    controller.timerMinutes = prefs.getInt(_kTimer) ?? 30;
    controller.intervalSeconds = prefs.getInt(_kInterval) ?? 8;
    controller.voiceRate = prefs.getDouble(_kVoiceRate) ?? 0.88;
    controller.speechVolume = prefs.getDouble(_kSpeechVolume) ?? 0.8;
    controller.noiseEnabled = prefs.getBool(_kNoiseEnabled) ?? true;
    controller.noiseVolume = prefs.getDouble(_kNoiseVolume) ?? 0.35;
    controller.noiseColor = prefs.getDouble(_kNoiseColor) ?? 0.3;
    controller.warmth = prefs.getDouble(_kWarmth) ?? 0.45;
    controller.fadeOutSeconds = prefs.getInt(_kFadeOut) ?? 60;
    controller.keepAwake = prefs.getBool(_kKeepAwake) ?? false;
    controller.showWords = prefs.getBool(_kShowWords) ?? true;
    controller.themeMode = prefs.getString(_kThemeMode) ?? 'dark';
    controller.dynamicColor = prefs.getBool(_kDynamicColor) ?? true;
    controller.oledMode = prefs.getBool(_kOledMode) ?? false;
    return controller;
  }

  Locale? get locale => uiLanguage == 'system' ? null : Locale(uiLanguage);

  ThemeMode get materialThemeMode => switch (themeMode) {
    'light' => ThemeMode.light,
    'system' => ThemeMode.system,
    _ => ThemeMode.dark,
  };

  void setUiLanguage(String value) {
    if (uiLanguage == value) return;
    uiLanguage = value;
    _writeString(_kUiLanguage, value);
    notifyListeners();
  }

  void setWordLanguage(String value) {
    if (wordLanguage == value) return;
    wordLanguage = value;
    _writeString(_kWordLanguage, value);
    notifyListeners();
  }

  void setTimerMinutes(int value) {
    if (timerMinutes == value) return;
    timerMinutes = value;
    _writeInt(_kTimer, value);
    notifyListeners();
  }

  void setIntervalSeconds(int value) {
    if (intervalSeconds == value) return;
    intervalSeconds = value;
    _writeInt(_kInterval, value);
    notifyListeners();
  }

  void setVoiceRate(double value) {
    if ((voiceRate - value).abs() < 0.001) return;
    voiceRate = value;
    _writeDouble(_kVoiceRate, value);
    notifyListeners();
  }

  void setSpeechVolume(double value) {
    if ((speechVolume - value).abs() < 0.001) return;
    speechVolume = value;
    _writeDouble(_kSpeechVolume, value);
    notifyListeners();
  }

  void setNoiseEnabled(bool value) {
    if (noiseEnabled == value) return;
    noiseEnabled = value;
    _writeBool(_kNoiseEnabled, value);
    notifyListeners();
  }

  void setNoiseVolume(double value) {
    if ((noiseVolume - value).abs() < 0.001) return;
    noiseVolume = value;
    _writeDouble(_kNoiseVolume, value);
    notifyListeners();
  }

  void setNoiseColor(double value) {
    if ((noiseColor - value).abs() < 0.001) return;
    noiseColor = value;
    _writeDouble(_kNoiseColor, value);
    notifyListeners();
  }

  void setWarmth(double value) {
    if ((warmth - value).abs() < 0.001) return;
    warmth = value;
    _writeDouble(_kWarmth, value);
    notifyListeners();
  }

  void setFadeOutSeconds(int value) {
    if (fadeOutSeconds == value) return;
    fadeOutSeconds = value;
    _writeInt(_kFadeOut, value);
    notifyListeners();
  }

  void setKeepAwake(bool value) {
    if (keepAwake == value) return;
    keepAwake = value;
    _writeBool(_kKeepAwake, value);
    notifyListeners();
  }

  void setShowWords(bool value) {
    if (showWords == value) return;
    showWords = value;
    _writeBool(_kShowWords, value);
    notifyListeners();
  }

  void setThemeMode(String value) {
    if (themeMode == value) return;
    themeMode = value;
    _writeString(_kThemeMode, value);
    notifyListeners();
  }

  void setDynamicColor(bool value) {
    if (dynamicColor == value) return;
    dynamicColor = value;
    _writeBool(_kDynamicColor, value);
    notifyListeners();
  }

  void setOledMode(bool value) {
    if (oledMode == value) return;
    oledMode = value;
    _writeBool(_kOledMode, value);
    notifyListeners();
  }

  void _writeString(String key, String value) =>
      unawaited(_prefs.setString(key, value));
  void _writeInt(String key, int value) => unawaited(_prefs.setInt(key, value));
  void _writeDouble(String key, double value) =>
      unawaited(_prefs.setDouble(key, value));
  void _writeBool(String key, bool value) =>
      unawaited(_prefs.setBool(key, value));
}
