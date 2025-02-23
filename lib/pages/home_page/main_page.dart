import 'package:edconnect_admin/models/providers/themeprovider.dart';
import 'package:edconnect_admin/models/providers/user_provider.dart';
import 'package:edconnect_admin/pages/auth_pages/auth_page.dart';
import 'package:edconnect_admin/pages/auth_pages/user_not_found.dart';
import 'package:edconnect_admin/pages/auth_pages/verify_email_page.dart';
import 'package:edconnect_admin/pages/home_page/home_page.dart';
import 'package:edconnect_admin/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  Widget build(BuildContext context) {
    final colorState = ref.watch(colorAndLogoProvider);
    final authStatus = ref.watch(authStatusProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              colorState.primaryColor,
              colorState.secondaryColor,
            ],
          ),
        ),
        child: switch (authStatus) {
          AuthStatus.initial =>
            const Center(child: CircularProgressIndicator()),
          AuthStatus.unauthenticated => const AuthPage(),
          AuthStatus.unverified => const VerifyEmailPage(),
          AuthStatus.authenticated => ref.watch(currentUserProvider).when(
                data: (user) => user != null
                    ? HomePage(permissions: user.permissions)
                    : const UserNotFoundPage(),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) =>
                    const Center(child: Text('Error loading user data')),
              ),
        },
      ),
    );
  }
}
