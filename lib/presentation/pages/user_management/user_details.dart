import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/interfaces/localization_repository.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/core/providers/interface_providers.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/domain/entities/permissions.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/checkbox.dart';
import 'package:edconnect_admin/presentation/widgets/common/chips.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/multi_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupsEditingProvider = StateProvider.autoDispose<bool>((ref) => false);
final permissionsEditingProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final selectedGroupsProvider =
    StateProvider.autoDispose<List<String>>((ref) => []);

final selectedPermissionsProvider =
    StateProvider.autoDispose<List<String>>((ref) => []);

final permissionCategoriesProvider =
    Provider.autoDispose<Map<PermissionCategory, List<Permission>>>((ref) {
  final categories = <PermissionCategory, List<Permission>>{};

  for (final category in PermissionCategory.values) {
    categories[category] = Permissions.getByCategory(category);
  }

  return categories;
});

class UserDetails extends ConsumerStatefulWidget {
  final AppUser user;
  const UserDetails({super.key, required this.user});

  @override
  ConsumerState<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends ConsumerState<UserDetails> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedGroupsProvider.notifier).state =
          List.from(widget.user.groupIds);
      ref.read(selectedPermissionsProvider.notifier).state =
          List.from(widget.user.permissions);
    });
  }

  Future<void> _saveGroupChanges(AppLocalizations l10n) async {
    final selectedGroups = ref.read(selectedGroupsProvider);

    try {
      await ref.read(groupManagementProvider.notifier).updateUserGroups(
            widget.user.id,
            selectedGroups,
          );
      if (!mounted) return;
      Toaster.success(context, l10n.successProfileUpdated);

      ref.read(groupsEditingProvider.notifier).state = false;
    } catch (e) {
      Toaster.error(context, l10n.errorUserGroupUpdateFailed);
    }
  }

  Future<void> _savePermissionChanges(AppLocalizations l10n) async {
    final selectedPermissions = ref.read(selectedPermissionsProvider);

    try {
      await ref.read(userManagementProvider.notifier).updateUserPermissions(
            widget.user.id,
            selectedPermissions,
          );
      if (!mounted) return;
      Toaster.success(context,
          l10n.successXUpdated(l10n.userManagementPermissionsLabel(0)));
      ref.read(permissionsEditingProvider.notifier).state = false;
    } catch (e) {
      Toaster.error(context, l10n.errorUnexpectedWithError(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final allGroups = ref.watch(allGroupsStreamProvider).value ?? [];
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final LocalizationRepository localizations =
        ref.read(localizationRepositoryProvider);
    return Scaffold(
      backgroundColor: isDarkMode
          ? Foundations.darkColors.background
          : Foundations.colors.background,
      appBar: BaseAppBar(
        title: l10n.globalDetailsLabel,
        showLeading: true,
        actions: [
          BaseButton(
            label: l10n.globalDeleteWithName(l10n.globalUserLabel(1)),
            variant: ButtonVariant.filled,
            onPressed: () async {
              final bool? confirm = await Dialogs.confirm(
                context: context,
                title: l10n.globalConfirm,
                message: l10n.globalDeleteConfirmationDialogWithName(
                    l10n.globalUserLabel(1)),
                confirmText: l10n.globalDelete,
                dangerous: true,
              );
              if (confirm == true) {
                _deleteUser(l10n);
                if (!context.mounted) return;
                Navigator.pop(context);
                Toaster.success(context,
                    l10n.successDeletedWithName(l10n.globalUserLabel(1)));
              }
            },
            backgroundColor: Foundations.colors.error,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfoCard(isDarkMode, l10n),
            SizedBox(height: Foundations.spacing.lg),
            _buildSectionHeader(
                l10n.globalGroupLabel(0), ref.watch(groupsEditingProvider),
                onEditPressed: () =>
                    ref.read(groupsEditingProvider.notifier).state = true,
                onSavePressed: () => _saveGroupChanges(l10n),
                isDarkMode: isDarkMode,
                l10n: l10n),
            SizedBox(height: Foundations.spacing.md),
            _buildGroupsCard(allGroups, isDarkMode,
                ref.watch(groupsEditingProvider), l10n, localizations),
            SizedBox(height: Foundations.spacing.lg),
            _buildSectionHeader(l10n.userManagementPermissionsLabel(0),
                ref.watch(permissionsEditingProvider),
                onEditPressed: () =>
                    ref.read(permissionsEditingProvider.notifier).state = true,
                onSavePressed: () => _savePermissionChanges(l10n),
                isDarkMode: isDarkMode,
                l10n: l10n),
            SizedBox(height: Foundations.spacing.md),
            _buildPermissionsCard(isDarkMode,
                ref.watch(permissionsEditingProvider), l10n, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    bool isEditing, {
    required AppLocalizations l10n,
    required Function() onEditPressed,
    required Function() onSavePressed,
    required bool isDarkMode,
  }) {
    bool isLoading = (title == l10n.globalGroupLabel(0)
        ? ref.watch(groupManagementProvider).isLoading
        : ref.watch(userManagementProvider).isLoading);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: Foundations.typography.xl,
            fontWeight: Foundations.typography.semibold,
            color: isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary,
          ),
        ),
        if (isEditing)
          Row(
            children: [
              BaseButton(
                label: l10n.globalCancel,
                variant: ButtonVariant.outlined,
                size: ButtonSize.medium,
                prefixIcon: Icons.close,
                onPressed: () {
                  if (title == l10n.globalGroupLabel(0)) {
                    ref.read(selectedGroupsProvider.notifier).state =
                        List.from(widget.user.groupIds);
                    ref.read(groupsEditingProvider.notifier).state = false;
                  } else if (title == l10n.userManagementPermissionsLabel(0)) {
                    ref.read(selectedPermissionsProvider.notifier).state =
                        List.from(widget.user.permissions);
                    ref.read(permissionsEditingProvider.notifier).state = false;
                  }
                },
              ),
              SizedBox(width: Foundations.spacing.sm),
              BaseButton(
                label: l10n.globalSave,
                variant: ButtonVariant.filled,
                size: ButtonSize.medium,
                isLoading: isLoading,
                onPressed: onSavePressed,
              ),
            ],
          )
        else
          BaseButton(
            label: l10n.globalEditWithName(title),
            variant: ButtonVariant.outlined,
            size: ButtonSize.medium,
            isLoading: isLoading,
            prefixIcon: Icons.edit_outlined,
            onPressed: onEditPressed,
          ),
      ],
    );
  }

  Widget _buildUserInfoCard(bool isDarkMode, AppLocalizations l10n) {
    return BaseCard(
      variant: CardVariant.elevated,
      padding: EdgeInsets.all(Foundations.spacing.lg),
      margin: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: isDarkMode
                ? Foundations.darkColors.backgroundMuted
                : Foundations.colors.backgroundMuted,
            child: Text(
              widget.user.initials,
              style: TextStyle(
                fontSize: Foundations.typography.xl,
                fontWeight: Foundations.typography.semibold,
                color: isDarkMode
                    ? Foundations.darkColors.textPrimary
                    : Foundations.colors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: Foundations.spacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.user.fullName,
                  style: TextStyle(
                    fontSize: Foundations.typography.xl,
                    fontWeight: Foundations.typography.semibold,
                    color: isDarkMode
                        ? Foundations.darkColors.textPrimary
                        : Foundations.colors.textPrimary,
                  ),
                ),
                SizedBox(height: Foundations.spacing.xs),
                Text(
                  widget.user.email,
                  style: TextStyle(
                    fontSize: Foundations.typography.base,
                    color: isDarkMode
                        ? Foundations.darkColors.textMuted
                        : Foundations.colors.textMuted,
                  ),
                ),
                SizedBox(height: Foundations.spacing.sm),
                if (widget.user.accountType.isNotEmpty) ...[
                  BaseChip(
                    label: switch (widget.user.accountType) {
                      'faculty' =>
                        l10n.userManagementAccountTypeLabelFacultyAndStaff,
                      'parent' => l10n.userManagementAccountTypeLabelParent,
                      'student' => l10n.userManagementAccountTypeLabelStudent,
                      _ => 'User',
                    },
                    variant: ChipVariant.outlined,
                    size: ChipSize.medium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupsCard(
      List<Group> allGroups,
      bool isDarkMode,
      bool isEditing,
      AppLocalizations l10n,
      LocalizationRepository localizations) {
    final selectedGroups = ref.watch(selectedGroupsProvider);

    return BaseCard(
      variant: CardVariant.outlined,
      padding: EdgeInsets.all(Foundations.spacing.lg),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing) ...[
            BaseMultiSelect<String>(
              label: l10n.userManagementAssignGroupsLabel,
              hint: l10n.userManagementSelectGroupsToAssign,
              searchable: true,
              options: allGroups
                  .map((group) => SelectOption(
                        value: group.id,
                        label: group.name,
                        icon: Icons.group_outlined,
                      ))
                  .toList(),
              values: selectedGroups,
              onChanged: (values) {
                ref.read(selectedGroupsProvider.notifier).state = values;
              },
            ),
            SizedBox(height: Foundations.spacing.md),
            const Divider(),
            SizedBox(height: Foundations.spacing.md),
          ],
          if (selectedGroups.isEmpty)
            Text(
              l10n.userManagementNoGroupsAssignedToUser,
              style: TextStyle(
                fontSize: Foundations.typography.base,
                color: isDarkMode
                    ? Foundations.darkColors.textMuted
                    : Foundations.colors.textMuted,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: Foundations.spacing.sm,
                  runSpacing: Foundations.spacing.sm,
                  children: selectedGroups.map((groupId) {
                    final group = allGroups.firstWhere(
                      (g) => g.id == groupId,
                      orElse: () => Group(
                        id: groupId,
                        name: 'Unknown Group',
                        permissions: [],
                        memberIds: [],
                      ),
                    );

                    return BaseChip(
                      label: group.name,
                      variant: ChipVariant.primary,
                      size: ChipSize.medium,
                      onDismissed: isEditing
                          ? () {
                              final updatedGroups =
                                  List<String>.from(selectedGroups)
                                    ..remove(groupId);
                              ref.read(selectedGroupsProvider.notifier).state =
                                  updatedGroups;
                            }
                          : null,
                    );
                  }).toList(),
                ),
                if (!isEditing) ...[
                  SizedBox(height: Foundations.spacing.md),
                  ...selectedGroups.map((groupId) {
                    final group = allGroups.firstWhere(
                      (g) => g.id == groupId,
                      orElse: () => Group(
                        id: groupId,
                        name: 'Unknown Group',
                        permissions: [],
                        memberIds: [],
                      ),
                    );

                    return _buildGroupDetailItem(
                      group,
                      isDarkMode,
                      l10n,
                      localizations,
                    );
                  }),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGroupDetailItem(Group group, bool isDarkMode,
      AppLocalizations l10n, LocalizationRepository localizations) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        expandedAlignment: Alignment.centerLeft,
        title: Text(
          group.name,
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: Foundations.typography.medium,
            color: isDarkMode
                ? Foundations.darkColors.textPrimary
                : Foundations.colors.textPrimary,
          ),
        ),
        subtitle: Text(
          '${group.memberIds.length} ${l10n.userManagementMembersLabel} • ${group.permissions.length} ${l10n.userManagementPermissionsLabel(group.permissions.length)}',
          style: TextStyle(
            fontSize: Foundations.typography.sm,
            color: isDarkMode
                ? Foundations.darkColors.textMuted
                : Foundations.colors.textMuted,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: Foundations.spacing.lg,
              right: Foundations.spacing.lg,
              bottom: Foundations.spacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${l10n.userManagementPermissionsLabel(0)}:',
                  style: TextStyle(
                    fontSize: Foundations.typography.sm,
                    fontWeight: Foundations.typography.semibold,
                    color: isDarkMode
                        ? Foundations.darkColors.textSecondary
                        : Foundations.colors.textSecondary,
                  ),
                ),
                SizedBox(height: Foundations.spacing.xs),
                Wrap(
                  spacing: Foundations.spacing.xs,
                  runSpacing: Foundations.spacing.xs,
                  children: group.permissions.map((permissionId) {
                    final permission = Permissions.getById(permissionId);
                    final label = permission?.getDisplayName(localizations) ??
                        permissionId;

                    return Tooltip(
                      message: permission?.getDescription(localizations) ??
                          '${l10n.userManagementPermissionsLabel(1)}: $permissionId',
                      child: BaseChip(
                        label: label,
                        variant: ChipVariant.outlined,
                        size: ChipSize.small,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsCard(bool isDarkMode, bool isEditing,
      AppLocalizations l10n, LocalizationRepository localizations) {
    final selectedPermissions = ref.watch(selectedPermissionsProvider);
    final permissionCategories = ref.watch(permissionCategoriesProvider);

    return BaseCard(
      variant: CardVariant.outlined,
      padding: EdgeInsets.all(Foundations.spacing.lg),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing) ...[
            for (final category in PermissionCategory.values) ...[
              if (permissionCategories[category]!.isNotEmpty) ...[
                _buildPermissionCategorySection(
                    category,
                    permissionCategories[category]!,
                    selectedPermissions,
                    isDarkMode,
                    localizations,
                    l10n),
                SizedBox(height: Foundations.spacing.md),
              ],
            ],
            const Divider(),
            SizedBox(height: Foundations.spacing.md),
          ],
          Text(
            l10n.userManagementAssignedPermissions,
            style: TextStyle(
              fontSize: Foundations.typography.base,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textSecondary
                  : Foundations.colors.textSecondary,
            ),
          ),
          SizedBox(height: Foundations.spacing.sm),
          if (selectedPermissions.isEmpty)
            Text(
              l10n.userManagementNoDirectPermissionsAssigned,
              style: TextStyle(
                fontSize: Foundations.typography.base,
                color: isDarkMode
                    ? Foundations.darkColors.textMuted
                    : Foundations.colors.textMuted,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: Foundations.spacing.sm,
                  runSpacing: Foundations.spacing.sm,
                  children: selectedPermissions.map((permissionId) {
                    final permission = Permissions.getById(permissionId);
                    final label = permission?.getDisplayName(localizations) ??
                        permissionId;

                    return BaseChip(
                      label: label,
                      variant: ChipVariant.secondary,
                      size: ChipSize.medium,
                      onDismissed: isEditing
                          ? () {
                              final updatedPermissions =
                                  List<String>.from(selectedPermissions)
                                    ..remove(permissionId);
                              ref
                                  .read(selectedPermissionsProvider.notifier)
                                  .state = updatedPermissions;
                            }
                          : null,
                    );
                  }).toList(),
                ),
                if (!isEditing) ...[
                  SizedBox(height: Foundations.spacing.md),
                  ...selectedPermissions.map((permissionId) {
                    final permission = Permissions.getById(permissionId);
                    if (permission != null) {
                      return Padding(
                        padding:
                            EdgeInsets.only(bottom: Foundations.spacing.sm),
                        child: ListTile(
                          title: Text(
                            permission.getDisplayName(localizations),
                            style: TextStyle(
                              fontSize: Foundations.typography.base,
                              fontWeight: Foundations.typography.medium,
                              color: isDarkMode
                                  ? Foundations.darkColors.textPrimary
                                  : Foundations.colors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            permission.getDescription(localizations),
                            style: TextStyle(
                              fontSize: Foundations.typography.sm,
                              color: isDarkMode
                                  ? Foundations.darkColors.textMuted
                                  : Foundations.colors.textMuted,
                            ),
                          ),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ],
            ),
          SizedBox(height: Foundations.spacing.lg),
          Text(
            l10n.userManagementPermissionsFromGroups,
            style: TextStyle(
              fontSize: Foundations.typography.base,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textSecondary
                  : Foundations.colors.textSecondary,
            ),
          ),
          SizedBox(height: Foundations.spacing.sm),
          _buildGroupPermissions(isDarkMode, l10n, localizations),
        ],
      ),
    );
  }

  Widget _buildPermissionCategorySection(
    PermissionCategory category,
    List<Permission> permissions,
    List<String> selectedPermissions,
    bool isDarkMode,
    LocalizationRepository localizations,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getCategoryDisplayName(category, l10n),
          style: TextStyle(
            fontSize: Foundations.typography.base,
            fontWeight: Foundations.typography.semibold,
            color: isDarkMode
                ? Foundations.darkColors.textSecondary
                : Foundations.colors.textSecondary,
          ),
        ),
        SizedBox(height: Foundations.spacing.sm),
        ...permissions.map((permission) {
          final isSelected = selectedPermissions.contains(permission.id);
          return BaseCheckbox(
            label: permission.getDisplayName(localizations),
            description: permission.getDescription(localizations),
            value: isSelected,
            onChanged: (value) {
              final updatedPermissions = List<String>.from(selectedPermissions);
              if (value == true) {
                if (!updatedPermissions.contains(permission.id)) {
                  updatedPermissions.add(permission.id);
                }
              } else {
                updatedPermissions.remove(permission.id);
              }
              ref.read(selectedPermissionsProvider.notifier).state =
                  updatedPermissions;
            },
          );
        }),
      ],
    );
  }

  Widget _buildGroupPermissions(bool isDarkMode, AppLocalizations l10n,
      LocalizationRepository localizations) {
    final selectedGroups = ref.watch(selectedGroupsProvider);
    final allGroups = ref.watch(allGroupsStreamProvider).value ?? [];
    final directPermissions = ref.watch(selectedPermissionsProvider);

    final groupPermissionsMap = <String, Set<String>>{};
    for (final groupId in selectedGroups) {
      final group = allGroups.firstWhere(
        (g) => g.id == groupId,
        orElse: () =>
            Group(id: groupId, name: 'Unknown', permissions: [], memberIds: []),
      );

      for (final permissionId in group.permissions) {
        if (!directPermissions.contains(permissionId)) {
          if (!groupPermissionsMap.containsKey(permissionId)) {
            groupPermissionsMap[permissionId] = {};
          }
          groupPermissionsMap[permissionId]!.add(group.name);
        }
      }
    }

    if (groupPermissionsMap.isEmpty) {
      return Text(
        l10n.userManagementNoPermissionsFromGroups,
        style: TextStyle(
          fontSize: Foundations.typography.base,
          color: isDarkMode
              ? Foundations.darkColors.textMuted
              : Foundations.colors.textMuted,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: Foundations.spacing.sm,
          runSpacing: Foundations.spacing.sm,
          children: groupPermissionsMap.keys.map((permissionId) {
            final permission = Permissions.getById(permissionId);
            final label =
                permission?.getDisplayName(localizations) ?? permissionId;
            final sourceGroups = groupPermissionsMap[permissionId]!.join(', ');

            return Tooltip(
              message: l10n.globalFromX(sourceGroups),
              child: BaseChip(
                label: label,
                variant: ChipVariant.outlined,
                size: ChipSize.small,
              ),
            );
          }).toList(),
        ),
        SizedBox(height: Foundations.spacing.md),
        ...groupPermissionsMap.entries.map((entry) {
          final permissionId = entry.key;
          final permission = Permissions.getById(permissionId);
          final sourceGroups = entry.value.join(', ');

          if (permission != null) {
            return Padding(
              padding: EdgeInsets.only(bottom: Foundations.spacing.sm),
              child: ListTile(
                title: Text(
                  permission.getDisplayName(localizations),
                  style: TextStyle(
                    fontSize: Foundations.typography.base,
                    fontWeight: Foundations.typography.medium,
                    color: isDarkMode
                        ? Foundations.darkColors.textPrimary
                        : Foundations.colors.textPrimary,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      permission.getDescription(localizations),
                      style: TextStyle(
                        fontSize: Foundations.typography.sm,
                        color: isDarkMode
                            ? Foundations.darkColors.textMuted
                            : Foundations.colors.textMuted,
                      ),
                    ),
                    SizedBox(height: Foundations.spacing.xs),
                    Text(
                      l10n.globalFromX(
                          '${l10n.globalGroupLabel(0)}: $sourceGroups'),
                      style: TextStyle(
                        fontSize: Foundations.typography.sm,
                        fontStyle: FontStyle.italic,
                        color: isDarkMode
                            ? Foundations.darkColors.textMuted
                            : Foundations.colors.textMuted,
                      ),
                    ),
                  ],
                ),
                dense: true,
                contentPadding: EdgeInsets.zero,
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  String _getCategoryDisplayName(
      PermissionCategory category, AppLocalizations l10n) {
    switch (category) {
      case PermissionCategory.role:
        return l10n.userManagementRolesLabel;
      case PermissionCategory.content:
        return l10n.userManagementContentManagementLabel;
      case PermissionCategory.user:
        return l10n.userManagementUserManagementLabel;
      case PermissionCategory.media:
        return l10n.userManagementMediaLabel;
      case PermissionCategory.notification:
        return l10n.userManagementNotificationsLabel;
      case PermissionCategory.settings:
        return l10n.navSettings;
      case PermissionCategory.survey:
        return l10n.navSurveys;
    }
  }

  void _deleteUser(AppLocalizations l10n) async {
    try {
      await ref
          .read(userManagementProvider.notifier)
          .deleteUser(widget.user.id);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      Toaster.error(context, l10n.errorUnexpectedWithError(e.toString()));
    }
  }
}
