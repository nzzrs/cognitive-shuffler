import 'package:flutter/material.dart';

import '../core/app_info.dart';
import '../l10n/generated/app_localizations.dart';
import 'spacing.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
            children: [
              Center(
                child: Material(
                  color: scheme.primaryContainer,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: SizedBox(
                    width: 88,
                    height: 88,
                    child: Icon(
                      Icons.nightlight_round,
                      size: 36,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.lg),
              Center(
                child: Text(l10n.appTitle, style: theme.textTheme.titleLarge),
              ),
              const SizedBox(height: Spacing.xs),
              Center(
                child: Text(
                  l10n.version(appVersion),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: Spacing.xxl),
              Text(l10n.aboutIntro, style: theme.textTheme.bodyLarge),
              const SizedBox(height: Spacing.xl),
              _Block(title: l10n.aboutMethodTitle, body: l10n.aboutMethod),
              _Block(title: l10n.aboutPrivacyTitle, body: l10n.aboutPrivacy),
              _Block(title: l10n.aboutSourcesTitle, body: l10n.aboutSources),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.description_outlined,
                  color: scheme.onSurfaceVariant,
                ),
                title: Text(l10n.licenses),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: l10n.appTitle,
                  applicationVersion: appVersion,
                ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.only(bottom: Spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.55)),
        ],
      ),
    );
  }
}
