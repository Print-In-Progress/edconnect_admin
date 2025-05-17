import 'package:edconnect_admin/core/interfaces/localization_repository.dart';

class LocalizationServiceImpl implements LocalizationRepository {
  String _locale;

  LocalizationServiceImpl(this._locale);
  void updateLocale(String locale) {
    _locale = locale;
  }

  @override
  Map<String, String> getRegistrationPdfStrings() {
    // Return hardcoded strings based on locale
    switch (_locale) {
      case 'de':
        return {
          'globalEdConnectRegistrationForm': 'edConnect Registrierungsformular',
          'globalFirstNameTextFieldHintText': 'Vorname',
          'globalLastNameTextFieldHintText': 'Nachname',
          'globalEmailLabel': 'E-Mail',
          'globalFormCryptographicallySigned':
              'Dieses Formular wurde vom Benutzer kryptografisch signiert.',
          'globalYes': 'Ja',
          'globalNo': 'Nein',
        };
      default:
        return {
          'globalEdConnectRegistrationForm': 'edConnect Registration Form',
          'globalFirstNameTextFieldHintText': 'First Name',
          'globalLastNameTextFieldHintText': 'Last Name',
          'globalEmailLabel': 'Email',
          'globalFormCryptographicallySigned':
              'This form was cryptographically signed by the user using the edConnect System.',
          'globalYes': 'Yes',
          'globalNo': 'No',
        };
    }
  }

  @override
  Map<String, String> getSortingModulePdfStrings() {
    switch (_locale) {
      case 'de':
        return {
          'sortingModuleClassDistributionResultsLabel':
              'Klassenverteilungsergebnisse',
          'sortingModuleSummaryStatisticsLabel': 'Statistik',
          'sortingModuleTotalClassesLabel': 'Gesamtanzahl der Klassen',
          'sortingModuleTotalStudentsLabel': 'Gesamtanzahl der Schüler',
          'sortingModuleAverageStudentsPerClassLabel':
              'Durchschnittliche Schüler pro Klasse',
          'sortingModulePreferencesSatisfiedLabel': 'Präferenzen erfüllt',
          'sortingModuleStudentsWithAtLeastOnePreferenceSatisfiedLabel':
              'Schüler mit mindestens einer erfüllten Präferenz',
          'sortingModulePreferencesStatisticsLabel': 'Statistik',
          'sortingModuleParametersLabel': 'Sortierparameter',
          'sortingModuleParameterDistributionLabel': 'Parameterverteilung',
          'globalName': 'Name',
          'globalBiologicalSexLabel': 'Biologisches Geschlecht',
          'globalMaleLabel': 'Männlich',
          'globalFemaleLabel': 'Weiblich',
          'globalNonBinaryLabel': 'Nicht-binär',
          'globalYes': 'Ja',
          'globalNo': 'Nein',
          'sortingModuleNumOfStudents': 'Schüler: {count}',
          'sortingModulePageXofY': 'Seite {currentPage} von {totalPages}',
          'sortingModuleStudentXToYOfZ':
              'Schüler {currentPage} bis {totalPages} von {count}',
        };
      default:
        return {
          'sortingModuleClassDistributionResultsLabel':
              'Class Distribution Results',
          'sortingModuleSummaryStatisticsLabel': 'Summary Statistics',
          'sortingModuleTotalClassesLabel': 'Total Classes',
          'sortingModuleTotalStudentsLabel': 'Total Students',
          'sortingModuleAverageStudentsPerClassLabel':
              'Average Students per Class',
          'sortingModulePreferencesSatisfiedLabel': 'Preferences Satisfied',
          'sortingModuleStudentsWithAtLeastOnePreferenceSatisfiedLabel':
              'Students with at least one preference satisfied',
          'sortingModulePreferencesStatisticsLabel': 'Statistics',
          'sortingModuleParametersLabel': 'Sorting Parameters',
          'sortingModuleParameterDistributionLabel': 'Parameter Distribution',
          'globalName': 'Name',
          'globalBiologicalSexLabel': 'Biological Sex',
          'globalMaleLabel': 'Male',
          'globalFemaleLabel': 'Female',
          'globalNonBinaryLabel': 'Non-binary',
          'globalYes': 'Yes',
          'globalNo': 'No',
          'sortingModuleNumOfStudents': 'Students: {count}',
          'sortingModulePageXofY': 'Page {currentPage} of {totalPages}',
          'sortingModuleStudentXToYOfZ':
              'Students {currentPage} to {totalPages} of {count}',
        };
    }
  }

