import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SurveyFilterBar extends ConsumerWidget {
  final SurveyFilterState filterState;

  const SurveyFilterBar({required this.filterState, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(child: _buildSearchInput(ref)),
        SizedBox(width: Foundations.spacing.md),
        SizedBox(width: 160, child: _buildStatusFilter(ref)),
        SizedBox(width: Foundations.spacing.md),
        SizedBox(width: 160, child: _buildSortOrder(ref)),
      ],
    );
  }

  Widget _buildSearchInput(WidgetRef ref) {
    return BaseInput(
      leadingIcon: Icons.search,
      hint: 'Search surveys...',
      onChanged: (value) {
        ref.read(surveyFilterProvider.notifier).state =
            filterState.copyWith(searchQuery: value);
      },
    );
  }

  Widget _buildStatusFilter(WidgetRef ref) {
    return BaseSelect<SortingSurveyStatus?>(
      value: filterState.statusFilter,
      options: _buildStatusOptions(),
      hint: 'Filter Status',
      leadingIcon: Icons.filter_list,
      size: SelectSize.medium,
      variant: SelectVariant.outlined,
      onChanged: (value) {
        ref.read(surveyFilterProvider.notifier).state = filterState.copyWith(
            statusFilter: value, clearStatusFilter: value == null);
      },
    );
  }

  Widget _buildSortOrder(WidgetRef ref) {
    return BaseSelect<SurveySortOrder>(
      value: filterState.sortOrder,
      options: _buildSortOptions(),
      hint: 'Sort By',
      leadingIcon: Icons.sort,
      size: SelectSize.medium,
      variant: SelectVariant.outlined,
      onChanged: (value) {
        if (value != null) {
          ref.read(surveyFilterProvider.notifier).state =
              filterState.copyWith(sortOrder: value);
        }
      },
    );
  }

  List<SelectOption<SortingSurveyStatus?>> _buildStatusOptions() {
    return [
      const SelectOption(
        value: null,
        label: 'All',
        icon: Icons.filter_list_off,
      ),
      ...SortingSurveyStatus.values.map((status) {
        IconData icon;
        switch (status) {
          case SortingSurveyStatus.draft:
            icon = Icons.edit_outlined;
            break;
          case SortingSurveyStatus.published:
            icon = Icons.public_outlined;
            break;
          case SortingSurveyStatus.closed:
            icon = Icons.lock_outlined;
            break;
        }
        return SelectOption(
          value: status,
          label: status.name.toUpperCase(),
          icon: icon,
        );
      }),
    ];
  }

  List<SelectOption<SurveySortOrder>> _buildSortOptions() {
    return SurveySortOrder.values.map((order) {
      IconData icon;
      String label;
      switch (order) {
        case SurveySortOrder.newest:
          icon = Icons.arrow_downward;
          label = 'Newest First';
          break;
        case SurveySortOrder.oldest:
          icon = Icons.arrow_upward;
          label = 'Oldest First';
          break;
        case SurveySortOrder.alphabetical:
          icon = Icons.sort_by_alpha;
          label = 'Alphabetical';
          break;
      }
      return SelectOption(
        value: order,
        label: label,
        icon: icon,
      );
    }).toList();
  }
}
