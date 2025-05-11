import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
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
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(Foundations.spacing.md),
          child: Row(
            children: [
              Expanded(
                child: BaseInput(
                  leadingIcon: Icons.search,
                  hint: 'Search by name...',
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
                      label: 'Name A-Z',
                      icon: Icons.arrow_upward,
                    ),
                    SelectOption(
                      value: SortOrder.desc,
                      label: 'Name Z-A',
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
                              SelectOption(value: null, label: 'All'),
                              SelectOption(value: 'm', label: 'Male'),
                              SelectOption(value: 'f', label: 'Female'),
                              SelectOption(value: 'nb', label: 'Non-Binary'),
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
                                SelectOption(value: null, label: 'All'),
                                SelectOption(value: 'yes', label: 'Yes'),
                                SelectOption(value: 'no', label: 'No'),
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
                              SelectOption(value: null, label: 'All'),
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
                      tooltip: 'Clear filters',
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
