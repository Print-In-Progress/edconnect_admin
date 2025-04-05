import 'package:edconnect_admin/data/repositories/theme_repository.dart';
import 'package:flutter/material.dart';

import '../../../core/models/app_theme.dart';
import '../../../core/interfaces/theme_repository.dart';

class GetAppThemeUseCase {
  final ThemeRepository _themeRepository;

  GetAppThemeUseCase(this._themeRepository);

  Future<AppTheme> execute() async {
    final isDark = await _themeRepository.isDarkMode();
    final colors = await _themeRepository.getColors();
    final logoUrl = await _themeRepository.getLogoLink();
    final customerName = await _themeRepository.getCustomerName();

    return AppTheme(
      isDarkMode: isDark,
      primaryColor: colors.primaryColor,
      secondaryColor: colors.secondaryColor,
      logoUrl: logoUrl,
      customerName: customerName,
    );
  }
}

class SetDarkModeUseCase {
  final ThemeRepository _themeRepository;

  SetDarkModeUseCase(this._themeRepository);

  Future<void> execute(bool isDarkMode) async {
    await _themeRepository.setDarkMode(isDarkMode);
  }
}

class SetThemeColorsUseCase {
  final ThemeRepository _themeRepository;

  SetThemeColorsUseCase(this._themeRepository);

  Future<void> execute({
    required Color primaryColor,
    required Color secondaryColor,
  }) async {
    await _themeRepository.setColors(
      primary: primaryColor,
      secondary: secondaryColor,
    );
  }
}

class SetLogoUrlUseCase {
  final ThemeRepository _themeRepository;

  SetLogoUrlUseCase(this._themeRepository);

  Future<void> execute(String url) async {
    await _themeRepository.setLogoLink(url);
  }
}

class RefreshRemoteThemeUseCase {
  final ThemeRepository _themeRepository;

  RefreshRemoteThemeUseCase(this._themeRepository);

  Future<void> execute() async {
    final needsRefresh = await _themeRepository.needsRemoteRefresh();

    if (needsRefresh) {
      if (_themeRepository is ThemeRepositoryImpl) {
        await (_themeRepository).refreshFromRemote();
      }
    }
  }
}
