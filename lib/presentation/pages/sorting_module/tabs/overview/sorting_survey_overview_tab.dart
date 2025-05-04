import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/components/section_header.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/overview/components/access_control_section.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/overview/components/basic_info_section.dart';
import 'package:edconnect_admin/presentation/pages/sorting_module/tabs/overview/components/statistics_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OverviewTab extends ConsumerWidget {
  final SortingSurvey survey;

  const OverviewTab({super.key, required this.survey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWideScreen = screenWidth > 1100;

    return SingleChildScrollView(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
                title: 'Basic Information', icon: Icons.info_outline),
            SizedBox(height: Foundations.spacing.md),
            if (isWideScreen)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: BasicInfoSection(survey: survey)),
                  SizedBox(width: Foundations.spacing.lg),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        StatisticsSection(survey: survey),
                        SizedBox(height: Foundations.spacing.lg),
                        AccessControlSection(survey: survey),
                      ],
                    ),
                  ),
                ],
              ),
            if (!isWideScreen)
              Column(children: [
                BasicInfoSection(survey: survey),
                SizedBox(height: Foundations.spacing.xl),

                // Statistics Section
                StatisticsSection(survey: survey),
                SizedBox(height: Foundations.spacing.xl),

                // Access Control Section - Editable
                AccessControlSection(survey: survey),
              ])
          ],
        ),
      ),
    );
  }
}
