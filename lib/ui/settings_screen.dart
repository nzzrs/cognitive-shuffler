import 'package:flutter/material.dart';

import '../core/settings.dart';
import '../l10n/generated/app_localizations.dart';
import 'about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.settings});

  final AppSettingsController settings;

  static const _timerOptions = <int>[15, 30, 45, 60, 90, 0];
  static const _fadeOptions = <int>[0, 30, 60, 120];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              _Section(
                title: l10n.appLanguage,
                children: [
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(
                        value: 'system',
                        label: Text(l10n.systemDefault),
                      ),
                      ButtonSegment(value: 'en', label: Text(l10n.english)),
                      ButtonSegment(value: 'es', label: Text(l10n.spanish)),
                    ],
                    selected: {settings.uiLanguage},
                    onSelectionChanged: (value) =>
                        settings.setUiLanguage(value.first),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: 'en', label: Text(l10n.english)),
                      ButtonSegment(value: 'es', label: Text(l10n.spanish)),
                    ],
                    selected: {settings.wordLanguage},
                    onSelectionChanged: (value) =>
                        settings.setWordLanguage(value.first),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _Section(
                title: l10n.sleepTimer,
                children: [
                  _ChoiceRow(
                    options: _timerOptions,
                    selected: settings.timerMinutes,
                    onChanged: settings.setTimerMinutes,
                    labelFor: (minutes) => minutes == 0
                        ? l10n.timerInfinite
                        : l10n.minutesShort(minutes),
                  ),
                  const SizedBox(height: 18),
                  _SliderTile(
                    label: l10n.pauseBetweenWords,
                    valueLabel: l10n.secondsShort(settings.intervalSeconds),
                    value: settings.intervalSeconds.toDouble(),
                    min: 4,
                    max: 15,
                    divisions: 11,
                    onChanged: (value) =>
                        settings.setIntervalSeconds(value.round()),
                  ),
                  _SliderTile(
                    label: l10n.voiceSpeed,
                    valueLabel: '${(settings.voiceRate * 100).round()}%',
                    value: settings.voiceRate,
                    min: 0.6,
                    max: 1.2,
                    divisions: 12,
                    onChanged: settings.setVoiceRate,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.fadeOut,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _ChoiceRow(
                    options: _fadeOptions,
                    selected: settings.fadeOutSeconds,
                    onChanged: settings.setFadeOutSeconds,
                    labelFor: (seconds) => seconds == 0
                        ? l10n.fadeOff
                        : l10n.secondsShort(seconds),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _Section(
                title: l10n.noiseDefaults,
                children: [
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.playNoise),
                    value: settings.noiseEnabled,
                    onChanged: settings.setNoiseEnabled,
                  ),
                  _SliderTile(
                    label: l10n.noiseLevel,
                    valueLabel: '${(settings.noiseVolume * 100).round()}%',
                    value: settings.noiseVolume,
                    enabled: settings.noiseEnabled,
                    onChanged: settings.setNoiseVolume,
                  ),
                  _SliderTile(
                    label: l10n.noiseColor,
                    valueLabel: settings.noiseColor < 0.5
                        ? l10n.pink
                        : l10n.brown,
                    value: settings.noiseColor,
                    enabled: settings.noiseEnabled,
                    onChanged: settings.setNoiseColor,
                  ),
                  _SliderTile(
                    label: l10n.warmth,
                    valueLabel: settings.warmth < 0.5 ? l10n.soft : l10n.deep,
                    value: settings.warmth,
                    enabled: settings.noiseEnabled,
                    onChanged: settings.setWarmth,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _Section(
                title: l10n.appearance,
                children: [
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    segments: [
                      ButtonSegment(value: 'dark', label: Text(l10n.themeDark)),
                      ButtonSegment(
                        value: 'system',
                        label: Text(l10n.themeSystem),
                      ),
                      ButtonSegment(
                        value: 'light',
                        label: Text(l10n.themeLight),
                      ),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (value) =>
                        settings.setThemeMode(value.first),
                  ),
                  const SizedBox(height: 6),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.dynamicColor),
                    value: settings.dynamicColor,
                    onChanged: settings.setDynamicColor,
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
              const SizedBox(height: 18),
              _Section(
                title: l10n.about,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.about),
                    subtitle: Text(l10n.aboutIntro),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const AboutScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 9),
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 1.6,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          ),
        ),
      ],
    );
  }
}

class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.labelFor,
  });

  final List<int> options;
  final int selected;
  final ValueChanged<int> onChanged;
  final String Function(int value) labelFor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          ChoiceChip(
            selected: selected == option,
            onSelected: (_) => onChanged(option),
            label: Text(labelFor(option)),
          ),
      ],
    );
  }
}

class _SliderTile extends StatelessWidget {
  const _SliderTile({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.enabled = true,
  });

  final String label;
  final String valueLabel;
  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final int? divisions;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                valueLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max).toDouble(),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
