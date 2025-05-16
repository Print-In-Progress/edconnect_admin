import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/interfaces/localization_repository.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/core/providers/interface_providers.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/domain/entities/permissions.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
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

  Future<void> _saveGroupName(AppLocalizations l10n) async {
    final newName = ref.read(groupNameProvider);
    if (newName.trim().isEmpty) {
      Toaster.error(context, 'Group name cannot be empty');
      return;
    }

    try {
      final updatedGroup = widget.group.copyWith(name: newName);
      await ref
          .read(groupManagementProvider.notifier)
          .updateGroup(updatedGroup);
      if (!mounted) return;
      Toaster.success(context, l10n.successXUpdated(l10n.globalGroupLabel(1)));
      ref.read(groupNameEditingProvider.notifier).state = false;
    } catch (e) {
      Toaster.error(context, l10n.errorUnexpectedWithError(e.toString()));
    }
  }

  Future<void> _saveGroupPermissions(AppLocalizations l10n) async {
    final selectedPermissions = ref.read(selectedGroupPermissionsProvider);

    try {
      if (!mounted) return;
      final updatedGroup =
          widget.group.copyWith(permissions: selectedPermissions);
      await ref
          .read(groupManagementProvider.notifier)
          .updateGroup(updatedGroup);
      if (!mounted) return;
      Toaster.success(context,
          l10n.successXUpdated(l10n.userManagementPermissionsLabel(0)));
      ref.read(groupPermissionsEditingProvider.notifier).state = false;
    } catch (e) {
      Toaster.error(context, l10n.errorUnexpectedWithError(e.toString()));
    }
  }

  Future<void> _saveGroupMembers(AppLocalizations l10n) async {
    final selectedMembers = ref.read(selectedMembersProvider);

    try {
      final updatedGroup = widget.group.copyWith(memberIds: selectedMembers);
      await ref
          .read(groupManagementProvider.notifier)
          .updateGroup(updatedGroup);
      if (!mounted) return;
      Toaster.success(
          context, l10n.successXUpdated(l10n.userManagementMembersLabel));
      ref.read(membersEditingProvider.notifier).state = false;
    } catch (e) {
      Toaster.error(context, l10n.errorUnexpectedWithError(e.toString()));
    }
  }

  Future<void> _deleteGroup(AppLocalizations l10n) async {
    try {
      await ref
          .read(groupManagementProvider.notifier)
          .deleteGroup(widget.group.id);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      Toaster.error(context, l10n.errorUnexpectedWithError(e.toString()));
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
    final localizations = ref.watch(localizationRepositoryProvider);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: isDarkMode
          ? Foundations.darkColors.background
          : Foundations.colors.background,
      appBar: BaseAppBar(
        title: l10n.globalDetailsLabel,
        showLeading: true,
        actions: [
          BaseButton(
            label: l10n.globalDeleteWithName(l10n.globalGroupLabel(1)),
            variant: ButtonVariant.filled,
            backgroundColor: Foundations.colors.error,
            onPressed: () async {
              final confirm = await Dialogs.confirm(
                context: context,
                title: l10n.globalConfirm,
                message: l10n.globalDeleteConfirmationDialogWithName(
                    l10n.globalGroupLabel(1)),
                confirmText: l10n.globalDelete,
                dangerous: true,
              );

              if (confirm == true) {
                await _deleteGroup(l10n);
                if (!context.mounted) return;
                Navigator.pop(context);
                Toaster.success(context,
                    l10n.successDeletedWithName(l10n.globalGroupLabel(1)));
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
            _buildGroupNameCard(isDarkMode, isNameEditing, l10n),
            SizedBox(height: Foundations.spacing.lg),
            _buildSectionHeader(
              l10n.userManagementPermissionsLabel(0),
              isPermissionsEditing,
              onEditPressed: () => ref
                  .read(groupPermissionsEditingProvider.notifier)
                  .state = true,
              onSavePressed: () => _saveGroupPermissions(l10n),
              isDarkMode: isDarkMode,
              l10n,
            ),
            SizedBox(height: Foundations.spacing.md),
            _buildPermissionsCard(
                isDarkMode, isPermissionsEditing, localizations, l10n),
            SizedBox(height: Foundations.spacing.lg),
            _buildSectionHeader(
              l10n.userManagementMembersLabel,
              isMembersEditing,
              onEditPressed: () =>
                  ref.read(membersEditingProvider.notifier).state = true,
              onSavePressed: () => _saveGroupMembers(l10n),
              isDarkMode: isDarkMode,
              l10n,
            ),
            SizedBox(height: Foundations.spacing.md),
            _buildMembersCard(allUsers, isDarkMode, isMembersEditing, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupNameCard(
      bool isDarkMode, bool isEditing, AppLocalizations l10n) {
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
                l10n.globalGroupName,
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
                      label: l10n.globalCancel,
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
                      label: l10n.globalSave,
                      variant: ButtonVariant.filled,
                      size: ButtonSize.medium,
                      isLoading: isLoading,
                      onPressed: () => _saveGroupName(l10n),
                    ),
                  ],
                )
              else
                BaseButton(
                  label: l10n.globalEditWithName(l10n.globalGroupLabel(1)),
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
              label: l10n.globalGroupName,
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
    bool isEditing,
    AppLocalizations l10n, {
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
                label: l10n.globalCancel,
                variant: ButtonVariant.outlined,
                size: ButtonSize.medium,
                prefixIcon: Icons.close,
                onPressed: () {
                  if (title == l10n.userManagementPermissionsLabel(0)) {
                    ref.read(selectedGroupPermissionsProvider.notifier).state =
                        List.from(widget.group.permissions);
                    ref.read(groupPermissionsEditingProvider.notifier).state =
                        false;
                  } else if (title == l10n.userManagementMembersLabel) {
                    ref.read(selectedMembersProvider.notifier).state =
                        List.from(widget.group.memberIds);
                    ref.read(membersEditingProvider.notifier).state = false;
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
            prefixIcon: Icons.edit_outlined,
            onPressed: onEditPressed,
          ),
      ],
    );
  }

  Widget _buildPermissionsCard(bool isDarkMode, bool isEditing,
      LocalizationRepository localizations, AppLocalizations l10n) {
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
                  localizations,
                  l10n,
                ),
                SizedBox(height: Foundations.spacing.md),
              ],
            ],
            const Divider(),
            SizedBox(height: Foundations.spacing.md),
          ],
          Text(
            l10n.userManagementPermissionsLabel(0),
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
              l10n.userManagementNoPermissiosnAssignedToGroup,
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
              ref.read(selectedGroupPermissionsProvider.notifier).state =
                  updatedPermissions;
            },
          );
        }),
      ],
    );
  }

  Widget _buildMembersCard(List<AppUser> allUsers, bool isDarkMode,
      bool isEditing, AppLocalizations l10n) {
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
              label: l10n.userManagementAssignMembersLabel,
              hint: l10n.userManagementSelectUsersToAddToGroup,
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
            const Divider(),
            SizedBox(height: Foundations.spacing.md),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.userManagementMembersLabel} (${members.length})',
                style: TextStyle(
                  fontSize: Foundations.typography.base,
                  fontWeight: Foundations.typography.semibold,
                  color: isDarkMode
                      ? Foundations.darkColors.textSecondary
                      : Foundations.colors.textSecondary,
                ),
              ),
              // if (!isEditing && members.isNotEmpty)
              // Text(
              // 'Tap to view details',
              // style: TextStyle(
              // fontSize: Foundations.typography.sm,
              // fontStyle: FontStyle.italic,
              // color: isDarkMode
              // ? Foundations.darkColors.textMuted
              // : Foundations.colors.textMuted,
              // ),
              // ),
            ],
          ),
          SizedBox(height: Foundations.spacing.sm),
          if (members.isEmpty)
            Text(
              l10n.userManagementNoMembersInGroup,
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
              physics: const NeverScrollableScrollPhysics(),
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
              Navigator.of(context).pushNamed(
                '/user-details',
                arguments: user,
              );
            },
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
        return l10n.userManagementSurveysLabel;
    }
  }
}
