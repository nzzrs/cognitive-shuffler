import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/settings.dart';
import '../l10n/generated/app_localizations.dart';
import '../playback/session_controller.dart';
import 'error_text.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({
    super.key,
    required this.controller,
    required this.settings,
  });

  final SessionController controller;
  final AppSettingsController settings;

  @override
  State<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  late final AppLifecycleListener _lifecycle;
  bool _notificationNoticeShown = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    if (widget.settings.keepAwake) {
      unawaited(widget.controller.setKeepScreenOn(true));
    }
    _lifecycle = AppLifecycleListener(
      onResume: () => unawaited(widget.controller.sync()),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _maybeShowNotificationNotice();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    if (widget.settings.keepAwake) {
      unawaited(widget.controller.setKeepScreenOn(false));
    }
    if (widget.controller.status.running) {
      unawaited(widget.controller.stop());
    }
    _lifecycle.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    _maybeShowNotificationNotice();
  }

  void _maybeShowNotificationNotice() {
    if (_notificationNoticeShown ||
        !widget.controller.status.notificationsDenied ||
        !mounted) {
      return;
    }
    _notificationNoticeShown = true;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.notificationDenied)));
  }

  Future<void> _togglePause() async {
    if (widget.controller.status.paused) {
      await widget.controller.resume();
    } else {
      await widget.controller.pause();
    }
  }

  Future<void> _end() async {
    await widget.controller.stop();
    if (mounted) Navigator.of(context).maybePop();
  }

  void _close() {
    if (mounted) Navigator.of(context).maybePop();
  }

  void _openNoiseSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) =>
          _NoiseSheet(settings: widget.settings, controller: widget.controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnimatedBuilder(
          animation: widget.controller,
          builder: (context, _) {
            final status = widget.controller.status;
            final ended = status.completed && status.error == null;
            final remainingMinutes = status.totalMs > 0
                ? (status.remainingMs / 60000).ceil()
                : 0;
            final timerLabel = status.totalMs > 0
                ? l10n.minutesShort(remainingMinutes)
                : l10n.timerInfinite;
            return Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.4),
                        radius: 1.1,
                        colors: [
                          scheme.primary.withValues(alpha: 0.10),
                          Colors.black,
                          Colors.black,
                        ],
                        stops: const [0, 0.6, 1],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            if (!ended)
                              _TimerPill(
                                label: timerLabel,
                                paused: status.paused,
                              ),
                            const Spacer(),
                            IconButton(
                              onPressed: ended ? _close : _end,
                              tooltip: l10n.endSession,
                              icon: const Icon(Icons.close_rounded),
                            ),
                          ],
                        ),
                        Expanded(
                          child: status.error != null
                              ? _SessionError(
                                  message: sessionErrorText(
                                    context,
                                    status.error!,
                                  ),
                                  onClose: _close,
                                )
                              : ended
                              ? _SessionEnded(onClose: _close)
                              : GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: _togglePause,
                                  child: Center(
                                    child: _WordStage(
                                      word: status.word,
                                      showWords: widget.settings.showWords,
                                      paused: status.paused,
                                    ),
                                  ),
                                ),
                        ),
                        if (status.error == null && !ended) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton.filledTonal(
                                onPressed: _togglePause,
                                tooltip: status.paused
                                    ? l10n.resume
                                    : l10n.pause,
                                iconSize: 28,
                                padding: const EdgeInsets.all(18),
                                icon: Icon(
                                  status.paused
                                      ? Icons.play_arrow_rounded
                                      : Icons.pause_rounded,
                                ),
                              ),
                              const SizedBox(width: 18),
                              IconButton.filledTonal(
                                onPressed: _openNoiseSheet,
                                tooltip: l10n.noiseSheetTitle,
                                iconSize: 26,
                                padding: const EdgeInsets.all(18),
                                icon: const Icon(Icons.graphic_eq_rounded),
                              ),
                            ],
                          ),
                          const SizedBox(height: 26),
                          Text(
                            l10n.screenHint,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant.withValues(
                                alpha: 0.55,
                              ),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  const _TimerPill({required this.label, required this.paused});

  final String label;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            paused ? Icons.pause_rounded : Icons.timer_outlined,
            size: 15,
            color: scheme.onSurfaceVariant,
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _WordStage extends StatelessWidget {
  const _WordStage({
    required this.word,
    required this.showWords,
    required this.paused,
  });

  final String? word;
  final bool showWords;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (!showWords) {
      return _BreathingDot(paused: paused);
    }
    final current = word;
    if (current == null) {
      return SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: scheme.primary.withValues(alpha: 0.6),
        ),
      );
    }
    return AnimatedOpacity(
      opacity: paused ? 0.32 : 1,
      duration: const Duration(milliseconds: 500),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 850),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1).animate(animation),
              child: child,
            ),
          );
        },
        child: Padding(
          key: ValueKey(current),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  current,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontSize: 58,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (paused) ...[
                const SizedBox(height: 26),
                Text(
                  AppLocalizations.of(context).paused,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _BreathingDot extends StatefulWidget {
  const _BreathingDot({required this.paused});

  final bool paused;

  @override
  State<_BreathingDot> createState() => _BreathingDotState();
}

class _BreathingDotState extends State<_BreathingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 7),
    lowerBound: 0.86,
    upperBound: 1.06,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    return ScaleTransition(
      scale: reduceMotion
          ? const AlwaysStoppedAnimation<double>(1)
          : _controller,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: widget.paused ? 0.25 : 1,
        child: Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                scheme.primary.withValues(alpha: 0.45),
                scheme.primary.withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
          ),
        ),
      ),
    );
  }
}

