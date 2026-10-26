import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/generated/app_localizations.dart';
import '../spacing.dart';

const int _maxCustomMinutes = 720;

/// Timer sheet with the common presets plus an exact minute input.
Future<int?> showSleepTimerSheet({
  required BuildContext context,
  required int selected,
}) {
  return showModalBottomSheet<int>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 640),
    builder: (context) => _SleepTimerSheet(selected: selected),
  );
}

class _SleepTimerSheet extends StatelessWidget {
  const _SleepTimerSheet({required this.selected});

  final int selected;

  static const _presets = <int>[15, 30, 45, 60, 90, 0];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.sleepTimer, style: theme.textTheme.titleLarge),
          const SizedBox(height: Spacing.lg),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              for (final minutes in _presets)
                ChoiceChip(
                  selected: selected == minutes,
                  onSelected: (_) => Navigator.of(context).pop(minutes),
                  label: Text(
                    minutes == 0
                        ? l10n.timerInfinite
                        : l10n.minutesShort(minutes),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          OutlinedButton.icon(
            onPressed: () => _pickCustom(context),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(l10n.customDuration),
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustom(BuildContext context) async {
    final minutes = await showDialog<int>(
      context: context,
      builder: (_) =>
          _CustomDurationDialog(initialMinutes: selected > 0 ? selected : 30),
    );
    if (minutes != null && context.mounted) {
      Navigator.of(context).pop(minutes);
    }
  }
}

class _CustomDurationDialog extends StatefulWidget {
  const _CustomDurationDialog({required this.initialMinutes});

  final int initialMinutes;

  @override
  State<_CustomDurationDialog> createState() => _CustomDurationDialogState();
}

class _CustomDurationDialogState extends State<_CustomDurationDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: '${widget.initialMinutes}',
  );
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final value = int.tryParse(_controller.text.trim());
    if (value == null || value < 1 || value > _maxCustomMinutes) {
      setState(() => _error = l10n.durationRangeError);
      return;
    }
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.customDuration),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: l10n.minutesLabel,
          errorText: _error,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(l10n.setLabel)),
      ],
    );
  }
}
