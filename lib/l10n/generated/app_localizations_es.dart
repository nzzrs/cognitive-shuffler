// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Cognitive Shuffler';

  @override
  String get tagline => 'Deja que las palabras fluyan.';

  @override
  String get begin => 'Comenzar';

  @override
  String get putPhoneDown => 'Deja el teléfono. Las palabras siguen.';

  @override
  String get sleepTimer => 'Temporizador';

  @override
  String get timerInfinite => 'Hasta que pare';

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String get noise => 'Ruido';

  @override
  String get on => 'Activado';

  @override
  String get off => 'Desactivado';

  @override
  String get cueLanguage => 'Idioma de las palabras';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get settings => 'Ajustes';

  @override
  String get pause => 'Pausa';

  @override
  String get resume => 'Continuar';

  @override
  String get stop => 'Terminar';

  @override
  String get endSession => 'Terminar sesión';

  @override
  String get noTimer => 'Sin temporizador';

  @override
  String get paused => 'En pausa';

  @override
  String get noiseSheetTitle => 'Ruido';

  @override
  String get level => 'Nivel';

  @override
  String get pinkBrown => 'Rosa / marrón';

  @override
  String get warmth => 'Calidez';

  @override
  String get soft => 'Suave';

  @override
  String get deep => 'Profundo';

  @override
  String get showWords => 'Mostrar palabras';

  @override
  String get screenHint =>
      'Puedes apagar la pantalla. La reproducción continúa.';

  @override
  String get wordLanguage => 'Idioma de las palabras';

  @override
  String get appLanguage => 'Idioma de la app';

  @override
  String get systemDefault => 'Sistema';

  @override
  String get voiceSpeed => 'Velocidad de la voz';

  @override
  String get pauseBetweenWords => 'Pausa entre palabras';

  @override
  String secondsShort(int seconds) {
    return '$seconds s';
  }

  @override
  String get defaultTimer => 'Temporizador predeterminado';

  @override
  String get fadeOut => 'Desvanecido';

  @override
  String get fadeOff => 'No';

  @override
  String get keepAwake => 'Mantener pantalla encendida';

  @override
  String get showWordsOnScreen => 'Mostrar palabras en pantalla';

  @override
  String get noiseDefaults => 'Ruido';

  @override
  String get playNoise => 'Reproducir ruido';

  @override
  String get noiseLevel => 'Nivel de ruido';

  @override
  String get noiseColor => 'Equilibrio rosa / marrón';

  @override
  String get appearance => 'Apariencia';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Sistema';

  @override
  String get themeLight => 'Claro';

  @override
  String get dynamicColor => 'Usar color del fondo';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutIntro =>
      'Una app tranquila y sin conexión que pronuncia una corriente lenta de sustantivos comunes y concretos. No hay nada que aprender ni lograr.';

  @override
  String get aboutMethodTitle => 'Cómo funciona';

  @override
  String get aboutMethod =>
      'El barajado cognitivo te da palabras sencillas y sin relación entre sí, fáciles de imaginar. Cada palabra es una escena pequeña. Deja que aparezca y luego suéltala. Si tu mente se distrae, esa es la idea.';

  @override
  String get aboutPrivacyTitle => 'Privacidad';

  @override
  String get aboutPrivacy =>
      'Sin permiso de internet. Sin cuentas. Sin analíticas. Tus ajustes se quedan en este dispositivo.';

  @override
  String get aboutSourcesTitle => 'Palabras y licencias';

  @override
  String get aboutSources =>
      'Los bancos de palabras se generan a partir de Princeton WordNet, FrequencyWords (OpenSubtitles), MultiWordNet, las valoraciones de concreción de Brysbaert y el léxico de concreción MEGAHit. La app y sus datos son software libre bajo GNU GPL v3 y CC BY-SA 4.0.';

  @override
  String get aboutLicense => 'GNU General Public License v3.0 o posterior';

  @override
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get close => 'Cerrar';

  @override
  String get done => 'Listo';

  @override
  String ttsUnavailable(String language) {
    return 'No hay una voz disponible para $language. Instala un motor de texto a voz en los ajustes de Android.';
  }

  @override
  String get ttsInitFailed => 'El motor de voz no pudo iniciarse.';

  @override
  String get notificationDenied =>
      'Las notificaciones están desactivadas, así que los controles no aparecerán con la pantalla apagada.';

  @override
  String get startFailed => 'No se pudo iniciar la sesión.';

  @override
  String get methodTitle => 'Un pequeño experimento para una mente ocupada';

  @override
  String get methodBody =>
      'Imagina cada palabra como una escena sencilla. No conectes las palabras. Cuando una desaparezca, deja que llegue la siguiente.';

  @override
  String get help => 'Acerca del barajado cognitivo';

  @override
  String get pink => 'Rosa';

  @override
  String get brown => 'Marrón';

  @override
  String get sessionEnded => 'Sesión terminada';
}
