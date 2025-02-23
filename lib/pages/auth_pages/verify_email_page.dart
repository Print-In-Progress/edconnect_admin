import 'dart:async';
import 'package:edconnect_admin/components/snackbars.dart';
import 'package:edconnect_admin/models/providers/themeprovider.dart';
import 'package:edconnect_admin/models/providers/user_provider.dart';
import 'package:edconnect_admin/pages/auth_pages/user_not_found.dart';
import 'package:edconnect_admin/pages/home_page/home_page.dart';
import 'package:edconnect_admin/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  final _authService = AuthService();

  Future<void> sendVerificationEmail() async {
    try {
      await _authService.sendEmailVerificationWithCooldown(
        onCooldownChange: (canResend) {
          if (mounted) setState(() => canResendEmail = canResend);
        },
      );
    } on Exception catch (e) {
      if (!context.mounted) return;
      errorMessage(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorState = ref.watch(colorAndLogoProvider);

    return isEmailVerified
        ? ref.watch(currentUserProvider).when(
              data: (user) {
                if (user == null) {
                  return const UserNotFoundPage();
                }

                return HomePage(permissions: user.permissions);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            )
        : Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    colorState.primaryColor,
                    colorState.secondaryColor,
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
                            AppLocalizations.of(context)!
                                .authPagesVerifyEmailPageTitle,
                            style: const TextStyle(
                                color: Colors.green, fontSize: 50),
                          ),
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .authPagesVerifyEmailPageContent,
                          style: const TextStyle(fontSize: 15),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        ElevatedButton.icon(
                            onPressed:
                                canResendEmail ? sendVerificationEmail : () {},
                            icon: const Icon(Icons.email),
                            label: Text(AppLocalizations.of(context)!
                                .globalResendEmailButtonLabel)),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton.icon(
                            onPressed: () => FirebaseAuth.instance.signOut(),
                            icon: const Icon(Icons.cancel),
                            label: Text(AppLocalizations.of(context)!
                                .globalCancelButtonLabel)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
