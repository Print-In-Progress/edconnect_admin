import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/results/components/class_column.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/results/components/results_header.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/results/components/student_card.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/dialogs/dialogs.dart';
import 'package:edconnect_admin/presentation/widgets/common/sortable.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
Search/filter functionality to temporarily show only students matching specific criteria across all columns

Highlight related items - When a student is selected, highlight their preferred classmates in other columns

Sticky headers to keep column titles visible when scrolling

*/

class ResultsTab extends ConsumerStatefulWidget {
  final SortingSurvey survey;
  const ResultsTab({super.key, required this.survey});

  @override
  ConsumerState<ResultsTab> createState() => _ResultsTabState();
}

class _ResultsTabState extends ConsumerState<ResultsTab> {
  Map<String, List<String>> _currentResults = {};
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    if (widget.survey.calculationResults != null &&
        widget.survey.calculationResults!.isNotEmpty) {
      _currentResults = widget.survey.calculationResults!.map(
          (className, students) =>
              MapEntry(className, (students as List).cast<String>()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final hasResults = _currentResults.isNotEmpty;
    final allUsers = ref.watch(allUsersStreamProvider).value ?? [];
    final l10n = AppLocalizations.of(context)!;

    if (!hasResults) {
      return _buildNoResultsState(isDarkMode, l10n);
    }

    final columns = _currentResults.entries.map((entry) {
      final className = entry.key;
      final studentIds = entry.value;

      final items = studentIds.map((studentId) {
        return SortableItem<String>(
          id: studentId,
          data: studentId,
        );
      }).toList();

      return SortableColumn<String>(
        id: className,
        title: className,
        description: l10n.sortingModuleNumOfStudents(studentIds.length),
        headerWidget: ClassColumnHeader(
            className: className,
            studentIds: studentIds,
            survey: widget.survey),
        items: items,
      );
    }).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SortingSurveyResultsHeader(
                currentResults: _currentResults, survey: widget.survey),
            if (_hasChanges) ...[
              SizedBox(height: Foundations.spacing.sm),
              Row(
                children: [
                  BaseButton(
                    label: l10n.globalSave,
                    prefixIcon: Icons.save_outlined,
                    variant: ButtonVariant.filled,
                    onPressed: () => _saveChanges(l10n),
                  ),
                  SizedBox(width: Foundations.spacing.md),
                  BaseButton(
                    label: l10n.globaDiscard,
                    prefixIcon: Icons.close,
                    variant: ButtonVariant.outlined,
                    onPressed: _discardChanges,
                  ),
                ],
              ),
              SizedBox(height: Foundations.spacing.sm),
              Text(
                l10n.globalYouHaveUnsavedChanges,
                style: TextStyle(
                  color: Foundations.colors.warning,
                  fontSize: Foundations.typography.sm,
                ),
              ),
              SizedBox(height: Foundations.spacing.sm),
            ],
            Center(
              child: SizedBox(
                height: 750,
                child: Sortable<String>(
                  columns: columns,
                  columnWidth:
                      MediaQuery.of(context).size.width > 1200 ? 320 : 280,
                  showEmptyPlaceholder: true,
                  itemSpacing: Foundations.spacing.xs,
                  onItemsReordered: _handleReorder,
                  itemBuilder: (context, item) {
                    return SortingSurveyStudentCard(
                        studentId: item.data,
                        allUsers: allUsers,
                        survey: widget.survey,
                        currentResults: _currentResults);
                  },
                  emptyPlaceholderBuilder: (context, column) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(Foundations.spacing.lg),
                        child: Text(
                          l10n.sortingModuleDragStudentsHerePlaceholder,
                          style: TextStyle(
                            color: isDarkMode
                                ? Foundations.darkColors.textMuted
                                : Foundations.colors.textMuted,
                            fontSize: Foundations.typography.base,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(bool isDarkMode, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline,
            size: 64,
            color: isDarkMode
                ? Foundations.darkColors.textMuted
                : Foundations.colors.textMuted,
          ),
          SizedBox(height: Foundations.spacing.lg),
          Text(
            l10n.sortingModuleNoCalcResults,
            style: TextStyle(
              fontSize: Foundations.typography.xl,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textPrimary
                  : Foundations.colors.textPrimary,
            ),
          ),
          SizedBox(height: Foundations.spacing.md),
          SizedBox(height: Foundations.spacing.xl),
          BaseButton(
            label: l10n.sortingModuleGoToCalculate,
            prefixIcon: Icons.calculate_outlined,
            variant: ButtonVariant.filled,
            onPressed: () {
              ref
                  .read(surveyTabIndexProvider(widget.survey.id).notifier)
                  .state = 2;
            },
          ),
        ],
      ),
    );
  }

  void _handleReorder(
    List<SortableColumn<String>> updatedColumns,
    String sourceColumnId,
    String targetColumnId,
    String itemId,
  ) {
    final Map<String, List<String>> newResults = {};

    final newColumns = <SortableColumn<String>>[];

    for (final column in updatedColumns) {
      final studentIds = column.items.map((item) => item.data).toList();

      newResults[column.id] = studentIds;

      newColumns.add(column.copyWith(
        headerWidget: ClassColumnHeader(
          className: column.id,
          studentIds: studentIds,
          survey: widget.survey,
        ),
      ));
    }

    setState(() {
      _currentResults = newResults;
      _hasChanges = true;
    });
  }

  Future<void> _saveChanges(AppLocalizations l10n) async {
    try {
      final confirmed = await Dialogs.confirm(
        context: context,
        title: l10n.globalSave,
        message: l10n.globalSaveChangesConfirmationDialog,
      );

      if (confirmed != true) return;

      await ref
          .read(sortingSurveyNotifierProvider.notifier)
          .saveCalculationResults(widget.survey, _currentResults);

      setState(() {
        _hasChanges = false;
      });

      if (mounted) {
        Toaster.success(context, l10n.successDataSaved);
      }
    } catch (e) {
      if (mounted) {
        Toaster.error(context, l10n.errorSaveFailed, description: e.toString());
      }
    }
  }

  void _discardChanges() {
    setState(() {
      if (widget.survey.calculationResults != null) {
        _currentResults = widget.survey.calculationResults!.map(
            (className, students) =>
                MapEntry(className, (students as List).cast<String>()));
      } else {
        _currentResults = {};
      }
      _hasChanges = false;
    });
  }
}
