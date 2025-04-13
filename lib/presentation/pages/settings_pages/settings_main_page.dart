import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/pages/settings_pages/settings_change_name_page.dart';
import 'package:edconnect_admin/presentation/pages/settings_pages/settings_change_email.dart';
import 'package:edconnect_admin/presentation/pages/settings_pages/settings_update_password_page.dart';
import 'package:edconnect_admin/presentation/pages/settings_pages/submit_registration_update.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/section_card_settings.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/snackbars.dart';
import 'package:edconnect_admin/presentation/widgets/common/switch.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountOverview extends ConsumerStatefulWidget {
  const AccountOverview({super.key});

  @override
  ConsumerState<AccountOverview> createState() => _AccountOverviewState();
}

class _AccountOverviewState extends ConsumerState<AccountOverview> {
  final _reauthenticatePasswordController = TextEditingController();
  bool reauthenticatePasswordVisible = false;

  @override
  void dispose() {
    _reauthenticatePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    // Responsive width calculation

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [theme.primaryColor, theme.secondaryColor],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            BaseAppBar(
              title: l10n.navSettings,
              showLeading: true,
              forceMaterialTransparency: true,
              showDivider: false,
              foregroundColor: Foundations.colors.surfaceActive,
              floating: true,
            ).asSliverAppBar(context, ref),
            SliverPadding(
              padding: EdgeInsets.all(Foundations.spacing.lg),
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Account Management Section
                        buildSectionCard(
                          l10n.settingsManageAccount,
                          theme.isDarkMode,
                          children: [
                            _buildSettingsItem(
                              icon: Icons.person_outline,
                              label: l10n.settingsChangeName,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: const RouteSettings(
                                      name: 'Settings Change Name Page'),
                                  builder: (context) => const AccountName(),
                                ),
                              ),
                            ),
                            _buildSettingsItem(
                              icon: Icons.email_outlined,
                              label: l10n.globalEmailLabel,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: const RouteSettings(
                                      name: 'Settings Change Email Screen'),
                                  builder: (context) => const ChangeEmail(),
                                ),
                              ),
                            ),
                            _buildSettingsItem(
                              icon: Icons.lock_outline,
                              label: l10n.settingsChangePassword,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: const RouteSettings(
                                      name: 'Settings Change Password Screen'),
                                  builder: (context) => const AccountPassword(),
                                ),
                              ),
                            ),
                            _buildSettingsItem(
                              icon: Icons.assignment_outlined,
                              label:
                                  l10n.settingsUpdateRegistrationQuestionaire,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  settings: const RouteSettings(
                                      name: 'resubmitRegInfo'),
                                  builder: (context) =>
                                      const SubmitRegistrationUpdate(),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: Foundations.spacing.lg),

                        // Appearance Section
                        buildSectionCard(
                          l10n.settingsAppearance,
                          theme.isDarkMode,
                          children: [
                            BaseSwitch(
                              label: l10n.settingsDarkMode,
                              value: theme.isDarkMode,
                              showHoverEffect: true,
                              trailing: theme.isDarkMode
                                  ? Icon(
                                      Icons.light_mode_outlined,
                                      color: isDarkMode
                                          ? Foundations.darkColors.textSecondary
                                          : Foundations.colors.textSecondary,
                                    )
                                  : Icon(
                                      Icons.dark_mode_outlined,
                                      color: isDarkMode
                                          ? Foundations.darkColors.textSecondary
                                          : Foundations.colors.textSecondary,
                                    ),
                              onChanged: (value) {
                                ref
                                    .read(appThemeProvider.notifier)
                                    .setDarkMode(!theme.isDarkMode);
                              },
                            ),
                          ],
                        ),

                        SizedBox(height: Foundations.spacing.lg),

                        // Account Actions Section
                        buildSectionCard(
                          'Account Actions',
                          theme.isDarkMode,
                          children: [
                            _buildSettingsItem(
                              icon: Icons.logout,
                              label: l10n.globalLogout,
                              textColor: Foundations.colors.error,
                              iconColor: Foundations.colors.error,
                              onTap: () async {
                                Navigator.of(context).pop();
                                await ref
                                    .read(signOutStateProvider.notifier)
                                    .signOut();
                              },
                            ),
                            _buildSettingsItem(
                                icon: Icons.abc,
                                label: 'Test',
                                onTap: () {
                                  Toaster.error(
                                    context,
                                    'Error message',
                                    description: 'This is a test error message',
                                  );
                                }),
                            _buildSettingsItem(
                              icon: Icons.delete_outline,
                              label: l10n.globalDeleteAccount,
                              textColor: Foundations.colors.error,
                              iconColor: Foundations.colors.error,
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  builder: (context) =>
                                      _buildDeleteAccountDialog(context),
                                );
                              },
                            ),
                          ],
                        ),

                        // Add bottom padding to ensure no white bar is visible
                        SizedBox(height: Foundations.spacing.xl3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String label,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    // Default colors if not specified
    final effectiveIconColor = iconColor ??
        (isDarkMode ? Foundations.darkColors.textPrimary : theme.primaryColor);
    final effectiveTextColor = textColor ??
        (isDarkMode
            ? Foundations.darkColors.textPrimary
            : Foundations.colors.textPrimary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: Foundations.borders.md,
        splashColor: isDarkMode
            ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.5)
            : theme.accentLight.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        hoverColor: isDarkMode
            ? Foundations.darkColors.backgroundSubtle.withValues(alpha: 0.5)
            : theme.accentLight.withValues(alpha: 0.1),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Foundations.spacing.lg,
            vertical: Foundations.spacing.md,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: effectiveIconColor,
              ),
              SizedBox(width: Foundations.spacing.lg),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: Foundations.typography.base,
                    fontWeight: Foundations.typography.medium,
                    color: effectiveTextColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDarkMode
                    ? Foundations.darkColors.textSecondary
                    : Foundations.colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;

    return StatefulBuilder(
      builder: (context, setState) {
        final deleteAccountState = ref.watch(deleteAccountProvider);

        return AlertDialog(
          title: Text(
            l10n.globalReauthenticate,
            style: TextStyle(
              fontSize: Foundations.typography.lg,
              fontWeight: Foundations.typography.semibold,
              color: isDarkMode
                  ? Foundations.darkColors.textPrimary
                  : Foundations.colors.textPrimary,
            ),
          ),
          backgroundColor: isDarkMode
              ? Foundations.darkColors.surface
              : Foundations.colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: Foundations.borders.md,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.settingsDeleteDialogBody,
                style: TextStyle(
                  fontSize: Foundations.typography.base,
                  color: isDarkMode
                      ? Foundations.darkColors.textSecondary
                      : Foundations.colors.textSecondary,
                ),
              ),
              SizedBox(height: Foundations.spacing.lg),
              BaseInput(
                controller: _reauthenticatePasswordController,
                label: l10n.authPasswordLabel,
                obscureText: !reauthenticatePasswordVisible,
                trailingIcon: IconButton(
                  icon: Icon(
                    reauthenticatePasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    size: 20,
                    color: isDarkMode
                        ? Foundations.darkColors.textSecondary
                        : Foundations.colors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      reauthenticatePasswordVisible =
                          !reauthenticatePasswordVisible;
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            BaseButton(
              label: l10n.globalCancel,
              variant: ButtonVariant.text,
              onPressed: () => Navigator.of(context).pop(),
            ),
            BaseButton(
              label: l10n.globalOk,
              variant: ButtonVariant.filled,
              isLoading: deleteAccountState.isLoading,
              onPressed: () async {
                try {
                  await ref
                      .read(deleteAccountProvider.notifier)
                      .deleteAccount(_reauthenticatePasswordController.text);

                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Pop settings page
                  successMessage(
                    context,
                    l10n.successDefault,
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  errorMessage(context, e.toString());
                }
              },
            ),
          ],
        );
      },
    );
  }
}
