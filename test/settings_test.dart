import 'package:cognitive_shuffler/core/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads defaults and persists changes', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = await AppSettingsController.load();
    expect(settings.timerMinutes, 30);
    expect(settings.intervalSeconds, 8);
    expect(settings.noiseEnabled, isTrue);
    expect(settings.fadeOutSeconds, 60);
    expect(settings.themeMode, 'dark');
    expect(settings.keepAwake, isFalse);
    expect(settings.speechVolume, 0.8);
    expect(settings.oledMode, isFalse);

    settings
      ..setTimerMinutes(45)
      ..setWordLanguage('es')
      ..setUiLanguage('es')
      ..setNoiseColor(0.75)
      ..setSpeechVolume(0.55)
      ..setShowWords(false)
      ..setDynamicColor(false)
      ..setOledMode(true);

    final reloaded = await AppSettingsController.load();
    expect(reloaded.timerMinutes, 45);
    expect(reloaded.wordLanguage, 'es');
    expect(reloaded.uiLanguage, 'es');
    expect(reloaded.noiseColor, 0.75);
    expect(reloaded.speechVolume, 0.55);
    expect(reloaded.showWords, isFalse);
    expect(reloaded.dynamicColor, isFalse);
    expect(reloaded.oledMode, isTrue);
    expect(reloaded.locale?.languageCode, 'es');
  });
}