class _SessionEnded extends StatelessWidget {
  const _SessionEnded({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.nightlight_round,
          size: 42,
          color: scheme.primary.withValues(alpha: 0.8),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.sessionEnded,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: scheme.onSurface,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.putPhoneDown,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 28),
        FilledButton.tonal(onPressed: onClose, child: Text(l10n.close)),
      ],
    );
  }
}

class _SessionError extends StatelessWidget {
  const _SessionError({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.volume_off_rounded, size: 40, color: scheme.error),
        const SizedBox(height: 18),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: 24),
        FilledButton.tonal(
          onPressed: onClose,
          child: Text(AppLocalizations.of(context).close),
        ),
      ],
    );
  }
}

class _NoiseSheet extends StatefulWidget {
  const _NoiseSheet({required this.settings, required this.controller});

  final AppSettingsController settings;
  final SessionController controller;

  @override
  State<_NoiseSheet> createState() => _NoiseSheetState();
}

class _NoiseSheetState extends State<_NoiseSheet> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _applyNoise() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 90), () {
      unawaited(widget.controller.updateNoise());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: widget.settings,
      builder: (context, _) {
        final settings = widget.settings;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            0,
            24,
            20 + MediaQuery.viewPaddingOf(context).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(l10n.noiseSheetTitle, style: theme.textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: l10n.close,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.playNoise),
                value: settings.noiseEnabled,
                onChanged: (value) {
                  settings.setNoiseEnabled(value);
                  unawaited(widget.controller.updateNoise());
                },
              ),
              _LabeledSlider(
                label: l10n.level,
                valueLabel: '${(settings.noiseVolume * 100).round()}%',
                value: settings.noiseVolume,
                enabled: settings.noiseEnabled,
                onChanged: (value) {
                  settings.setNoiseVolume(value);
                  _applyNoise();
                },
              ),
              _LabeledSlider(
                label: l10n.pinkBrown,
                valueLabel: settings.noiseColor < 0.5 ? l10n.pink : l10n.brown,
                value: settings.noiseColor,
                enabled: settings.noiseEnabled,
                onChanged: (value) {
                  settings.setNoiseColor(value);
                  _applyNoise();
                },
              ),
              _LabeledSlider(
                label: l10n.warmth,
                valueLabel: settings.warmth < 0.5 ? l10n.soft : l10n.deep,
                value: settings.warmth,
                enabled: settings.noiseEnabled,
                onChanged: (value) {
                  settings.setWarmth(value);
                  _applyNoise();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

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
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                valueLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(0.0, 1.0).toDouble(),
            onChanged: enabled ? onChanged : null,
          ),
        ],
      ),
    );
  }
}
