abstract class LocalizationRepository {
  Map<String, String> getRegistrationPdfStrings();
  Map<String, String> getSortingModulePdfStrings();
  Map<String, String> getSortingModuleStrings();
  Map<String, String> getGlobalStrings();
  Map<String, String> getPermissionsStrings();

  String formatParameterizedString(String key, Map<String, String> parameters);
}
