import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/snackbars.dart';
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
  final _formKey = GlobalKey<FormState>();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.globalEmptyFormFieldErrorLabel;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await ref
          .read(resetPasswordProvider.notifier)
          .resetPassword(_emailController.text.trim());

      if (!mounted) return;
      successMessage(
        context,
        AppLocalizations.of(context)!
            .forgotPasswordPageSuccessLinkSendSnackbarMessage,
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
                      child: Form(
                        key: _formKey,
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
                            TextFormField(
                              controller: _emailController,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 10),
                            PIPResponsiveRaisedButton(
                              label: AppLocalizations.of(context)!
                                  .forgotPasswordPageResetPasswordButtonLabel,
                              onPressed: () {
                                resetPasswordState.isLoading
                                    ? null
                                    : _resetPassword;
                              },
                              fontWeight: FontWeight.w700,
                              width: MediaQuery.of(context).size.width < 700
                                  ? MediaQuery.of(context).size.width
                                  : MediaQuery.of(context).size.width / 4,
                            ),
                            if (resetPasswordState.isLoading)
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            const SizedBox(height: 10),
                            PIPResponsiveTextButton(
                              label: AppLocalizations.of(context)!
                                  .globalBackToLoginLabel,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w700,
                              onPressed: () => Navigator.of(context).pop(),
                              width: MediaQuery.of(context).size.width < 700
                                  ? MediaQuery.of(context).size.width / 2
                                  : MediaQuery.of(context).size.width / 4,
                              height: MediaQuery.of(context).size.height / 20,
                            ),
                          ],
                        ),
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
