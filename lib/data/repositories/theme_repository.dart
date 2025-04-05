import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/interfaces/theme_repository.dart';
import '../datasource/theme_data_source.dart';
import '../../core/constants/database_constants.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeDataSource _localDataSource;
  final RemoteThemeDataSource _remoteDataSource;

  ThemeRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<bool> isDarkMode() async {
    return await _localDataSource.isDarkMode();
  }

  @override
  Future<void> setDarkMode(bool isDark) async {
    await _localDataSource.setDarkMode(isDark);
  }

  @override
  Future<ColorPair> getColors() async {
    final primary = await _localDataSource.getPrimaryColor();
    final secondary = await _localDataSource.getSecondaryColor();
    return ColorPair(
      primaryColor: primary,
      secondaryColor: secondary,
    );
  }

  @override
  Future<void> setColors(
      {required Color primary, required Color secondary}) async {
    await _localDataSource.saveColors(primary, secondary);
  }

  @override
  Future<String> getLogoLink() async {
    return await _localDataSource.getLogoLink();
  }

  @override
  Future<void> setLogoLink(String url) async {
    await _localDataSource.saveLogoLink(url);
  }

  @override
  Future<String> getCustomerName() async {
    final savedName = await _localDataSource.getCustomerName();
    return savedName.isNotEmpty ? savedName : customerName;
  }

  @override
  Future<void> setCustomerName(String name) async {
    await _localDataSource.saveCustomerName(name);
  }

  @override
  Future<bool> needsRemoteRefresh() async {
    final lastRefreshTimestamp =
        await _localDataSource.getLastRefreshTimestamp();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Refresh if cache is older than 24 hours
    return now - lastRefreshTimestamp > const Duration(days: 1).inMilliseconds;
  }

  @override
  Future<void> markRefreshed() async {
    await _localDataSource
        .saveRefreshTimestamp(DateTime.now().millisecondsSinceEpoch);
  }

  /// Fetch theme settings from remote and update local storage
  /// For background refresh
  Future<void> refreshFromRemote() async {
    try {
      final remoteData = await _remoteDataSource.fetchThemeSettings();

      if (remoteData != null) {
        // Parse colors
        if (remoteData['primary_color']?.isNotEmpty ?? false) {
          final primaryColor =
              Color(int.parse(remoteData['primary_color'], radix: 16));
          final secondaryColor =
              remoteData['secondary_color']?.isNotEmpty ?? false
                  ? Color(int.parse(remoteData['secondary_color'], radix: 16))
                  : const Color(0xFF01629C);

          await setColors(primary: primaryColor, secondary: secondaryColor);
        }

        // Store logo link
        if (remoteData['logo_link']?.isNotEmpty ?? false) {
          await setLogoLink(remoteData['logo_link']);
        }
      }

      // Mark as refreshed
      await markRefreshed();
    } catch (e) {
      debugPrint('Error refreshing theme from remote: $e');
    }
  }
}
