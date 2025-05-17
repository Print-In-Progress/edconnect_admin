import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/presentation/pages/auth_pages/user_not_found.dart';
import 'package:edconnect_admin/presentation/pages/auth_pages/verify_email_page.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_pages/auth_page.dart';
import './home_page.dart';
import '../../providers/theme_provider.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final authStatus = ref.watch(authStatusProvider);
    final userState = ref.watch(currentUserProvider);

    final authError = ref.watch(authErrorProvider);
    if (authStatus == AuthStatus.authenticating) {
      Future.delayed(const Duration(seconds: 10), () {
        if (ref.read(authStatusProvider) == AuthStatus.authenticating) {
          ref
              .read(authStatusProvider.notifier)
              .updateAuthStatus(AuthStatus.unauthenticated);
        }
      });
    }

    if (authError != null && context.mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Toaster.error(context, authError.message);
          ref.read(authErrorProvider.notifier).state = null;
        }
      });
    }
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [theme.primaryColor, theme.secondaryColor],
          ),
        ),
        child: _buildMainContent(authStatus, userState, context),
      ),
    );
  }

  Widget _buildMainContent(
      AuthStatus status, AsyncValue<AppUser?> userState, BuildContext context) {
    if (status == AuthStatus.authenticated) {
      return userState.when(
        data: (user) {
          if (user == null) {
            // If user is null, Firebase Auth isn't logged in, go to login page
            return const AuthPage();
          }

          // Check special document not found state
          if (user.isDocumentMissing) {
            return const UserNotFoundPage();
          }

          // Check for error state
          if (user.errorMessage != null) {
            return Center(child: Text('Error: ${user.errorMessage}'));
          }

          // Check for unverified state
          if (user.isUnverified) {
            return const VerifyEmailPage();
          }

          // Normal authenticated user with document
          return const HomePage();
        },
        loading: () => _buildLoadingScreen(AuthStatus.loadingUserData, context),
        error: (error, __) {
          return Center(child: Text('Authentication error: $error'));
        },
      );
    }

    // Handle other auth states
    return switch (status) {
      AuthStatus.initial ||
      AuthStatus.authenticating ||
      AuthStatus.loadingUserData =>
        _buildLoadingScreen(status, context),
      AuthStatus.unauthenticated => const AuthPage(),
      AuthStatus.error => const AuthPage(),
      // AuthStatus.authenticated is already handled above
      _ => const AuthPage(),
    };
  }

  Widget _buildLoadingScreen(AuthStatus status, BuildContext context) {
    String loadingMessage = switch (status) {
      AuthStatus.initial => 'Initializing...',
      AuthStatus.authenticating => 'Authenticating...',
      AuthStatus.loadingUserData => 'Loading user data...',
      _ => 'Loading...',
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo
          Image.asset(
            'assets/edconnect_logo_transparent.png',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 32),

          // Loading indicator with message
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                loadingMessage,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const SizedBox(height: 8),
              // Additional status text if needed
              Text(
                'Please wait...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
