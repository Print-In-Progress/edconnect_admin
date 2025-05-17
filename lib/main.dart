import 'dart:ui';
import 'package:edconnect_admin/core/constants/database_constants.dart';
import 'package:edconnect_admin/core/providers/interface_providers.dart';
import 'package:edconnect_admin/core/routing/app_routes.dart';
import 'package:edconnect_admin/data/repositories/localization_repository_impl.dart';
import 'package:edconnect_admin/presentation/pages/home_page/main_page.dart';
import 'package:edconnect_admin/presentation/providers/state_providers.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

    final platformLocale = PlatformDispatcher.instance.locale;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appLocaleProvider.notifier).updateLocale(platformLocale);

      final localizationService =
          ref.read(localizationRepositoryProvider) as LocalizationServiceImpl;
      localizationService.updateLocale(platformLocale.languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeData = ref.watch(themeDataProvider);
    final theme = ref.watch(appThemeProvider);
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      title: '$customerName Admin Panel',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRoutes.onGenerateRoute,
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
