import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';

class BasicInfoCard extends ConsumerWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const BasicInfoCard({
    required this.titleController,
    required this.descriptionController,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return BaseCard(
      variant: CardVariant.elevated,
      child: Padding(
        padding: EdgeInsets.all(Foundations.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Basic Information',
              style: TextStyle(
                fontSize: Foundations.typography.lg,
                fontWeight: Foundations.typography.semibold,
                color: theme.isDarkMode
                    ? Foundations.darkColors.textPrimary
                    : Foundations.colors.textPrimary,
              ),
            ),
            SizedBox(height: Foundations.spacing.lg),
            BaseInput(
              controller: titleController,
              label: 'Title',
              hint: 'Enter survey title',
              isRequired: true,
            ),
            SizedBox(height: Foundations.spacing.md),
            BaseInput(
              controller: descriptionController,
              label: 'Description',
              hint: 'Enter survey description',
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
