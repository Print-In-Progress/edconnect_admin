import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/permissions.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_icon_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/checkbox.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/multi_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State providers for create group page
final createGroupNameProvider = StateProvider.autoDispose<String>((ref) => '');
final createGroupMembersProvider =
    StateProvider.autoDispose<List<String>>((ref) => []);
final createGroupPermissionsProvider =
    StateProvider.autoDispose<List<String>>((ref) => []);

// Provider to get permission categories - same as in details page
final createPermissionCategoriesProvider =
    Provider.autoDispose<Map<PermissionCategory, List<Permission>>>((ref) {
  final categories = <PermissionCategory, List<Permission>>{};

  for (final category in PermissionCategory.values) {
    categories[category] = Permissions.getByCategory(category);
  }

  return categories;
});

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({super.key});

  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupState();
}

class _CreateGroupState extends ConsumerState<CreateGroupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // Create the group
  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final groupName = ref.read(createGroupNameProvider);
    final selectedMembers = ref.read(createGroupMembersProvider);
    final selectedPermissions = ref.read(createGroupPermissionsProvider);

    // Validate group name
    if (groupName.trim().isEmpty) {
      Toaster.error(context, 'Group name cannot be empty');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      Toaster.info(context, 'Creating group...');

      // Create group ID
      ref.read(groupManagementProvider.notifier).createGroup(
            groupName,
            selectedPermissions,
            selectedMembers,
          );
      if (!context.mounted) return;

      Toaster.success(context, 'Group created successfully');
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      Toaster.error(context, 'Error creating group: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final allUsers = ref.watch(allUsersStreamProvider).value ?? [];

    return Scaffold(
      backgroundColor: isDarkMode
          ? Foundations.darkColors.background
          : Foundations.colors.background,
      appBar: BaseAppBar(
        title: 'Create Group',
        showLeading: true,
        actions: [
          BaseButton(
            label: 'Create Group',
            variant: ButtonVariant.filled,
            size: ButtonSize.large,
            isLoading: _isSubmitting,
            prefixIcon: Icons.add_circle_outline,
            onPressed: _createGroup,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group information card
              BaseCard(
                variant: CardVariant.elevated,
                padding: EdgeInsets.all(Foundations.spacing.lg),
                margin: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Group Information',
                      style: TextStyle(
                        fontSize: Foundations.typography.lg,
                        fontWeight: Foundations.typography.semibold,
                        color: isDarkMode
                            ? Foundations.darkColors.textPrimary
                            : Foundations.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Foundations.spacing.md),
                    BaseInput(
                      label: 'Group Name',
                      hint: 'Enter group name',
                      isRequired: true,
                      controller: _nameController,
                      onChanged: (value) {
                        ref.read(createGroupNameProvider.notifier).state =
                            value;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: Foundations.spacing.lg),

              // Members section
              Text(
                'Members',
                style: TextStyle(
                  fontSize: Foundations.typography.xl,
                  fontWeight: Foundations.typography.semibold,
                  color: isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
              ),
              SizedBox(height: Foundations.spacing.md),
              _buildMembersCard(allUsers, isDarkMode),
              SizedBox(height: Foundations.spacing.lg),

              // Permissions section
              Text(
                'Permissions',
                style: TextStyle(
                  fontSize: Foundations.typography.xl,
                  fontWeight: Foundations.typography.semibold,
                  color: isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
              ),
              SizedBox(height: Foundations.spacing.md),
              _buildPermissionsCard(isDarkMode),
              SizedBox(height: Foundations.spacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersCard(List<AppUser> allUsers, bool isDarkMode) {
    final selectedMembers = ref.watch(createGroupMembersProvider);

    return BaseCard(
      variant: CardVariant.outlined,
      padding: EdgeInsets.all(Foundations.spacing.lg),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseMultiSelect<String>(
            label: 'Assign Members',
            hint: 'Select users to add to this group',
            searchable: true,
            size: SelectSize.large,
            options: allUsers
                .map((user) => SelectOption(
                      value: user.id,
                      label: user.fullName,
                      description: user.email,
                      icon: Icons.person_outline,
                    ))
                .toList(),
            values: selectedMembers,
            onChanged: (values) {
              ref.read(createGroupMembersProvider.notifier).state = values;
            },
          ),
          if (selectedMembers.isNotEmpty) ...[
            SizedBox(height: Foundations.spacing.md),
            Text(
              'Selected Members (${selectedMembers.length})',
              style: TextStyle(
                fontSize: Foundations.typography.base,
                fontWeight: Foundations.typography.semibold,
                color: isDarkMode
                    ? Foundations.darkColors.textSecondary
                    : Foundations.colors.textSecondary,
              ),
            ),
            SizedBox(height: Foundations.spacing.sm),

            // Show a preview of selected users
            Container(
              constraints: BoxConstraints(
                maxHeight: 200,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: selectedMembers.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  thickness: 1,
                  color: isDarkMode
                      ? Foundations.darkColors.border
                      : Foundations.colors.border,
                ),
                itemBuilder: (context, index) {
                  final userId = selectedMembers[index];
                  final user = allUsers.firstWhere(
                    (u) => u.id == userId,
                    orElse: () => AppUser(
                      id: userId,
                      firstName: 'Unknown',
                      lastName: 'User',
                      email: '',
                      fcmTokens: [],
                      groupIds: [],
                      permissions: [],
                      deviceIds: {},
                      accountType: '',
                    ),
                  );

                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: Foundations.spacing.xs,
                      horizontal: Foundations.spacing.md,
                    ),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: isDarkMode
                          ? Foundations.darkColors.backgroundMuted
                          : Foundations.colors.backgroundMuted,
                      child: Text(
                        user.initials,
                        style: TextStyle(
                          fontSize: Foundations.typography.sm,
                          fontWeight: Foundations.typography.semibold,
                          color: isDarkMode
                              ? Foundations.darkColors.textPrimary
                              : Foundations.colors.textPrimary,
                        ),
                      ),
                    ),
                    title: Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: Foundations.typography.sm,
                        fontWeight: Foundations.typography.medium,
                        color: isDarkMode
                            ? Foundations.darkColors.textPrimary
                            : Foundations.colors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      user.email.isEmpty ? 'Unknown Email' : user.email,
                      style: TextStyle(
                        fontSize: Foundations.typography.xs,
                        color: isDarkMode
                            ? Foundations.darkColors.textMuted
                            : Foundations.colors.textMuted,
                      ),
                    ),
                    trailing: BaseIconButton(
                      icon: Icons.remove_circle_outline,
                      color: Foundations.colors.error,
                      onPressed: () {
                        final updatedMembers =
                            List<String>.from(selectedMembers)..remove(userId);
                        ref.read(createGroupMembersProvider.notifier).state =
                            updatedMembers;
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPermissionsCard(bool isDarkMode) {
    final selectedPermissions = ref.watch(createGroupPermissionsProvider);
    final permissionCategories = ref.watch(createPermissionCategoriesProvider);

    return BaseCard(
      variant: CardVariant.outlined,
      padding: EdgeInsets.all(Foundations.spacing.lg),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Permissions',
            style: TextStyle(
              fontSize: Foundations.typography.base,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textPrimary
                  : Foundations.colors.textPrimary,
            ),
          ),
          SizedBox(height: Foundations.spacing.md),

          // Show permissions by category without expansion panels
          for (final category in PermissionCategory.values) ...[
            if (permissionCategories[category]!.isNotEmpty) ...[
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
              ...permissionCategories[category]!.map((permission) {
                final isSelected = selectedPermissions.contains(permission.id);
                return BaseCheckbox(
                  label: permission.displayName,
                  description: permission.description,
                  value: isSelected,
                  onChanged: (value) {
                    final updatedPermissions =
                        List<String>.from(selectedPermissions);
                    if (value == true) {
                      if (!updatedPermissions.contains(permission.id)) {
                        updatedPermissions.add(permission.id);
                      }
                    } else {
                      updatedPermissions.remove(permission.id);
                    }
                    ref.read(createGroupPermissionsProvider.notifier).state =
                        updatedPermissions;
                  },
                );
              }),
              SizedBox(height: Foundations.spacing.md),
            ],
          ],

          // Selected permissions summary
          if (selectedPermissions.isNotEmpty) ...[
            SizedBox(height: Foundations.spacing.md),
            Text(
              'Selected Permissions (${selectedPermissions.length})',
              style: TextStyle(
                fontSize: Foundations.typography.base,
                fontWeight: Foundations.typography.semibold,
                color: isDarkMode
                    ? Foundations.darkColors.textSecondary
                    : Foundations.colors.textSecondary,
              ),
            ),
            SizedBox(height: Foundations.spacing.sm),
            Wrap(
              spacing: Foundations.spacing.sm,
              runSpacing: Foundations.spacing.sm,
              children: selectedPermissions.map((permissionId) {
                final permission = Permissions.getById(permissionId);
                final label = permission?.displayName ?? permissionId;

                return Chip(
                  label: Text(label),
                  backgroundColor: isDarkMode
                      ? Foundations.darkColors.textMuted
                      : Foundations.colors.textMuted,
                  deleteIcon: Icon(
                    Icons.close,
                    size: 18,
                  ),
                  onDeleted: () {
                    final updatedPermissions =
                        List<String>.from(selectedPermissions)
                          ..remove(permissionId);
                    ref.read(createGroupPermissionsProvider.notifier).state =
                        updatedPermissions;
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
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
}
