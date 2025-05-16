import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SurveyEmptyState extends ConsumerWidget {
  const SurveyEmptyState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.ballot_outlined,
            size: 64,
            color: Foundations.colors.textMuted,
          ),
          SizedBox(height: Foundations.spacing.md),
          Text(
            l10n.globalNoXFound(l10n.sortingSurvey(0)),
            style: TextStyle(
              fontSize: Foundations.typography.lg,
              color: Foundations.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