  @override
  Map<String, String> getGlobalStrings() {
    switch (_locale) {
      case 'de':
        return {
          'globalFemaleLabel': 'Weiblich',
          'globalMaleLabel': 'Männlich',
          'globalNonBinaryLabel': 'Nicht-binär',
        };
      default:
        return {
          'globalFemaleLabel': 'Female',
          'globalMaleLabel': 'Male',
          'globalNonBinaryLabel': 'Non-binary',
        };
    }
  }

  @override
  Map<String, String> getSortingModuleStrings() {
    switch (_locale) {
      case 'de':
        return {
          'sortingModuleStrategyDistribute': 'Gleichmäßig verteilen',
          'sortingModuleStrategyConcentrate': 'In einer Klasse konzentrieren',
          'sortingModuleParameterTypeBinary': 'Binär (Ja/Nein)',
          'sortingModuleParameterTypeCategorical': 'Kategorisch (Text)',
        };

      default:
        return {
          'sortingModuleStrategyDistribute': 'Distribute Evenly',
          'sortingModuleStrategyConcentrate': 'Concentrate in one Class',
          'sortingModuleParameterTypeBinary': 'Binary (Yes/No)',
          'sortingModuleParameterTypeCategorical': 'Categorical (Text)',
        };
    }
  }

  @override
  Map<String, String> getPermissionsStrings() {
    switch (_locale) {
      case 'de':
        return {
          'userManagementPermissionsAdministrator': 'Administrator',
          'userManagementPermissionsAdministratorDescription':
              'Vollzugriff auf alle Funktionen und Einstellungen',
          'userManagementPermissionsAuthor': 'Autor',
          'userManagementPermissionsAuthorDescription':
              'Kann Inhalte erstellen und verwalten',
          'userManagementPermissionsCreateArticles': 'Artikel erstellen',
          'userManagementPermissionsCreateArticlesDescription':
              'Kann Artikel erstellen, verwalten und löschen',
          'userManagementPermissionsEditArticles': 'Artikel bearbeiten',
          'userManagementPermissionsEditArticlesDescription':
              'Kann bestehende Artikel bearbeiten',
          'userManagementPermissionsCreateEvents': 'Veranstaltungen erstellen',
          'userManagementPermissionsCreateEventsDescription':
              'Kann Veranstaltungen erstellen, verwalten und löschen',
          'userManagementPermissionsEditEvents': 'Veranstaltungen bearbeiten',
          'userManagementPermissionsEditEventsDescription':
              'Kann bestehende Veranstaltungen bearbeiten',
          'userManagementPermissionsCreateSurveys': 'Umfragen erstellen',
          'userManagementPermissionsCreateSurveysDescription':
              'Kann Umfragen erstellen, verwalten und löschen',
          'userManagementPermissionsEditSurveys': 'Umfragen bearbeiten',
          'userManagementPermissionsEditSurveysDescription':
              'Kann bestehende Umfragen bearbeiten',
          'userManagementPermissionsUserManagement': 'Benutzerverwaltung',
          'userManagementPermissionsUserManagementDescription':
              'Kann Benutzer verwalten, Gruppen erstellen und Berechtigungen verwalten',
          'userManagementFileManagement': 'Dateiverwaltung',
          'userManagementFileManagementDescription':
              'Kann alle öffentlichen Dateien verwalten und darauf zugreifen',
          'userManagementPermissionsDigitalLibrary': 'Digitale Bibliothek',
          'userManagementPermissionsDigitalLibraryDescription':
              'Kann auf die digitale Bibliothek zugreifen und diese verwalten',
          'userManagementPermissionsPushNotifications':
              'Push-Benachrichtigungen',
          'userManagementPermissionsPushNotificationsDescription':
              'Kann Push-Benachrichtigungen senden',
        };
      default:
        return {
          'userManagementPermissionsAdministrator': 'Administrator',
          'userManagementPermissionsAdministratorDescription':
              'Full access to all features and settings',
          'userManagementPermissionsAuthor': 'Author',
          'userManagementPermissionsAuthorDescription':
              'Can create and manage content',
          'userManagementPermissionsCreateArticles': 'Create Articles',
          'userManagementPermissionsCreateArticlesDescription':
              'Can create, manage and delete articles',
          'userManagementPermissionsEditArticles': 'Edit Articles',
          'userManagementPermissionsEditArticlesDescription':
              'Can modify existing articles',
          'userManagementPermissionsCreateEvents': 'Create Events',
          'userManagementPermissionsCreateEventsDescription':
              'Can create, manage and delete events',
          'userManagementPermissionsEditEvents': 'Edit Events',
          'userManagementPermissionsEditEventsDescription':
              'Can modify existing events',
          'userManagementPermissionsCreateSurveys': 'Create Surveys',
          'userManagementPermissionsCreateSurveysDescription':
              'Can create, manage and delete surveys',
          'userManagementPermissionsEditSurveys': 'Edit Surveys',
          'userManagementPermissionsEditSurveysDescription':
              'Can modify existing surveys',
          'userManagementPermissionsUserManagement': 'User Management',
          'userManagementPermissionsUserManagementDescription':
              'Can manage users, create groups and manage their permissions',
          'userManagementFileManagement': 'File Management',
          'userManagementFileManagementDescription':
              'Can manage and access all public files',
          'userManagementPermissionsDigitalLibrary': 'Digital Library',
          'userManagementPermissionsDigitalLibraryDescription':
              'Can access and manage digital library',
          'userManagementPermissionsPushNotifications': 'Push Notifications',
          'userManagementPermissionsPushNotificationsDescription':
              'Can send push notifications',
        };
    }
  }

