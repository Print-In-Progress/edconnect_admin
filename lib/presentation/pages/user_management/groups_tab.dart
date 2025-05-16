import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/routing/app_router.dart';
import 'package:edconnect_admin/domain/entities/group.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredGroupsProvider = Provider<AsyncValue<List<Group>>>((ref) {
  final groupsAsync = ref.watch(allGroupsStreamProvider);
  final searchQuery = ref.watch(groupSearchQueryProvider);

  return groupsAsync.when(
    data: (groups) {
      if (searchQuery.isEmpty) {
        return AsyncValue.data(groups);
      }

      final filteredGroups = groups
          .where((group) =>
              group.name.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();

      return AsyncValue.data(filteredGroups);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

class GroupsTab extends ConsumerStatefulWidget {
  const GroupsTab({super.key});

  @override
  ConsumerState<GroupsTab> createState() => _GroupsTabState();
}

class _GroupsTabState extends ConsumerState<GroupsTab> {
  late TextEditingController _searchController;
  final ScrollController groupsTabScrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentQuery = ref.read(groupSearchQueryProvider);
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
    final groupsAsync = ref.watch(filteredGroupsProvider);
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      controller: groupsTabScrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Row(
            children: [
              Expanded(
                child: BaseInput(
                  hint: l10n.globalSearchWithName(l10n.globalGroupLabel(1)),
                  leadingIcon: Icons.search,
                  controller: _searchController,
                  onChanged: (value) {
                    ref.read(groupSearchQueryProvider.notifier).state = value;
                  },
                ),
              ),
              SizedBox(width: Foundations.spacing.md),
              BaseButton(
                label: l10n.globalCreateButtonLabel(l10n.globalGroupLabel(1)),
                prefixIcon: Icons.add_circle_outline,
                variant: ButtonVariant.filled,
                onPressed: () => AppRouter.toCreateGroup(context),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: Foundations.spacing.lg)),
        SliverToBoxAdapter(
          child: groupsAsync.when(
            data: (groups) {
              if (groups.isEmpty) {
                return Center(
                  child: Text(
                    _searchController.text.isEmpty
                        ? l10n.userManagementNoGroupsCreatedYet
                        : l10n.globalNoResults,
                    style: TextStyle(
                      fontSize: Foundations.typography.base,
                      color: isDarkMode
                          ? Foundations.darkColors.textMuted
                          : Foundations.colors.textMuted,
                    ),
                  ),
                );
              }

              return BaseCard(
                margin: EdgeInsets.zero,
                variant: CardVariant.outlined,
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: Foundations.borders.md,
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: groups.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: isDarkMode
                          ? Foundations.darkColors.border
                          : Foundations.colors.border,
                    ),
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return _buildGroupListItem(
                        context: context,
                        group: group,
                        isDarkMode: isDarkMode,
                        l10n: l10n,
                      );
                    },
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Text(
                l10n.errorLoadingX(l10n.globalGroupLabel(0)),
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
  }

  Widget _buildGroupListItem({
    required BuildContext context,
    required Group group,
    required bool isDarkMode,
    required AppLocalizations l10n,
  }) {
    return Material(
      child: InkWell(
        onTap: () => AppRouter.toGroupDetails(context, group: group),
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
              // Group icon
              CircleAvatar(
                backgroundColor: isDarkMode
                    ? Foundations.darkColors.backgroundMuted
                    : Foundations.colors.backgroundMuted,
                radius: 24,
                child: Icon(
                  Icons.group,
                  color: isDarkMode
                      ? Foundations.darkColors.textMuted
                      : Foundations.colors.textMuted,
                ),
              ),
              SizedBox(width: Foundations.spacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: TextStyle(
                        fontSize: Foundations.typography.base,
                        fontWeight: Foundations.typography.medium,
                        color: isDarkMode
                            ? Foundations.darkColors.textPrimary
                            : Foundations.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Foundations.spacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 16,
                          color: isDarkMode
                              ? Foundations.darkColors.textMuted
                              : Foundations.colors.textMuted,
                        ),
                        SizedBox(width: Foundations.spacing.xs),
                        Text(
                          '${group.memberIds.length} ${l10n.userManagementMembersLabel}',
                          style: TextStyle(
                            fontSize: Foundations.typography.sm,
                            color: isDarkMode
                                ? Foundations.darkColors.textMuted
                                : Foundations.colors.textMuted,
                          ),
                        ),
                        SizedBox(width: Foundations.spacing.md),
                        Icon(
                          Icons.vpn_key_outlined,
                          size: 16,
                          color: isDarkMode
                              ? Foundations.darkColors.textMuted
                              : Foundations.colors.textMuted,
                        ),
                        SizedBox(width: Foundations.spacing.xs),
                        Text(
                          '${group.permissions.length} ${l10n.userManagementPermissionsLabel(group.permissions.length)}',
                          style: TextStyle(
                            fontSize: Foundations.typography.sm,
                            color: isDarkMode
                                ? Foundations.darkColors.textMuted
                                : Foundations.colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: Foundations.spacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
