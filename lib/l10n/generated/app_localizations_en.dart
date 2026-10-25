// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cognitive Shuffler';

  @override
  String get tagline => 'Let the words drift.';

  @override
  String get begin => 'Begin';

  @override
  String get putPhoneDown => 'Put the phone down. The words keep going.';

  @override
  String get sleepTimer => 'Sleep timer';

  @override
  String get timerInfinite => 'Until I stop';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get noise => 'Noise';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get cueLanguage => 'Cue language';

  @override
  String get english => 'English';

  @override
  String get spanish => 'Spanish';

  @override
  String get settings => 'Settings';

  @override
  String get pause => 'Pause';

  @override
  String get resume => 'Resume';

  @override
  String get stop => 'End';

  @override
  String get endSession => 'End session';

  @override
  String get noTimer => 'No timer';

  @override
  String get paused => 'Paused';

  @override
  String get noiseSheetTitle => 'Noise';

  @override
  String get level => 'Level';

  @override
  String get pinkBrown => 'Pink / brown';

  @override
  String get warmth => 'Warmth';

  @override
  String get soft => 'Soft';

  @override
  String get deep => 'Deep';

  @override
  String get showWords => 'Show words';

  @override
  String get screenHint => 'You can turn the screen off. Playback continues.';

  @override
  String get wordLanguage => 'Word language';

  @override
  String get appLanguage => 'App language';

  @override
  String get systemDefault => 'System';

  @override
  String get voiceSpeed => 'Voice speed';

  @override
  String get pauseBetweenWords => 'Pause between words';

  @override
  String secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get defaultTimer => 'Default timer';

  @override
  String get fadeOut => 'Fade out';

  @override
  String get fadeOff => 'Off';

  @override
  String get keepAwake => 'Keep screen on';

  @override
  String get showWordsOnScreen => 'Show words on screen';

  @override
  String get noiseDefaults => 'Noise';

  @override
  String get playNoise => 'Play noise';

  @override
  String get noiseLevel => 'Noise level';

  @override
  String get noiseColor => 'Pink / brown balance';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get dynamicColor => 'Use wallpaper colour';

  @override
  String get about => 'About';

  @override
  String get aboutIntro =>
      'A quiet, offline app that speaks a slow stream of ordinary, concrete nouns. There is nothing to learn and nothing to achieve.';

  @override
  String get aboutMethodTitle => 'How it works';

  @override
  String get aboutMethod =>
      'Cognitive shuffling gives your mind unrelated, easy-to-picture words. Each word is a small scene. Let the scene appear, then let it go. If your thoughts wander, that is the point.';

  @override
  String get aboutPrivacyTitle => 'Privacy';

  @override
  String get aboutPrivacy =>
      'No internet permission. No accounts. No analytics. Your settings stay on this device.';

  @override
  String get aboutSourcesTitle => 'Words and licences';

  @override
  String get aboutSources =>
      'Word pools are generated from Princeton WordNet, FrequencyWords (OpenSubtitles), MultiWordNet, the Brysbaert concreteness ratings and the MEGAHit concreteness lexicon. The app and its word data are free software under the GNU GPL v3 and CC BY-SA 4.0.';

  @override
  String get aboutLicense => 'GNU General Public License v3.0 or later';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String ttsUnavailable(String language) {
    return 'No speech voice is available for $language. Install a text-to-speech engine in Android settings.';
  }

  @override
  String get ttsInitFailed => 'The speech engine could not start.';

  @override
  String get notificationDenied =>
      'Notifications are off, so the sleep controls will not appear while the screen is off.';

  @override
  String get startFailed => 'The session could not start.';

  @override
  String get methodTitle => 'A small experiment for a busy mind';

  @override
  String get methodBody =>
      'Picture each word as a simple scene. Do not connect the words. When a word disappears, let the next one arrive.';

  @override
  String get help => 'About cognitive shuffling';

  @override
  String get pink => 'Pink';

  @override
  String get brown => 'Brown';

  @override
  String get sessionEnded => 'Session ended';
}
