import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_icon_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'dart:math';

class Pagination extends ConsumerWidget {
  final String paginationKey;
  final bool isDarkMode;
  final List<int> itemsPerPageOptions;
  final void Function(int itemsPerPage)? onItemsPerPageChanged;

  const Pagination({
    super.key,
    required this.paginationKey,
    required this.isDarkMode,
    this.itemsPerPageOptions = const [10, 25, 50, 100],
    this.onItemsPerPageChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paginationStateProvider(paginationKey));
    final theme = ref.watch(appThemeProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 768; // Breakpoint for small screens

    List<int> getVisiblePages() {
      const maxVisible = 5;
      final totalPages = state.totalPages;
      final current = state.currentPage;

      if (totalPages <= maxVisible) {
        return List.generate(totalPages, (i) => i);
      }

      var pages = <int>[];
      if (current <= 2) {
        pages.addAll(List.generate(3, (i) => i));
        pages.add(-1); // Ellipsis
        pages.add(totalPages - 1);
      } else if (current >= totalPages - 3) {
        pages.add(0);
        pages.add(-1); // Ellipsis
        pages.addAll(List.generate(3, (i) => totalPages - 3 + i));
      } else {
        pages.add(0);
        pages.add(-1); // Ellipsis
        pages.addAll(List.generate(3, (i) => current - 1 + i));
        pages.add(-1); // Ellipsis
        pages.add(totalPages - 1);
      }
      return pages;
    }

    Widget buildItemsPerPageSelector() {
      return Wrap(
        alignment: isSmallScreen ? WrapAlignment.center : WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Showing ${state.currentPage * state.itemsPerPage + 1} to ${min((state.currentPage + 1) * state.itemsPerPage, state.totalItems)} of ${state.totalItems} entries',
            style: TextStyle(
              fontSize: Foundations.typography.sm,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
          ),
          SizedBox(width: Foundations.spacing.lg),
          SizedBox(
            width: 80,
            child: BaseSelect<int>(
              value: state.itemsPerPage,
              options: itemsPerPageOptions
                  .map((value) => SelectOption(
                        value: value,
                        label: value.toString(),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(paginationStateProvider(paginationKey).notifier)
                      .setItemsPerPage(value);
                  onItemsPerPageChanged?.call(value);
                }
              },
              size: SelectSize.small,
            ),
          ),
          SizedBox(width: Foundations.spacing.sm),
          Text(
            'per page',
            style: TextStyle(
              fontSize: Foundations.typography.sm,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
          ),
        ],
      );
    }

    Widget buildNavigationButtons() {
      if (state.totalPages <= 1) return const SizedBox.shrink();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            BaseIconButton(
              icon: Icons.keyboard_double_arrow_left,
              variant: IconButtonVariant.ghost,
              size: IconButtonSize.small,
              onPressed: state.currentPage > 0
                  ? () => ref
                      .read(paginationStateProvider(paginationKey).notifier)
                      .setPage(0)
                  : null,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
            BaseIconButton(
              icon: Icons.chevron_left,
              variant: IconButtonVariant.ghost,
              size: IconButtonSize.small,
              onPressed: state.currentPage > 0
                  ? () => ref
                      .read(paginationStateProvider(paginationKey).notifier)
                      .setPage(state.currentPage - 1)
                  : null,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
            ...getVisiblePages().map((pageIndex) {
              if (pageIndex == -1) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Foundations.spacing.xs,
                  ),
                  child: Text(
                    '...',
                    style: TextStyle(
                      color: isDarkMode
                          ? Foundations.darkColors.textMuted
                          : Foundations.colors.textMuted,
                    ),
                  ),
                );
              }

              final isActive = pageIndex == state.currentPage;
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Foundations.spacing.xs,
                ),
                child: BaseButton(
                  label: '${pageIndex + 1}',
                  variant: isActive ? ButtonVariant.filled : ButtonVariant.text,
                  size: ButtonSize.small,
                  backgroundColor:
                      isActive ? theme.primaryColor : Colors.transparent,
                  foregroundColor: isActive
                      ? Colors.white
                      : isDarkMode
                          ? Foundations.darkColors.textMuted
                          : Foundations.colors.textMuted,
                  onPressed: isActive
                      ? null
                      : () => ref
                          .read(paginationStateProvider(paginationKey).notifier)
                          .setPage(pageIndex),
                ),
              );
            }),
            BaseIconButton(
              icon: Icons.chevron_right,
              variant: IconButtonVariant.ghost,
              size: IconButtonSize.small,
              onPressed: state.currentPage < state.totalPages - 1
                  ? () => ref
                      .read(paginationStateProvider(paginationKey).notifier)
                      .setPage(state.currentPage + 1)
                  : null,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
            BaseIconButton(
              icon: Icons.keyboard_double_arrow_right,
              variant: IconButtonVariant.ghost,
              size: IconButtonSize.small,
              onPressed: state.currentPage < state.totalPages - 1
                  ? () => ref
                      .read(paginationStateProvider(paginationKey).notifier)
                      .setPage(state.totalPages - 1)
                  : null,
              color: isDarkMode
                  ? Foundations.darkColors.textMuted
                  : Foundations.colors.textMuted,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        buildItemsPerPageSelector(),
        if (isSmallScreen && state.totalPages > 1)
          SizedBox(height: Foundations.spacing.md),
        buildNavigationButtons(),
      ],
    );
  }
}
