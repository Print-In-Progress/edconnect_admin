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
      SortingSurvey? survey, dynamic notifierState) {
    if (survey == null) return [];

    return [
      if (survey.status == SortingSurveyStatus.draft) ...[
        BaseButton(
          label: 'Publish',
          prefixIcon: Icons.publish_outlined,
          variant: ButtonVariant.filled,
          isLoading: notifierState.isLoading,
          onPressed: () => publishSurvey(context, ref, survey.id),
        ),
        SizedBox(width: Foundations.spacing.md),
      ],
      if (survey.status == SortingSurveyStatus.published) ...[
        BaseButton(
          label: 'Close',
          prefixIcon: Icons.close,
          variant: ButtonVariant.outlined,
          isLoading: notifierState.isLoading,
          onPressed: () => closeSortingSurvey(context, ref, survey.id),
        ),
        SizedBox(width: Foundations.spacing.md),
      ],
      BaseButton(
        label: 'Delete',
        prefixIcon: Icons.delete_outline,
        backgroundColor: Foundations.colors.error,
        variant: ButtonVariant.filled,
        isLoading: notifierState.isLoading,
        onPressed: () => deleteSurvey(context, ref, survey.id),
      ),
    ];
  }

  static Future<void> publishSurvey(
      BuildContext context, WidgetRef ref, String id) async {
    await ref
        .read(sortingSurveyNotifierProvider.notifier)
        .publishSortingSurvey(id);

    if (context.mounted) {
      Toaster.success(context, 'Survey published successfully');
    }
  }

  static Future<void> closeSortingSurvey(
      BuildContext context, WidgetRef ref, String id) async {
    await ref
        .read(sortingSurveyNotifierProvider.notifier)
        .closeSortingSurvey(id);

    if (context.mounted) {
      Toaster.success(context, 'Survey closed successfully');
    }
  }

  static Future<void> deleteSurvey(
      BuildContext context, WidgetRef ref, String id) async {
    final bool? confirmed = await Dialogs.confirm(
        context: context,
        title: 'Delete Survey',
        message: 'Are you sure you want to delete this survey?',
        dangerous: true);

    if (confirmed != true) return;

    if (!context.mounted) return;
    Navigator.pop(context);

    await ref
        .read(sortingSurveyNotifierProvider.notifier)
        .deleteSortingSurvey(id);

    if (context.mounted) {
      Toaster.success(context, 'Survey deleted successfully');
    }
  }
}
