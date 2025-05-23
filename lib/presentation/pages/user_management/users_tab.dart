import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/core/providers/interface_providers.dart';
import 'package:edconnect_admin/core/routing/app_router.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/domain/entities/permissions.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/chips.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/multi_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userFilterQueryProvider = StateProvider<String>((ref) => '');

final userGroupFilterProvider = StateProvider<List<String>>((ref) => []);

final userPermissionFilterProvider = StateProvider<List<String>>((ref) => []);

final filteredUsersWithFiltersProvider =
    Provider<AsyncValue<List<AppUser>>>((ref) {
  final usersAsync = ref.watch(filteredUsersProvider);
  final selectedGroups = ref.watch(userGroupFilterProvider);
  final selectedPermissions = ref.watch(userPermissionFilterProvider);

  return usersAsync.when(
    data: (users) {
      if (selectedGroups.isEmpty && selectedPermissions.isEmpty) {
        return AsyncValue.data(users);
      }

      final filteredUsers = users.where((user) {
        bool matchesGroups = selectedGroups.isEmpty ||
            selectedGroups.any((groupId) => user.groupIds.contains(groupId));

        bool matchesPermissions = selectedPermissions.isEmpty ||
            selectedPermissions
                .any((permission) => user.hasPermission(permission));

        return matchesGroups && matchesPermissions;
      }).toList();

      return AsyncValue.data(filteredUsers);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

class UsersTab extends ConsumerStatefulWidget {
  const UsersTab({super.key});

  @override
  ConsumerState<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<UsersTab> {
  late TextEditingController _searchController;
  final usersTabScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentQuery = ref.read(userFilterQueryProvider);
      if (currentQuery.isNotEmpty) {
        _searchController.text = currentQuery;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final selectedGroups = ref.watch(userGroupFilterProvider);
    final selectedPermissions = ref.watch(userPermissionFilterProvider);
    final usersAsync = ref.watch(filteredUsersWithFiltersProvider);
    final groups = ref.watch(allGroupsStreamProvider).value ?? [];
    final l10n = AppLocalizations.of(context)!;
    final localizations = ref.watch(localizationRepositoryProvider);

    final permissions = Permissions.allPermissionIds;
    return LayoutBuilder(builder: (context, constraints) {
      final isWideScreen = constraints.maxWidth > 800;
      return CustomScrollView(
        controller: usersTabScrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: BaseCard(
              variant: CardVariant.outlined,
              padding: EdgeInsets.all(Foundations.spacing.lg),
              margin: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.globalFiltersLabel,
                    style: TextStyle(
                      fontSize: Foundations.typography.lg,
                      fontWeight: Foundations.typography.semibold,
                      color: isDarkMode
                          ? Foundations.darkColors.textPrimary
                          : Foundations.colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: Foundations.spacing.md),

                  // Filters row
                  if (isWideScreen) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search field
                        Expanded(
                          flex: 2,
                          child: BaseInput(
                            hint: l10n
                                .globalSearchWithName(l10n.globalUserLabel(0)),
                            leadingIcon: Icons.search,
                            controller: _searchController,
                            onChanged: (value) {
                              ref.read(userSearchQueryProvider.notifier).state =
                                  value;
                            },
                          ),
                        ),
                        SizedBox(width: Foundations.spacing.md),

                        // Group filter
                        Expanded(
                          flex: 1,
                          child: BaseMultiSelect<String>(
                            hint: l10n.globalFilterByGroup,
                            options: groups
                                .map((group) => SelectOption(
                                    value: group.id, label: group.name))
                                .toList(),
                            values: selectedGroups,
                            onChanged: (values) {
                              ref.read(userGroupFilterProvider.notifier).state =
                                  values;
                            },
                          ),
                        ),
                        SizedBox(width: Foundations.spacing.md),

                        // Permission filter
                        Expanded(
                          flex: 1,
                          child: BaseMultiSelect<String>(
                            hint: l10n.userManagementFilterbyPermissions,
                            options: permissions.map((permission) {
                              final permissionObj =
                                  Permissions.getById(permission);
                              final label = permissionObj
                                      ?.getDisplayName(localizations) ??
                                  permission;
                              return SelectOption(
                                  value: permission, label: label);
                            }).toList(),
                            values: selectedPermissions,
                            onChanged: (values) {
                              ref
                                  .read(userPermissionFilterProvider.notifier)
                                  .state = values;
                            },
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    // Stacked layout for smaller screens
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BaseInput(
                          hint: l10n
                              .globalSearchWithName(l10n.globalUserLabel(0)),
                          leadingIcon: Icons.search,
                          controller: _searchController,
                          onChanged: (value) {
                            ref.read(userSearchQueryProvider.notifier).state =
                                value;
                          },
                        ),
                        SizedBox(height: Foundations.spacing.md),
                        BaseMultiSelect<String>(
                          hint: l10n.globalFilterByGroup,
                          options: groups
                              .map((group) => SelectOption(
                                  value: group.id, label: group.name))
                              .toList(),
                          values: selectedGroups,
                          onChanged: (values) {
                            ref.read(userGroupFilterProvider.notifier).state =
                                values;
                          },
                        ),
                        SizedBox(height: Foundations.spacing.md),
                        BaseMultiSelect<String>(
                          hint: l10n.userManagementFilterbyPermissions,
                          options: permissions.map((permission) {
                            final permissionObj =
                                Permissions.getById(permission);
                            final label =
                                permissionObj?.getDisplayName(localizations) ??
                                    permission;
                            return SelectOption(
                                value: permission, label: label);
                          }).toList(),
                          values: selectedPermissions,
                          onChanged: (values) {
                            ref
                                .read(userPermissionFilterProvider.notifier)
                                .state = values;
                          },
                        ),
                      ],
                    ),
                  ],

                  // Applied filters indicator
                  if (selectedGroups.isNotEmpty ||
                      selectedPermissions.isNotEmpty) ...[
                    SizedBox(height: Foundations.spacing.md),
                    Wrap(
                      spacing: Foundations.spacing.sm,
                      runSpacing: Foundations.spacing.sm,
                      children: [
                        ...selectedGroups.map((groupId) {
                          final group = groups.firstWhere(
                            (g) => g.id == groupId,
                            orElse: () => Group(
                                id: groupId,
                                name: 'Unknown Group',
                                permissions: [],
                                memberIds: []),
                          );
                          return BaseChip(
                            label: 'Group: ${group.name}',
                            variant: ChipVariant.primary,
                            onDismissed: () {
                              ref.read(userGroupFilterProvider.notifier).state =
                                  selectedGroups
                                      .where((id) => id != groupId)
                                      .toList();
                            },
                          );
                        }),
                        ...selectedPermissions.map((permission) => BaseChip(
                              label:
                                  '${l10n.userManagementPermissionsLabel(1)}: $permission',
                              variant: ChipVariant.secondary,
                              onDismissed: () {
                                ref
                                        .read(userPermissionFilterProvider.notifier)
                                        .state =
                                    selectedPermissions
                                        .where((p) => p != permission)
                                        .toList();
                              },
                            )),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Users list
          SliverToBoxAdapter(child: SizedBox(height: Foundations.spacing.md)),
          usersAsync.when(
            data: (users) {
              if (users.isEmpty) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      l10n.globalNoResults,
                      style: TextStyle(
                        fontSize: Foundations.typography.base,
                        color: isDarkMode
                            ? Foundations.darkColors.textMuted
                            : Foundations.colors.textMuted,
                      ),
                    ),
                  ),
                );
              }

              return SliverToBoxAdapter(
                child: BaseCard(
                  variant: CardVariant.outlined,
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: Foundations.borders.md,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: users.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        thickness: 1,
                        color: isDarkMode
                            ? Foundations.darkColors.border
                            : Foundations.colors.border,
                      ),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return _buildUserListItem(
                            context, user, isDarkMode, l10n);
                      },
                    ),
                  ),
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator())),
            error: (error, stackTrace) => Center(
              child: SliverToBoxAdapter(
                child: Text(
                  l10n.errorUnexpectedWithError(error.toString()),
                  style: TextStyle(
                    color: Foundations.colors.error,
                    fontSize: Foundations.typography.base,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildUserListItem(
    BuildContext context,
    AppUser user,
    bool isDarkMode,
    AppLocalizations l10n,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => AppRouter.toUserDetails(
          context,
          user: user,
        ),
        hoverColor: isDarkMode
            ? Foundations.darkColors.surfaceHover
            : Foundations.colors.surfaceHover,
        splashColor: isDarkMode
            ? Foundations.darkColors.surfaceActive
            : Foundations.colors.surfaceActive,
        highlightColor: isDarkMode
            ? Foundations.darkColors.surfaceActive.withOpacity(0.3)
            : Foundations.colors.surfaceActive.withOpacity(0.3),
        child: Padding(
          padding: EdgeInsets.all(Foundations.spacing.md),
          child: Row(
            children: [
              // User avatar or initials
              CircleAvatar(
                backgroundColor: isDarkMode
                    ? Foundations.darkColors.backgroundMuted
                    : Foundations.colors.backgroundMuted,
                radius: 24,
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
              SizedBox(width: Foundations.spacing.md),

              // User details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName,
                      style: TextStyle(
                        fontSize: Foundations.typography.base,
                        fontWeight: Foundations.typography.medium,
                        color: isDarkMode
                            ? Foundations.darkColors.textPrimary
                            : Foundations.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Foundations.spacing.xs),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: Foundations.typography.sm,
                        color: isDarkMode
                            ? Foundations.darkColors.textMuted
                            : Foundations.colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Account type indicator
              if (user.accountType.isNotEmpty) ...[
                BaseChip(
                  label: switch (user.accountType) {
                    'faculty' =>
                      l10n.userManagementAccountTypeLabelFacultyAndStaff,
                    'parent' => l10n.userManagementAccountTypeLabelParent,
                    'student' => l10n.userManagementAccountTypeLabelStudent,
                    _ => 'User',
                  },
                  variant: ChipVariant.outlined,
                  size: ChipSize.small,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
