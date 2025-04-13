import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/section_card_settings.dart';
import 'package:edconnect_admin/presentation/pages/auth_pages/forgot_password_page.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/navigation/app_bar.dart';
import 'package:edconnect_admin/presentation/widgets/common/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountPassword extends ConsumerStatefulWidget {
  const AccountPassword({super.key});

  @override
  ConsumerState<AccountPassword> createState() => _AccountPasswordState();
}

class _AccountPasswordState extends ConsumerState<AccountPassword> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _newPasswordVisible = false;
  bool _currentPasswordVisible = false;
  bool _confirmNewPasswordVisible = false;

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // First reauthenticate
      await ref
          .read(reauthenticateProvider.notifier)
          .reauthenticate(_currentPasswordController.text);

      // Then change password
      await ref
          .read(changePasswordProvider.notifier)
          .changePassword(_newPasswordController.text);

      if (!mounted) return;
      successMessage(
        context,
        AppLocalizations.of(context)!.successPasswordChanged,
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      errorMessage(context, e.toString());
    }
  }

  @override
  void dispose() {
    super.dispose();
    _currentPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _newPasswordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final l10n = AppLocalizations.of(context)!;
    final reauthenticateState = ref.watch(reauthenticateProvider);
    final changePasswordState = ref.watch(changePasswordProvider);

    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [theme.primaryColor, theme.secondaryColor],
            ),
          ),
          padding: const EdgeInsets.all(8.0),
          child: SafeArea(
              child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, bool innerBoxIsScrolled) {
              return [
                BaseAppBar(
                  title: l10n.navSettings,
                  showLeading: true,
                  forceMaterialTransparency: true,
                  showDivider: false,
                  foregroundColor: Foundations.colors.surfaceActive,
                  floating: true,
                ).asSliverAppBar(context, ref),
              ];
            },
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 700),
                    child: Form(
                      key: _formKey,
                      child: buildSectionCard(
                        l10n.settingsChangePassword,
                        theme.isDarkMode,
                        children: [
                          SizedBox(height: Foundations.spacing.lg),
                          BaseInput(
                            controller: _currentPasswordController,
                            label:
                                AppLocalizations.of(context)!.authPasswordLabel,
                            hint:
                                AppLocalizations.of(context)!.authPasswordLabel,
                            leadingIcon: Icons.lock_outline,
                            isRequired: true,
                            obscureText: !_currentPasswordVisible,
                            variant: InputVariant.default_,
                            size: InputSize.large,
                            fullWidth: true,
                            trailingIcon: IconButton(
                              icon: Icon(
                                _currentPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: theme.isDarkMode
                                    ? Foundations.darkColors.textMuted
                                    : Foundations.colors.textMuted,
                              ),
                              onPressed: () {
                                setState(() {
                                  _currentPasswordVisible =
                                      !_currentPasswordVisible;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: Foundations.spacing.lg),
                          BaseInput(
                            controller: _newPasswordController,
                            label: AppLocalizations.of(context)!
                                .settingsNewPassword,
                            hint: AppLocalizations.of(context)!
                                .settingsNewPassword,
                            leadingIcon: Icons.lock_outline,
                            isRequired: true,
                            obscureText: !_newPasswordVisible,
                            variant: InputVariant.default_,
                            size: InputSize.large,
                            fullWidth: true,
                            trailingIcon: IconButton(
                              icon: Icon(
                                _newPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: theme.isDarkMode
                                    ? Foundations.darkColors.textMuted
                                    : Foundations.colors.textMuted,
                              ),
                              onPressed: () {
                                setState(() {
                                  _newPasswordVisible = !_newPasswordVisible;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: Foundations.spacing.lg),
                          BaseInput(
                            controller: _confirmNewPasswordController,
                            label: AppLocalizations.of(context)!
                                .authPagesRegisterConfirmPasswordTextFieldHintText,
                            hint: AppLocalizations.of(context)!
                                .authPagesRegisterConfirmPasswordTextFieldHintText,
                            leadingIcon: Icons.lock_outline,
                            isRequired: true,
                            obscureText: !_confirmNewPasswordVisible,
                            variant: InputVariant.default_,
                            size: InputSize.large,
                            fullWidth: true,
                            trailingIcon: IconButton(
                              icon: Icon(
                                _confirmNewPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: theme.isDarkMode
                                    ? Foundations.darkColors.textMuted
                                    : Foundations.colors.textMuted,
                              ),
                              onPressed: () {
                                setState(() {
                                  _confirmNewPasswordVisible =
                                      !_confirmNewPasswordVisible;
                                });
                              },
                            ),
                          ),
                          SizedBox(height: Foundations.spacing.lg),
                          Align(
                            alignment: Alignment.centerRight,
                            child: BaseButton(
                              label: AppLocalizations.of(context)!
                                  .authForgotPassword,
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      settings: const RouteSettings(
                                          name: 'Change Password Screen'),
                                      builder: (context) =>
                                          const ForgotPasswordPage(),
                                    ));
                              },
                              variant: ButtonVariant.text,
                              size: ButtonSize.medium,
                            ),
                          ),
                          SizedBox(height: Foundations.spacing.lg),
                          BaseButton(
                              label: l10n.globalSave,
                              onPressed: _updatePassword,
                              variant: ButtonVariant.filled,
                              size: ButtonSize.large,
                              isLoading: reauthenticateState.isLoading ||
                                  changePasswordState.isLoading,
                              fullWidth: true),
                          SizedBox(height: Foundations.spacing.lg),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
        ));
  }
}
