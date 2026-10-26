import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/settings.dart';
import '../l10n/generated/app_localizations.dart';
import '../playback/session_controller.dart';
import 'error_text.dart';
import 'spacing.dart';
import 'theme.dart';
import 'widgets/labeled_slider.dart';

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
  late final Listenable _listenable = Listenable.merge([
    widget.controller,
    widget.settings,
  ]);
  bool _notificationNoticeShown = false;
  bool _allowPop = false;
  bool _confirming = false;
  bool _oled = false;

  @override
  void initState() {
    super.initState();
    _oled = widget.settings.oledMode;
    if (_oled) {
      unawaited(
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
      );
    }
    widget.controller.addListener(_onControllerChanged);
    if (widget.settings.keepAwake) {
      unawaited(widget.controller.setKeepScreenOn(true));
    }
    _lifecycle = AppLifecycleListener(
      onResume: () => unawaited(widget.controller.sync()),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_oled) {
        _showOledNotice();
      } else {
        _maybeShowNotificationNotice();
      }
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
    if (_oled ||
        _notificationNoticeShown ||
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

  void _enterOled() {
    if (_oled) return;
    unawaited(
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
    );
    setState(() => _oled = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _showOledNotice();
    });
  }

  void _exitOled() {
    if (!_oled) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    setState(() => _oled = false);
    _maybeShowNotificationNotice();
  }

  void _showOledNotice() {
    if (!_oled) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            l10n.oledInstructions,
            style: const TextStyle(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black.withValues(alpha: 0.92),
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 120),
          duration: const Duration(seconds: 4),
        ),
      );
  }

  void _handleBack() {
    if (_oled) {
      _exitOled();
      return;
    }
    unawaited(_confirmEnd());
  }

  Future<void> _togglePause() async {
    if (widget.controller.status.paused) {
      await widget.controller.resume();
    } else {
      await widget.controller.pause();
    }
  }

  Future<void> _confirmEnd() async {
    if (_confirming) return;
    final status = widget.controller.status;
    if (!status.running) {
      _popNow();
      return;
    }
    _confirming = true;
    final l10n = AppLocalizations.of(context);
    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.endSessionQuestion),
        content: Text(l10n.endSessionBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.keepListening),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.stop),
          ),
        ],
      ),
    );
    _confirming = false;
    if (shouldEnd != true || !mounted) return;
    setState(() => _allowPop = true);
    await widget.controller.stop();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _popNow() {
    Navigator.of(context).pop();
  }

  void _openSoundSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (_) =>
          _SoundSheet(settings: widget.settings, controller: widget.controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return AnimatedBuilder(
      animation: _listenable,
      builder: (context, _) {
        final status = widget.controller.status;
        final ended = status.completed && status.error == null;
        final oled = _oled && !ended && status.error == null;
        final remainingMinutes = status.totalMs > 0
            ? (status.remainingMs / 60000).ceil()
            : 0;
        final timerLabel = status.totalMs > 0
            ? AppLocalizations.of(context).minutesShort(remainingMinutes)
            : AppLocalizations.of(context).timerInfinite;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: oled
              ? const SystemUiOverlayStyle(
                  statusBarColor: Colors.transparent,
                  statusBarIconBrightness: Brightness.light,
                  systemNavigationBarColor: Colors.black,
                  systemNavigationBarDividerColor: Colors.transparent,
                  systemNavigationBarIconBrightness: Brightness.light,
                )
              : appOverlayStyle(scheme),
          child: PopScope(
            canPop: _allowPop || !status.running,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) _handleBack();
            },
            child: oled
                ? _buildOledStage(status)
                : _buildFullStage(status, ended, timerLabel),
          ),
        );
      },
    );
  }

  Widget _buildOledStage(SessionStatus status) {
    final l10n = AppLocalizations.of(context);
    final dimmed = Colors.white.withValues(alpha: 0.55);
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _togglePause,
        onDoubleTap: _exitOled,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: _WordStage(
                word: status.word,
                showWords: widget.settings.showWords,
                paused: status.paused,
                oled: true,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.only(bottom: 44),
                child: IconButton.filled(
                  onPressed: _togglePause,
                  tooltip: status.paused ? l10n.resume : l10n.pause,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: dimmed,
                    side: BorderSide(color: dimmed, width: 1.5),
                  ),
                  iconSize: 30,
                  padding: const EdgeInsets.all(20),
                  icon: Icon(
                    status.paused
                        ? Icons.play_arrow_rounded
                        : Icons.pause_rounded,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullStage(SessionStatus status, bool ended, String timerLabel) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: _BreathingBackdrop(
              glow: scheme.primaryContainer,
              surface: scheme.surface,
            ),
          ),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (!ended && status.error == null)
                            _TimerPill(
                              label: timerLabel,
                              paused: status.paused,
                            ),
                          if (status.running && status.totalMs > 0) ...[
                            const SizedBox(width: Spacing.sm),
                            TextButton(
                              onPressed: () => widget.controller.extend(15),
                              child: Text(l10n.extendFifteen),
                            ),
                          ],
                          const Spacer(),
                          IconButton(
                            onPressed: status.running ? _confirmEnd : _popNow,
                            tooltip: status.running
                                ? l10n.endSession
                                : l10n.close,
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onDoubleTap:
                              status.running && status.error == null && !ended
                              ? _enterOled
                              : null,
                          child: status.error != null
                              ? _SessionError(
                                  message: sessionErrorText(
                                    context,
                                    status.error!,
                                  ),
                                  onClose: _popNow,
                                )
                              : ended
                              ? _SessionEnded(onClose: _popNow)
                              : Center(
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
                            IconButton.filled(
                              onPressed: _togglePause,
                              tooltip: status.paused ? l10n.resume : l10n.pause,
                              style: IconButton.styleFrom(
                                backgroundColor: scheme.primary,
                                foregroundColor: scheme.onPrimary,
                              ),
                              iconSize: 28,
                              padding: const EdgeInsets.all(18),
                              icon: Icon(
                                status.paused
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded,
                              ),
                            ),
                            const SizedBox(width: Spacing.lg),
                            IconButton.filledTonal(
                              onPressed: _openSoundSheet,
                              tooltip: l10n.soundSheetTitle,
                              iconSize: 26,
                              padding: const EdgeInsets.all(18),
                              icon: const Icon(Icons.tune_rounded),
                            ),
                            const SizedBox(width: Spacing.lg),
                            IconButton.filledTonal(
                              onPressed: _enterOled,
                              tooltip: l10n.oledMode,
                              iconSize: 26,
                              padding: const EdgeInsets.all(18),
                              icon: const Icon(Icons.contrast_rounded),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.xl),
                        Text(
                          l10n.screenHint,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreathingBackdrop extends StatefulWidget {
  const _BreathingBackdrop({required this.glow, required this.surface});

  final Color glow;
  final Color surface;

  @override
  State<_BreathingBackdrop> createState() => _BreathingBackdropState();
}

class _BreathingBackdropState extends State<_BreathingBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 16),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_controller.value);
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.55 + 0.10 * t),
                radius: 0.95 + 0.35 * t,
                colors: [
                  widget.glow.withValues(alpha: 0.16 + 0.12 * t),
                  widget.surface,
                ],
                stops: const [0, 0.78],
              ),
            ),
          );
        },
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
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerHigh,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(30),
        ),
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
    this.oled = false,
  });

  final String? word;
  final bool showWords;
  final bool paused;
  final bool oled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (!showWords) {
      return _BreathingDot(paused: paused, oled: oled);
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
    final duration = reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 500);
    return AnimatedOpacity(
      opacity: paused ? (oled ? 0.45 : 0.32) : 1,
      duration: duration,
      child: AnimatedSwitcher(
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 850),
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
                    color: oled ? Colors.white : scheme.onSurface,
                  ),
                ),
              ),
              if (paused && !oled) ...[
                const SizedBox(height: Spacing.xl),
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
  const _BreathingDot({required this.paused, this.oled = false});

  final bool paused;
  final bool oled;

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
          width: widget.oled ? 8 : 62,
          height: widget.oled ? 8 : 62,
          decoration: widget.oled
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.7),
                )
              : ShapeDecoration(
                  shape: const CircleBorder(),
                  color: scheme.primaryContainer,
                  shadows: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.24),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
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
        const SizedBox(height: Spacing.xl),
        Text(
          l10n.sessionEnded,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Text(
          l10n.putPhoneDown,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: Spacing.xxl),
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
        const SizedBox(height: Spacing.lg),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
        ),
        const SizedBox(height: Spacing.xl),
        FilledButton.tonal(
          onPressed: onClose,
          child: Text(AppLocalizations.of(context).close),
        ),
      ],
    );
  }
}

