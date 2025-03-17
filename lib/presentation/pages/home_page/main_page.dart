import 'package:edconnect_admin/presentation/providers/user_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth_pages/auth_page.dart';
import '../auth_pages/verify_email_page.dart';
import './home_page.dart';
import '../../providers/theme_provider.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [theme.primaryColor, theme.secondaryColor],
          ),
        ),
        child: ref.watch(currentUserProvider).when(
              data: (user) {
                if (user == null) {
                  return const AuthPage();
                }

                // Check for unverified state
                if (user.isUnverified) {
                  return const VerifyEmailPage();
                }

                // Regular authenticated user
                return const HomePage();
              },
              loading: () => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/edconnect_logo_transparent.png',
                      width: 200,
                    ),
                    const SizedBox(height: 24),
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
      ),
    );
  }
}
