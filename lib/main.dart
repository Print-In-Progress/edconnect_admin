import 'dart:ui';

import 'package:edconnect_admin/constants/database_constants.dart';
import 'package:edconnect_admin/models/providers/themeprovider.dart';
import 'package:edconnect_admin/pages/home_page/main_page.dart';
import 'package:edconnect_admin/utils/color_and_logo_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
  print('System locale: $systemLocale');

  runApp(const ProviderScope(
    child: EdConnectAdmin(),
  ));
}

class EdConnectAdmin extends ConsumerStatefulWidget {
  const EdConnectAdmin({super.key});

  @override
  ConsumerState<EdConnectAdmin> createState() => _EdConnectAdminState();
}

class _EdConnectAdminState extends ConsumerState<EdConnectAdmin> {
  @override
  void initState() {
    super.initState();
    // Call initializeColorScheme to refresh colors and logo.
    Future.microtask(() => initializeColorScheme(ref));
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final colorState = ref.watch(colorAndLogoProvider);
    final primaryColor = colorState.primaryColor;
    final secondaryColor = colorState.secondaryColor;

    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: '$customerName Admin Panel',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus
        },
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
              foregroundColor: Colors.white, iconColor: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
          ),
        ),
        colorScheme: ColorScheme.dark(
          primary: colorState.primaryColor,
          onPrimary: Colors.white,
          secondary: colorState.secondaryColor,
          onSecondary: Colors.white,
          background: Colors.grey.shade900,
          surface: Colors.grey.shade900,
          shadow: Colors.grey.shade700,
        ),
        tabBarTheme: const TabBarTheme(
          dividerColor: Colors.transparent,
          indicatorColor: Color.fromRGBO(202, 196, 208, 1),
          labelColor: Color.fromRGBO(202, 196, 208, 1),
        ),
        navigationRailTheme: const NavigationRailThemeData(
            selectedIconTheme: IconThemeData(color: Colors.white),
            unselectedIconTheme: IconThemeData(color: Colors.white),
            unselectedLabelTextStyle: TextStyle(color: Colors.white),
            selectedLabelTextStyle: TextStyle(color: Colors.white)),
        primaryColor: colorState.primaryColor,
      ),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          onPrimary: Colors.white,
          secondary: secondaryColor,
          onSecondary: Colors.white,
        ),
        // ... other light theme properties
        primaryColor: primaryColor,
      ),
      home: const MainPage(),
    );
  }
}
