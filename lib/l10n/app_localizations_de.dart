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
  String get globalCancel => 'Cancel';

  @override
  String get globalSave => 'Save';

  @override
  String get globalEdit => 'Edit';

  @override
  String globalEditWithName(String name) {
    return 'Edit $name';
  }

  @override
  String get globalYes => 'Yes';

  @override
  String get globalNo => 'No';

  @override
  String get globalAdd => 'Add';

  @override
  String globalUserLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Users',
      one: 'User',
    );
    return '$_temp0';
  }

  @override
  String globalAddX(String name) {
    return 'Add $name';
  }

  @override
  String globalFromX(String name) {
    return 'From $name';
  }

  @override
  String get globalFiltersLabel => 'Filters';

  @override
  String get globalFilterByGroup => 'Filter by group';

  @override
  String get globalRequiredLabel => 'Required';

  @override
  String get globalNotRequiredLabel => 'Not Required';

  @override
  String get globalStatisticsLabel => 'Statistics';

  @override
  String get globalOtherLabel => 'Other';

  @override
  String get globalEnabledLabel => 'Enabled';

  @override
  String get globalConfirm => 'Confirm';

  @override
  String get globalDelete => 'Delete';

  @override
  String get globalActionsLabel => 'Actions';

  @override
  String get globalViewAllLabel => 'View All';

  @override
  String globalSelectX(String name) {
    return 'Select $name';
  }

  @override
  String get globalDraft => 'Draft';

  @override
  String get globalPublished => 'Published';

  @override
  String get globalClosed => 'Closed';

  @override
  String get globalLoading => 'Loading...';

  @override
  String get globalReauthenticate => 'Re-authentification required';

  @override
  String get globalEditorsLabel => 'Editors';

  @override
  String globalDeleteConfirmationDialogWithName(String name) {
    return 'Are you sure you want to delete this $name?';
  }

  @override
  String globalDeleteConfirmationDialogAllWithName(String name) {
    return 'Are you sure you want to delete all $name?';
  }

  @override
  String get globalYouHaveUnsavedChanges => 'You have unsaved changes';

  @override
  String get globaDiscard => 'Discard';

  @override
  String get globalDisabledLabel => 'Disabled';

  @override
  String get globalStatusLabel => 'Status';

  @override
  String get globalCreatedByLabel => 'Created by';

  @override
  String get globalCreatedAtLabel => 'Created at';

  @override
  String get globalTitle => 'Title';

  @override
  String get globalTypeLabel => 'Type';

  @override
  String get globalRetry => 'Retry';

  @override
  String get globalNoGroupsSelected => 'No groups selected';

  @override
  String get globalFeatureNotImplementedYet => 'Feature not implemented yet';

  @override
  String get globalNoUsersSelected => 'No users selected';

  @override
  String globalTitleWithPrefix(String prefix) {
    return '$prefix Title';
  }

  @override
  String get globalDescription => 'Description';

  @override
  String get globalName => 'Name';

  @override
  String get globalBiologicalSexLabel => 'Biological Sex';

  @override
  String globalDescriptionWithPrefix(String prefix) {
    return '$prefix Description';
  }

  @override
  String globalSupportedFormatsWithFormats(String formats) {
    return 'Supported formats: $formats';
  }

  @override
  String get globalSelectFileToImport => 'Select file to import';

  @override
  String globalImportX(String name) {
    return 'Import $name';
  }

  @override
  String get globalPreviewLabel => 'Preview';

  @override
  String get globalSelectPageSize => 'Select page size';

  @override
  String get globalEdConnectRegistrationForm => 'edConnect Registration Form';

  @override
  String get globalPageSize => 'Page size';

  @override
  String get globalFormCryptographicallySigned => 'This form was cryptographically signed by the user using the edConnect System.';

  @override
  String globalCreateButtonLabel(String prefix) {
    return 'Create $prefix';
  }

  @override
  String globalLoadingWithName(String name) {
    return 'Loading $name...';
  }

  @override
  String globalNotFoundWithName(String name) {
    return '$name not found';
  }

  @override
  String globalNoXFound(String name) {
    return 'No $name found';
  }

  @override
  String globalExportX(String name) {
    return 'Export $name';
  }

  @override
  String globalDeleteAllX(String name) {
    return 'Delete All $name';
  }

  @override
  String globalGroupLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Groups',
      one: 'Group',
    );
    return '$_temp0';
  }

  @override
  String get globalFilterStatus => 'Filter by status';

  @override
  String get globalAdjustFilters => 'Adjust filters to see more results';

  @override
  String get globalClearFilters => 'Clear filters';

  @override
  String get globalSortBy => 'Sort by';

  @override
  String get globalFilterByNameAZ => 'Name A-Z';

  @override
  String get globalFilterByNameZA => 'Name Z-A';

  @override
  String get globalFilterByNewestFirst => 'Newest first';

  @override
  String get globalFilterByOldestFirst => 'Oldest first';

  @override
  String get globalFilterByAlphabetical => 'Alphabetical';

  @override
  String get globalSelectGroups => 'Select groups';

  @override
  String get globalBasicInfo => 'Basic Information';

  @override
  String get globalSelectUsers => 'Select Users';

  @override
  String get globalSelectUser => 'Select User';

  @override
  String get globalSearch => 'Search';

  @override
  String globalXSelected(num number) {
    return '$number selected';
  }

  @override
  String get globalAllLabel => 'All';

  @override
  String get globalSaveChangesConfirmationDialog => 'Are you sure you want to save these changes?';

  @override
  String get globalAccessControlLabel => 'Access Control';

  @override
  String globalSearchWithName(String name) {
    return 'Search $name ...';
  }

  @override
  String globalCreatingX(String name) {
    return 'Creating $name...';
  }

  @override
  String get globalExportOptions => 'Export Options';

  @override
  String get globalMaleLabel => 'Male';

  @override
  String get globalDetailsLabel => 'Details';

  @override
  String get globalFemaleLabel => 'Female';

  @override
  String get globalNonBinaryLabel => 'Non-binary';

  @override
  String get globalMaleLegend => 'M';

  @override
  String get globalFemaleLegend => 'F';

  @override
  String get globalNonBinaryLegend => 'NB';

  @override
  String get globalPublish => 'Publish';

  @override
  String get globalClose => 'Close';

  @override
  String get globalEditorGroups => 'Editor Groups';

  @override
  String get globalEditorUsers => 'Editor Users';

  @override
  String get globalRespondentGroups => 'Respondent Groups';

  @override
  String get globalGroupName => 'Group Name';

  @override
  String get globalRespondentUsers => 'Respondent Users';

  @override
  String get globalClear => 'Clear';

  @override
  String globalMintuesWithNumber(num number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'minutes',
      one: 'minute',
    );
    return '$_temp0';
  }

  @override
  String globalSecondsWithNumber(num number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'seconds',
      one: 'second',
    );
    return '$_temp0';
  }

  @override
  String get globalNoResults => 'No results found';

  @override
  String get globalLogout => 'Logout';

  @override
  String get globalDeleteAccount => 'Delete Account';

  @override
  String get globalFirstNameTextFieldHintText => 'First Name';

  @override
  String get globalLastNameTextFieldHintText => 'Last Name';

  @override
  String get globalEmailLabel => 'Email';

  @override
  String get globalLegalNotice => 'Legal Notice';

  @override
  String get globalSubmit => 'Submit';

  @override
  String get globalDismiss => 'Dismiss';

  @override
  String globalGreetingOne(String firstName) {
    return 'Hi, $firstName!';
  }

  @override
  String globalDeleteWithName(String name) {
    return 'Delete $name';
  }

  @override
  String get globalNoResponsesMatchFilter => 'No responses match the current filter';

  @override
  String get globalToS => 'Terms of Service';

  @override
  String get globalBack => 'Back';

  @override
  String get globalBackToLogin => 'Back to Login';

  @override
  String get authResetPassword => 'Reset Password';

  @override
  String get authLoginTitle => 'Login';

  @override
  String get authSignDocument => 'Sign Document';

  @override
  String get authSignDocumentBody => 'I hereby confirm that by checking this box and submitting this form, I give my consent to digitally sign this document. I understand that my signature will be generated securely using cryptographic techniques to ensure the authenticity and integrity of the document. This signature is legally binding and I certify that the information provided is correct to the best of my knowledge and belief.';

  @override
  String get authDocumentSigned => 'Document Signed';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authForgotPassword => 'Forgot Password?';

  @override
  String get authResetPasswordSendEmail => 'Send Reset Password Email';

  @override
  String get authResetPasswordBody => 'Please enter your email address to receive a link to reset your password.';

  @override
  String get authPagesRegisterConfirmPasswordTextFieldHintText => 'Confirm Password';

  @override
  String get authPagesWelcomeLabelOne => 'Welcome!';

  @override
  String get authPagesRegisterWelcomeLabelTwo => 'Create your account';

  @override
  String get authPagesRegisterButtonLabel => 'Register';

  @override
  String get authVerifyEmailTitle => 'Verify your email address';

  @override
  String get authVerifyEmailBody => 'A verification link has been sent to your email address. Please check your inbox and click the link to verify your account.';

  @override
  String get authResendVerificationEmail => 'Resend Verification Email';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navHideSidebar => 'Hide Sidebar';

  @override
  String get navArticles => 'Articles';

  @override
  String get navEvents => 'Events';

  @override
  String get navUsers => 'Users';

  @override
  String get navComments => 'Comments';

  @override
  String get navDigitalLibrary => 'Digital Library';

  @override
  String get navMedia => 'Media';

  @override
  String get navPushNotifications => 'Push Notifications';

  @override
  String get navAdminSettings => 'Admin Settings';

  @override
  String get navSurveys => 'Surveys';

  @override
  String get navSurveySorter => 'Survey Sorter';

  @override
  String get navSettings => 'Settings';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationError => 'Validation error';

  @override
  String get validationRequiredSnackbar => 'Please fill in all required fields';

  @override
  String get validationEmail => 'Please enter a valid email address';

  @override
  String get validationSignatureMissing => 'Signature is required';

  @override
  String get validationSignatureFailed => 'Signature validation failed';

  @override
  String get validationTextTooShort => 'Text is too short';

  @override
  String get validationTextTooLong => 'Text is too long';

  @override
  String get termsAndConditionsPrefix => 'I agree to the ';

  @override
  String get termsAndConditionsLinkText => 'Terms & Conditions';

  @override
  String get termsAndConditionsMiddle => ' and ';

  @override
  String get privacyPolicyLinkText => 'Privacy Policy';

  @override
  String get termsAndConditionsSuffix => '.';

  @override
  String get errorAccessDenied => '403 - Access Denied';

  @override
  String errorUnexpectedWithError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get errorCalculationFailed => 'Failed to calculate classes. Please try again';

  @override
  String get errorInvalidCalculationParameters => 'Invalid calculation parameters. Please check your inputs.';

  @override
  String get errorCalculationTimeout => 'Calculation timed out. Try reducing complexity or increasing time limit.';

  @override
  String get errorInsufficientClassCapacity => 'Total class capacity must be at least equal to the number of students';

  @override
  String get errorCalculationServerError => 'Unable to reach calculation server. Please check your connection and try again.';

  @override
  String get errorAcceptToSAndPrivacyPolicy => 'You must accept the Terms & Conditions and Privacy Policy';

  @override
  String get errorAccessDeniedMessage => 'You do not have permission to access this page.';

  @override
  String get errorUnauthorized => 'Unauthorized Access';

  @override
  String get errorImgCouldNotBeFound => 'Image could not be found';

  @override
  String get errorNetwork => 'Network error, please try again';

  @override
  String get errorPagesRegisterAcceptToSAndPrivacyPolicy => 'Please accept the Terms & Conditions and Privacy Policy';

  @override
  String get errorUnexpected => 'Unexpected error occurred';

  @override
  String get errorUserNotFound => 'User not found';

  @override
  String get errorSelectFile => 'Please select a file';

  @override
  String get errorSaveFailed => 'Save failed';

  @override
  String get errorExportFailed => 'Export failed';

  @override
  String errorLoadingX(String name) {
    return 'Error loading $name';
  }

  @override
  String get errorUserNotFoundMessage => 'User not found. The user may have been deleted by an administrator or does not exist.';

  @override
  String get errorInvalidPassword => 'Invalid password';

  @override
  String get errorPasswordMissingNumber => 'Password must contain at least one number';

  @override
  String get errorPasswordMissingSpecial => 'Password must contain at least one special character';

  @override
  String get errorPasswordsDoNotMatch => 'Passwords do not match';

  @override
  String get errorEmailAlreadyInUse => 'Email already in use';

  @override
  String get errorGroupNotFound => 'Group not found';

  @override
  String get errorGroupUpdateFailed => 'Group update failed';

  @override
  String get errorGroupDeleteFailed => 'Group deletion failed';

  @override
  String get errorInvalidGroupOperation => 'Invalid group operation';

  @override
  String get errorUserGroupUpdateFailed => 'User group update failed';

  @override
  String get errorFileUploadFailed => 'File upload failed';

  @override
  String get errorFileDownloadFailed => 'File download failed';

  @override
  String get errorFileDeleteFailed => 'File deletion failed';

  @override
  String get errorAuthAccountAlreadyExists => 'Auth account already exists';

  @override
  String get errorFileNotFound => 'File not found';

  @override
  String get errorInvalidFileType => 'Invalid file type';

  @override
  String get errorFileTooLarge => 'File too large';

  @override
  String errorCreateFailed(String name) {
    return 'Failed to create $name';
  }

  @override
  String get errorFileListFailed => 'File list retrieval failed';

  @override
  String get errorStorageOperationFailed => 'Storage operation failed';

  @override
  String get successDefault => 'Success';

  @override
  String get successClassesCalculated => 'Classes calculated successfully! Navigate to results page to view them.';

  @override
  String get successAccountCreated => 'Account created successfully!';

  @override
  String get successRegistration => 'Registration successful!';

  @override
  String get successEmailVerificationSent => 'Verification email sent successfully';

  @override
  String get successPasswordChanged => 'Password changed successfully';

  @override
  String get successResetPasswordEmailSent => 'Reset password email sent successfully';

  @override
  String get successEmailChanged => 'Email changed successfully';

  @override
  String get successProfileUpdated => 'Profile updated successfully';

  @override
  String get successDataSaved => 'Data saved successfully';

  @override
  String successPublishedSuccessfullyWithName(String name) {
    return '$name published successfully';
  }

  @override
  String successClosedSuccessfullyWithName(String name) {
    return '$name closed successfully';
  }

  @override
  String get successSettingsUpdated => 'Settings updated successfully';

  @override
  String get successExport => 'Export successful';

  @override
  String successCreatedWithPrefix(String prefix) {
    return '$prefix created successfully';
  }

  @override
  String successDeletedWithName(String name) {
    return '$name deleted successfully';
  }

  @override
  String successXAdded(String name) {
    return '$name added successfully';
  }

  @override
  String successXUpdated(String name) {
    return '$name updated successfully';
  }

  @override
  String get settingsLabel => 'Settings';

  @override
  String get settingsManageAccount => 'Manage Account';

  @override
  String get settingsChangeName => 'Change Name';

  @override
  String get settingsChangeEmail => 'Change Email';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsUpdateRegistrationQuestionaire => 'Update Registration Questionnaire';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsDeleteDialogBody => 'Are you sure you want to delete your account? This action cannot be undone.';

  @override
  String get settingsNewPassword => 'New Password';

  @override
  String get mediaSelectorInsertImage => 'Insert Image';

  @override
  String get mediaSelectorInsertVideo => 'Insert Video';

  @override
  String get mediaSelectorInsertAudio => 'Insert Audio';

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
  String get userManagementGroupInformationLabel => 'Group Information';

  @override
  String get userManagementMembersLabel => 'Members';

  @override
  String userManagementPermissionsLabel(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Permissions',
      one: 'Permission',
      zero: 'Permissions',
    );
    return '$_temp0';
  }

  @override
  String get userManagementFilterbyPermissions => 'Filter by Permissions';

  @override
  String get userManagementAccountTypeLabelFacultyAndStaff => 'Faculty & Staff';

  @override
  String get userManagementAccountTypeLabelStudent => 'Student';

  @override
  String get userManagementAccountTypeLabelParent => 'Parent';

  @override
  String get userManagementNoPermissiosnAssignedToGroup => 'No permissions assigned to this group';

  @override
  String get userManagementNoMembersInGroup => 'No members in this group';

  @override
  String get userManagementAssignMembersLabel => 'Assign Members';

  @override
  String get userManagementSelectUsersToAddToGroup => 'Select users to add to this group';

  @override
  String userManagementSelectedMembers(num count) {
    return 'Selected Members ($count)';
  }

  @override
  String userManagementSelectedPermissions(num count) {
    return 'Selected Permissions ($count)';
  }

  @override
  String get userManagementSelectGroupsToAssign => 'Select groups to assign to this user';

  @override
  String get userManagementRolesLabel => 'Roles';

  @override
  String get userManagementNoGroupsAssignedToUser => 'No groups assigned to this user';

  @override
  String get userManagementNoGroupsCreatedYet => 'No groups created yet';

  @override
  String get userManagementContentManagementLabel => 'Content Management';

  @override
  String get userManagementMediaLabel => 'Media';

  @override
  String get userManagementAssignedPermissions => 'Assigned Permissions';

  @override
  String get userManagementNoPermissionsFromGroups => 'No permissions from groups';

  @override
  String get userManagementNoDirectPermissionsAssigned => 'No direct permissions assigned to this user';

  @override
  String get userManagementAssignGroupsLabel => 'Assign Groups';

  @override
  String get userManagementPermissionsFromGroups => 'Permissions from Groups';

  @override
  String get userManagementNotificationsLabel => 'Notifications';

  @override
  String get userManagementUserManagementLabel => 'User Management';

  @override
  String get userManagementSurveysLabel => 'Surveys';

  @override
  String get sortingModuleAccessControlDescription => 'Users and groups that can edit this survey';

  @override
  String get sortingModuleRespondents => 'Respondents';

  @override
  String get sortingModuleRespondentsDescription => 'Users and groups that can respond to this survey';

  @override
  String get sortingModuleTotalResponsesLabel => 'Total Responses';

  @override
  String sortingSurvey(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Sorting Surveys',
      one: 'Sorting Survey',
      zero: 'Sorting Surveys',
    );
    return '$_temp0';
  }

  @override
  String sortingModulePreferences(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Preferences',
      one: 'Preference',
      zero: 'Preferences',
    );
    return '$_temp0';
  }

  @override
  String get sortingModuleParameters => 'Sorting Parameters';

  @override
  String get sortingModuleNoResponsesYet => 'No responses yet';

  @override
  String get sortingModuleAskForBiologicalSex => 'Ask respondents for their biological sex';

  @override
  String get sortingModuleAskForPreferences => 'Ask respondents to select preferred people';

  @override
  String get sortingModuleMaximumPreferencesLabel => 'Maximum Preferences';

  @override
  String get sortingModuleMaximumPreferencesDescription => 'Maximum number of people that can be selected';

  @override
  String get sortingModuleNoResponsesImportManuallyLabel => 'Start by adding responses manually or import from a file';

  @override
  String get sortingModulePublishSortingSurveyNoResponsesLabel => 'Publish Sorting Survey to start collecting responses';

  @override
  String get sortingModuleParameterName => 'Parameter Name';

  @override
  String get sortingModuleStrategy => 'Strategy';

  @override
  String get sortingModuleStrategyDistribute => 'Distribute evenly';

  @override
  String get sortingModuleStrategyConcentrate => 'Concentrate in one class';

  @override
  String get sortingModuleTypeBinary => 'Binary (Yes/No)';

  @override
  String get sortingModuleTypeCategorical => 'Categorical (Text)';

  @override
  String get sortingModulePriorityLabel => 'Priority';

  @override
  String get sortingModulePriorityDescription => 'Lower number means higher priority (1-10)';

  @override
  String get sortingModuleOverview => 'Overview';

  @override
  String get sortingModuleCalculate => 'Calculate';

  @override
  String get sortingModuleResults => 'Results';

  @override
  String get sortingModuleCalculating => 'Calculating...';

  @override
  String get sortingModuleResultsAvailable => 'Results available';

  @override
  String get sortingModuleVariables => 'Variables';

  @override
  String get sortingModuleProblemSize => 'Problem Size';

  @override
  String sortingModuleNumOfStudents(num count) {
    return 'Students: $count';
  }

  @override
  String sortingModuleNumOfClasses(num count) {
    return 'Classes: $count';
  }

  @override
  String sortingModuleNumOfParams(num count) {
    return 'Parameters: $count';
  }

  @override
  String sortingModuleNumOfPreferences(num count) {
    return 'Preferences: $count';
  }

  @override
  String get sortingModuleMaxCalcTimeLabel => 'Max Calculation Time';

  @override
  String get sortingModuleMaxCalcTimeDescription => 'The algorithm will attempt to find the best solution within this time limit. In most cases, it will find a solution faster.';

  @override
  String get sortingModuleTimeLimitLabel => 'Time Limit';

  @override
  String get sortingModuleCalculateLoadingLabel => 'The algorithm will attempt to find the best solution within this time limit. In most cases, it will find a solution faster.';

  @override
  String get sortingModuleClassConfigLabel => 'Class Configuration';

  @override
  String get sortingModuleClassesLabel => 'Classes';

  @override
  String get sortingModuleSelectClassesToExportLabel => 'Select classes to export';

  @override
  String get sortingModuleSelectAllClasses => 'Select All Classes';

  @override
  String get sortingModuleDistributionSettingsLabel => 'Distribution Settings';

  @override
  String get sortingModuleDistributeByBiologicalSexLabel => 'Distribute by Biological Sex';

  @override
  String get sortingModuleDistributeByBiologicalSexDescription => 'Attempt to achieve an even male/female distribution in each class';

  @override
  String get sortingModuleCapacityInfoLabel => 'Capacity Information';

  @override
  String get sortingModuleClassNameLabel => 'Class Name';

  @override
  String get sortingModuleIncludeGender => 'Include Gender';

  @override
  String get sortingModuleSelectInfoToIncludeLabel => 'Select information to include';

  @override
  String get sortingModuleClassSizeLabel => 'Class Size';

  @override
  String get sortingModuleNewClassNameLabel => 'New Class Name';

  @override
  String get sortingModuleNewClassNameHint => 'Leave empty for automatic numbering';

  @override
  String sortingModuleTotalCapacity(num count) {
    return 'Total Capacity: $count students';
  }

  @override
  String sortingModuleMinimumRequiredCapacity(num count) {
    return 'Minimum Required Capacity: $count students';
  }

  @override
  String get sortingModuleWarningMinimumRequiredCapacity => 'Warning: Total Capacity must be at least equal to the number of students';

  @override
  String get sortingModuleCapacityRecommendation => 'Recommendation: Consider leaving space for at least one additional student in each class for better alogrithm flexibility.';

  @override
  String get sortingModuleParametersConfigurationTitle => 'Parameters Configuration';

  @override
  String get sortingModuleParameterDisabledDescription => 'This parameter is disabled and will not be used in calculations';

  @override
  String get sortingModuleCloseSurveyBeforeCalculating => 'Please close the survey before starting the calculation process.';

  @override
  String get sortingModuleNoParamsDefined => 'No parameters defined';

  @override
  String get sortingModuleAddManuallyLabel => 'Add Manually';

  @override
  String sortingModuleResponses(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Responses',
      one: 'Response',
      zero: 'Responses',
    );
    return '$_temp0';
  }

  @override
  String get sortingModuleTotalNumOfPreferences => 'Total Number of Preferences';

  @override
  String sortingModuleMaxPreferencesPerUser(num count) {
    return '(max $count per user)';
  }

  @override
  String get sortingModuleManualEntry => 'Manual Entry';

  @override
  String sortingModuleSelectUpToXPreferencesLabel(num count) {
    return 'Select up to $count preferences';
  }

  @override
  String get sortingModuleDuplicateNamesFound => 'Duplicate names found';

  @override
  String sortingModuleUniqueValuesCount(num count) {
    return 'Unique Values: $count';
  }

  @override
  String get sortingModuleSelectInformationToIncludeLabel => 'Select information to include';

  @override
  String sortingModuleNumOfStudentsForPdf(num count) {
    return '($count students)';
  }

  @override
  String get sortingModuleExportIncludeSummaryStatistics => 'Include Summary Statistics';

  @override
  String get sortingModuleIncludeClassStatistics => 'Include Class Statistics';

  @override
  String get sortingModuleResponseStatisticsLabel => 'Response Statistics';

  @override
  String get sortingModuleParameterDistributionLabel => 'Parameter Distribution';

  @override
  String get sortingModuleIndividualResponsesLabel => 'Individual Responses';

  @override
  String get sortingModuleSelectAtLeastOneClassForExport => 'Please select at least one class to export';

  @override
  String get sortingModuleAdditionalParametersLabel => 'Additional Parameters';

  @override
  String get sortingModuleSelectAllParameters => 'Select All Parameters';

  @override
  String get sortingModuleClassDistributionResultsLabel => 'Class Distribution Results';

  @override
  String get sortingModuleTotalStudentsLabel => 'Total Students';

  @override
  String get sortingModuleTotalClassesLabel => 'Total Classes';

  @override
  String get sortingModuleAverageStudentsPerClassLabel => 'Average Students per Class';

  @override
  String get sortingModulePreferencesSatisfiedLabel => 'Preferences Satisfied';

  @override
  String get sortingModuleStudentsWithAtLeastOnePreferenceSatisfiedLabel => 'Students with at least one preference satisfied';

  @override
  String get sortingModuleShowClassStatisticssLabel => 'Show Class Statistics';

  @override
  String get sortingModuleNoPreferencesSelected => 'No preferences selected';

  @override
  String get sortingModuleDragStudentsHerePlaceholder => 'Drag students here to add them to the class';

  @override
  String get sortingModuleNoCalcResults => 'No calculation results available';

  @override
  String get sortingModuleGoToCalculate => 'Go to Calculate';
}
