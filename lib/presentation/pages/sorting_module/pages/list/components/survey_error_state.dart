import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/errors/domain_exception.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SurveyErrorState extends ConsumerWidget {
  final Object error;
  const SurveyErrorState({super.key, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    return Center(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Foundations.colors.error,
            ),
            SizedBox(height: Foundations.spacing.md),
            if (error is DomainException) ...[
              Text(
                (error as DomainException).originalError,
                style: TextStyle(
                  fontSize: Foundations.typography.lg,
                  fontWeight: Foundations.typography.semibold,
                  color: theme.isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
              ),
              if ((error as DomainException).originalError != null) ...[
                SizedBox(height: Foundations.spacing.sm),
                Text(
                  (error as DomainException).originalError,
                  style: TextStyle(
                    fontSize: Foundations.typography.sm,
                    color: theme.isDarkMode
                        ? Foundations.darkColors.textSecondary
                        : Foundations.colors.textSecondary,
                  ),
                ),
              ],
            ] else ...[
              Text(
                'An unexpected error occurred',
                style: TextStyle(
                  fontSize: Foundations.typography.lg,
                  fontWeight: Foundations.typography.semibold,
                  color: theme.isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
              ),
              SizedBox(height: Foundations.spacing.sm),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: Foundations.typography.sm,
                  color: theme.isDarkMode
                      ? Foundations.darkColors.textSecondary
                      : Foundations.colors.textSecondary,
                ),
              ),
            ],
            SizedBox(height: Foundations.spacing.lg),
            BaseButton(
              label: 'Retry',
              prefixIcon: Icons.refresh,
              variant: ButtonVariant.outlined,
              onPressed: () {
                // Invalidate the provider to trigger a refresh
                ref.invalidate(sortingSurveysProvider);
              },
            ),
          ],
        ),
      ),
    );
  }
}
