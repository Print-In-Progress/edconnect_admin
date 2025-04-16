import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/sorting_survey.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ResponsesTab extends ConsumerStatefulWidget {
  final SortingSurvey survey;

  const ResponsesTab({super.key, required this.survey});

  @override
  ConsumerState<ResponsesTab> createState() => ResponsesTabState();
}

class ResponsesTabState extends ConsumerState<ResponsesTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Foundations.spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [],
      ),
    );
  }
}
