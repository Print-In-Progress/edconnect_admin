import 'package:edconnect_admin/presentation/widgets/common/buttons.dart';
import 'package:edconnect_admin/presentation/widgets/common/forms.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/snackbars.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  // text editing controllers
  final _emailController = TextEditingController();

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim())
          .then((value) {
        successMessage(
            context,
            AppLocalizations.of(context)!
                .forgotPasswordPageSuccessLinkSendSnackbarMessage);
      });
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      errorMessage(context, e.toString());
    } catch (e) {
      if (!context.mounted) return;
      errorMessage(
          context, AppLocalizations.of(context)!.globalUnexpectedErrorLabel);
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width < 700
                    ? MediaQuery.of(context).size.width
                    : MediaQuery.of(context).size.width / 2,
                child: Card(
                    elevation: 50,
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            AppLocalizations.of(context)!
                                .forgotPasswordPagePasswordResetLabel,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 10),
                          PIPOutlinedBorderInputForm(
                            validate: false,
                            width: MediaQuery.of(context).size.width,
                            controller: _emailController,
                            label:
                                AppLocalizations.of(context)!.globalEmailLabel,
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          PIPResponsiveRaisedButton(
                            label: AppLocalizations.of(context)!
                                .forgotPasswordPageResetPasswordButtonLabel,
                            onPressed: passwordReset,
                            fontWeight: FontWeight.w700,
                            width: MediaQuery.of(context).size.width < 700
                                ? MediaQuery.of(context).size.width
                                : MediaQuery.of(context).size.width / 4,
                          ),
                          const SizedBox(height: 10),
                          PIPResponsiveTextButton(
                            label: AppLocalizations.of(context)!
                                .globalBackToLoginLabel,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w700,
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            width: MediaQuery.of(context).size.width < 700
                                ? MediaQuery.of(context).size.width / 2
                                : MediaQuery.of(context).size.width / 4,
                            height: MediaQuery.of(context).size.height / 20,
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    )),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
