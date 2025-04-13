// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get globalLanguage => 'English';

  @override
  String get globalOk => 'OK';

  @override
  String get globalCancel => 'Cancel';

  @override
  String get globalSave => 'Save';

  @override
  String get globalEdit => 'Edit';

  @override
  String get globalAdd => 'Add';

  @override
  String get globalConfirm => 'Confirm';

  @override
  String get globalDelete => 'Delete';

  @override
  String get globalLoading => 'Loading...';

  @override
  String get globalReauthenticate => 'Re-authentification required';

  @override
  String get globalSearch => 'Search';

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
  String get navSurveySorter => 'Sorting Module';

  @override
  String get navSettings => 'Settings';

  @override
  String get validationRequired => 'This field is required';

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
  String get errorUserNotFound => '404 - User not found';

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
  String get errorGroupCreateFailed => 'Group creation failed';

  @override
  String get errorInvalidGroupOperation => 'Invalid group operation';

  @override
  String get errorUserGroupUpdateFailed => 'User group update failed';

  @override
  String get errorFileUploadFailed => 'File upload failed';

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
  String get errorFileListFailed => 'File list retrieval failed';

  @override
  String get errorStorageOperationFailed => 'Storage operation failed';

  @override
  String get successDefault => 'Success';

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
  String get successSettingsUpdated => 'Settings updated successfully';

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
}
