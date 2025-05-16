import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/utils/parameter_formatter.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_icon_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponseTableFilter extends ConsumerStatefulWidget {
  final SortingSurvey survey;
  const ResponseTableFilter({super.key, required this.survey});

  @override
  ConsumerState<ResponseTableFilter> createState() =>
      _ResponseTableFilterState();
}

class _ResponseTableFilterState extends ConsumerState<ResponseTableFilter> {
  final filterRowScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(Foundations.spacing.md),
          child: Row(
            children: [
              Expanded(
                child: BaseInput(
                  leadingIcon: Icons.search,
                  hint: l10n.globalSearchWithName(''),
                  size: InputSize.small,
                  onChanged: (value) {
                    ref
                            .read(responsesFilterProvider(widget.survey.id)
                                .notifier)
                            .state =
                        ref
                            .read(responsesFilterProvider(widget.survey.id))
                            .copyWith(
                              searchQuery: value,
                            );
                  },
                ),
              ),
              SizedBox(width: Foundations.spacing.md),
              SizedBox(
                width: 160,
                child: BaseSelect<SortOrder>(
                  value: ref
                      .watch(responsesFilterProvider(widget.survey.id))
                      .sortOrder,
                  options: [
                    SelectOption(
                      value: SortOrder.asc,
                      label: l10n.globalFilterByNameAZ,
                      icon: Icons.arrow_upward,
                    ),
                    SelectOption(
                      value: SortOrder.desc,
                      label: l10n.globalFilterByNameZA,
                      icon: Icons.arrow_downward,
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref
                              .read(responsesFilterProvider(widget.survey.id)
                                  .notifier)
                              .state =
                          ref
                              .read(responsesFilterProvider(widget.survey.id))
                              .copyWith(
                                sortOrder: value,
                              );
                    }
                  },
                  size: SelectSize.small,
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: filterRowScrollController,
            child: Column(children: [
              // Parameter filters row
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Foundations.spacing.md,
                  vertical: Foundations.spacing.sm,
                ),
                child: Wrap(
                  children: [
                    if (widget.survey.askBiologicalSex)
                      Padding(
                        padding: EdgeInsets.only(right: Foundations.spacing.sm),
                        child: SizedBox(
                          width: 140,
                          child: BaseSelect<String?>(
                            hint: 'Sex',
                            size: SelectSize.small,
                            value: ref
                                .watch(
                                    responsesFilterProvider(widget.survey.id))
                                .parameterFilters['sex'],
                            options: [
                              SelectOption(
                                  value: null, label: l10n.globalAllLabel),
                              SelectOption(
                                  value: 'm', label: l10n.globalMaleLabel),
                              SelectOption(
                                  value: 'f', label: l10n.globalFemaleLabel),
                              SelectOption(
                                  value: 'nb',
                                  label: l10n.globalNonBinaryLabel),
                            ],
                            onChanged: (value) {
                              final currentFilters = Map<String, String?>.from(
                                ref
                                    .read(responsesFilterProvider(
                                        widget.survey.id))
                                    .parameterFilters,
                              );
                              currentFilters['sex'] = value;
                              ref
                                      .read(responsesFilterProvider(
                                              widget.survey.id)
                                          .notifier)
                                      .state =
                                  ref
                                      .read(responsesFilterProvider(
                                          widget.survey.id))
                                      .copyWith(
                                        parameterFilters: currentFilters,
                                      );
                            },
                          ),
                        ),
                      ),
                    ...widget.survey.parameters.map((param) {
                      if (param['type'] == 'binary') {
                        return Padding(
                          padding:
                              EdgeInsets.only(right: Foundations.spacing.sm),
                          child: SizedBox(
                            width: 140,
                            child: BaseSelect<String?>(
                              hint: ParameterFormatter.formatParameterName(
                                param['name'],
                              ),
                              size: SelectSize.small,
                              value: ref
                                  .watch(
                                      responsesFilterProvider(widget.survey.id))
                                  .parameterFilters[param['name']],
                              options: [
                                SelectOption(
                                    value: null, label: l10n.globalAllLabel),
                                SelectOption(
                                    value: 'yes', label: l10n.globalYes),
                                SelectOption(value: 'no', label: l10n.globalNo),
                              ],
                              onChanged: (value) {
                                final currentFilters =
                                    Map<String, String?>.from(
                                  ref
                                      .read(responsesFilterProvider(
                                          widget.survey.id))
                                      .parameterFilters,
                                );
                                currentFilters[param['name']] = value;
                                ref
                                        .read(responsesFilterProvider(
                                                widget.survey.id)
                                            .notifier)
                                        .state =
                                    ref
                                        .read(responsesFilterProvider(
                                            widget.survey.id))
                                        .copyWith(
                                          parameterFilters: currentFilters,
                                        );
                              },
                            ),
                          ),
                        );
                      }
                      // For categorical parameters
                      final uniqueValues = widget.survey.responses.values
                          .map((r) => r[param['name']]?.toString())
                          .where((v) => v != null)
                          .toSet()
                          .toList()
                        ..sort();

                      return Padding(
                        padding: EdgeInsets.only(right: Foundations.spacing.sm),
                        child: SizedBox(
                          width: 140,
                          child: BaseSelect<String?>(
                            hint: ParameterFormatter.formatParameterName(
                              param['name'],
                            ),
                            size: SelectSize.small,
                            searchable: true,
                            value: ref
                                .watch(
                                    responsesFilterProvider(widget.survey.id))
                                .parameterFilters[param['name']],
                            options: [
                              SelectOption(
                                  value: null, label: l10n.globalAllLabel),
                              ...uniqueValues.map((v) => SelectOption(
                                  value: v,
                                  label: ParameterFormatter
                                      .formatParameterNameForDisplay(v!))),
                            ],
                            onChanged: (value) {
                              final currentFilters = Map<String, String?>.from(
                                ref
                                    .read(responsesFilterProvider(
                                        widget.survey.id))
                                    .parameterFilters,
                              );
                              currentFilters[param['name']] = value;
                              ref
                                      .read(responsesFilterProvider(
                                              widget.survey.id)
                                          .notifier)
                                      .state =
                                  ref
                                      .read(responsesFilterProvider(
                                          widget.survey.id))
                                      .copyWith(
                                        parameterFilters: currentFilters,
                                      );
                            },
                          ),
                        ),
                      );
                    }),
                    BaseIconButton(
                      icon: Icons.clear_all,
                      onPressed: () {
                        ref
                            .read(responsesFilterProvider(widget.survey.id)
                                .notifier)
                            .state = const ResponsesFilterState();
                      },
                      tooltip: l10n.globalClearFilters,
                      variant: IconButtonVariant.outlined,
                      size: IconButtonSize.small,
                    ),
                  ],
                ),
              ),
            ])),
      ],
    );
  }
}
