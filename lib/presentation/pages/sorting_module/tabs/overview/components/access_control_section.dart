import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
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
    return Column(
      children: [
        SectionHeader(
            title: 'Access Control',
            icon: Icons.people_outline,
            actionButton: BaseButton(
              label: 'Edit Access',
              prefixIcon: Icons.edit,
              variant: ButtonVariant.outlined,
              size: ButtonSize.small,
              isLoading: notifierState.isLoading,
              onPressed: () => _showEditAccessDialog(context, ref, survey),
            )),
        SizedBox(height: Foundations.spacing.md),
        InfoCard(children: [
          MultiValueRow(
            ids: survey.editorGroups.isEmpty
                ? ['No editor groups']
                : survey.editorGroups,
            label: 'Editor Groups',
            isUserIds: false,
          ),
          MultiValueRow(
            ids: survey.editorUsers.isEmpty
                ? ['No editor users']
                : survey.editorUsers,
            label: 'Editor Users',
            isUserIds: true,
          ),
          MultiValueRow(
            ids: survey.respondentsGroups.isEmpty
                ? ['No respondent groups']
                : survey.respondentsGroups,
            label: 'Respondent Groups',
            isUserIds: false,
          ),
          MultiValueRow(
            ids: survey.respondentsUsers.isEmpty
                ? ['No respondent users']
                : survey.respondentsUsers,
            label: 'Respondent Users',
            isUserIds: true,
          ),
        ]),
      ],
    );
  }

  void _showEditAccessDialog(
      BuildContext context, WidgetRef ref, SortingSurvey survey) {
    final groups = ref.watch(allGroupsStreamProvider).value ?? [];
    final users = ref.watch(allUsersStreamProvider).value ?? [];

    List<String> editorGroups = List.from(survey.editorGroups);
    List<String> editorUsers = List.from(survey.editorUsers);
    List<String> respondentGroups = List.from(survey.respondentsGroups);
    List<String> respondentUsers = List.from(survey.respondentsUsers);
    Dialogs.show(
        context: context,
        title: 'Edit Access Control',
        content: StatefulBuilder(builder: (context, setState) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Editor Groups
                BaseMultiSelect<String>(
                  label: 'Editor Groups',
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

                // Editor Users
                BaseMultiSelect<String>(
                  label: 'Editor Users',
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

                // Respondent Groups
                BaseMultiSelect<String>(
                  label: 'Respondent Groups',
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

                // Respondent Users
                BaseMultiSelect<String>(
                  label: 'Respondent Users',
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
            label: 'Save',
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
