import 'dart:async';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/section_card_settings.dart';
import 'package:edconnect_admin/presentation/widgets/common/snackbars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import '../home_page/home_page.dart';
import 'user_not_found.dart';
import '../../providers/theme_provider.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  bool canResendEmail = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerification() async {
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => ref.read(checkEmailVerificationProvider)(),
    );
  }

  Future<void> sendVerificationEmail() async {
    try {
      setState(() => canResendEmail = false);

      // Using the provider instead of direct service call
      final sendVerification = ref.read(sendEmailVerificationProvider);
      await sendVerification();

      await Future.delayed(const Duration(seconds: 5));
      if (mounted) setState(() => canResendEmail = true);
    } catch (e) {
      if (!mounted) return;
      errorMessage(context, e.toString());
      setState(() => canResendEmail = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = ref.watch(authStatusProvider);
    final theme = ref.watch(appThemeProvider);
    final l10n = AppLocalizations.of(context)!;
    if (authStatus == AuthStatus.authenticated) {
      return ref.watch(currentUserProvider).when(
            data: (user) =>
                user == null ? const UserNotFoundPage() : const HomePage(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
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
              constraints: const BoxConstraints(maxWidth: 700),
              child: buildSectionCard(
                l10n.authVerifyEmailTitle,
                theme.isDarkMode,
                children: [
                  Text(
                    AppLocalizations.of(context)!.authVerifyEmailBody,
                    style: TextStyle(
                        color: theme.isDarkMode
                            ? Foundations.darkColors.textPrimary
                            : Foundations.colors.textPrimary,
                        fontSize: Foundations.typography.base),
                  ),
                  SizedBox(
                    height: Foundations.spacing.lg,
                  ),
                  BaseButton(
                    label: l10n.authResendVerificationEmail,
                    onPressed: canResendEmail ? sendVerificationEmail : null,
                    variant: ButtonVariant.filled,
                    size: ButtonSize.large,
                    isLoading: canResendEmail == false,
                    fullWidth: true,
                    prefixIcon: Icons.email_outlined,
                  ),
                  SizedBox(
                    height: Foundations.spacing.lg,
                  ),
                  BaseButton(
                    label: l10n.globalCancel,
                    onPressed: () =>
                        ref.read(signOutStateProvider.notifier).signOut(),
                    variant: ButtonVariant.text,
                    size: ButtonSize.large,
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
