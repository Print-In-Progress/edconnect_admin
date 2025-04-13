import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/validation/validators/text_field_validator.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/section_card_settings.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  // text editing controllers
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(resetPasswordProvider.notifier)
          .resetPassword(_emailController.text.trim());

      if (!mounted) return;
      successMessage(
        context,
        AppLocalizations.of(context)!.successResetPasswordEmailSent,
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      errorMessage(context, e.toString());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final resetPasswordState = ref.watch(resetPasswordProvider);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              theme.primaryColor,
              theme.secondaryColor,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: Foundations.spacing.sm,
              vertical: Foundations.spacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Form(
                key: _formKey,
                child: buildSectionCard(
                  l10n.authResetPassword,
                  theme.isDarkMode,
                  children: [
                    SizedBox(height: Foundations.spacing.lg),
                    Text(
                      AppLocalizations.of(context)!.authResetPasswordBody,
                      style: TextStyle(
                        fontSize: Foundations.typography.base,
                        fontWeight: Foundations.typography.semibold,
                        color: theme.isDarkMode
                            ? Foundations.darkColors.textPrimary
                            : Foundations.colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: Foundations.spacing.lg),
                    BaseInput(
                      controller: _emailController,
                      label: l10n.globalEmailLabel,
                      hint: l10n.globalEmailLabel,
                      leadingIcon: Icons.email_outlined,
                      isRequired: true,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      type: TextFieldType.email,
                      keyboardType: TextInputType.emailAddress,
                      variant: InputVariant.default_,
                      size: InputSize.medium,
                    ),
                    SizedBox(height: Foundations.spacing.lg),
                    BaseButton(
                        label: l10n.authResetPasswordSendEmail,
                        variant: ButtonVariant.filled,
                        isLoading: resetPasswordState.isLoading,
                        size: ButtonSize.large,
                        fullWidth: true,
                        onPressed: () {
                          resetPasswordState.isLoading ? null : _resetPassword;
                        }),
                    SizedBox(height: Foundations.spacing.lg),
                    BaseButton(
                      label: l10n.globalBack,
                      onPressed: () => Navigator.of(context).pop(),
                      variant: ButtonVariant.outlined,
                      size: ButtonSize.large,
                      fullWidth: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
