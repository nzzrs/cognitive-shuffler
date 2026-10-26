import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/settings.dart';
import '../l10n/generated/app_localizations.dart';
import '../playback/session_controller.dart';
import 'error_text.dart';
import 'how_to_screen.dart';
import 'session_screen.dart';
import 'settings_screen.dart';
import 'spacing.dart';
import 'theme.dart';
import 'widgets/sleep_timer_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.settings,
    required this.dynamicColorAvailable,
  });

  final AppSettingsController settings;
  final bool dynamicColorAvailable;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SessionController _controller = SessionController(
    settings: widget.settings,
  );
  late final Listenable _listenable = Listenable.merge([
    widget.settings,
    _controller,
  ]);
  late final AppLifecycleListener _lifecycle;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _syncSession);
    _syncSession();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _syncSession() async {
    await _controller.sync();
  }

  Future<void> _primaryAction() async {
    if (_busy) return;
    final wasRunning = _controller.status.running;
    if (!wasRunning) {
      setState(() => _busy = true);
      await _controller.start();
      if (!mounted) return;
      setState(() => _busy = false);
      final error = _controller.status.error;
      if (error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(sessionErrorText(context, error))),
          );
        return;
      }
    } else {
      await _controller.sync();
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            SessionScreen(controller: _controller, settings: widget.settings),
      ),
    );
    if (!mounted) return;
    await _controller.sync();
  }

  Future<void> _pickTimer() async {
    final value = await showSleepTimerSheet(
      context: context,
      selected: widget.settings.timerMinutes,
    );
    if (value != null) widget.settings.setTimerMinutes(value);
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsScreen(
          settings: widget.settings,
          dynamicColorAvailable: widget.dynamicColorAvailable,
        ),
      ),
    );
  }

  void _openHowTo() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const HowToScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _listenable,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final width = MediaQuery.sizeOf(context).width;
        final startSize = (width * 0.58).clamp(200.0, 248.0);
        final status = _controller.status;
        final running = status.running;
        final timerLabel = widget.settings.timerMinutes == 0
            ? l10n.timerInfinite
            : l10n.minutesShort(widget.settings.timerMinutes);
        final languageLabel = widget.settings.wordLanguage == 'es'
            ? l10n.spanish
            : l10n.english;
        final noiseLabel = widget.settings.noiseEnabled
            ? l10n.noiseOn
            : l10n.noiseOff;
        final remainingLabel = status.totalMs > 0
            ? l10n.minutesShort((status.remainingMs / 60000).ceil())
            : l10n.timerInfinite;
        final summary = running
            ? '${l10n.sessionInProgress} · $remainingLabel'
            : '$languageLabel · $noiseLabel';

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: appOverlayStyle(scheme),
          child: Scaffold(
            body: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.5),
                        radius: 1.05,
                        colors: [
                          scheme.primaryContainer.withValues(alpha: 0.34),
                          scheme.surface,
                        ],
                        stops: const [0, 0.72],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: CustomScrollView(
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 560),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                              child: Column(
                                children: [
                                  _Header(
                                    title: l10n.appTitle,
                                    onInfo: _busy ? null : _openHowTo,
                                    onSettings: _busy ? null : _openSettings,
                                  ),
                                  const Spacer(flex: 2),
                                  Text(
                                    l10n.tagline,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          color: scheme.onSurface.withValues(
                                            alpha: 0.9,
                                          ),
                                        ),
                                  ),
                                  const SizedBox(height: Spacing.xxl),
                                  _StartButton(
                                    size: startSize,
                                    label: running
                                        ? l10n.returnToSession
                                        : l10n.begin,
                                    busy: _busy,
                                    onTap: _busy ? null : _primaryAction,
                                  ),
                                  const SizedBox(height: Spacing.lg),
                                  if (!running)
                                    OutlinedButton.icon(
                                      onPressed: _busy ? null : _pickTimer,
                                      icon: const Icon(
                                        Icons.timer_outlined,
                                        size: 18,
                                      ),
                                      label: Text(
                                        '${l10n.sleepTimer} · $timerLabel',
                                      ),
                                    ),
                                  const SizedBox(height: Spacing.md),
                                  Text(
                                    summary,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.labelMedium
                                        ?.copyWith(
                                          color: scheme.onSurfaceVariant,
                                        ),
                                  ),
                                  const Spacer(flex: 3),
                                  Text(
                                    l10n.putPhoneDown,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
  const _Header({
    required this.title,
    required this.onInfo,
    required this.onSettings,
  });

  final String title;
  final VoidCallback? onInfo;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        IconButton(
          onPressed: onInfo,
          tooltip: l10n.howToUse,
          icon: const Icon(Icons.info_outline_rounded),
        ),
        IconButton(
          onPressed: onSettings,
          tooltip: l10n.settings,
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }
}

class _StartButton extends StatefulWidget {
  const _StartButton({
    required this.size,
    required this.label,
    required this.busy,
    required this.onTap,
  });

  final double size;
  final String label;
  final bool busy;
  final VoidCallback? onTap;

  @override
  State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.circular(widget.size * 0.36),
    );
    return Semantics(
      button: true,
      enabled: widget.onTap != null,
      label: widget.label,
      excludeSemantics: true,
      child: Material(
        color: scheme.primaryContainer,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: shape,
          onTap: widget.onTap,
          onHighlightChanged: (value) {
            if (_pressed != value) setState(() => _pressed = value);
          },
          splashColor: scheme.primary.withValues(alpha: 0.16),
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: Center(
                child: widget.busy
                    ? SizedBox(
                        width: 34,
                        height: 34,
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
                            size: 34,
                            color: scheme.onPrimaryContainer.withValues(
                              alpha: 0.9,
                            ),
                          ),
                          const SizedBox(height: Spacing.lg),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.lg,
                            ),
                            child: Text(
                              widget.label,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
