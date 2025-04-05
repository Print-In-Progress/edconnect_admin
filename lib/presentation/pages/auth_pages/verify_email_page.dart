import 'dart:async';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
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
          child: SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            height: MediaQuery.of(context).size.height / 2,
            child: Card(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      AppLocalizations.of(context)!.authVerifyEmailTitle,
                      style: const TextStyle(color: Colors.green, fontSize: 50),
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.authVerifyEmailBody,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: canResendEmail ? sendVerificationEmail : null,
                    icon: const Icon(Icons.email),
                    label: Text(AppLocalizations.of(context)!
                        .authResendVerificationEmail),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(signOutStateProvider.notifier).signOut(),
                    icon: const Icon(Icons.cancel),
                    label: Text(AppLocalizations.of(context)!.globalCancel),
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
