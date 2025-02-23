import 'package:cached_network_image/cached_network_image.dart';
import 'package:edconnect_admin/components/buttons.dart';
import 'package:edconnect_admin/components/forms.dart';
import 'package:edconnect_admin/components/snackbars.dart';
import 'package:edconnect_admin/models/providers/themeprovider.dart';
import 'package:edconnect_admin/pages/auth_pages/forgot_password_page.dart';
import 'package:edconnect_admin/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends ConsumerStatefulWidget {
  final VoidCallback showRegisterPage;
  const LoginPage({super.key, required this.showRegisterPage});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  bool _validateEmailField = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorState = ref.watch(colorAndLogoProvider);
    final isDarkMode = ref.watch(themeProvider);
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [colorState.primaryColor, colorState.secondaryColor],
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Customer Logo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                                child: FractionallySizedBox(
                                    widthFactor: 0.8,
                                    child: colorState.logoLink != ''
                                        ? CachedNetworkImage(
                                            imageUrl: colorState.logoLink,
                                            progressIndicatorBuilder: (context,
                                                    url, downloadProgress) =>
                                                Center(
                                              child: CircularProgressIndicator(
                                                  value: downloadProgress
                                                      .progress),
                                            ),
                                            errorWidget:
                                                (context, url, error) => Center(
                                              child: Text(AppLocalizations.of(
                                                      context)!
                                                  .globalImgCouldNotBeFound),
                                            ),
                                          )
                                        : Image.asset(
                                            'assets/edconnect_logo.png'))),
                            Flexible(
                                child: FractionallySizedBox(
                              widthFactor: 0.7,
                              child: isDarkMode
                                  ? Image.asset(
                                      'assets/pip_branding_dark_mode_verticalxxxhdpi.png')
                                  : Image.asset(
                                      'assets/pip_branding_light_mode_verticalxxxhdpi.png'),
                            ))
                          ],
                        ),

                        // Greeting
                        Text(
                          AppLocalizations.of(context)!
                              .authPagesWelcomeLabelOne,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 32),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          AppLocalizations.of(context)!
                              .authPagesLoginWelcomeLabelTwo,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          height: 20,
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: PIPOutlinedBorderInputForm(
                            validate: _validateEmailField,
                            autofillHints: const [AutofillHints.email],
                            width: MediaQuery.of(context).size.width,
                            controller: _emailController,
                            label:
                                AppLocalizations.of(context)!.globalEmailLabel,
                            icon: Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25.0),
                          child: PIPPasswordForm(
                              label: AppLocalizations.of(context)!
                                  .globalPasswordLabel,
                              width: MediaQuery.of(context).size.width,
                              controller: _passwordController,
                              passwordVisible: _passwordVisible,
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              }),
                        ),
                        const SizedBox(height: 10),

                        // forgot password button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 25),
                          child: SizedBox(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          settings: const RouteSettings(
                                              name: 'Change Password Screen'),
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
                          )),
                        ),
                        const SizedBox(height: 15),

                        PIPResponsiveRaisedButton(
                          label: AppLocalizations.of(context)!
                              .authPagesLoginButtonLabel,
                          onPressed: () async {
                            setState(() {
                              _emailController.text.isEmpty
                                  ? _validateEmailField = true
                                  : _validateEmailField = false;
                            });
                            await _authService
                                .signIn(_emailController.text,
                                    _passwordController.text)
                                .then((value) {
                              if (value.contains('AuthError')) {
                                errorMessage(context, value);
                              } else if (value.contains('UnexpectedError')) {
                                errorMessage(context, value);
                              }
                            });
                          },
                          fontWeight: FontWeight.w700,
                          width: MediaQuery.of(context).size.width < 700
                              ? MediaQuery.of(context).size.width / 2
                              : MediaQuery.of(context).size.width / 4,
                          height: MediaQuery.of(context).size.height / 20,
                        ),
                        const SizedBox(height: 10),

                        PIPResponsiveTextButton(
                          label: AppLocalizations.of(context)!
                              .authPagesRegisterButtonLabel,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w700,
                          onPressed: widget.showRegisterPage,
                          width: MediaQuery.of(context).size.width < 700
                              ? MediaQuery.of(context).size.width / 2
                              : MediaQuery.of(context).size.width / 4,
                          height: MediaQuery.of(context).size.height / 20,
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
