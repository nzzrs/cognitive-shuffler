import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    scheme.primary.withValues(alpha: 0.45),
                    scheme.primary.withValues(alpha: 0.08),
                  ],
                ),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                Icons.nightlight_round,
                size: 36,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(child: Text(l10n.appTitle, style: theme.textTheme.titleLarge)),
          Center(
            child: Text(
              l10n.tagline,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(l10n.aboutIntro, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 28),
          _Block(title: l10n.aboutMethodTitle, body: l10n.aboutMethod),
          _Block(title: l10n.aboutPrivacyTitle, body: l10n.aboutPrivacy),
          _Block(title: l10n.aboutSourcesTitle, body: l10n.aboutSources),
          const SizedBox(height: 8),
          _Block(title: l10n.aboutLicense, body: l10n.version('1.0.0')),
          const SizedBox(height: 22),
          OutlinedButton(
            onPressed: () => showLicensePage(
              context: context,
              applicationName: l10n.appTitle,
              applicationVersion: '1.0.0',
            ),
            child: Text(l10n.aboutLicense),
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.55)),
        ],
      ),
    );
  }
}
