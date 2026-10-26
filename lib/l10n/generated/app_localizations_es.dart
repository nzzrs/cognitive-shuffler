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
  String get paused => 'En pausa';

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
  String get fadeOut => 'Desvanecido';

  @override
  String get fadeOff => 'No';

  @override
  String get keepAwake => 'Mantener pantalla encendida';

  @override
  String get showWordsOnScreen => 'Mostrar palabras en pantalla';

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
  String version(String version) {
    return 'Versión $version';
  }

  @override
  String get close => 'Cerrar';

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
  String get pink => 'Rosa';

  @override
  String get brown => 'Marrón';

  @override
  String get sessionEnded => 'Sesión terminada';

  @override
  String get cuesSection => 'Palabras';

  @override
  String get sleepSection => 'Sueño';

  @override
  String get appSection => 'App';

  @override
  String get theme => 'Tema';

  @override
  String get licenses => 'Licencias';

  @override
  String get dynamicColorHint => 'Usa los colores de tu fondo de pantalla.';

  @override
  String get noiseOn => 'Ruido activado';

  @override
  String get noiseOff => 'Ruido desactivado';

  @override
  String get returnToSession => 'Volver a la sesión';

  @override
  String get sessionInProgress => 'Sesión en curso';

  @override
  String get endSessionQuestion => '¿Terminar la sesión?';

  @override
  String get endSessionBody => 'Las palabras y el ruido se detendrán.';

  @override
  String get keepListening => 'Seguir escuchando';

  @override
  String get extendFifteen => '+15 min';

  @override
  String get customDuration => 'Duración personalizada';

  @override
  String get minutesLabel => 'Minutos';

  @override
  String get setLabel => 'Establecer';

  @override
  String get cancel => 'Cancelar';

  @override
  String get durationRangeError => 'Introduce un valor entre 1 y 720 minutos.';

  @override
  String get voiceVolume => 'Volumen de la voz';

  @override
  String get soundSheetTitle => 'Sonido';

  @override
  String get oledMode => 'Modo OLED';

  @override
  String get oledModeHint =>
      'Pantalla negra solo con las palabras y el botón de pausa.';

  @override
  String get oledInstructions =>
      'Toca para pausar. Toca dos veces para mostrar los controles.';

  @override
  String get howToUse => '¿Cómo usar esto?';

  @override
  String get howToTitle => 'Un pequeño ejercicio para una mente ocupada';

  @override
  String get howToIntro =>
      'El barajado cognitivo da a tu mente palabras sin relación entre sí y fáciles de imaginar. No intentas forzar el sueño. Le quitas a los pensamientos acelerados aquello a lo que aferrarse.';

  @override
  String get howToStep1 =>
      'Túmbate y baja la luz. Deja el teléfono; las palabras siguen.';

  @override
  String get howToStep2 =>
      'Deja que llegue una palabra concreta. Imagínala como una escena sencilla, sin juzgarla.';

  @override
  String get howToStep3 =>
      'No conectes las palabras en una historia. Deja que cada escena aparezca y se desvanezca.';

  @override
  String get howToStep4 =>
      'Cuando un pensamiento te arrastre, nótalo y vuelve a la siguiente palabra.';

  @override
  String get howToStep5 =>
      'Mantén la voz baja. El temporizador desvanece las palabras para que puedas dejar de prestar atención.';

  @override
  String get howToWhyTitle => 'Por qué puede ayudar';

  @override
  String get howToWhy =>
      'El método también se llama imaginación serial diversa. Ocupa la memoria de trabajo con imágenes aleatorias y emocionalmente neutras, lo que dificulta que la mente siga repasando pensamientos preocupantes, uno de los principales motores de la activación antes de dormir. La evidencia es temprana y limitada; no es un tratamiento para el insomnio crónico.';

  @override
  String get howToReferenceTitle => 'Referencia del estudio';

  @override
  String get howToReference =>
      'Digdon, N., & Beaudoin, L. P. (2015). A test of the somnolent mentation theory and the cognitive shuffle insomnia treatment. Poster presented at the 37th Annual Conference of the Cognitive Science Society.';

  @override
  String get howToDisclaimer =>
      'Esta app es una ayuda para dormir, no un tratamiento médico. Si el insomnio persiste, habla con un profesional sanitario.';
}
