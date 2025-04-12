import 'dart:async';

import 'package:edconnect_admin/core/design_system/app_theme.dart';
import 'package:edconnect_admin/data/datasource/firebase/firebase_theme_data_source.dart';
import 'package:edconnect_admin/data/datasource/local/shared_prefs_theme_data_source.dart';
import 'package:edconnect_admin/data/repositories/theme_repository.dart';
import 'package:edconnect_admin/domain/usecases/theme_usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/app_theme.dart';
import '../../core/interfaces/theme_repository.dart';
import '../../data/datasource/theme_data_source.dart';
import 'package:flutter/material.dart';

// ----------------- DATA LAYER PROVIDERS -----------------

// DataSource Providers
final themeLocalDataSourceProvider = Provider<ThemeDataSource>((ref) {
  return SharedPrefsThemeDataSource();
});

final themeRemoteDataSourceProvider = Provider<RemoteThemeDataSource>((ref) {
  return FirebaseRemoteThemeDataSource();
});

// Repository Provider
final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepositoryImpl(
    ref.read(themeLocalDataSourceProvider),
    ref.read(themeRemoteDataSourceProvider),
  );
});

// ----------------- DOMAIN LAYER PROVIDERS -----------------

// Use Case Providers
final getAppThemeUseCaseProvider = Provider<GetAppThemeUseCase>((ref) {
  return GetAppThemeUseCase(ref.read(themeRepositoryProvider));
});

final setDarkModeUseCaseProvider = Provider<SetDarkModeUseCase>((ref) {
  return SetDarkModeUseCase(ref.read(themeRepositoryProvider));
});

final setThemeColorsUseCaseProvider = Provider<SetThemeColorsUseCase>((ref) {
  return SetThemeColorsUseCase(ref.read(themeRepositoryProvider));
});

final setLogoUrlUseCaseProvider = Provider<SetLogoUrlUseCase>((ref) {
  return SetLogoUrlUseCase(ref.read(themeRepositoryProvider));
});

final refreshRemoteThemeUseCaseProvider =
    Provider<RefreshRemoteThemeUseCase>((ref) {
  return RefreshRemoteThemeUseCase(ref.read(themeRepositoryProvider));
});

// ----------------- PRESENTATION LAYER PROVIDERS -----------------

// App Theme state notifier
class AppThemeNotifier extends StateNotifier<AppTheme> {
  final GetAppThemeUseCase _getAppThemeUseCase;
  final SetDarkModeUseCase _setDarkModeUseCase;
  final SetThemeColorsUseCase _setThemeColorsUseCase;
  final SetLogoUrlUseCase _setLogoUrlUseCase;
  final RefreshRemoteThemeUseCase _refreshRemoteThemeUseCase;

  AppThemeNotifier({
    required GetAppThemeUseCase getAppThemeUseCase,
    required SetDarkModeUseCase setDarkModeUseCase,
    required SetThemeColorsUseCase setThemeColorsUseCase,
    required SetLogoUrlUseCase setLogoUrlUseCase,
    required RefreshRemoteThemeUseCase refreshRemoteThemeUseCase,
  })  : _getAppThemeUseCase = getAppThemeUseCase,
        _setDarkModeUseCase = setDarkModeUseCase,
        _setThemeColorsUseCase = setThemeColorsUseCase,
        _setLogoUrlUseCase = setLogoUrlUseCase,
        _refreshRemoteThemeUseCase = refreshRemoteThemeUseCase,
        super(const AppTheme()) {
    _init();
  }

  Future<void> _init() async {
    try {
      // Load theme from local storage
      final theme = await _getAppThemeUseCase.execute();
      state = theme;

      // Asynchronously refresh from remote if needed
      unawaited(_refreshRemoteThemeUseCase.execute().then((_) async {
        // Reload theme after refresh
        final refreshedTheme = await _getAppThemeUseCase.execute();
        state = refreshedTheme;
      }));
    } catch (e) {
      print('Error initializing theme: $e');
    }
  }

  Future<void> setDarkMode(bool isDarkMode) async {
    await _setDarkModeUseCase.execute(isDarkMode);
    state = state.copyWith(isDarkMode: isDarkMode);
  }

  Future<void> setPrimaryColor(Color color) async {
    await _setThemeColorsUseCase.execute(
      primaryColor: color,
      secondaryColor: state.secondaryColor,
    );
    state = state.copyWith(primaryColor: color);
  }

  Future<void> setSecondaryColor(Color color) async {
    await _setThemeColorsUseCase.execute(
      primaryColor: state.primaryColor,
      secondaryColor: color,
    );
    state = state.copyWith(secondaryColor: color);
  }

  Future<void> setLogoUrl(String url) async {
    await _setLogoUrlUseCase.execute(url);
    state = state.copyWith(logoUrl: url);
  }

  // Helper method to convert hex string to Color
  Color hexToColor(String hexCode) {
    return Color(int.parse(hexCode));
  }
}

// Main theme state provider
final appThemeProvider =
    StateNotifierProvider<AppThemeNotifier, AppTheme>((ref) {
  return AppThemeNotifier(
    getAppThemeUseCase: ref.read(getAppThemeUseCaseProvider),
    setDarkModeUseCase: ref.read(setDarkModeUseCaseProvider),
    setThemeColorsUseCase: ref.read(setThemeColorsUseCaseProvider),
    setLogoUrlUseCase: ref.read(setLogoUrlUseCaseProvider),
    refreshRemoteThemeUseCase: ref.read(refreshRemoteThemeUseCaseProvider),
  );
});

// Theme data provider for Material app
final themeDataProvider = Provider<ThemeData>((ref) {
  final appTheme = ref.watch(appThemeProvider);
  return appTheme.isDarkMode
      ? AppThemeData.darkTheme(appTheme)
      : AppThemeData.lightTheme(appTheme);
});
