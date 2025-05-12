import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/domain/entities/permissions.dart';
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

// Separate editing state providers for groups and permissions
final groupsEditingProvider = StateProvider.autoDispose<bool>((ref) => false);
final permissionsEditingProvider =
    StateProvider.autoDispose<bool>((ref) => false);

// Provider to track current group selections
final selectedGroupsProvider =
    StateProvider.autoDispose<List<String>>((ref) => []);

// Provider to track current permission selections
final selectedPermissionsProvider =
    StateProvider.autoDispose<List<String>>((ref) => []);

// Provider to get permission categories
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

    // Initialize the state with the user's current groups and permissions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedGroupsProvider.notifier).state =
          List.from(widget.user.groupIds);
      ref.read(selectedPermissionsProvider.notifier).state =
          List.from(widget.user.permissions);
    });
  }

  // Save group changes
  Future<void> _saveGroupChanges() async {
    final selectedGroups = ref.read(selectedGroupsProvider);

    try {
      Toaster.info(context, 'Saving group changes...');

      await ref.read(groupManagementProvider.notifier).updateUserGroups(
            widget.user.id,
            selectedGroups,
          );
      Toaster.success(context, 'User groups updated successfully');

      ref.read(groupsEditingProvider.notifier).state = false;
    } catch (e) {
      Toaster.error(context, 'Error saving group changes: ${e.toString()}');
    }
  }

  // Save permission changes
  Future<void> _savePermissionChanges() async {
    final selectedPermissions = ref.read(selectedPermissionsProvider);

    try {
      Toaster.info(context, 'Saving permission changes...');
      await ref.read(userManagementProvider.notifier).updateUserPermissions(
            widget.user.id,
            selectedPermissions,
          );
      Toaster.success(context, 'User permissions updated successfully');
      ref.read(permissionsEditingProvider.notifier).state = false;
    } catch (e) {
      Toaster.error(
          context, 'Error saving permission changes: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final allGroups = ref.watch(allGroupsStreamProvider).value ?? [];

    return Scaffold(
      backgroundColor: isDarkMode
          ? Foundations.darkColors.background
          : Foundations.colors.background,
      appBar: BaseAppBar(
        title: 'User Details',
        showLeading: true,
        actions: [
          BaseButton(
            label: 'Delete User',
            variant: ButtonVariant.filled,
            onPressed: () async {
              final bool? confirm = await Dialogs.confirm(
                context: context,
                title: 'Confirm User Deletion',
                message:
                    'Are you sure you want to delete this user? This action cannot be undone.',
                confirmText: 'Delete',
                dangerous: true,
              );
              if (confirm == true) {
                _deleteUser();
                if (!context.mounted) return;
                Navigator.pop(context);
                Toaster.success(context, 'User deleted successfully');
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
            // User info card
            _buildUserInfoCard(isDarkMode),
            SizedBox(height: Foundations.spacing.lg),

            // Groups section with its own edit button
            _buildSectionHeader('Groups', ref.watch(groupsEditingProvider),
                onEditPressed: () =>
                    ref.read(groupsEditingProvider.notifier).state = true,
                onSavePressed: _saveGroupChanges,
                isDarkMode: isDarkMode),
            SizedBox(height: Foundations.spacing.md),
            _buildGroupsCard(
                allGroups, isDarkMode, ref.watch(groupsEditingProvider)),
            SizedBox(height: Foundations.spacing.lg),

            // Permissions section with its own edit button
            _buildSectionHeader(
                'Permissions', ref.watch(permissionsEditingProvider),
                onEditPressed: () =>
                    ref.read(permissionsEditingProvider.notifier).state = true,
                onSavePressed: _savePermissionChanges,
                isDarkMode: isDarkMode),
            SizedBox(height: Foundations.spacing.md),
            _buildPermissionsCard(
                isDarkMode, ref.watch(permissionsEditingProvider)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    bool isEditing, {
    required Function() onEditPressed,
    required Function() onSavePressed,
    required bool isDarkMode,
  }) {
    bool isLoading = (title == 'Groups'
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
                label: 'Cancel',
                variant: ButtonVariant.outlined,
                size: ButtonSize.medium,
                prefixIcon: Icons.close,
                onPressed: () {
                  if (title == 'Groups') {
                    ref.read(selectedGroupsProvider.notifier).state =
                        List.from(widget.user.groupIds);
                    ref.read(groupsEditingProvider.notifier).state = false;
                  } else if (title == 'Permissions') {
                    ref.read(selectedPermissionsProvider.notifier).state =
                        List.from(widget.user.permissions);
                    ref.read(permissionsEditingProvider.notifier).state = false;
                  }
                },
              ),
              SizedBox(width: Foundations.spacing.sm),
              BaseButton(
                label: 'Save Changes',
                variant: ButtonVariant.filled,
                size: ButtonSize.medium,
                isLoading: isLoading,
                onPressed: onSavePressed,
              ),
            ],
          )
        else
          BaseButton(
            label: 'Edit $title',
            variant: ButtonVariant.outlined,
            size: ButtonSize.medium,
            isLoading: isLoading,
            prefixIcon: Icons.edit_outlined,
            onPressed: onEditPressed,
          ),
      ],
    );
  }

  Widget _buildUserInfoCard(bool isDarkMode) {
    return BaseCard(
      variant: CardVariant.elevated,
      padding: EdgeInsets.all(Foundations.spacing.lg),
      margin: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
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

          // User details
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
                      'faculty' => 'Faculty & Staff',
                      'parent' => 'Parent',
                      'student' => 'Student',
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
      List<Group> allGroups, bool isDarkMode, bool isEditing) {
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
              label: 'Assign Groups',
              hint: 'Select groups to assign to this user',
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
            Divider(),
            SizedBox(height: Foundations.spacing.md),
          ],

          // Group list
          if (selectedGroups.isEmpty)
            Text(
              'No groups assigned',
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
                // Show group chips
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

                // Group information with collapsible details
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

                    return _buildGroupDetailItem(group, isDarkMode);
                  }),
                ],
              ],
            ),
        ],
      ),
    );
  }

  // New widget to show collapsible group details
  Widget _buildGroupDetailItem(Group group, bool isDarkMode) {
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
          '${group.memberIds.length} members • ${group.permissions.length} permissions',
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
                  'Permissions in this group:',
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
                    final label = permission?.displayName ?? permissionId;

                    return Tooltip(
                      message: permission?.description ??
                          'Permission: $permissionId',
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

  Widget _buildPermissionsCard(bool isDarkMode, bool isEditing) {
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
                    isDarkMode),
                SizedBox(height: Foundations.spacing.md),
              ],
            ],
            const Divider(),
            SizedBox(height: Foundations.spacing.md),
          ],

          Text(
            'Assigned Permissions',
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
              'No direct permissions assigned',
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
                    final label = permission?.displayName ?? permissionId;

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
                            permission.displayName,
                            style: TextStyle(
                              fontSize: Foundations.typography.base,
                              fontWeight: Foundations.typography.medium,
                              color: isDarkMode
                                  ? Foundations.darkColors.textPrimary
                                  : Foundations.colors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            permission.description,
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

          // Permissions from Groups section
          Text(
            'Permissions from Groups',
            style: TextStyle(
              fontSize: Foundations.typography.base,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textSecondary
                  : Foundations.colors.textSecondary,
            ),
          ),
          SizedBox(height: Foundations.spacing.sm),
          _buildGroupPermissions(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildPermissionCategorySection(
    PermissionCategory category,
    List<Permission> permissions,
    List<String> selectedPermissions,
    bool isDarkMode,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getCategoryDisplayName(category),
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
            label: permission.displayName,
            description: permission.description,
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

  Widget _buildGroupPermissions(bool isDarkMode) {
    final selectedGroups = ref.watch(selectedGroupsProvider);
    final allGroups = ref.watch(allGroupsStreamProvider).value ?? [];
    final directPermissions = ref.watch(selectedPermissionsProvider);

    // Get all permissions from the selected groups
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
        'No additional permissions from groups',
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
            final label = permission?.displayName ?? permissionId;
            final sourceGroups = groupPermissionsMap[permissionId]!.join(', ');

            return Tooltip(
              message: 'From: $sourceGroups',
              child: BaseChip(
                label: label,
                variant: ChipVariant.outlined,
                size: ChipSize.small,
              ),
            );
          }).toList(),
        ),

        // List of permissions with their descriptions and source groups
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
                  permission.displayName,
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
                      permission.description,
                      style: TextStyle(
                        fontSize: Foundations.typography.sm,
                        color: isDarkMode
                            ? Foundations.darkColors.textMuted
                            : Foundations.colors.textMuted,
                      ),
                    ),
                    SizedBox(height: Foundations.spacing.xs),
                    Text(
                      'From group(s): $sourceGroups',
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
          return SizedBox.shrink();
        }),
      ],
    );
  }

  String _getCategoryDisplayName(PermissionCategory category) {
    switch (category) {
      case PermissionCategory.role:
        return 'Roles';
      case PermissionCategory.content:
        return 'Content Management';
      case PermissionCategory.user:
        return 'User Management';
      case PermissionCategory.media:
        return 'Media';
      case PermissionCategory.notification:
        return 'Notifications';
      case PermissionCategory.settings:
        return 'Settings';
      case PermissionCategory.survey:
        return 'Surveys';
    }
  }

  void _deleteUser() async {
    try {
      await ref
          .read(userManagementProvider.notifier)
          .deleteUser(widget.user.id);
      Navigator.pop(context); // Go back to user list
    } catch (e) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: ${e.toString()}')),
      );
    }
  }
}
