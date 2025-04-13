import 'package:cached_network_image/cached_network_image.dart';
import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/core/validation/validators/text_field_validator.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/pages/auth_pages/forgot_password_page.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/snackbars.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
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
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Rely on the login notifier to handle auth stages
    if (_formKey.currentState!.validate()) {
      try {
        await ref.read(loginStateProvider.notifier).login(
              _emailController.text,
              _passwordController.text,
            );
      } catch (e) {
        if (!mounted) return;
        Toaster.error(
          context,
          e.toString(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    final loginState = ref.watch(loginStateProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 700;

    // Calculate card width - more generous on small screens
    final cardWidth = isSmallScreen
        ? screenWidth * 0.95 // 95% of screen width on small screens
        : 600.0; // Fixed width on larger screens

    // Listen for errors
    ref.listen<AsyncValue<void>>(loginStateProvider, (_, state) {
      state.whenOrNull(
        error: (error, _) => errorMessage(context, error.toString()),
      );
    });

    return Scaffold(
        backgroundColor: theme.isDarkMode
            ? Foundations.darkColors.background
            : Foundations.colors.background,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: cardWidth,
                      child: BaseCard(
                        variant: CardVariant.elevated,
                        padding: EdgeInsets.symmetric(
                          horizontal: Foundations.spacing.xl4,
                          vertical: Foundations.spacing.xl5,
                        ),
                        backgroundColor: theme.isDarkMode
                            ? Foundations.darkColors.surface
                            : Foundations.colors.surface,
                        margin: EdgeInsets.zero,
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Large branding section
                              _buildEnhancedLogoSection(
                                  theme.logoUrl, theme.isDarkMode),
                              SizedBox(height: Foundations.spacing.xl4),

                              // Welcome text - larger and bolder
                              Text(
                                AppLocalizations.of(context)!
                                    .authPagesWelcomeLabelOne,
                                style: TextStyle(
                                  fontSize: Foundations.typography.xl4,
                                  fontWeight: Foundations.typography.bold,
                                  color: theme.isDarkMode
                                      ? Foundations.darkColors.textPrimary
                                      : Foundations.colors.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: Foundations.spacing.md),

                              // Subtitle
                              Text(
                                "Sign in to access your account",
                                style: TextStyle(
                                  fontSize: Foundations.typography.lg,
                                  color: theme.isDarkMode
                                      ? Foundations.darkColors.textMuted
                                      : Foundations.colors.textMuted,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: Foundations.spacing.xl4),

                              BaseInput(
                                controller: _emailController,
                                label: AppLocalizations.of(context)!
                                    .globalEmailLabel,
                                hint: AppLocalizations.of(context)!
                                    .globalEmailLabel,
                                leadingIcon: Icons.email_outlined,
                                isRequired: true,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                type: TextFieldType.email,
                                keyboardType: TextInputType.emailAddress,
                                variant: InputVariant.default_,
                                size: InputSize.large,
                                fullWidth: true,
                              ),
                              SizedBox(height: Foundations.spacing.xl),

                              // Password input
                              BaseInput(
                                controller: _passwordController,
                                label: AppLocalizations.of(context)!
                                    .authPasswordLabel,
                                hint: AppLocalizations.of(context)!
                                    .authPasswordLabel,
                                leadingIcon: Icons.lock_outline,
                                isRequired: true,
                                obscureText: !_passwordVisible,
                                variant: InputVariant.default_,
                                size: InputSize.large,
                                fullWidth: true,
                                trailingIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: theme.isDarkMode
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

                              // Forgot password link
                              Align(
                                alignment: Alignment.centerRight,
                                child: BaseButton(
                                  label: AppLocalizations.of(context)!
                                      .authForgotPassword,
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          settings: const RouteSettings(
                                              name: 'Change Password Screen'),
                                          builder: (context) =>
                                              const ForgotPasswordPage(),
                                        ));
                                  },
                                  variant: ButtonVariant.text,
                                  size: ButtonSize.medium,
                                ),
                              ),
                              SizedBox(height: Foundations.spacing.xl4),

                              // Sign in button - large
                              BaseButton(
                                label: AppLocalizations.of(context)!
                                    .authLoginTitle,
                                onPressed:
                                    loginState.isLoading ? null : _handleLogin,
                                variant: ButtonVariant.filled,
                                size: ButtonSize.large,
                                isLoading: loginState.isLoading,
                                fullWidth: true,
                              ),
                              SizedBox(height: Foundations.spacing.xl2),

                              // Register button - large and prominent
                              BaseButton(
                                label: AppLocalizations.of(context)!
                                    .authPagesRegisterButtonLabel,
                                onPressed: widget.showRegisterPage,
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
                          top: Foundations.spacing.xl3,
                          bottom: Foundations.spacing.lg),
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
        ));
  }
}

Widget _buildEnhancedLogoSection(String logoUrl, bool isDarkMode) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Expanded(
        flex: 1,
        child: SizedBox(
          height: 120,
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
        height: 80,
        width: 1,
        margin: EdgeInsets.symmetric(horizontal: Foundations.spacing.lg),
        color: isDarkMode
            ? Foundations.darkColors.border
            : Foundations.colors.border.withValues(alpha: 0.6),
      ),
      Expanded(
        flex: 1,
        child: SizedBox(
          height: 120,
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
