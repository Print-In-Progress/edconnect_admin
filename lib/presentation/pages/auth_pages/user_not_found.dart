import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/domain/services/url_service.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserNotFoundPage extends ConsumerWidget {
  const UserNotFoundPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDarkMode = ref.watch(appThemeProvider).isDarkMode;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: BaseCard(
          variant: CardVariant.elevated,
          padding: EdgeInsets.all(Foundations.spacing.xl2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 72,
                color: Foundations.colors.error,
              ),

              SizedBox(height: Foundations.spacing.lg),

              // Title
              Text(
                l10n.errorUserNotFound,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Foundations.typography.xl2,
                  fontWeight: Foundations.typography.semibold,
                  color: isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
              ),

              SizedBox(height: Foundations.spacing.md),
              Text(
                l10n.errorUserNotFoundMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: Foundations.typography.base,
                  color: isDarkMode
                      ? Foundations.darkColors.textSecondary
                      : Foundations.colors.textSecondary,
                ),
              ),

              SizedBox(height: Foundations.spacing.xl),
              BaseButton(
                label: l10n.globalBackToLogin,
                onPressed: () =>
                    ref.read(signOutStateProvider.notifier).signOut(),
                variant: ButtonVariant.filled,
                size: ButtonSize.large,
                prefixIcon: Icons.arrow_back,
                fullWidth: true,
              ),

              SizedBox(height: Foundations.spacing.lg),
              BaseButton(
                label: 'Print In Progress Homepage',
                onPressed: () =>
                    UrlService.launchWebUrl('https://printinprogress.com'),
                variant: ButtonVariant.outlined,
                size: ButtonSize.large,
                prefixIcon: Icons.arrow_back,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
