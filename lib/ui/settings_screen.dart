import 'package:flutter/material.dart';

import '../core/app_info.dart';
import '../core/settings.dart';
import '../l10n/generated/app_localizations.dart';
import 'about_screen.dart';
import 'spacing.dart';
import 'widgets/choice_sheet.dart';
import 'widgets/labeled_slider.dart';
import 'widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.settings,
    required this.dynamicColorAvailable,
  });

  final AppSettingsController settings;
  final bool dynamicColorAvailable;

  static const _fadeOptions = <int>[0, 30, 60, 120];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  SettingsSection(
                    title: l10n.cuesSection,
                    children: [
                      ChoiceTile(
                        label: l10n.wordLanguage,
                        valueLabel: _wordLanguageLabel(context),
                        onTap: () => _pickWordLanguage(context),
                      ),
                      LabeledSlider(
                        label: l10n.pauseBetweenWords,
                        valueLabel: l10n.secondsShort(settings.intervalSeconds),
                        value: settings.intervalSeconds.toDouble(),
                        min: 4,
                        max: 15,
                        divisions: 11,
                        onChanged: (value) =>
                            settings.setIntervalSeconds(value.round()),
                      ),
                      LabeledSlider(
                        label: l10n.voiceSpeed,
                        valueLabel: '${(settings.voiceRate * 100).round()}%',
                        value: settings.voiceRate,
                        min: 0.6,
                        max: 1.2,
                        divisions: 12,
                        onChanged: settings.setVoiceRate,
                      ),
                      LabeledSlider(
                        label: l10n.voiceVolume,
                        valueLabel: '${(settings.speechVolume * 100).round()}%',
                        value: settings.speechVolume,
                        onChanged: settings.setSpeechVolume,
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: l10n.sleepSection,
                    children: [
                      ChoiceTile(
                        label: l10n.fadeOut,
                        valueLabel: settings.fadeOutSeconds == 0
                            ? l10n.fadeOff
                            : l10n.secondsShort(settings.fadeOutSeconds),
                        onTap: () => _pickFadeOut(context),
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.keepAwake),
                        value: settings.keepAwake,
                        onChanged: settings.setKeepAwake,
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.showWordsOnScreen),
                        value: settings.showWords,
                        onChanged: settings.setShowWords,
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: l10n.noise,
                    children: [
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.playNoise),
                        value: settings.noiseEnabled,
                        onChanged: settings.setNoiseEnabled,
                      ),
                      LabeledSlider(
                        label: l10n.noiseLevel,
                        valueLabel: '${(settings.noiseVolume * 100).round()}%',
                        value: settings.noiseVolume,
                        enabled: settings.noiseEnabled,
                        onChanged: settings.setNoiseVolume,
                      ),
                      LabeledSlider(
                        label: l10n.noiseColor,
                        valueLabel: settings.noiseColor < 0.5
                            ? l10n.pink
                            : l10n.brown,
                        value: settings.noiseColor,
                        enabled: settings.noiseEnabled,
                        onChanged: settings.setNoiseColor,
                      ),
                      LabeledSlider(
                        label: l10n.warmth,
                        valueLabel: settings.warmth < 0.5
                            ? l10n.soft
                            : l10n.deep,
                        value: settings.warmth,
                        enabled: settings.noiseEnabled,
                        onChanged: settings.setWarmth,
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: l10n.appearance,
                    children: [
                      ChoiceTile(
                        label: l10n.theme,
                        valueLabel: _themeLabel(context),
                        onTap: () => _pickTheme(context),
                      ),
                      if (dynamicColorAvailable)
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.dynamicColor),
                          subtitle: Text(l10n.dynamicColorHint),
                          value: settings.dynamicColor,
                          onChanged: settings.setDynamicColor,
                        ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.oledMode),
                        subtitle: Text(l10n.oledModeHint),
                        value: settings.oledMode,
                        onChanged: (value) {
                          settings.setOledMode(value);
                          if (value) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(content: Text(l10n.oledInstructions)),
                              );
                          }
                        },
                      ),
                    ],
                  ),
                  SettingsSection(
                    title: l10n.appSection,
                    children: [
                      ChoiceTile(
                        label: l10n.appLanguage,
                        valueLabel: _uiLanguageLabel(context),
                        onTap: () => _pickUiLanguage(context),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.about),
                        subtitle: Text(l10n.version(appVersion)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const AboutScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.sm),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _uiLanguageLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (settings.uiLanguage) {
      'en' => l10n.english,
      'es' => l10n.spanish,
      _ => l10n.systemDefault,
    };
  }

  String _wordLanguageLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return settings.wordLanguage == 'es' ? l10n.spanish : l10n.english;
  }

  String _themeLabel(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (settings.themeMode) {
      'light' => l10n.themeLight,
      'system' => l10n.themeSystem,
      _ => l10n.themeDark,
    };
  }

  Future<void> _pickUiLanguage(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final value = await showChoiceSheet<String>(
      context: context,
      title: l10n.appLanguage,
      selected: settings.uiLanguage,
      options: [
        ChoiceOption(value: 'system', label: l10n.systemDefault),
        ChoiceOption(value: 'en', label: l10n.english),
        ChoiceOption(value: 'es', label: l10n.spanish),
      ],
    );
    if (value != null) settings.setUiLanguage(value);
  }

  Future<void> _pickWordLanguage(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final value = await showChoiceSheet<String>(
      context: context,
      title: l10n.wordLanguage,
      selected: settings.wordLanguage,
      options: [
        ChoiceOption(value: 'en', label: l10n.english),
        ChoiceOption(value: 'es', label: l10n.spanish),
      ],
    );
    if (value != null) settings.setWordLanguage(value);
  }

  Future<void> _pickTheme(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final value = await showChoiceSheet<String>(
      context: context,
      title: l10n.theme,
      selected: settings.themeMode,
      options: [
        ChoiceOption(value: 'system', label: l10n.themeSystem),
        ChoiceOption(value: 'light', label: l10n.themeLight),
        ChoiceOption(value: 'dark', label: l10n.themeDark),
      ],
    );
    if (value != null) settings.setThemeMode(value);
  }

  Future<void> _pickFadeOut(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final value = await showChoiceSheet<int>(
      context: context,
      title: l10n.fadeOut,
      selected: settings.fadeOutSeconds,
      options: [
        for (final seconds in _fadeOptions)
          ChoiceOption(
            value: seconds,
            label: seconds == 0 ? l10n.fadeOff : l10n.secondsShort(seconds),
          ),
      ],
    );
    if (value != null) settings.setFadeOutSeconds(value);
  }
}
