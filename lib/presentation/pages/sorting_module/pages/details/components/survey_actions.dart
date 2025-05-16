import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';

class SurveyActions {
  static List<Widget> buildActions(BuildContext context, WidgetRef ref,
      SortingSurvey? survey, dynamic notifierState, AppLocalizations l10n) {
    if (survey == null) return [];

    return [
      if (survey.status == SortingSurveyStatus.draft) ...[
        BaseButton(
          label: l10n.globalPublish,
          prefixIcon: Icons.publish_outlined,
          variant: ButtonVariant.filled,
          isLoading: notifierState.isLoading,
          onPressed: () => publishSurvey(context, ref, survey.id, l10n),
        ),
        SizedBox(width: Foundations.spacing.md),
      ],
      if (survey.status == SortingSurveyStatus.published) ...[
        BaseButton(
          label: l10n.globalClose,
          prefixIcon: Icons.close,
          variant: ButtonVariant.outlined,
          isLoading: notifierState.isLoading,
          onPressed: () => closeSortingSurvey(context, ref, survey.id, l10n),
        ),
        SizedBox(width: Foundations.spacing.md),
      ],
      BaseButton(
        label: l10n.globalDelete,
        prefixIcon: Icons.delete_outline,
        backgroundColor: Foundations.colors.error,
        variant: ButtonVariant.filled,
        isLoading: notifierState.isLoading,
        onPressed: () => deleteSurvey(context, ref, survey.id, l10n),
      ),
    ];
  }

  static Future<void> publishSurvey(BuildContext context, WidgetRef ref,
      String id, AppLocalizations l10n) async {
    await ref
        .read(sortingSurveyNotifierProvider.notifier)
        .publishSortingSurvey(id);

    if (context.mounted) {
      Toaster.success(context,
          l10n.successPublishedSuccessfullyWithName(l10n.sortingSurvey(1)));
    }
  }

  static Future<void> closeSortingSurvey(BuildContext context, WidgetRef ref,
      String id, AppLocalizations l10n) async {
    await ref
        .read(sortingSurveyNotifierProvider.notifier)
        .closeSortingSurvey(id);

    if (context.mounted) {
      Toaster.success(context,
          l10n.successClosedSuccessfullyWithName(l10n.sortingSurvey(1)));
    }
  }

  static Future<void> deleteSurvey(BuildContext context, WidgetRef ref,
      String id, AppLocalizations l10n) async {
    final bool? confirmed = await Dialogs.confirm(
        context: context,
        title: l10n.globalDeleteWithName(l10n.sortingSurvey(1)),
        message:
            l10n.globalDeleteConfirmationDialogWithName(l10n.sortingSurvey(1)),
        dangerous: true);

    if (confirmed != true) return;

    if (!context.mounted) return;
    Navigator.pop(context);

    await ref
        .read(sortingSurveyNotifierProvider.notifier)
        .deleteSortingSurvey(id);

    if (context.mounted) {
      Toaster.success(
          context, l10n.successDeletedWithName(l10n.sortingSurvey(1)));
    }
  }
}
