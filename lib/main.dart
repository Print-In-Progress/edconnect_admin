import 'dart:ui';
import 'package:edconnect_admin/constants/database_constants.dart';
import 'package:edconnect_admin/presentation/pages/home_page/main_page.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
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

  // final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
  // debugPrint('System locale: $systemLocale');

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
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeDataProvider);
    final theme = ref.watch(appThemeProvider);
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
      themeMode: theme.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      darkTheme: themeData,
      theme: themeData,
      home: const MainPage(),
    );
  }
}
