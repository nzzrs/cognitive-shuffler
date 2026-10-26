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
  String get paused => 'Paused';

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
  String get fadeOut => 'Fade out';

  @override
  String get fadeOff => 'Off';

  @override
  String get keepAwake => 'Keep screen on';

  @override
  String get showWordsOnScreen => 'Show words on screen';

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
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get close => 'Close';

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
  String get pink => 'Pink';

  @override
  String get brown => 'Brown';

  @override
  String get sessionEnded => 'Session ended';

  @override
  String get cuesSection => 'Cues';

  @override
  String get sleepSection => 'Sleep';

  @override
  String get appSection => 'App';

  @override
  String get theme => 'Theme';

  @override
  String get licenses => 'Licences';

  @override
  String get dynamicColorHint => 'Uses the colours from your wallpaper.';

  @override
  String get noiseOn => 'Noise on';

  @override
  String get noiseOff => 'Noise off';

  @override
  String get returnToSession => 'Return to session';

  @override
  String get sessionInProgress => 'Session in progress';

  @override
  String get endSessionQuestion => 'End session?';

  @override
  String get endSessionBody => 'The words and noise will stop.';

  @override
  String get keepListening => 'Keep listening';

  @override
  String get extendFifteen => '+15 min';

  @override
  String get customDuration => 'Custom duration';

  @override
  String get minutesLabel => 'Minutes';

  @override
  String get setLabel => 'Set';

  @override
  String get cancel => 'Cancel';

  @override
  String get durationRangeError => 'Enter a value between 1 and 720 minutes.';

  @override
  String get voiceVolume => 'Voice volume';

  @override
  String get soundSheetTitle => 'Sound';

  @override
  String get oledMode => 'OLED mode';

  @override
  String get oledModeHint =>
      'Black screen with only the words and pause button.';

  @override
  String get oledInstructions => 'Tap to pause. Double tap to show controls.';

  @override
  String get howToUse => 'How to use this?';

  @override
  String get howToTitle => 'A small exercise for a busy mind';

  @override
  String get howToIntro =>
      'Cognitive shuffling gives your mind unrelated, easy-to-picture words. You are not trying to force sleep. You are giving racing thoughts nothing to hold on to.';

  @override
  String get howToStep1 =>
      'Lie down and dim the room. Put the phone down; the words keep going.';

  @override
  String get howToStep2 =>
      'Let one concrete word arrive. Picture it as a simple scene, without judging the scene.';

  @override
  String get howToStep3 =>
      'Do not connect the words into a story. Let each scene appear, then fade.';

  @override
  String get howToStep4 =>
      'When a thought pulls you away, notice it and return to the next word.';

  @override
  String get howToStep5 =>
      'Keep the voice low. The sleep timer fades the words out so you can stop paying attention.';

  @override
  String get howToWhyTitle => 'Why it may help';

  @override
  String get howToWhy =>
      'The method is also called serial diverse imagining. It fills working memory with random, emotionally neutral images, making it harder for the mind to keep rehearsing worried thoughts, one of the main drivers of pre-sleep arousal. The evidence is early and limited; this is not a treatment for chronic insomnia.';

  @override
  String get howToReferenceTitle => 'Study reference';

  @override
  String get howToReference =>
      'Digdon, N., & Beaudoin, L. P. (2015). A test of the somnolent mentation theory and the cognitive shuffle insomnia treatment. Poster presented at the 37th Annual Conference of the Cognitive Science Society.';

  @override
  String get howToDisclaimer =>
      'This app is a sleep aid, not a medical treatment. If insomnia persists, talk to a clinician.';
}
