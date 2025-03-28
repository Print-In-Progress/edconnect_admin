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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [theme.primaryColor, theme.secondaryColor],
          ),
        ),
        child: _buildMainContent(authStatus, context),
      ),
    );
  }

  Widget _buildMainContent(AuthStatus status, BuildContext context) {
    return switch (status) {
      AuthStatus.initial ||
      AuthStatus.authenticating ||
      AuthStatus.loadingUserData =>
        _buildLoadingScreen(status, context),
      AuthStatus.authenticated => const HomePage(),
      AuthStatus.unauthenticated => const AuthPage(),
      AuthStatus.error => const AuthPage(),
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
