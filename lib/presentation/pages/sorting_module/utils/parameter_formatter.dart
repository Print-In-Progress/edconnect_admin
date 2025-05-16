import 'package:edconnect_admin/core/interfaces/localization_repository.dart';

class ParameterFormatter {
  ParameterFormatter._();

  static String formatParameterName(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^a-z0-9_äöüß]'), '')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^_|_$'), '');
  }

  static String formatParameterNameForDisplay(String name) {
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  static String formatParameterType(
      String? type, LocalizationRepository localizations) {
    final Map<String, String> localizedStrings =
        localizations.getSortingModuleStrings();
    switch (type) {
      case 'binary':
        return localizedStrings['soringModuleParameterTypeBinary'] ??
            'Binary (Yes/No)';
      case 'categorical':
        return localizedStrings['soringModuleParameterTypeCategorical'] ??
            'Categorical (Text)';
      default:
        return type ?? 'Unknown';
    }
  }

  static String formatParameterStrategy(
      String? strategy, LocalizationRepository localizations) {
    final Map<String, String> localizedStrings =
        localizations.getSortingModuleStrings();
    switch (strategy) {
      case 'distribute':
        return localizedStrings['sortingModuleStrategyDistribute'] ??
            'Distribute Evenly';
      case 'concentrate':
        return localizedStrings['sortingModuleStrategyConcentrate'] ??
            'Concentrate Together';
      default:
        return strategy ?? 'Unknown';
    }
  }

  static String formatSexForDisplay(
      String? sex, LocalizationRepository localizations) {
    final Map<String, String> localizedStrings =
        localizations.getGlobalStrings();
    switch (sex) {
      case 'm':
        return localizedStrings['globalMaleLabel'] ?? 'Male';
      case 'f':
        return localizedStrings['globalFemaleLabel'] ?? 'Female';
      case 'nb':
        return localizedStrings['globalNonBinaryLabel'] ?? 'Non-binary';
      default:
        return 'Unknown';
    }
  }
}
