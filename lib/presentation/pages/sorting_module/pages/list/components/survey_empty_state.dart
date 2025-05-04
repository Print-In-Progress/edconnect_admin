import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SurveyEmptyState extends ConsumerWidget {
  const SurveyEmptyState({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.ballot_outlined,
            size: 64,
            color: Foundations.colors.textMuted,
          ),
          SizedBox(height: Foundations.spacing.md),
          Text(
            'No surveys found',
            style: TextStyle(
              fontSize: Foundations.typography.lg,
              color: Foundations.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
