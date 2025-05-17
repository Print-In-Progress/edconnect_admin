// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get globalLanguage => 'Deutsch';

  @override
  String get globalOk => 'OK';

  @override
  String get globalCancel => 'Abbrechen';

  @override
  String get globalSave => 'Speichern';

  @override
  String get globalEdit => 'Bearbeiten';

  @override
  String globalEditWithName(String name) {
    return '$name bearbeiten';
  }

  @override
  String get globalYes => 'Ja';

  @override
  String get globalWelcomeLabelSignIn => 'Melde dich an um auf dein Account zuzugreifen';

  @override
  String get globalNo => 'Nein';

  @override
  String get globalAdd => 'Hinzufügen';

  @override
  String globalUserLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Nutzer',
      one: 'Nutzer',
    );
    return '$_temp0';
  }

  @override
  String globalAddX(String name) {
    return '$name hinzufügen';
  }

  @override
  String globalFromX(String name) {
    return 'Von $name';
  }

  @override
  String get globalFiltersLabel => 'Filter';

  @override
  String get globalFilterByGroup => 'Nach Gruppen filtern';

  @override
  String get globalRequiredLabel => 'Erforderlich';

  @override
  String get globalNotRequiredLabel => 'Nicht erforderlich';

  @override
  String get globalStatisticsLabel => 'Statistiken';

  @override
  String get globalOtherLabel => 'Andere';

  @override
  String get globalEnabledLabel => 'Aktiviert';

  @override
  String get globalConfirm => 'Bestätigen';

  @override
  String get globalDelete => 'Löschen';

  @override
  String get globalActionsLabel => 'Aktionen';

  @override
  String get globalViewAllLabel => 'Alle anzeigen';

  @override
  String globalSelectX(String name) {
    return '$name auswählen';
  }

  @override
  String get globalDraft => 'Entwurf';

  @override
  String get globalPublished => 'Veröffentlicht';

  @override
  String get globalClosed => 'Geschlossen';

  @override
  String get globalLoading => 'Wird geladen...';

  @override
  String get globalReauthenticate => 'Erneute Authentifizierung erforderlich';

  @override
  String get globalEditorsLabel => 'Editoren';

  @override
  String globalDeleteConfirmationDialogWithName(String name) {
    return 'Möchten Sie diese $name wirklich löschen?';
  }

  @override
  String globalDeleteConfirmationDialogAllWithName(String name) {
    return 'Möchten Sie wirklich alle $name löschen?';
  }

  @override
  String get globalYouHaveUnsavedChanges => 'Sie haben ungespeicherte Änderungen';

  @override
  String get globaDiscard => 'Verwerfen';

  @override
  String get globalDisabledLabel => 'Deaktiviert';

  @override
  String get globalStatusLabel => 'Status';

  @override
  String get globalCreatedByLabel => 'Erstellt von';

  @override
  String get globalCreatedAtLabel => 'Erstellt am';

  @override
  String get globalTitle => 'Titel';

  @override
  String get globalTypeLabel => 'Typ';

  @override
  String get globalRetry => 'Wiederholen';

  @override
  String get globalNoGroupsSelected => 'Keine Gruppen ausgewählt';

  @override
  String get globalFeatureNotImplementedYet => 'Funktion noch nicht implementiert';

  @override
  String get globalNoUsersSelected => 'Keine Nutzer ausgewählt';

  @override
  String globalTitleWithPrefix(String prefix) {
    return '$prefix Titel';
  }

  @override
  String get globalDescription => 'Beschreibung';

  @override
  String get globalName => 'Name';

  @override
  String get globalBiologicalSexLabel => 'Geschlecht';

  @override
  String globalDescriptionWithPrefix(String prefix) {
    return '$prefix Beschreibung';
  }

  @override
  String globalSupportedFormatsWithFormats(String formats) {
    return 'Unterstützte Dateienformate: $formats';
  }

  @override
  String get globalSelectFileToImport => 'Datei zum Importieren auswählen';

  @override
  String globalImportX(String name) {
    return '$name importieren';
  }

  @override
  String get globalPreviewLabel => 'Vorschau';

  @override
  String get globalSelectPageSize => 'Seitengröße auswählen';

  @override
  String get globalEdConnectRegistrationForm => 'edConnect Registrierungsformular';

  @override
  String get globalPageSize => 'Seitengröße';

  @override
  String get globalFormCryptographicallySigned => 'Dieses Formular wurde kryptographisch vom Nutzer mit dem edConnect-System signiert.';

  @override
  String globalCreateButtonLabel(String prefix) {
    return '$prefix erstellen';
  }

  @override
  String globalLoadingWithName(String name) {
    return '$name wird geladen...';
  }

  @override
  String globalNotFoundWithName(String name) {
    return '$name nicht gefunden';
  }

  @override
  String globalNoXFound(String name) {
    return 'Keine $name gefunden';
  }

  @override
  String globalExportX(String name) {
    return '$name exportieren';
  }

  @override
  String globalDeleteAllX(String name) {
    return 'Alle $name löschen';
  }

  @override
  String globalGroupLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Gruppen',
      one: 'Gruppe',
    );
    return '$_temp0';
  }

  @override
  String get globalFilterStatus => 'Nach Status filtern';

  @override
  String get globalAdjustFilters => 'Filter anpassen, um mehr Ergebnisse zu sehen';

  @override
  String get globalClearFilters => 'Filter löschen';

  @override
  String get globalSortBy => 'Sortieren nach';

  @override
  String get globalFilterByNameAZ => 'Name A-Z';

  @override
  String get globalFilterByNameZA => 'Name Z-A';

  @override
  String get globalFilterByNewestFirst => 'Neueste zuerst';

  @override
  String get globalFilterByOldestFirst => 'Älteste zuerst';

  @override
  String get globalFilterByAlphabetical => 'Alphabetisch';

  @override
  String get globalSelectGroups => 'Gruppen auswählen';

  @override
  String get globalBasicInfo => 'Grundinformationen';

  @override
  String get globalSelectUsers => 'Benutzer auswählen';

  @override
  String get globalSelectUser => 'Benutzer auswählen';

  @override
  String get globalSearch => 'Suchen';

  @override
  String globalXSelected(num number) {
    return '$number ausgewählt';
  }

  @override
  String get globalAllLabel => 'Alle';

  @override
  String get globalSaveChangesConfirmationDialog => 'Möchten Sie diese Änderungen wirklich speichern?';

  @override
  String get globalAccessControlLabel => 'Zugriffskontrolle';

  @override
  String globalSearchWithName(String name) {
    return '$name suchen...';
  }

  @override
  String globalCreatingX(String name) {
    return '$name wird erstellt...';
  }

  @override
  String get globalExportOptions => 'Export-Optionen';

  @override
  String get globalMaleLabel => 'Männlich';

  @override
  String get globalDetailsLabel => 'Details';

  @override
  String get globalFemaleLabel => 'Weiblich';

  @override
  String get globalNonBinaryLabel => 'Nicht-binär';

  @override
  String get globalMaleLegend => 'M';

  @override
  String get globalFemaleLegend => 'W';

  @override
  String get globalNonBinaryLegend => 'NB';

  @override
  String get globalPublish => 'Veröffentlichen';

  @override
  String get globalClose => 'Schließen';

  @override
  String get globalEditorGroups => 'Editor-Gruppen';

  @override
  String get globalEditorUsers => 'Editor-Benutzer';

  @override
  String get globalRespondentGroups => 'Teilnehmer-Gruppen';

  @override
  String get globalGroupName => 'Gruppenname';

  @override
  String get globalRespondentUsers => 'Teilnehmer-Benutzer';

  @override
  String get globalClear => 'Löschen';

  @override
  String globalMintuesWithNumber(num number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Minuten',
      one: 'Minute',
    );
    return '$_temp0';
  }

  @override
  String globalSecondsWithNumber(num number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Sekunden',
      one: 'Sekunde',
    );
    return '$_temp0';
  }

  @override
  String get globalNoResults => 'Keine Ergebnisse gefunden';

  @override
  String get globalLogout => 'Abmelden';

  @override
  String get globalDeleteAccount => 'Konto löschen';

  @override
  String get globalFirstNameTextFieldHintText => 'Vorname';

  @override
  String get globalLastNameTextFieldHintText => 'Nachname';

  @override
  String get globalEmailLabel => 'E-Mail';

  @override
  String get globalLegalNotice => 'Rechtlicher Hinweis';

  @override
  String get globalSubmit => 'Absenden';

  @override
  String get globalDismiss => 'Verwerfen';

  @override
  String globalGreetingOne(String firstName) {
    return 'Hallo, $firstName!';
  }

  @override
  String globalDeleteWithName(String name) {
    return '$name löschen';
  }

  @override
  String get globalNoResponsesMatchFilter => 'Keine Antworten entsprechen dem aktuellen Filter';

  @override
  String get globalToS => 'AGBs';

  @override
  String get globalAdditionalInfoRequestedByYourOrg => 'Zusätzliche Informationen (von Ihrer Organisation angefordert)';

  @override
  String get globalBack => 'Zurück';

  @override
  String get globalBackToLogin => 'Zurück zum Login';

  @override
  String get authResetPassword => 'Passwort zurücksetzen';

  @override
  String get authLoginTitle => 'Anmelden';

  @override
  String get authSignDocument => 'Dokument unterschreiben';

  @override
  String get authSignDocumentBody => 'Ich bestätige hiermit, dass ich durch Ankreuzen dieses Kästchens und Absenden dieses Formulars meine Zustimmung zur digitalen Unterzeichnung dieses Dokuments gebe. Ich verstehe, dass meine Unterschrift sicher mit kryptografischen Techniken erstellt wird, um die Authentizität und Integrität des Dokuments zu gewährleisten. Diese Unterschrift ist rechtlich bindend, und ich bestätige, dass die angegebenen Informationen nach meinem besten Wissen und Gewissen korrekt sind.';

  @override
  String get authDocumentSigned => 'Dokument unterschrieben';

  @override
  String get authPasswordLabel => 'Passwort';

  @override
  String get authForgotPassword => 'Passwort vergessen?';

  @override
  String get authResetPasswordSendEmail => 'E-Mail senden';

  @override
  String get authResetPasswordBody => 'Bitte geben Sie Ihre E-Mail-Adresse ein, um einen Link zum Zurücksetzen Ihres Passworts zu erhalten.';

  @override
  String get authPagesRegisterConfirmPasswordTextFieldHintText => 'Passwort bestätigen';

  @override
  String get authPagesWelcomeLabelOne => 'Willkommen!';

  @override
  String get authPagesRegisterWelcomeLabelTwo => 'Erstellen Sie Ihr Konto';

  @override
  String get authPagesRegisterButtonLabel => 'Registrieren';

  @override
  String get authAccountTypeLabel => 'Kontotyp';

  @override
  String get authAccountTypePlaceholder => 'Wählen Sie Ihren Kontotyp';

  @override
  String get authVerifyEmailTitle => 'E-Mail-Adresse bestätigen';

  @override
  String get authVerifyEmailBody => 'Ein Bestätigungslink wurde an Ihre E-Mail-Adresse gesendet. Bitte prüfen Sie Ihren Posteingang und klicken Sie auf den Link, um Ihr Konto zu verifizieren.';

  @override
  String get authResendVerificationEmail => 'Bestätigungs-E-Mail erneut senden';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navHideSidebar => 'Seitenleiste ausblenden';

  @override
  String get navArticles => 'Artikel';

  @override
  String get navEvents => 'Veranstaltungen';

  @override
  String get navUsers => 'Benutzer';

  @override
  String get navComments => 'Kommentare';

  @override
  String get navDigitalLibrary => 'Digitale Bibliothek';

  @override
  String get navMedia => 'Medien';

  @override
  String get navPushNotifications => 'Push-Benachrichtigungen';

  @override
  String get navAdminSettings => 'Admin-Einstellungen';

  @override
  String get navSurveys => 'Umfragen';

  @override
  String get navSurveySorter => 'Sortiermodul';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get validationRequired => 'Dieses Feld ist erforderlich';

  @override
  String get validationError => 'Validierungsfehler';

  @override
  String get validationRequiredSnackbar => 'Bitte füllen Sie alle erforderlichen Felder aus';

  @override
  String get validationEmail => 'Bitte geben Sie eine gültige E-Mail-Adresse ein';

  @override
  String get validationSignatureMissing => 'Unterschrift ist erforderlich';

  @override
  String get validationSignatureFailed => 'Unterschriftsvalidierung fehlgeschlagen';

  @override
  String get validationTextTooShort => 'Text ist zu kurz';

  @override
  String get validationTextTooLong => 'Text ist zu lang';

  @override
  String get termsAndConditionsPrefix => 'Ich stimme den ';

  @override
  String get termsAndConditionsLinkText => 'Nutzungsbedingungen';

  @override
  String get termsAndConditionsMiddle => ' und der ';

  @override
  String get privacyPolicyLinkText => 'Datenschutzerklärung';

  @override
  String get termsAndConditionsSuffix => ' zu.';

  @override
  String get errorAccessDenied => '403 - Zugriff verweigert';

  @override
  String errorUnexpectedWithError(String error) {
    return 'Unerwarteter Fehler: $error';
  }

  @override
  String get errorCalculationFailed => 'Berechnung der Klassen fehlgeschlagen. Bitte versuchen Sie es erneut';

  @override
  String get errorInvalidCalculationParameters => 'Ungültige Berechnungsparameter. Bitte überprüfen Sie Ihre Eingaben.';

  @override
  String get errorCalculationTimeout => 'Zeitüberschreitung bei der Berechnung. Versuchen Sie, die Komplexität zu reduzieren oder das Zeitlimit zu erhöhen.';

  @override
  String get errorInsufficientClassCapacity => 'Die Gesamtklassenkapazität muss mindestens der Anzahl der Schüler entsprechen';

  @override
  String get errorCalculationServerError => 'Berechnungsserver nicht erreichbar. Bitte überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.';

  @override
  String get errorAcceptToSAndPrivacyPolicy => 'Sie müssen die Nutzungsbedingungen und die Datenschutzerklärung akzeptieren';

  @override
  String get errorAccessDeniedMessage => 'Sie haben keine Berechtigung, auf diese Seite zuzugreifen.';

  @override
  String get errorUnauthorized => 'Unautorisierter Zugriff';

  @override
  String get errorImgCouldNotBeFound => 'Bild konnte nicht gefunden werden';

  @override
  String get errorNetwork => 'Netzwerkfehler, bitte versuchen Sie es erneut';

  @override
  String get errorPagesRegisterAcceptToSAndPrivacyPolicy => 'Bitte akzeptieren Sie die Nutzungsbedingungen und die Datenschutzerklärung';

  @override
  String get errorUnexpected => 'Unerwarteter Fehler aufgetreten';

  @override
  String get errorUserNotFound => '404 - Benutzer nicht gefunden';

  @override
  String get errorSelectFile => 'Bitte wählen Sie eine Datei aus';

  @override
  String get errorSaveFailed => 'Speichern fehlgeschlagen';

  @override
  String get errorExportFailed => 'Export fehlgeschlagen';

  @override
  String errorLoadingX(String name) {
    return 'Fehler beim Laden von $name';
  }

  @override
  String get errorUserNotFoundMessage => 'Benutzer nicht gefunden. Der Benutzer wurde möglicherweise von einem Administrator gelöscht oder existiert nicht.';

  @override
  String get errorInvalidPassword => 'Ungültiges Passwort';

  @override
  String get errorPasswordMissingNumber => 'Das Passwort muss mindestens eine Zahl enthalten';

  @override
  String get errorPasswordMissingSpecial => 'Das Passwort muss mindestens ein Sonderzeichen enthalten';

  @override
  String get errorPasswordsDoNotMatch => 'Passwörter stimmen nicht überein';

  @override
  String get errorEmailAlreadyInUse => 'E-Mail wird bereits verwendet';

  @override
  String get errorGroupNotFound => 'Gruppe nicht gefunden';

  @override
  String get errorGroupUpdateFailed => 'Gruppenaktualisierung fehlgeschlagen';

  @override
  String get errorGroupDeleteFailed => 'Gruppenlöschung fehlgeschlagen';

  @override
  String get errorInvalidGroupOperation => 'Ungültige Gruppenoperation';

  @override
  String get errorUserGroupUpdateFailed => 'Aktualisierung der Benutzergruppe fehlgeschlagen';

  @override
  String get errorFileUploadFailed => 'Datei-Upload fehlgeschlagen';

  @override
  String get errorFileDownloadFailed => 'Datei-Download fehlgeschlagen';

  @override
  String get errorFileDeleteFailed => 'Dateilöschung fehlgeschlagen';

  @override
  String get errorAuthAccountAlreadyExists => 'Authentifizierungskonto existiert bereits';

  @override
  String get errorFileNotFound => 'Datei nicht gefunden';

  @override
  String get errorInvalidFileType => 'Ungültiger Dateityp';

  @override
  String get errorFileTooLarge => 'Datei zu groß';

  @override
  String errorCreateFailed(String name) {
    return 'Fehler beim Erstellen von $name';
  }

  @override
  String get errorFileListFailed => 'Abrufen der Dateiliste fehlgeschlagen';

  @override
  String get errorStorageOperationFailed => 'Speicheroperation fehlgeschlagen';

  @override
  String get successDefault => 'Erfolg';

  @override
  String get successClassesCalculated => 'Klassen erfolgreich berechnet! Gehen Sie zur Ergebnisseite, um sie anzuzeigen.';

  @override
  String get successAccountCreated => 'Konto erfolgreich erstellt!';

  @override
  String get successRegistration => 'Registrierung erfolgreich!';

  @override
  String get successEmailVerificationSent => 'Bestätigungs-E-Mail erfolgreich gesendet';

  @override
  String get successPasswordChanged => 'Passwort erfolgreich geändert';

  @override
  String get successResetPasswordEmailSent => 'E-Mail zum Zurücksetzen des Passworts erfolgreich gesendet';

  @override
  String get successEmailChanged => 'E-Mail erfolgreich geändert';

  @override
  String get successProfileUpdated => 'Profil erfolgreich aktualisiert';

  @override
  String get successDataSaved => 'Daten erfolgreich gespeichert';

  @override
  String successPublishedSuccessfullyWithName(String name) {
    return '$name erfolgreich veröffentlicht';
  }

  @override
  String successClosedSuccessfullyWithName(String name) {
    return '$name erfolgreich geschlossen';
  }

  @override
  String get successSettingsUpdated => 'Einstellungen erfolgreich aktualisiert';

  @override
  String get successExport => 'Export erfolgreich';

  @override
  String successCreatedWithPrefix(String prefix) {
    return '$prefix erfolgreich erstellt';
  }

  @override
  String successDeletedWithName(String name) {
    return '$name erfolgreich gelöscht';
  }

  @override
  String successXAdded(String name) {
    return '$name erfolgreich hinzugefügt';
  }

  @override
  String successXUpdated(String name) {
    return '$name erfolgreich aktualisiert';
  }

  @override
  String get settingsLabel => 'Einstellungen';

  @override
  String get settingsManageAccount => 'Konto verwalten';

  @override
  String get settingsChangeName => 'Namen ändern';

  @override
  String get settingsChangeEmail => 'E-Mail ändern';

  @override
  String get settingsChangePassword => 'Passwort ändern';

  @override
  String get settingsUpdateRegistrationQuestionaire => 'Registrierungsfragebogen aktualisieren';

  @override
  String get settingsAppearance => 'Erscheinungsbild';

  @override
  String get settingsDarkMode => 'Dunkler Modus';

  @override
  String get settingsDeleteDialogBody => 'Möchten Sie Ihr Konto wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get settingsNewPassword => 'Neues Passwort';

  @override
  String get mediaSelectorInsertImage => 'Bild einfügen';

  @override
  String get mediaSelectorInsertVideo => 'Video einfügen';

  @override
  String get mediaSelectorInsertAudio => 'Audio einfügen';

  @override
  String get textEditorInsertLink => 'Insert Link';

  @override
  String get textEditorInsertLinkTextToDisplay => 'Text to display';

  @override
  String get textEditorHintText => 'Start typing...';

  @override
  String get textEditorTooltipStyles => 'Text Styles';

  @override
  String get textEditorStyleMenuItemNormal => 'Normal';

  @override
  String get textEditorStyleMenuItemHeader1 => 'Header 1';

  @override
  String get textEditorStyleMenuItemHeader2 => 'Header 2';

  @override
  String get textEditorStyleMenuItemHeader3 => 'Header 3';

  @override
  String get textEditorStyleMenuItemHeader4 => 'Header 4';

  @override
  String get textEditorStyleMenuItemHeader5 => 'Header 5';

  @override
  String get textEditorStyleMenuItemHeader6 => 'Header 6';

  @override
  String get textEditorTooltipChangeFontFamily => 'Change Font Family';

  @override
  String get textEditorTooltipChangeFontSize => 'Change Font Size';

  @override
  String get textEditorTooltipBold => 'Bold';

  @override
  String get textEditorTooltipItalic => 'Italic';

  @override
  String get textEditorTooltipUnderline => 'Underline';

  @override
  String get textEditorTooltipStrikethrough => 'Strikethrough';

  @override
  String get textEditorTooltipSubscript => 'Subscript';

  @override
  String get textEditorTooltipSuperscript => 'Superscript';

  @override
  String get textEditorTooltipRemoveFormat => 'Clear Formatting';

  @override
  String get textEditorTooltipChangeFontColor => 'Font Color';

  @override
  String get textEditorTooltipChangeBackgroundColor => 'Background Color';

  @override
  String get textEditorTooltipInsertBulletedList => 'Bulleted List';

  @override
  String get textEditorTooltipInsertNumberedList => 'Numbered List';

  @override
  String get textEditorChangeListStyleButtonLabel => 'List Style';

  @override
  String get textEditorTooltipLeftAlign => 'Align Left';

  @override
  String get textEditorTooltipCenterAlign => 'Center Align';

  @override
  String get textEditorTooltipRightAlign => 'Align Right';

  @override
  String get textEditorTooltipJustifyAlign => 'Justify';

  @override
  String get textEditorTooltipIncreaseIndent => 'Increase Indent';

  @override
  String get textEditorTooltipDeacreaseIndent => 'Decrease Indent';

  @override
  String get textEditorTooltipChangeLineSpacing => 'Line Spacing';

  @override
  String get textEditorChooseColorDialogTitle => 'Choose Color';

  @override
  String get textEditorSetColorButtonLabel => 'Set Color';

  @override
  String get textEditorResetColorButtonLabel => 'Reset';

  @override
  String get textEditorListStyleMenuItemDisc => 'Disc';

  @override
  String get textEditorListStyleMenuItemDecimal => 'Decimal';

  @override
  String get textEditorListStyleMenuItemSquare => 'Square';

  @override
  String get textEditorListStyleMenuItemCircle => 'Circle';

  @override
  String get textEditorListStyleMenuItemUpperRomanNumerals => 'Upper Roman';

  @override
  String get textEditorListStyleMenuItemLowerRomanNumerals => 'Lower Roman';

  @override
  String get textEditorListStyleMenuItemUppercaseLetters => 'ABC';

  @override
  String get textEditorListStyleMenuItemLowercaseLetters => 'abc';

  @override
  String get textEditorListStyleMenuItemLowercaseClassicalGreek => 'Greek';

  @override
  String get userManagementGroupInformationLabel => 'Gruppeninformationen';

  @override
  String get userManagementMembersLabel => 'Mitglieder';

  @override
  String userManagementPermissionsLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Berechtigungen',
      one: 'Berechtigung',
      zero: 'Berechtigungen',
    );
    return '$_temp0';
  }

  @override
  String get userManagementFilterbyPermissions => 'Nach Berechtigungen filtern';

  @override
  String get userManagementAccountTypeLabelFacultyAndStaff => 'Lehrkräfte und Personal';

  @override
  String get userManagementAccountTypeLabelStudent => 'Student';

  @override
  String get userManagementAccountTypeLabelParent => 'Elternteil';

  @override
  String get userManagementNoPermissiosnAssignedToGroup => 'Keine Berechtigungen dieser Gruppe zugewiesen';

  @override
  String get userManagementNoMembersInGroup => 'Keine Mitglieder in dieser Gruppe';

  @override
  String get userManagementAssignMembersLabel => 'Mitglieder zuweisen';

  @override
  String get userManagementSelectUsersToAddToGroup => 'Wählen Sie Benutzer aus, die dieser Gruppe hinzugefügt werden sollen';

  @override
  String userManagementSelectedMembers(num count) {
    return 'Ausgewählte Mitglieder ($count)';
  }

  @override
  String userManagementSelectedPermissions(num count) {
    return 'Ausgewählte Berechtigungen ($count)';
  }

  @override
  String get userManagementSelectGroupsToAssign => 'Wählen Sie Gruppen aus, die diesem Benutzer zugewiesen werden sollen';

  @override
  String get userManagementRolesLabel => 'Rollen';

  @override
  String get userManagementNoGroupsAssignedToUser => 'Diesem Benutzer sind keine Gruppen zugewiesen';

  @override
  String get userManagementNoGroupsCreatedYet => 'Noch keine Gruppen erstellt';

  @override
  String get userManagementContentManagementLabel => 'Inhaltsverwaltung';

  @override
  String get userManagementMediaLabel => 'Medien';

  @override
  String get userManagementAssignedPermissions => 'Zugewiesene Berechtigungen';

  @override
  String get userManagementNoPermissionsFromGroups => 'Keine Berechtigungen von Gruppen';

  @override
  String get userManagementNoDirectPermissionsAssigned => 'Diesem Benutzer sind keine direkten Berechtigungen zugewiesen';

  @override
  String get userManagementAssignGroupsLabel => 'Gruppen zuweisen';

  @override
  String get userManagementPermissionsFromGroups => 'Berechtigungen aus Gruppen';

  @override
  String get userManagementNotificationsLabel => 'Benachrichtigungen';

  @override
  String get userManagementUserManagementLabel => 'Benutzerverwaltung';

  @override
  String get userManagementSurveysLabel => 'Umfragen';

  @override
  String get sortingModuleAccessControlDescription => 'Benutzer und Gruppen, die diese Umfrage bearbeiten können';

  @override
  String get sortingModuleRespondents => 'Teilnehmer';

  @override
  String get sortingModuleRespondentsDescription => 'Benutzer und Gruppen, die auf diese Umfrage antworten können';

  @override
  String get sortingModuleTotalResponsesLabel => 'Gesamtzahl der Antworten';

  @override
  String sortingSurvey(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sortierumfragen',
      one: 'Sortierumfrage',
      zero: 'Sortierumfragen',
    );
    return '$_temp0';
  }

  @override
  String sortingModulePreferences(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Präferenzen',
      one: 'Präferenz',
      zero: 'Präferenzen',
    );
    return '$_temp0';
  }

  @override
  String get sortingModuleParameters => 'Sortierparameter';

  @override
  String get sortingModuleNoResponsesYet => 'Noch keine Antworten';

  @override
  String get sortingModuleAskForBiologicalSex => 'Nach dem Geschlecht der Teilnehmer fragen';

  @override
  String get sortingModuleAskForPreferences => 'Teilnehmer nach bevorzugten Personen fragen';

  @override
  String get sortingModuleMaximumPreferencesLabel => 'Maximale Präferenzen';

  @override
  String get sortingModuleMaximumPreferencesDescription => 'Maximale Anzahl an Personen, die ausgewählt werden können';

  @override
  String get sortingModuleNoResponsesImportManuallyLabel => 'Beginnen Sie damit, Antworten manuell hinzuzufügen oder aus einer Datei zu importieren';

  @override
  String get sortingModulePublishSortingSurveyNoResponsesLabel => 'Sortierumfrage veröffentlichen, um mit der Sammlung von Antworten zu beginnen';

  @override
  String get sortingModuleParameterName => 'Parametername';

  @override
  String get sortingModuleStrategy => 'Strategie';

  @override
  String get sortingModuleStrategyDistribute => 'Gleichmäßig verteilen';

  @override
  String get sortingModuleStrategyConcentrate => 'In einer Klasse konzentrieren';

  @override
  String get sortingModuleTypeBinary => 'Binär (Ja/Nein)';

  @override
  String get sortingModuleTypeCategorical => 'Kategorisch (Text)';

  @override
  String get sortingModulePriorityLabel => 'Priorität';

  @override
  String get sortingModulePriorityDescription => 'Niedrigere Zahl bedeutet höhere Priorität (1-10)';

  @override
  String get sortingModuleOverview => 'Übersicht';

  @override
  String get sortingModuleCalculate => 'Berechnen';

  @override
  String get sortingModuleResults => 'Ergebnisse';

  @override
  String get sortingModuleCalculating => 'Wird berechnet...';

  @override
  String get sortingModuleResultsAvailable => 'Ergebnisse verfügbar';

  @override
  String get sortingModuleVariables => 'Variablen';

  @override
  String get sortingModuleProblemSize => 'Problemgröße';

  @override
  String sortingModuleNumOfStudents(num count) {
    return 'Schüler: $count';
  }

  @override
  String sortingModuleNumOfClasses(num count) {
    return 'Klassen: $count';
  }

  @override
  String sortingModuleNumOfParams(num count) {
    return 'Parameter: $count';
  }

  @override
  String sortingModuleNumOfPreferences(num count) {
    return 'Präferenzen: $count';
  }

  @override
  String get sortingModuleMaxCalcTimeLabel => 'Max. Berechnungszeit';

  @override
  String get sortingModuleMaxCalcTimeDescription => 'Der Algorithmus versucht, die beste Lösung innerhalb dieses Zeitlimits zu finden. In den meisten Fällen wird er schneller eine Lösung finden.';

  @override
  String get sortingModuleTimeLimitLabel => 'Zeitlimit';

  @override
  String get sortingModuleCalculateLoadingLabel => 'Der Algorithmus versucht, die beste Lösung innerhalb dieses Zeitlimits zu finden. In den meisten Fällen wird er schneller eine Lösung finden.';

  @override
  String get sortingModuleClassConfigLabel => 'Klassenkonfiguration';

  @override
  String get sortingModuleClassesLabel => 'Klassen';

  @override
  String get sortingModuleSelectClassesToExportLabel => 'Klassen zum Exportieren auswählen';

  @override
  String get sortingModuleSelectAllClasses => 'Alle Klassen auswählen';

  @override
  String get sortingModuleDistributionSettingsLabel => 'Verteilungseinstellungen';

  @override
  String get sortingModuleDistributeByBiologicalSexLabel => 'Nach Geschlecht verteilen';

  @override
  String get sortingModuleDistributeByBiologicalSexDescription => 'Versuch einer gleichmäßigen Verteilung von Männern/Frauen in jeder Klasse';

  @override
  String get sortingModuleCapacityInfoLabel => 'Kapazitätsinformationen';

  @override
  String get sortingModuleClassNameLabel => 'Klassenname';

  @override
  String get sortingModuleIncludeGender => 'Geschlecht einschließen';

  @override
  String get sortingModuleSelectInfoToIncludeLabel => 'Informationen auswählen, die einbezogen werden sollen';

  @override
  String get sortingModuleClassSizeLabel => 'Klassengröße';

  @override
  String get sortingModuleNewClassNameLabel => 'Neuer Klassenname';

  @override
  String get sortingModuleNewClassNameHint => 'Leer lassen für automatische Nummerierung';

  @override
  String sortingModuleTotalCapacity(num count) {
    return 'Gesamtkapazität: $count Schüler';
  }

  @override
  String sortingModuleMinimumRequiredCapacity(num count) {
    return 'Mindestkapazität: $count Schüler';
  }

  @override
  String get sortingModuleWarningMinimumRequiredCapacity => 'Warnung: Die Gesamtkapazität muss mindestens der Anzahl der Schüler entsprechen';

  @override
  String get sortingModuleCapacityRecommendation => 'Empfehlung: Erwägen Sie, in jeder Klasse Platz für mindestens einen zusätzlichen Schüler für bessere Algorithmusflexibilität zu lassen.';

  @override
  String get sortingModuleParametersConfigurationTitle => 'Parameterkonfiguration';

  @override
  String get sortingModuleParameterDisabledDescription => 'Dieser Parameter ist deaktiviert und wird bei Berechnungen nicht verwendet';

  @override
  String get sortingModuleCloseSurveyBeforeCalculating => 'Bitte schließen Sie die Umfrage, bevor Sie den Berechnungsprozess starten.';

  @override
  String get sortingModuleNoParamsDefined => 'Keine Parameter definiert';

  @override
  String get sortingModuleAddManuallyLabel => 'Manuell hinzufügen';

  @override
  String sortingModuleResponses(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Antworten',
      one: 'Antwort',
      zero: 'Antworten',
    );
    return '$_temp0';
  }

  @override
  String get sortingModuleTotalNumOfPreferences => 'Gesamtzahl der Präferenzen';

  @override
  String sortingModuleMaxPreferencesPerUser(num count) {
    return '(max. $count pro Benutzer)';
  }

  @override
  String get sortingModuleManualEntry => 'Manuelle Eingabe';

  @override
  String sortingModuleSelectUpToXPreferencesLabel(num count) {
    return 'Bis zu $count Präferenzen auswählen';
  }

  @override
  String get sortingModuleDuplicateNamesFound => 'Doppelte Namen gefunden';

  @override
  String sortingModuleUniqueValuesCount(num count) {
    return 'Eindeutige Werte: $count';
  }

  @override
  String get sortingModuleSelectInformationToIncludeLabel => 'Informationen auswählen, die einbezogen werden sollen';

  @override
  String sortingModuleNumOfStudentsForPdf(num count) {
    return '($count Schüler)';
  }

  @override
  String get sortingModuleExportIncludeSummaryStatistics => 'Zusammenfassende Statistiken einschließen';

  @override
  String get sortingModuleIncludeClassStatistics => 'Klassenstatistiken einschließen';

  @override
  String get sortingModuleResponseStatisticsLabel => 'Antwortstatistiken';

  @override
  String get sortingModuleParameterDistributionLabel => 'Parameterverteilung';

  @override
  String get sortingModuleIndividualResponsesLabel => 'Einzelne Antworten';

  @override
  String get sortingModuleSelectAtLeastOneClassForExport => 'Bitte wählen Sie mindestens eine Klasse zum Exportieren aus';

  @override
  String get sortingModuleAdditionalParametersLabel => 'Zusätzliche Parameter';

  @override
  String get sortingModuleSelectAllParameters => 'Alle Parameter auswählen';

  @override
  String get sortingModuleClassDistributionResultsLabel => 'Klassenverteilungsergebnisse';

  @override
  String get sortingModuleTotalStudentsLabel => 'Gesamtzahl der Schüler';

  @override
  String get sortingModuleTotalClassesLabel => 'Gesamtzahl der Klassen';

  @override
  String get sortingModuleAverageStudentsPerClassLabel => 'Durchschnittliche Schüler pro Klasse';

  @override
  String get sortingModulePreferencesSatisfiedLabel => 'Erfüllte Präferenzen';

  @override
  String get sortingModuleStudentsWithAtLeastOnePreferenceSatisfiedLabel => 'Schüler mit mindestens einer erfüllten Präferenz';

  @override
  String get sortingModuleShowClassStatisticssLabel => 'Klassenstatistiken anzeigen';

  @override
  String get sortingModuleNoPreferencesSelected => 'Keine Präferenzen ausgewählt';

  @override
  String get sortingModuleDragStudentsHerePlaceholder => 'Schüler hierher ziehen, um sie zur Klasse hinzuzufügen';

  @override
  String get sortingModuleNoCalcResults => 'Keine Berechnungsergebnisse verfügbar';

  @override
  String get sortingModuleGoToCalculate => 'Zur Berechnung gehen';
}
