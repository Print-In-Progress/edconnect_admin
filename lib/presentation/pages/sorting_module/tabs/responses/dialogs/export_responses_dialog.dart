import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class ExportResponsesDialog extends StatelessWidget {
  const ExportResponsesDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.globalFeatureNotImplementedYet,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
