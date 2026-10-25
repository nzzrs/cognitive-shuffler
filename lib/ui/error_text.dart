import 'package:flutter/widgets.dart';

import '../l10n/generated/app_localizations.dart';
import '../playback/session_controller.dart';

String sessionErrorText(BuildContext context, SessionError error) {
  final l10n = AppLocalizations.of(context);
  return switch (error.code) {
    'tts_unavailable' => l10n.ttsUnavailable(
      error.language == 'es' ? l10n.spanish : l10n.english,
    ),
    'tts_init_failed' => l10n.ttsInitFailed,
    _ => l10n.startFailed,
  };
}
