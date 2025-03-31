import 'package:cached_network_image/cached_network_image.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons.dart';
import 'package:edconnect_admin/presentation/widgets/common/forms.dart';
import 'package:edconnect_admin/presentation/widgets/common/snackbars.dart';
import 'package:edconnect_admin/constants/database_constants.dart';
import 'package:edconnect_admin/domain/entities/registration_request.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/terms_and_conditions_checkbox.dart';
import 'package:edconnect_admin/presentation/widgets/registration_card_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({super.key, required this.showLoginPage});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  // text controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmedPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isCheckedAgreement = false;

  bool _validateFirstNameField = false;
  bool _validateLastNameField = false;
  bool _validateEmailField = false;

  List<BaseRegistrationField>? _registrationFields;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> signUp(BuildContext context) async {
    final request = RegistrationRequest(
        email: _emailController.text,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        password: _passwordController.text,
        confirmedPassword: _confirmedPasswordController.text,
        orgName: customerName,
        registrationFields: _registrationFields ?? [],
        accountType: 'Student');

    // Use the SignUpNotifier through the provider
    await ref.read(signUpNotifierProvider.notifier).signUp(request);
  }

  void handleAccountAlreadyExistsWithOtherOrg(
      List<BaseRegistrationField> registrationFields,
      BuildContext context,
      AppLocalizations localizations) async {
    final request = RegistrationRequest(
      email: _emailController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      password: _passwordController.text,
      confirmedPassword: _confirmedPasswordController.text,
      orgName: customerName,
      registrationFields: registrationFields,
      accountType: 'Student',
    );

    await ref
        .read(signUpWithExistingAuthAccountNotifierProvider.notifier)
        .signUpWithExistingAuthAccount(request);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the sign up state
    final signUpState = ref.watch(signUpNotifierProvider);
    final registrationFields = ref.watch(registrationFieldsProvider);

    // Watch theme providers
    final theme = ref.watch(appThemeProvider);

    // Handle sign up state
    ref.listen<AsyncValue<String?>>(signUpNotifierProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          errorMessage(context, error.toString());
        },
        data: (data) {
          if (data == null) {
            // Success case
            successMessage(
              context,
              AppLocalizations.of(context)!
                  .authPagesRegisterSuccessSnackbarLabel,
            );
          }
        },
      );
    });

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
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Customer Logo
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                  child: FractionallySizedBox(
                                      widthFactor: 0.7,
                                      child: theme.logoUrl != ''
                                          ? CachedNetworkImage(
                                              imageUrl: theme.logoUrl,
                                              progressIndicatorBuilder:
                                                  (context, url,
                                                          downloadProgress) =>
                                                      Center(
                                                child:
                                                    CircularProgressIndicator(
                                                        value: downloadProgress
                                                            .progress),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Center(
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
                                child: theme.isDarkMode
                                    ? Image.asset(
                                        'assets/pip_branding_dark_mode_horizontalxxxhdpi.png')
                                    : Image.asset(
                                        'assets/pip_branding_light_mode_horizontalxxxhdpi.png'),
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
                                .authPagesRegisterWelcomeLabelTwo,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(
                            height: 20,
                          ),

                          PIPOutlinedBorderInputForm(
                            validate: _validateFirstNameField,
                            width: MediaQuery.of(context).size.width,
                            controller: _firstNameController,
                            label: AppLocalizations.of(context)!
                                .globalFirstNameTextFieldHintText,
                            icon: Icons.person,
                          ),
                          const SizedBox(
                            height: 5,
                          ),

                          PIPOutlinedBorderInputForm(
                            validate: _validateLastNameField,
                            width: MediaQuery.of(context).size.width,
                            controller: _lastNameController,
                            label: AppLocalizations.of(context)!
                                .globalLastNameTextFieldHintText,
                            icon: Icons.person,
                          ),
                          const SizedBox(
                            height: 5,
                          ),

                          PIPOutlinedBorderInputForm(
                            validate: _validateEmailField,
                            width: MediaQuery.of(context).size.width,
                            controller: _emailController,
                            label:
                                AppLocalizations.of(context)!.globalEmailLabel,
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          PIPPasswordForm(
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
                          const SizedBox(
                            height: 5,
                          ),

                          PIPPasswordForm(
                              label: AppLocalizations.of(context)!
                                  .authPagesRegisterConfirmPasswordTextFieldHintText,
                              width: MediaQuery.of(context).size.width,
                              controller: _confirmedPasswordController,
                              passwordVisible: _confirmPasswordVisible,
                              onPressed: () {
                                setState(() {
                                  _confirmPasswordVisible =
                                      !_confirmPasswordVisible;
                                });
                              }),

                          TermsAndConditionsCheckbox(
                            isChecked: _isCheckedAgreement,
                            onChanged: (value) {
                              setState(() {
                                _isCheckedAgreement = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),

                          registrationFields.when(
                            loading: () => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                5,
                                (index) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  child: Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            height: 20.0,
                                            color: Colors.grey[300],
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            width: double.infinity,
                                            height: 20.0,
                                            color: Colors.grey[300],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            error: (error, stack) => Center(
                              child: Text('Error: $error'),
                            ),
                            data: (fields) {
                              if (fields.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: fields.length,
                                itemBuilder: (context, index) =>
                                    buildRegistrationCard(
                                        context, fields, index),
                              );
                            },
                          ),

                          const SizedBox(
                            height: 10,
                          ),
                          PIPResponsiveRaisedButton(
                            label: AppLocalizations.of(context)!
                                .authPagesRegisterButtonLabel,
                            onPressed: () {
                              if (signUpState.isLoading) return;

                              setState(() {
                                _validateFirstNameField =
                                    _firstNameController.text.isEmpty;
                                _validateLastNameField =
                                    _lastNameController.text.isEmpty;
                                _validateEmailField =
                                    _emailController.text.isEmpty;
                              });

                              if (_isCheckedAgreement &&
                                  !_validateFirstNameField &&
                                  !_validateLastNameField &&
                                  !_validateEmailField) {
                                signUp(context);
                              } else if (!_isCheckedAgreement) {
                                errorMessage(
                                  context,
                                  AppLocalizations.of(context)!
                                      .authPagesRegisterAcceptToSAndPrivacyPolicyErrorMessage,
                                );
                              }
                            },
                            fontWeight: FontWeight.w700,
                            width: MediaQuery.of(context).size.width < 700
                                ? MediaQuery.of(context).size.width / 2
                                : MediaQuery.of(context).size.width / 4,
                          ),

                          if (signUpState.isLoading)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),

                          const SizedBox(height: 10),

                          PIPResponsiveTextButton(
                            label: AppLocalizations.of(context)!
                                .authPagesLoginButtonLabel,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w700,
                            onPressed: widget.showLoginPage,
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
          ),
        ));
  }
}
