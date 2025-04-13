import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/presentation/pages/auth_pages/user_not_found.dart';
import 'package:edconnect_admin/presentation/pages/auth_pages/verify_email_page.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
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
    // If authenticated, check if user document exists
    if (status == AuthStatus.authenticated) {
      return userState.when(
        data: (user) {
          print('Main page received user: $user');

          if (user == null) {
            print('User is null, redirecting to AuthPage');
            // If user is null, Firebase Auth isn't logged in, go to login page
            return const AuthPage();
          }

          // Check special document not found state
          if (user.isDocumentMissing) {
            print('Document missing, redirecting to UserNotFoundPage');
            return const UserNotFoundPage();
          }

          // Check for error state
          if (user.errorMessage != null) {
            print('Error in user data: ${user.errorMessage}');
            return Center(child: Text('Error: ${user.errorMessage}'));
          }

          // Check for unverified state
          if (user.isUnverified) {
            print('User not verified, redirecting to verify page');
            return const VerifyEmailPage();
          }

          // Normal authenticated user with document
          print('User authenticated and document exists');
          return const HomePage();
        },
        loading: () => _buildLoadingScreen(AuthStatus.loadingUserData, context),
        error: (error, __) {
          print('Error in userState: $error');
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
