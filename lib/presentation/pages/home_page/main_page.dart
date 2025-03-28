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
        child: _buildMainContent(authStatus),
      ),
    );
  }

  Widget _buildMainContent(AuthStatus status) {
    return switch (status) {
      AuthStatus.initial ||
      AuthStatus.authenticating ||
      AuthStatus.loadingUserData =>
        const Center(
          child: CircularProgressIndicator(),
        ),
      AuthStatus.authenticated => const HomePage(),
      AuthStatus.unauthenticated => const AuthPage(),
      AuthStatus.error => const AuthPage(),
    };
  }
}
