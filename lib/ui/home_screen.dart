import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/settings.dart';
import '../l10n/generated/app_localizations.dart';
import '../playback/session_controller.dart';
import 'about_screen.dart';
import 'error_text.dart';
import 'session_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.settings});

  final AppSettingsController settings;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _busy = false;

  Future<void> _begin() async {
    if (_busy) return;
    setState(() => _busy = true);
    final controller = SessionController(settings: widget.settings);
    await controller.start();
    if (!mounted) {
      controller.dispose();
      return;
    }
    setState(() => _busy = false);
    final error = controller.status.error;
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(sessionErrorText(context, error))),
        );
      controller.dispose();
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SessionScreen(controller: controller, settings: widget.settings),
      ),
    );
    controller.dispose();
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(settings: widget.settings),
      ),
    );
  }

  void _openAbout() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const AboutScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final width = MediaQuery.sizeOf(context).width;
        final orbSize = (width * 0.62).clamp(192.0, 264.0);
        final timerLabel = widget.settings.timerMinutes == 0
            ? l10n.timerInfinite
            : l10n.minutesShort(widget.settings.timerMinutes);

        final dark = theme.brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
            systemNavigationBarColor: scheme.surface,
            systemNavigationBarIconBrightness: dark
                ? Brightness.light
                : Brightness.dark,
          ),
          child: Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.35),
                        radius: 1.15,
                        colors: [
                          scheme.primary.withValues(alpha: 0.15),
                          scheme.surface,
                          scheme.surface,
                        ],
                        stops: const [0, 0.55, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -120,
                  right: -80,
                  child: _Glow(
                    color: scheme.tertiary.withValues(alpha: 0.10),
                    size: 300,
                  ),
                ),
                Positioned(
                  bottom: -160,
                  left: -120,
                  child: _Glow(
                    color: scheme.secondary.withValues(alpha: 0.07),
                    size: 340,
                  ),
                ),
                SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                          child: Column(
                            children: [
                              _Header(
                                onAbout: _openAbout,
                                onSettings: _openSettings,
                              ),
                              const Spacer(flex: 2),
                              Text(
                                l10n.tagline,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: scheme.onSurface.withValues(
                                    alpha: 0.9,
                                  ),
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              const SizedBox(height: 36),
                              _OrbButton(
                                size: orbSize,
                                label: l10n.begin,
                                sublabel: timerLabel,
                                busy: _busy,
                                onTap: _busy ? null : _begin,
                              ),
                              const SizedBox(height: 40),
                              Text(
                                l10n.sleepTimer,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _TimerChips(
                                minutes: widget.settings.timerMinutes,
                                onChanged: widget.settings.setTimerMinutes,
                              ),
                              const SizedBox(height: 22),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  FilterChip(
                                    selected: widget.settings.noiseEnabled,
                                    onSelected: widget.settings.setNoiseEnabled,
                                    avatar: Icon(
                                      widget.settings.noiseEnabled
                                          ? Icons.graphic_eq_rounded
                                          : Icons.volume_off_rounded,
                                      size: 18,
                                    ),
                                    label: Text(l10n.noise),
                                  ),
                                  ActionChip(
                                    onPressed: () {
                                      widget.settings.setWordLanguage(
                                        widget.settings.wordLanguage == 'es'
                                            ? 'en'
                                            : 'es',
                                      );
                                    },
                                    avatar: const Icon(
                                      Icons.translate_rounded,
                                      size: 18,
                                    ),
                                    label: Text(
                                      widget.settings.wordLanguage == 'es'
                                          ? l10n.spanish
                                          : l10n.english,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(flex: 3),
                              Text(
                                l10n.putPhoneDown,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant.withValues(
                                    alpha: 0.7,
                                  ),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onAbout, required this.onSettings});

  final VoidCallback onAbout;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.appTitle.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              letterSpacing: 2.6,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: onAbout,
          tooltip: l10n.help,
          icon: const Icon(Icons.info_outline_rounded),
        ),
        const SizedBox(width: 2),
        IconButton(
          onPressed: onSettings,
          tooltip: l10n.settings,
          icon: const Icon(Icons.tune_rounded),
        ),
      ],
    );
  }
}

class _TimerChips extends StatelessWidget {
  const _TimerChips({required this.minutes, required this.onChanged});

  final int minutes;
  final ValueChanged<int> onChanged;

  static const _options = <int>[15, 30, 45, 60, 90, 0];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in _options)
          ChoiceChip(
            selected: minutes == option,
            onSelected: (_) => onChanged(option),
            label: Text(
              option == 0 ? l10n.timerInfinite : l10n.minutesShort(option),
            ),
          ),
      ],
    );
  }
}

class _OrbButton extends StatefulWidget {
  const _OrbButton({
    required this.size,
    required this.label,
    required this.sublabel,
    required this.busy,
    required this.onTap,
  });

  final double size;
  final String label;
  final String sublabel;
  final bool busy;
  final VoidCallback? onTap;

  @override
  State<_OrbButton> createState() => _OrbButtonState();
}

class _OrbButtonState extends State<_OrbButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      button: true,
      label: widget.label,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: GestureDetector(
          onTapDown: widget.onTap == null
              ? null
              : (_) => setState(() => _pressed = true),
          onTapCancel: widget.onTap == null
              ? null
              : () => setState(() => _pressed = false),
          onTapUp: widget.onTap == null
              ? null
              : (_) {
                  setState(() => _pressed = false);
                  widget.onTap?.call();
                },
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.2, -0.3),
                radius: 0.9,
                colors: [
                  scheme.primary.withValues(alpha: 0.42),
                  scheme.primary.withValues(alpha: 0.16),
                  scheme.surfaceContainerLow.withValues(alpha: 0.8),
                ],
                stops: const [0, 0.62, 1],
              ),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.45)),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.22),
                  blurRadius: 70,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: widget.onTap,
                splashColor: scheme.primary.withValues(alpha: 0.16),
                child: Center(
                  child: widget.busy
                      ? SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: scheme.onPrimaryContainer,
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.nightlight_round,
                              size: 30,
                              color: scheme.onPrimaryContainer.withValues(
                                alpha: 0.9,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              widget.label,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: scheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.sublabel,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: scheme.onPrimaryContainer.withValues(
                                  alpha: 0.65,
                                ),
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
