import 'package:cached_network_image/cached_network_image.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/errors/domain_exception.dart';
import 'package:edconnect_admin/core/errors/error_messages.dart';
import 'package:edconnect_admin/core/validation/validators/text_field_validator.dart';
import 'package:edconnect_admin/domain/services/url_service.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/checkbox.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/core/constants/database_constants.dart';
import 'package:edconnect_admin/domain/entities/registration_request.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:edconnect_admin/presentation/widgets/registration_card_builder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
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
  final _formKey = GlobalKey<FormState>();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isCheckedAgreement = false;

  String? selectedAccountType;

  List<BaseRegistrationField>? _registrationFields;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmedPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isCheckedAgreement) {
      Toaster.error(
        context,
        AppLocalizations.of(context)!
            .errorPagesRegisterAcceptToSAndPrivacyPolicy,
      );
      return;
    }

    final request = RegistrationRequest(
      email: _emailController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      password: _passwordController.text,
      confirmedPassword: _confirmedPasswordController.text,
      orgName: customerName,
      registrationFields: _registrationFields ?? [],
      accountType: selectedAccountType ?? 'student',
    );

    await ref.read(signUpNotifierProvider.notifier).signUp(request);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the sign up state
    final signUpState = ref.watch(signUpNotifierProvider);
    final registrationFields = ref.watch(registrationFieldsProvider);

    // Watch theme providers
    final theme = ref.watch(appThemeProvider);
    final isDarkMode = theme.isDarkMode;
    final l10n = AppLocalizations.of(context)!;

    // Screen size calculations for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 700;

    // Calculate card width - responsive sizing
    final cardWidth = isSmallScreen
        ? screenWidth * 0.95 // 95% of screen width on small screens
        : 700.0; // Fixed width on larger screens

    // Handle sign up state
    ref.listen<AsyncValue<void>>(signUpNotifierProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) {
          if (error is DomainException) {
            Toaster.error(
              context,
              error.getLocalizedMessage(context),
            );
          } else {
            Toaster.error(
              context,
              AppLocalizations.of(context)!.errorUnexpected,
            );
          }
        },
        data: (_) {
          Toaster.success(
            context,
            AppLocalizations.of(context)!.successRegistration,
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: isDarkMode
          ? Foundations.darkColors.background
          : Foundations.colors.background,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: cardWidth,
                    child: BaseCard(
                      variant: CardVariant.elevated,
                      padding: EdgeInsets.symmetric(
                        horizontal: Foundations.spacing.xl3,
                        vertical: Foundations.spacing.xl3,
                      ),
                      backgroundColor: isDarkMode
                          ? Foundations.darkColors.surface
                          : Foundations.colors.surface,
                      margin: EdgeInsets.zero,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo section
                            _buildEnhancedLogoSection(
                                theme.logoUrl, isDarkMode),
                            SizedBox(height: Foundations.spacing.xl2),

                            // Welcome text
                            Text(
                              l10n.authPagesWelcomeLabelOne,
                              style: TextStyle(
                                fontSize: Foundations.typography.xl3,
                                fontWeight: Foundations.typography.bold,
                                color: isDarkMode
                                    ? Foundations.darkColors.textPrimary
                                    : Foundations.colors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: Foundations.spacing.md),

                            // Subtitle
                            Text(
                              l10n.authPagesRegisterWelcomeLabelTwo,
                              style: TextStyle(
                                fontSize: Foundations.typography.lg,
                                color: isDarkMode
                                    ? Foundations.darkColors.textMuted
                                    : Foundations.colors.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: Foundations.spacing.xl2),

                            // Personal information section
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: BaseInput(
                                    controller: _firstNameController,
                                    label:
                                        l10n.globalFirstNameTextFieldHintText,
                                    hint: l10n.globalFirstNameTextFieldHintText,
                                    leadingIcon: Icons.person_outline,
                                    isRequired: true,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    type: TextFieldType.text,
                                    variant: InputVariant.default_,
                                    size: InputSize.medium,
                                  ),
                                ),
                                SizedBox(width: Foundations.spacing.lg),
                                Expanded(
                                  child: BaseInput(
                                    controller: _lastNameController,
                                    label: l10n.globalLastNameTextFieldHintText,
                                    hint: l10n.globalLastNameTextFieldHintText,
                                    leadingIcon: Icons.person_outline,
                                    isRequired: true,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    type: TextFieldType.text,
                                    variant: InputVariant.default_,
                                    size: InputSize.medium,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: Foundations.spacing.lg),

                            // Email input
                            BaseInput(
                              controller: _emailController,
                              label: l10n.globalEmailLabel,
                              hint: l10n.globalEmailLabel,
                              leadingIcon: Icons.email_outlined,
                              isRequired: true,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              type: TextFieldType.email,
                              keyboardType: TextInputType.emailAddress,
                              variant: InputVariant.default_,
                              size: InputSize.medium,
                            ),
                            SizedBox(height: Foundations.spacing.lg),

                            // Password input
                            BaseInput(
                              controller: _passwordController,
                              label: l10n.authPasswordLabel,
                              hint: l10n.authPasswordLabel,
                              leadingIcon: Icons.lock_outline,
                              isRequired: true,
                              obscureText: !_passwordVisible,
                              variant: InputVariant.default_,
                              size: InputSize.medium,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              type: TextFieldType.password,
                              minLength: 6,
                              trailingIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: isDarkMode
                                      ? Foundations.darkColors.textMuted
                                      : Foundations.colors.textMuted,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: Foundations.spacing.lg),

                            // Confirm password input
                            BaseInput(
                              controller: _confirmedPasswordController,
                              label: l10n
                                  .authPagesRegisterConfirmPasswordTextFieldHintText,
                              hint: l10n
                                  .authPagesRegisterConfirmPasswordTextFieldHintText,
                              leadingIcon: Icons.lock_outline,
                              isRequired: true,
                              obscureText: !_confirmPasswordVisible,
                              variant: InputVariant.default_,
                              size: InputSize.medium,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              type: TextFieldType.password,
                              trailingIcon: IconButton(
                                icon: Icon(
                                  _confirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: isDarkMode
                                      ? Foundations.darkColors.textMuted
                                      : Foundations.colors.textMuted,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _confirmPasswordVisible =
                                        !_confirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            SizedBox(height: Foundations.spacing.lg),

                            BaseSelect<String>(
                              label: 'Account Type',
                              hint: 'Select your account type',
                              isRequired: true,
                              size: SelectSize.large,
                              options: [
                                SelectOption(
                                    value: 'student', label: 'Student'),
                                SelectOption(value: 'parent', label: 'Parent'),
                                SelectOption(
                                    value: 'faculty', label: 'Faculty'),
                              ],
                              value: selectedAccountType,
                              onChanged: (value) {
                                setState(() {
                                  selectedAccountType = value;
                                });
                              },
                            ),
                            SizedBox(height: Foundations.spacing.lg),
                            // Terms and conditions checkbox
                            BaseCheckbox(
                              value: _isCheckedAgreement,
                              onChanged: (value) {
                                setState(() {
                                  _isCheckedAgreement = value ?? false;
                                });
                              },
                              size: CheckboxSize.medium,
                              child: RichText(
                                  text: TextSpan(children: [
                                TextSpan(
                                  text: l10n.termsAndConditionsPrefix,
                                  style: TextStyle(
                                    fontSize: Foundations.typography.sm,
                                    color: isDarkMode
                                        ? Foundations.darkColors.textPrimary
                                        : Foundations.colors.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: l10n.globalToS,
                                  style: TextStyle(
                                    fontSize: Foundations.typography.sm,
                                    color: Foundations.colors.info,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      UrlService.launchWebUrl(
                                          'https://printinprogress.net/terms');
                                    },
                                ),
                                TextSpan(
                                  text: l10n.termsAndConditionsMiddle,
                                  style: TextStyle(
                                    fontSize: Foundations.typography.sm,
                                    color: isDarkMode
                                        ? Foundations.darkColors.textPrimary
                                        : Foundations.colors.textPrimary,
                                  ),
                                ),
                                TextSpan(
                                  text: l10n.privacyPolicyLinkText,
                                  style: TextStyle(
                                    fontSize: Foundations.typography.sm,
                                    color: Foundations.colors.info,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      UrlService.launchWebUrl(
                                          'https://printinprogress.net/privacy');
                                    },
                                ),
                              ])),
                            ),
                            // Additional registration fields
                            registrationFields.when(
                              loading: () => _buildSkeletonFields(),
                              error: (error, stack) => Text(
                                'Error: $error',
                                style:
                                    TextStyle(color: Foundations.colors.error),
                              ),
                              data: (fields) {
                                _registrationFields = fields;

                                if (fields.isEmpty) {
                                  return const SizedBox.shrink();
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: Foundations.spacing.lg),
                                    Text(
                                      'Additional Information (Requested by your organization)',
                                      style: TextStyle(
                                        fontSize: Foundations.typography.lg,
                                        fontWeight:
                                            Foundations.typography.semibold,
                                        color: isDarkMode
                                            ? Foundations.darkColors.textPrimary
                                            : Foundations.colors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: Foundations.spacing.md),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: fields.length,
                                      separatorBuilder: (_, __) => SizedBox(
                                          height: Foundations.spacing.md),
                                      itemBuilder: (context, index) =>
                                          buildRegistrationCard(context, fields,
                                              index, theme.isDarkMode),
                                    ),
                                  ],
                                );
                              },
                            ),

                            SizedBox(height: Foundations.spacing.xl2),

                            // Register button
                            BaseButton(
                              label: l10n.authPagesRegisterButtonLabel,
                              onPressed: signUpState.isLoading
                                  ? null
                                  : () => signUp(context),
                              variant: ButtonVariant.filled,
                              size: ButtonSize.large,
                              isLoading: signUpState.isLoading,
                              fullWidth: true,
                            ),
                            SizedBox(height: Foundations.spacing.lg),

                            // Login link
                            BaseButton(
                              label: l10n.authLoginTitle,
                              onPressed: widget.showLoginPage,
                              variant: ButtonVariant.outlined,
                              size: ButtonSize.large,
                              fullWidth: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Footer branding
                  Padding(
                    padding: EdgeInsets.only(
                      top: Foundations.spacing.xl2,
                      bottom: Foundations.spacing.lg,
                    ),
                    child: Text(
                      "Powered by Print In Progress © ${DateTime.now().year}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: Foundations.typography.base,
                        fontWeight: Foundations.typography.medium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonFields() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: Foundations.spacing.lg),
        Container(
          width: 200,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.2),
            borderRadius: Foundations.borders.md,
          ),
        ),
        SizedBox(height: Foundations.spacing.lg),
        ...List.generate(
          3,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: Foundations.spacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: Foundations.borders.sm,
                  ),
                ),
                SizedBox(height: Foundations.spacing.xs),
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: Foundations.borders.md,
                    border: Border.all(
                      color: Colors.grey.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

Widget _buildEnhancedLogoSection(String logoUrl, bool isDarkMode) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Expanded(
        flex: 1,
        child: SizedBox(
          height: 100,
          child: logoUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: logoUrl,
                  fit: BoxFit.contain,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      Center(
                    child: CircularProgressIndicator(
                        value: downloadProgress.progress),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Text(
                        AppLocalizations.of(context)!.errorImgCouldNotBeFound),
                  ),
                )
              : Image.asset('assets/edconnect_logo.png', fit: BoxFit.contain),
        ),
      ),
      Container(
        height: 70,
        width: 1,
        margin: EdgeInsets.symmetric(horizontal: Foundations.spacing.lg),
        color: isDarkMode
            ? Foundations.darkColors.border
            : Foundations.colors.border.withValues(alpha: 0.6),
      ),
      Expanded(
        flex: 1,
        child: SizedBox(
          height: 100,
          child: Image.asset(
            isDarkMode
                ? 'assets/pip_branding_dark_mode_verticalxxxhdpi.png'
                : 'assets/pip_branding_light_mode_verticalxxxhdpi.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    ],
  );
}