class _SoundSheet extends StatefulWidget {
  const _SoundSheet({required this.settings, required this.controller});

  final AppSettingsController settings;
  final SessionController controller;

  @override
  State<_SoundSheet> createState() => _SoundSheetState();
}

class _SoundSheetState extends State<_SoundSheet> {
  Timer? _noiseDebounce;
  Timer? _speechDebounce;

  @override
  void dispose() {
    _noiseDebounce?.cancel();
    _speechDebounce?.cancel();
    super.dispose();
  }

  void _applyNoise() {
    _noiseDebounce?.cancel();
    _noiseDebounce = Timer(const Duration(milliseconds: 90), () {
      unawaited(widget.controller.updateNoise());
    });
  }

  void _applySpeech() {
    _speechDebounce?.cancel();
    _speechDebounce = Timer(const Duration(milliseconds: 90), () {
      unawaited(widget.controller.updateSpeechVolume());
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
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(l10n.soundSheetTitle, style: theme.textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: l10n.close,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              LabeledSlider(
                label: l10n.voiceVolume,
                valueLabel: '${(settings.speechVolume * 100).round()}%',
                value: settings.speechVolume,
                onChanged: (value) {
                  settings.setSpeechVolume(value);
                  _applySpeech();
                },
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
              LabeledSlider(
                label: l10n.level,
                valueLabel: '${(settings.noiseVolume * 100).round()}%',
                value: settings.noiseVolume,
                enabled: settings.noiseEnabled,
                onChanged: (value) {
                  settings.setNoiseVolume(value);
                  _applyNoise();
                },
              ),
              LabeledSlider(
                label: l10n.pinkBrown,
                valueLabel: settings.noiseColor < 0.5 ? l10n.pink : l10n.brown,
                value: settings.noiseColor,
                enabled: settings.noiseEnabled,
                onChanged: (value) {
                  settings.setNoiseColor(value);
                  _applyNoise();
                },
              ),
              LabeledSlider(
                label: l10n.warmth,
                valueLabel: settings.warmth < 0.5 ? l10n.soft : l10n.deep,
                value: settings.warmth,
                enabled: settings.noiseEnabled,
                onChanged: (value) {
                  settings.setWarmth(value);
                  _applyNoise();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
