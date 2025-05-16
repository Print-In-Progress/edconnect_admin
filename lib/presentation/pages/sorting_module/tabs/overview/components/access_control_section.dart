import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/components/info_card.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/components/section_header.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/overview/components/multi_value_row.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/multi_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccessControlSection extends ConsumerWidget {
  final SortingSurvey survey;
  const AccessControlSection({super.key, required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifierState = ref.watch(sortingSurveyNotifierProvider);
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        SectionHeader(
            title: l10n.globalAccessControlLabel,
            icon: Icons.people_outline,
            actionButton: BaseButton(
              label: l10n.globalEdit,
              prefixIcon: Icons.edit,
              variant: ButtonVariant.outlined,
              size: ButtonSize.small,
              isLoading: notifierState.isLoading,
              onPressed: () =>
                  _showEditAccessDialog(context, ref, survey, l10n),
            )),
        SizedBox(height: Foundations.spacing.md),
        InfoCard(children: [
          MultiValueRow(
            ids: survey.editorGroups.isEmpty
                ? [l10n.globalNoGroupsSelected]
                : survey.editorGroups,
            label: l10n.globalEditorGroups,
            isUserIds: false,
          ),
          MultiValueRow(
            ids: survey.editorUsers.isEmpty
                ? [l10n.globalNoUsersSelected]
                : survey.editorUsers,
            label: l10n.globalEditorUsers,
            isUserIds: true,
          ),
          MultiValueRow(
            ids: survey.respondentsGroups.isEmpty
                ? [l10n.globalNoGroupsSelected]
                : survey.respondentsGroups,
            label: l10n.globalRespondentGroups,
            isUserIds: false,
          ),
          MultiValueRow(
            ids: survey.respondentsUsers.isEmpty
                ? [l10n.globalNoUsersSelected]
                : survey.respondentsUsers,
            label: l10n.globalRespondentUsers,
            isUserIds: true,
          ),
        ]),
      ],
    );
  }

  void _showEditAccessDialog(BuildContext context, WidgetRef ref,
      SortingSurvey survey, AppLocalizations l10n) {
    final groups = ref.watch(allGroupsStreamProvider).value ?? [];
    final users = ref.watch(allUsersStreamProvider).value ?? [];

    List<String> editorGroups = List.from(survey.editorGroups);
    List<String> editorUsers = List.from(survey.editorUsers);
    List<String> respondentGroups = List.from(survey.respondentsGroups);
    List<String> respondentUsers = List.from(survey.respondentsUsers);
    Dialogs.show(
        context: context,
        title: l10n.globalEditWithName(l10n.globalAccessControlLabel),
        content: StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BaseMultiSelect<String>(
                  label: l10n.globalEditorGroups,
                  searchable: true,
                  values: editorGroups,
                  options: groups
                      .map((group) => SelectOption(
                            value: group.id,
                            label: group.name,
                            icon: Icons.group_outlined,
                          ))
                      .toList(),
                  onChanged: (values) {
                    setState(() {
                      editorGroups = values;
                    });
                  },
                ),
                SizedBox(height: Foundations.spacing.md),
                BaseMultiSelect<String>(
                  label: l10n.globalEditorUsers,
                  searchable: true,
                  values: editorUsers,
                  options: users
                      .map((user) => SelectOption(
                            value: user.id,
                            label: user.fullName,
                            icon: Icons.person_outlined,
                          ))
                      .toList(),
                  onChanged: (values) {
                    setState(() {
                      editorUsers = values;
                    });
                  },
                ),
                SizedBox(height: Foundations.spacing.lg),
                BaseMultiSelect<String>(
                  label: l10n.globalRespondentGroups,
                  searchable: true,
                  values: respondentGroups,
                  options: groups
                      .map((group) => SelectOption(
                            value: group.id,
                            label: group.name,
                            icon: Icons.group_outlined,
                          ))
                      .toList(),
                  onChanged: (values) {
                    setState(() {
                      respondentGroups = values;
                    });
                  },
                ),
                SizedBox(height: Foundations.spacing.md),
                BaseMultiSelect<String>(
                  label: l10n.globalRespondentUsers,
                  searchable: true,
                  values: respondentUsers,
                  options: users
                      .map((user) => SelectOption(
                            value: user.id,
                            label: user.fullName,
                            icon: Icons.person_outlined,
                          ))
                      .toList(),
                  onChanged: (values) {
                    setState(() {
                      respondentUsers = values;
                    });
                  },
                ),
              ],
            ),
          );
        }),
        showCancelButton: true,
        actions: [
          BaseButton(
            label: l10n.globalSave,
            onPressed: () {
              final updatedSurvey = survey.copyWith(
                editorGroups: editorGroups,
                editorUsers: editorUsers,
                respondentsGroups: respondentGroups,
                respondentsUsers: respondentUsers,
              );

              ref
                  .read(sortingSurveyNotifierProvider.notifier)
                  .updateSortingSurvey(updatedSurvey);

              Navigator.of(context).pop();
            },
            variant: ButtonVariant.filled,
          )
        ]);
  }
}
