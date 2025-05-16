import 'package:edconnect_admin/core/models/app_theme.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/multi_select_dropdown.dart';

class AccessControlCard extends ConsumerWidget {
  final List<String> selectedEditorGroups;
  final List<String> selectedRespondentGroups;
  final List<String> selectedEditorUsers;
  final List<String> selectedRespondentUsers;
  final Function(List<String>) onEditorGroupsChanged;
  final Function(List<String>) onRespondentGroupsChanged;
  final Function(List<String>) onEditorUsersChanged;
  final Function(List<String>) onRespondentUsersChanged;

  const AccessControlCard({
    required this.selectedEditorGroups,
    required this.selectedRespondentGroups,
    required this.selectedEditorUsers,
    required this.selectedRespondentUsers,
    required this.onEditorGroupsChanged,
    required this.onRespondentGroupsChanged,
    required this.onEditorUsersChanged,
    required this.onRespondentUsersChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final groups = ref.watch(allGroupsStreamProvider).value ?? [];
    final users = ref.watch(allUsersStreamProvider).value ?? [];
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 800;
    final l10n = AppLocalizations.of(context)!;

    return BaseCard(
      variant: CardVariant.elevated,
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.globalAccessControlLabel,
              style: TextStyle(
                fontSize: Foundations.typography.lg,
                fontWeight: Foundations.typography.semibold,
                color: theme.isDarkMode
                    ? Foundations.darkColors.textPrimary
                    : Foundations.colors.textPrimary,
              ),
            ),
            SizedBox(height: Foundations.spacing.lg),
            if (isWideScreen)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildEditorsSection(groups, users, theme, l10n),
                  ),
                  SizedBox(width: Foundations.spacing.lg),
                  Expanded(
                    child: _buildRespondentsSection(groups, users, theme, l10n),
                  ),
                ],
              )
            else
              Column(
                children: [
                  _buildEditorsSection(groups, users, theme, l10n),
                  SizedBox(height: Foundations.spacing.lg),
                  _buildRespondentsSection(groups, users, theme, l10n),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorsSection(List<Group> groups, List<AppUser> users,
      AppTheme theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.globalEditorsLabel,
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: Foundations.typography.semibold,
            color: theme.isDarkMode
                ? Foundations.darkColors.textSecondary
                : Foundations.colors.textSecondary,
          ),
        ),
        Text(
          l10n.sortingModuleAccessControlDescription,
          style: TextStyle(
            fontSize: Foundations.typography.sm,
            color: theme.isDarkMode
                ? Foundations.darkColors.textMuted
                : Foundations.colors.textMuted,
          ),
        ),
        SizedBox(height: Foundations.spacing.md),
        BaseMultiSelect<String>(
          label: l10n.globalSelectGroups,
          searchable: true,
          values: selectedEditorGroups,
          options: _buildGroupOptions(groups),
          onChanged: onEditorGroupsChanged,
        ),
        SizedBox(height: Foundations.spacing.md),
        BaseMultiSelect<String>(
          label: l10n.globalSelectUsers,
          values: selectedEditorUsers,
          searchable: true,
          options: _buildUserOptions(users),
          onChanged: onEditorUsersChanged,
        ),
      ],
    );
  }

  Widget _buildRespondentsSection(List<Group> groups, List<AppUser> users,
      AppTheme theme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.sortingModuleRespondents,
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: Foundations.typography.semibold,
            color: theme.isDarkMode
                ? Foundations.darkColors.textSecondary
                : Foundations.colors.textSecondary,
          ),
        ),
        Text(
          l10n.sortingModuleRespondentsDescription,
          style: TextStyle(
            fontSize: Foundations.typography.sm,
            color: theme.isDarkMode
                ? Foundations.darkColors.textMuted
                : Foundations.colors.textMuted,
          ),
        ),
        SizedBox(height: Foundations.spacing.md),
        BaseMultiSelect<String>(
          label: l10n.globalSelectGroups,
          searchable: true,
          values: selectedRespondentGroups,
          options: _buildGroupOptions(groups),
          onChanged: onRespondentGroupsChanged,
        ),
        SizedBox(height: Foundations.spacing.md),
        BaseMultiSelect<String>(
          label: l10n.globalSelectUsers,
          values: selectedRespondentUsers,
          searchable: true,
          options: _buildUserOptions(users),
          onChanged: onRespondentUsersChanged,
        ),
      ],
    );
  }

  List<SelectOption<String>> _buildGroupOptions(List<Group> groups) {
    return groups
        .map((group) => SelectOption(
              value: group.id,
              label: group.name,
              icon: Icons.group_outlined,
            ))
        .toList();
  }

  List<SelectOption<String>> _buildUserOptions(List<AppUser> users) {
    return users
        .map((user) => SelectOption(
              value: user.id,
              label: user.fullName,
              icon: Icons.person_outline,
            ))
        .toList();
  }
}
