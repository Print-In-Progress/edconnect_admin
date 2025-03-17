import 'package:edconnect_admin/presentation/widgets/common/buttons.dart';
import 'package:edconnect_admin/presentation/widgets/common/forms.dart';
import 'package:edconnect_admin/presentation/pages/auth_pages/forgot_password_page.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/snackbars.dart';
import 'package:edconnect_admin/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  final _auth = AuthService();

  bool _newPasswordVisible = false;
  bool _currentPasswordVisible = false;
  bool _confirmNewPasswordVisible = false;

  Future<void> _updatePassword() async {
    try {
      await _auth.updatePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmedPassword: _confirmNewPasswordController.text,
      );

      if (!mounted) return;
      successMessage(
        context,
        AppLocalizations.of(context)!
            .settingsPageSuccessOnPasswordChangedSnackbarLabel,
      );
    } on Exception catch (e) {
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
                SliverAppBar(
                  automaticallyImplyLeading: true,
                  floating: true,
                  snap: true,
                  forceMaterialTransparency: true,
                  actionsIconTheme: const IconThemeData(color: Colors.white),
                  iconTheme: const IconThemeData(color: Colors.white),
                  title: Text(
                    AppLocalizations.of(context)!.globalSettingsLabel,
                    style: const TextStyle(color: Colors.white),
                  ),
                )
              ];
            },
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width < 700
                        ? MediaQuery.of(context).size.width
                        : MediaQuery.of(context).size.width / 2,
                    child: Card(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),

                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: PIPPasswordForm(
                                  label: AppLocalizations.of(context)!
                                      .settingsPageCurrentPasswordHintText,
                                  width: MediaQuery.of(context).size.width,
                                  controller: _currentPasswordController,
                                  passwordVisible: _currentPasswordVisible,
                                  onPressed: () {
                                    setState(() {
                                      _currentPasswordVisible =
                                          !_currentPasswordVisible;
                                    });
                                  }),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: PIPPasswordForm(
                                  label: AppLocalizations.of(context)!
                                      .settingsPageNewPasswordHintText,
                                  width: MediaQuery.of(context).size.width,
                                  controller: _newPasswordController,
                                  passwordVisible: _newPasswordVisible,
                                  onPressed: () {
                                    setState(() {
                                      _newPasswordVisible =
                                          !_newPasswordVisible;
                                    });
                                  }),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: PIPPasswordForm(
                                  label: AppLocalizations.of(context)!
                                      .authPagesRegisterConfirmPasswordTextFieldHintText,
                                  width: MediaQuery.of(context).size.width,
                                  controller: _confirmNewPasswordController,
                                  passwordVisible: _confirmNewPasswordVisible,
                                  onPressed: () {
                                    setState(() {
                                      _confirmNewPasswordVisible =
                                          !_confirmNewPasswordVisible;
                                    });
                                  }),
                            ),

                            // forgot password button
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              settings: const RouteSettings(
                                                  name: 'Forgot Password Page'),
                                              builder: (context) {
                                                return const ForgotPasswordPage();
                                              }));
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .authPagesForgotPasswordButtonLabel,
                                      style: const TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25.0),
                              child: PIPResponsiveRaisedButton(
                                  fontWeight: FontWeight.w600,
                                  label: AppLocalizations.of(context)!
                                      .globalApplyChangesButtonLabel,
                                  onPressed: _updatePassword,
                                  width: MediaQuery.of(context).size.width),
                            ),

                            const SizedBox(height: 10),
                          ],
                        ),
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
