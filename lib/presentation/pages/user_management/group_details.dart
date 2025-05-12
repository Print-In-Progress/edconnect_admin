import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/domain/entities/permissions.dart';
import 'package:edconnect_admin/presentation/pages/user_management/user_details.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_icon_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/checkbox.dart';
import 'package:edconnect_admin/presentation/widgets/common/chips.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/multi_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for group name editing
final groupNameEditingProvider =
    StateProvider.autoDispose<bool>((ref) => false);
final groupNameProvider = StateProvider.autoDispose<String>((ref) => '');

// Provider for members editing
final membersEditingProvider = StateProvider.autoDispose<bool>((ref) => false);
final selectedMembersProvider =
    StateProvider.autoDispose<List<String>>((ref) => []);

// Provider for permissions editing
final groupPermissionsEditingProvider =
    StateProvider.autoDispose<bool>((ref) => false);
final selectedGroupPermissionsProvider =
    StateProvider.autoDispose<List<String>>((ref) => []);

class GroupDetailsPage extends ConsumerStatefulWidget {
  final Group group;
  const GroupDetailsPage({super.key, required this.group});

  @override
  ConsumerState<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends ConsumerState<GroupDetailsPage> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group.name);

    // Initialize state providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupNameProvider.notifier).state = widget.group.name;
      ref.read(selectedMembersProvider.notifier).state =
          List.from(widget.group.memberIds);
      ref.read(selectedGroupPermissionsProvider.notifier).state =
          List.from(widget.group.permissions);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveGroupName() async {
    final newName = ref.read(groupNameProvider);
    if (newName.trim().isEmpty) {
      Toaster.error(context, 'Group name cannot be empty');
      return;
    }

    try {
      Toaster.info(context, 'Saving group name...');

      final updatedGroup = widget.group.copyWith(name: newName);
      await ref
          .read(groupManagementProvider.notifier)
          .updateGroup(updatedGroup);

      Toaster.success(context, 'Group name updated successfully');
      ref.read(groupNameEditingProvider.notifier).state = false;
    } catch (e) {
      Toaster.error(context, 'Error saving group name: ${e.toString()}');
    }
  }

  Future<void> _saveGroupPermissions() async {
    final selectedPermissions = ref.read(selectedGroupPermissionsProvider);

    try {
      Toaster.info(context, 'Saving group permissions...');

      final updatedGroup =
          widget.group.copyWith(permissions: selectedPermissions);
      await ref
          .read(groupManagementProvider.notifier)
          .updateGroup(updatedGroup);

      Toaster.success(context, 'Group permissions updated successfully');
      ref.read(groupPermissionsEditingProvider.notifier).state = false;
    } catch (e) {
      Toaster.error(context, 'Error saving permissions: ${e.toString()}');
    }
  }

  Future<void> _saveGroupMembers() async {
    final selectedMembers = ref.read(selectedMembersProvider);

    try {
      Toaster.info(context, 'Saving group members...');

      final updatedGroup = widget.group.copyWith(memberIds: selectedMembers);
      await ref
          .read(groupManagementProvider.notifier)
          .updateGroup(updatedGroup);

      Toaster.success(context, 'Group members updated successfully');
      ref.read(membersEditingProvider.notifier).state = false;
    } catch (e) {
      Toaster.error(context, 'Error saving group members: ${e.toString()}');
    }
  }

  Future<void> _deleteGroup() async {
    try {
      await ref
          .read(groupManagementProvider.notifier)
          .deleteGroup(widget.group.id);
      Navigator.pop(context);
    } catch (e) {
      Toaster.error(context, 'Error deleting group: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final allUsers = ref.watch(allUsersStreamProvider).value ?? [];

    final isNameEditing = ref.watch(groupNameEditingProvider);
    final isMembersEditing = ref.watch(membersEditingProvider);
    final isPermissionsEditing = ref.watch(groupPermissionsEditingProvider);

    return Scaffold(
      backgroundColor: isDarkMode
          ? Foundations.darkColors.background
          : Foundations.colors.background,
      appBar: BaseAppBar(
        title: 'Group Details',
        showLeading: true,
        actions: [
          BaseButton(
            label: 'Delete Group',
            variant: ButtonVariant.filled,
            backgroundColor: Foundations.colors.error,
            onPressed: () async {
              final confirm = await Dialogs.confirm(
                context: context,
                title: 'Confirm Group Deletion',
                message:
                    'Are you sure you want to delete this group? This action cannot be undone.',
                confirmText: 'Delete',
                dangerous: true,
              );

              if (confirm == true) {
                await _deleteGroup();
                if (!context.mounted) return;
                Navigator.pop(context);
                Toaster.success(context, 'Group deleted successfully');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group name card
            _buildGroupNameCard(isDarkMode, isNameEditing),
            SizedBox(height: Foundations.spacing.lg),

            // Permissions section
            _buildSectionHeader(
              'Permissions',
              isPermissionsEditing,
              onEditPressed: () => ref
                  .read(groupPermissionsEditingProvider.notifier)
                  .state = true,
              onSavePressed: _saveGroupPermissions,
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: Foundations.spacing.md),
            _buildPermissionsCard(isDarkMode, isPermissionsEditing),
            SizedBox(height: Foundations.spacing.lg),

            // Members section
            _buildSectionHeader(
              'Members',
              isMembersEditing,
              onEditPressed: () =>
                  ref.read(membersEditingProvider.notifier).state = true,
              onSavePressed: _saveGroupMembers,
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: Foundations.spacing.md),
            _buildMembersCard(allUsers, isDarkMode, isMembersEditing),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupNameCard(bool isDarkMode, bool isEditing) {
    final groupName = ref.watch(groupNameProvider);
    final isLoading = ref.watch(groupManagementProvider).isLoading;

    return BaseCard(
      variant: CardVariant.elevated,
      padding: EdgeInsets.all(Foundations.spacing.lg),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Group Name',
                style: TextStyle(
                  fontSize: Foundations.typography.lg,
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
                        ref.read(groupNameProvider.notifier).state =
                            widget.group.name;
                        ref.read(groupNameEditingProvider.notifier).state =
                            false;
                      },
                    ),
                    SizedBox(width: Foundations.spacing.sm),
                    BaseButton(
                      label: 'Save',
                      variant: ButtonVariant.filled,
                      size: ButtonSize.medium,
                      isLoading: isLoading,
                      onPressed: _saveGroupName,
                    ),
                  ],
                )
              else
                BaseButton(
                  label: 'Edit Name',
                  variant: ButtonVariant.outlined,
                  size: ButtonSize.medium,
                  prefixIcon: Icons.edit_outlined,
                  onPressed: () =>
                      ref.read(groupNameEditingProvider.notifier).state = true,
                ),
            ],
          ),
          SizedBox(height: Foundations.spacing.md),
          if (isEditing)
            BaseInput(
              label: 'Group Name',
              initialValue: groupName,
              onChanged: (value) =>
                  ref.read(groupNameProvider.notifier).state = value,
            )
          else
            Text(
              groupName,
              style: TextStyle(
                fontSize: Foundations.typography.xl,
                fontWeight: Foundations.typography.semibold,
                color: isDarkMode
                    ? Foundations.darkColors.textPrimary
                    : Foundations.colors.textPrimary,
              ),
            ),
          SizedBox(height: Foundations.spacing.sm),
          Text(
            'ID: ${widget.group.id}',
            style: TextStyle(
              fontSize: Foundations.typography.sm,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
          ),
        ],
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
    final isLoading = ref.watch(groupManagementProvider).isLoading;

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
                  if (title == 'Permissions') {
                    ref.read(selectedGroupPermissionsProvider.notifier).state =
                        List.from(widget.group.permissions);
                    ref.read(groupPermissionsEditingProvider.notifier).state =
                        false;
                  } else if (title == 'Members') {
                    ref.read(selectedMembersProvider.notifier).state =
                        List.from(widget.group.memberIds);
                    ref.read(membersEditingProvider.notifier).state = false;
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
            prefixIcon: Icons.edit_outlined,
            onPressed: onEditPressed,
          ),
      ],
    );
  }

  Widget _buildPermissionsCard(bool isDarkMode, bool isEditing) {
    final selectedPermissions = ref.watch(selectedGroupPermissionsProvider);
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
                ),
                SizedBox(height: Foundations.spacing.md),
              ],
            ],
            const Divider(),
            SizedBox(height: Foundations.spacing.md),
          ],
          Text(
            'Group Permissions',
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
              'No permissions assigned to this group',
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
                                  .read(
                                      selectedGroupPermissionsProvider.notifier)
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
              ref.read(selectedGroupPermissionsProvider.notifier).state =
                  updatedPermissions;
            },
          );
        }),
      ],
    );
  }

  Widget _buildMembersCard(
      List<AppUser> allUsers, bool isDarkMode, bool isEditing) {
    final selectedMembers = ref.watch(selectedMembersProvider);

    // Convert IDs to user objects
    final members = selectedMembers
        .map((id) => allUsers.firstWhere(
              (user) => user.id == id,
              orElse: () => AppUser(
                id: id,
                firstName: 'Unknown',
                lastName: 'User',
                email: '',
                fcmTokens: [],
                groupIds: [],
                permissions: [],
                deviceIds: {},
                accountType: '',
              ),
            ))
        .toList();

    return BaseCard(
      variant: CardVariant.outlined,
      padding: EdgeInsets.all(Foundations.spacing.lg),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEditing) ...[
            BaseMultiSelect<String>(
              label: 'Assign Members',
              hint: 'Select users to add to this group',
              searchable: true,
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
                ref.read(selectedMembersProvider.notifier).state = values;
              },
            ),
            SizedBox(height: Foundations.spacing.md),
            Divider(),
            SizedBox(height: Foundations.spacing.md),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members (${members.length})',
                style: TextStyle(
                  fontSize: Foundations.typography.base,
                  fontWeight: Foundations.typography.semibold,
                  color: isDarkMode
                      ? Foundations.darkColors.textSecondary
                      : Foundations.colors.textSecondary,
                ),
              ),
              if (!isEditing && members.isNotEmpty)
                Text(
                  'Tap to view details',
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
          SizedBox(height: Foundations.spacing.sm),
          if (members.isEmpty)
            Text(
              'No members in this group',
              style: TextStyle(
                fontSize: Foundations.typography.base,
                color: isDarkMode
                    ? Foundations.darkColors.textMuted
                    : Foundations.colors.textMuted,
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: members.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                thickness: 1,
                color: isDarkMode
                    ? Foundations.darkColors.border
                    : Foundations.colors.border,
              ),
              itemBuilder: (context, index) {
                final user = members[index];
                return _buildMemberListItem(
                    context, user, isDarkMode, isEditing);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMemberListItem(
    BuildContext context,
    AppUser user,
    bool isDarkMode,
    bool isEditing,
  ) {
    final selectedMembers = ref.watch(selectedMembersProvider);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        vertical: Foundations.spacing.sm,
        horizontal: Foundations.spacing.md,
      ),
      leading: CircleAvatar(
        backgroundColor: isDarkMode
            ? Foundations.darkColors.backgroundMuted
            : Foundations.colors.backgroundMuted,
        radius: 20,
        child: Text(
          user.initials,
          style: TextStyle(
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
          fontSize: Foundations.typography.base,
          fontWeight: Foundations.typography.medium,
          color: isDarkMode
              ? Foundations.darkColors.textPrimary
              : Foundations.colors.textPrimary,
        ),
      ),
      subtitle: Text(
        user.email.isEmpty ? 'Unknown Email' : user.email,
        style: TextStyle(
          fontSize: Foundations.typography.sm,
          color: isDarkMode
              ? Foundations.darkColors.textMuted
              : Foundations.colors.textMuted,
        ),
      ),
      trailing: isEditing
          ? BaseIconButton(
              icon: Icons.remove_circle_outline,
              onPressed: () {
                final updatedMembers = List<String>.from(selectedMembers)
                  ..remove(user.id);
                ref.read(selectedMembersProvider.notifier).state =
                    updatedMembers;
              },
              color: Foundations.colors.error,
            )
          : null,
      onTap: isEditing
          ? null
          : () {
              // Navigate to user details
              Navigator.of(context).pushNamed(
                '/user-details',
                arguments: user,
              );
            },
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