  @override
  Map<String, String> getErrorStrings() {
    switch (_locale) {
      case 'de':
        return {
          'errorUserNotFound': 'Nutzer nicht gefunden',
          'errorInvalidEmail': 'Ungültige E-Mail-Adresse',
          'errorInvalidPassword': 'Ungültiges Passwort',
          'errorEmailAlreadyInUse': 'E-Mail-Adresse wird bereits verwendet',
          'errorUnexpected': 'Unerwarteter Fehler aufgetreten',
        };
      default:
        return {
          'errorUserNotFound': 'User not found',
          'errorInvalidEmail': 'Invalid email address',
          'errorInvalidPassword': 'Invalid password',
          'errorEmailAlreadyInUse': 'Email address already in use',
          'errorUnexpected': 'An unexpected error occurred',
        };
    }
  }

  @override
  String formatParameterizedString(String key, Map<String, dynamic> params) {
    String template;

    final sortingStrings = getSortingModulePdfStrings();
    if (sortingStrings.containsKey(key)) {
      template = sortingStrings[key]!;
    } else if (getRegistrationPdfStrings().containsKey(key)) {
      template = getRegistrationPdfStrings()[key]!;
    } else {
      return key;
    }

    if (params.isNotEmpty) {
      String result = template;
      params.forEach((name, value) {
        result = result.replaceAll('{$name}', value.toString());
      });
      return result;
    }

    return template;
  }
}
