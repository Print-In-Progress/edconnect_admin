class ParameterFormatter {
  // Prevent instantiation
  ParameterFormatter._();

  static String formatParameterName(String value) {
    return value
        .trim() // Remove leading/trailing spaces
        .toLowerCase() // Make case insensitive
        .replaceAll(RegExp(r'\s+'), '_') // Replace spaces with underscores
        .replaceAll(RegExp(r'[^a-z0-9_äöüß]'),
            '') // Allow german umlauts, a-z, digits and underscore
        .replaceAll(RegExp(r'_+'), '_') // Replace multiple underscores
        .replaceAll(
            RegExp(r'^_|_$'), ''); // Remove leading/trailing underscores
  }

  static String foratParameterNameForDisplay(String name) {
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }

  static String formatParameterType(String? type) {
    switch (type) {
      case 'binary':
        return 'Binary (Yes/No)';
      case 'categorical':
        return 'Categorical (Text)';
      default:
        return type ?? 'Unknown';
    }
  }

  static String formatParameterStrategy(String? strategy) {
    switch (strategy) {
      case 'distribute':
        return 'Distribute Evenly';
      case 'concentrate':
        return 'Concentrate Together';
      default:
        return strategy ?? 'Unknown';
    }
  }

  static String formatSexForDisplay(String? sex) {
    switch (sex) {
      case 'm':
        return 'Male';
      case 'f':
        return 'Female';
      case 'nb':
        return 'Non-Binary';
      default:
        return 'Unknown';
    }
  }
}
