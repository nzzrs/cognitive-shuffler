import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cognitive Shuffler'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Let the words drift.'**
  String get tagline;

  /// No description provided for @begin.
  ///
  /// In en, this message translates to:
  /// **'Begin'**
  String get begin;

  /// No description provided for @putPhoneDown.
  ///
  /// In en, this message translates to:
  /// **'Put the phone down. The words keep going.'**
  String get putPhoneDown;

  /// No description provided for @sleepTimer.
  ///
  /// In en, this message translates to:
  /// **'Sleep timer'**
  String get sleepTimer;

  /// No description provided for @timerInfinite.
  ///
  /// In en, this message translates to:
  /// **'Until I stop'**
  String get timerInfinite;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @noise.
  ///
  /// In en, this message translates to:
  /// **'Noise'**
  String get noise;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get stop;

  /// No description provided for @endSession.
  ///
  /// In en, this message translates to:
  /// **'End session'**
  String get endSession;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @pinkBrown.
  ///
  /// In en, this message translates to:
  /// **'Pink / brown'**
  String get pinkBrown;

  /// No description provided for @warmth.
  ///
  /// In en, this message translates to:
  /// **'Warmth'**
  String get warmth;

  /// No description provided for @soft.
  ///
  /// In en, this message translates to:
  /// **'Soft'**
  String get soft;

  /// No description provided for @deep.
  ///
  /// In en, this message translates to:
  /// **'Deep'**
  String get deep;

  /// No description provided for @screenHint.
  ///
  /// In en, this message translates to:
  /// **'You can turn the screen off. Playback continues.'**
  String get screenHint;

  /// No description provided for @wordLanguage.
  ///
  /// In en, this message translates to:
  /// **'Word language'**
  String get wordLanguage;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get appLanguage;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemDefault;

  /// No description provided for @voiceSpeed.
  ///
  /// In en, this message translates to:
  /// **'Voice speed'**
  String get voiceSpeed;

  /// No description provided for @pauseBetweenWords.
  ///
  /// In en, this message translates to:
  /// **'Pause between words'**
  String get pauseBetweenWords;

  /// No description provided for @secondsShort.
  ///
  /// In en, this message translates to:
  /// **'{seconds} s'**
  String secondsShort(int seconds);

  /// No description provided for @fadeOut.
  ///
  /// In en, this message translates to:
  /// **'Fade out'**
  String get fadeOut;

  /// No description provided for @fadeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get fadeOff;

  /// No description provided for @keepAwake.
  ///
  /// In en, this message translates to:
  /// **'Keep screen on'**
  String get keepAwake;

  /// No description provided for @showWordsOnScreen.
  ///
  /// In en, this message translates to:
  /// **'Show words on screen'**
  String get showWordsOnScreen;

  /// No description provided for @playNoise.
  ///
  /// In en, this message translates to:
  /// **'Play noise'**
  String get playNoise;

  /// No description provided for @noiseLevel.
  ///
  /// In en, this message translates to:
  /// **'Noise level'**
  String get noiseLevel;

  /// No description provided for @noiseColor.
  ///
  /// In en, this message translates to:
  /// **'Pink / brown balance'**
  String get noiseColor;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @dynamicColor.
  ///
  /// In en, this message translates to:
  /// **'Use wallpaper colour'**
  String get dynamicColor;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutIntro.
  ///
  /// In en, this message translates to:
  /// **'A quiet, offline app that speaks a slow stream of ordinary, concrete nouns. There is nothing to learn and nothing to achieve.'**
  String get aboutIntro;

  /// No description provided for @aboutMethodTitle.
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get aboutMethodTitle;

  /// No description provided for @aboutMethod.
  ///
  /// In en, this message translates to:
  /// **'Cognitive shuffling gives your mind unrelated, easy-to-picture words. Each word is a small scene. Let the scene appear, then let it go. If your thoughts wander, that is the point.'**
  String get aboutMethod;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacy.
  ///
  /// In en, this message translates to:
  /// **'No internet permission. No accounts. No analytics. Your settings stay on this device.'**
  String get aboutPrivacy;

  /// No description provided for @aboutSourcesTitle.
  ///
  /// In en, this message translates to:
  /// **'Words and licences'**
  String get aboutSourcesTitle;

  /// No description provided for @aboutSources.
  ///
  /// In en, this message translates to:
  /// **'Word pools are generated from Princeton WordNet, FrequencyWords (OpenSubtitles), MultiWordNet, the Brysbaert concreteness ratings and the MEGAHit concreteness lexicon. The app and its word data are free software under the GNU GPL v3 and CC BY-SA 4.0.'**
  String get aboutSources;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @ttsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'No speech voice is available for {language}. Install a text-to-speech engine in Android settings.'**
  String ttsUnavailable(String language);

  /// No description provided for @ttsInitFailed.
  ///
  /// In en, this message translates to:
  /// **'The speech engine could not start.'**
  String get ttsInitFailed;

  /// No description provided for @notificationDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off, so the sleep controls will not appear while the screen is off.'**
  String get notificationDenied;

  /// No description provided for @startFailed.
  ///
  /// In en, this message translates to:
  /// **'The session could not start.'**
  String get startFailed;

  /// No description provided for @pink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get pink;

  /// No description provided for @brown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get brown;

  /// No description provided for @sessionEnded.
  ///
  /// In en, this message translates to:
  /// **'Session ended'**
  String get sessionEnded;

  /// No description provided for @cuesSection.
  ///
  /// In en, this message translates to:
  /// **'Cues'**
  String get cuesSection;

  /// No description provided for @sleepSection.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepSection;

  /// No description provided for @appSection.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get appSection;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Licences'**
  String get licenses;

  /// No description provided for @dynamicColorHint.
  ///
  /// In en, this message translates to:
  /// **'Uses the colours from your wallpaper.'**
  String get dynamicColorHint;

  /// No description provided for @noiseOn.
  ///
  /// In en, this message translates to:
  /// **'Noise on'**
  String get noiseOn;

  /// No description provided for @noiseOff.
  ///
  /// In en, this message translates to:
  /// **'Noise off'**
  String get noiseOff;

  /// No description provided for @returnToSession.
  ///
  /// In en, this message translates to:
  /// **'Return to session'**
  String get returnToSession;

  /// No description provided for @sessionInProgress.
  ///
  /// In en, this message translates to:
  /// **'Session in progress'**
  String get sessionInProgress;

  /// No description provided for @endSessionQuestion.
  ///
  /// In en, this message translates to:
  /// **'End session?'**
  String get endSessionQuestion;

  /// No description provided for @endSessionBody.
  ///
  /// In en, this message translates to:
  /// **'The words and noise will stop.'**
  String get endSessionBody;

  /// No description provided for @keepListening.
  ///
  /// In en, this message translates to:
  /// **'Keep listening'**
  String get keepListening;

  /// No description provided for @extendFifteen.
  ///
  /// In en, this message translates to:
  /// **'+15 min'**
  String get extendFifteen;

  /// No description provided for @customDuration.
  ///
  /// In en, this message translates to:
  /// **'Custom duration'**
  String get customDuration;

  /// No description provided for @minutesLabel.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutesLabel;

  /// No description provided for @setLabel.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setLabel;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @durationRangeError.
  ///
  /// In en, this message translates to:
  /// **'Enter a value between 1 and 720 minutes.'**
  String get durationRangeError;

  /// No description provided for @voiceVolume.
  ///
  /// In en, this message translates to:
  /// **'Voice volume'**
  String get voiceVolume;

  /// No description provided for @soundSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundSheetTitle;

  /// No description provided for @oledMode.
  ///
  /// In en, this message translates to:
  /// **'OLED mode'**
  String get oledMode;

  /// No description provided for @oledModeHint.
  ///
  /// In en, this message translates to:
  /// **'Black screen with only the words and pause button.'**
  String get oledModeHint;

  /// No description provided for @oledInstructions.
  ///
  /// In en, this message translates to:
  /// **'Tap to pause. Double tap to show controls.'**
  String get oledInstructions;

  /// No description provided for @howToUse.
  ///
  /// In en, this message translates to:
  /// **'How to use this?'**
  String get howToUse;

  /// No description provided for @howToTitle.
  ///
  /// In en, this message translates to:
  /// **'A small exercise for a busy mind'**
  String get howToTitle;

  /// No description provided for @howToIntro.
  ///
  /// In en, this message translates to:
  /// **'Cognitive shuffling gives your mind unrelated, easy-to-picture words. You are not trying to force sleep. You are giving racing thoughts nothing to hold on to.'**
  String get howToIntro;

  /// No description provided for @howToStep1.
  ///
  /// In en, this message translates to:
  /// **'Lie down and dim the room. Put the phone down; the words keep going.'**
  String get howToStep1;

  /// No description provided for @howToStep2.
  ///
  /// In en, this message translates to:
  /// **'Let one concrete word arrive. Picture it as a simple scene, without judging the scene.'**
  String get howToStep2;

  /// No description provided for @howToStep3.
  ///
  /// In en, this message translates to:
  /// **'Do not connect the words into a story. Let each scene appear, then fade.'**
  String get howToStep3;

  /// No description provided for @howToStep4.
  ///
  /// In en, this message translates to:
  /// **'When a thought pulls you away, notice it and return to the next word.'**
  String get howToStep4;

  /// No description provided for @howToStep5.
  ///
  /// In en, this message translates to:
  /// **'Keep the voice low. The sleep timer fades the words out so you can stop paying attention.'**
  String get howToStep5;

  /// No description provided for @howToWhyTitle.
  ///
  /// In en, this message translates to:
  /// **'Why it may help'**
  String get howToWhyTitle;

  /// No description provided for @howToWhy.
  ///
  /// In en, this message translates to:
  /// **'The method is also called serial diverse imagining. It fills working memory with random, emotionally neutral images, making it harder for the mind to keep rehearsing worried thoughts, one of the main drivers of pre-sleep arousal. The evidence is early and limited; this is not a treatment for chronic insomnia.'**
  String get howToWhy;

  /// No description provided for @howToReferenceTitle.
  ///
  /// In en, this message translates to:
  /// **'Study reference'**
  String get howToReferenceTitle;

  /// No description provided for @howToReference.
  ///
  /// In en, this message translates to:
  /// **'Digdon, N., & Beaudoin, L. P. (2015). A test of the somnolent mentation theory and the cognitive shuffle insomnia treatment. Poster presented at the 37th Annual Conference of the Cognitive Science Society.'**
  String get howToReference;

  /// No description provided for @howToDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This app is a sleep aid, not a medical treatment. If insomnia persists, talk to a clinician.'**
  String get howToDisclaimer;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
