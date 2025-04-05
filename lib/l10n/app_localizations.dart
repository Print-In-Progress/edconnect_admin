import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// Global section - The current language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get globalLanguage;

  /// Global section - OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get globalOk;

  /// Global section - Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get globalCancel;

  /// Global section - Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get globalSave;

  /// Global section - Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get globalDelete;

  /// Global section - Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get globalLoading;

  /// Global section - Re-authentication required message
  ///
  /// In en, this message translates to:
  /// **'Re-authentification required'**
  String get globalReauthenticate;

  /// Global section - Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get globalLogout;

  /// Global section - Delete Account button text
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get globalDeleteAccount;

  /// Global section - First name input hint
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get globalFirstNameTextFieldHintText;

  /// Global section - Last name input hint
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get globalLastNameTextFieldHintText;

  /// Global section - Email input label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get globalEmailLabel;

  /// Global section - Legal notice text
  ///
  /// In en, this message translates to:
  /// **'Legal Notice'**
  String get globalLegalNotice;

  /// Global section - Submit button text
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get globalSubmit;

  /// Global section - Greeting message with first name
  ///
  /// In en, this message translates to:
  /// **'Hi, {firstName}!'**
  String globalGreetingOne(String firstName);

  /// Global section - Terms of Service text
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get globalToS;

  /// Global section - Back to login button text
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get globalBackToLogin;

  /// Global section - Reset password button text
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get authResetPassword;

  /// Auth section - Login page title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginTitle;

  /// Global section - Password input label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// Global section - Forgot password link text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get authForgotPassword;

  /// Auth section - Send reset password email button text
  ///
  /// In en, this message translates to:
  /// **'Send Reset Password Email'**
  String get authResetPasswordSendEmail;

  /// Auth section - Reset password message body
  ///
  /// In en, this message translates to:
  /// **'Please enter your email address to receive a link to reset your password.'**
  String get authResetPasswordBody;

  /// Auth section - Confirm password input hint
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get authPagesRegisterConfirmPasswordTextFieldHintText;

  /// Auth section - Primary welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get authPagesWelcomeLabelOne;

  /// Auth section - Secondary welcome message for registration
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get authPagesRegisterWelcomeLabelTwo;

  /// Auth section - Register button text
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get authPagesRegisterButtonLabel;

  /// Auth section - Email verification message
  ///
  /// In en, this message translates to:
  /// **'Verify your email address'**
  String get authVerifyEmailTitle;

  /// Auth section - Email verification message body
  ///
  /// In en, this message translates to:
  /// **'A verification link has been sent to your email address. Please check your inbox and click the link to verify your account.'**
  String get authVerifyEmailBody;

  /// Auth section - Resend verification email button text
  ///
  /// In en, this message translates to:
  /// **'Resend Verification Email'**
  String get authResendVerificationEmail;

  /// Navigation section - Dashboard menu item
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// Navigation section - Articles menu item
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get navArticles;

  /// Navigation section - Events menu item
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get navEvents;

  /// Navigation section - Users menu item
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get navUsers;

  /// Navigation section - Comments menu item
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get navComments;

  /// Navigation section - Digital Library menu item
  ///
  /// In en, this message translates to:
  /// **'Digital Library'**
  String get navDigitalLibrary;

  /// Navigation section - Media menu item
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get navMedia;

  /// Navigation section - Push Notifications menu item
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get navPushNotifications;

  /// Navigation section - Admin Settings menu item
  ///
  /// In en, this message translates to:
  /// **'Admin Settings'**
  String get navAdminSettings;

  /// Navigation section - Surveys menu item
  ///
  /// In en, this message translates to:
  /// **'Surveys'**
  String get navSurveys;

  /// Navigation section - Survey Sorter menu item
  ///
  /// In en, this message translates to:
  /// **'Survey Sorter'**
  String get navSurveySorter;

  /// Navigation section - Settings button text
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Validation section - Required field message
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validationRequired;

  /// Validation section - Snackbar message for required fields
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get validationRequiredSnackbar;

  /// Validation section - Invalid email message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validationEmail;

  /// Validation section - Signature field required message
  ///
  /// In en, this message translates to:
  /// **'Signature is required'**
  String get validationSignatureMissing;

  /// Terms section - Text before Terms & Conditions link
  ///
  /// In en, this message translates to:
  /// **'I agree to the '**
  String get termsAndConditionsPrefix;

  /// Terms section - Terms & Conditions link text
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditionsLinkText;

  /// Terms section - Text between Terms and Privacy links
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get termsAndConditionsMiddle;

  /// Terms section - Privacy Policy link text
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyLinkText;

  /// Terms section - Text after Privacy Policy link
  ///
  /// In en, this message translates to:
  /// **'.'**
  String get termsAndConditionsSuffix;

  /// Error section - Access denied message
  ///
  /// In en, this message translates to:
  /// **'403 - Access Denied'**
  String get errorAccessDenied;

  /// Global section - Access denied message body
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this page.'**
  String get errorAccessDeniedMessage;

  /// Error section - Unauthorized access message
  ///
  /// In en, this message translates to:
  /// **'Unauthorized Access'**
  String get errorUnauthorized;

  /// Global section - Image loading error message
  ///
  /// In en, this message translates to:
  /// **'Image could not be found'**
  String get errorImgCouldNotBeFound;

  /// Global section - Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error, please try again'**
  String get errorNetwork;

  /// Auth section - Terms acceptance error message
  ///
  /// In en, this message translates to:
  /// **'Please accept the Terms & Conditions and Privacy Policy'**
  String get errorPagesRegisterAcceptToSAndPrivacyPolicy;

  /// Global section - Unknown error message
  ///
  /// In en, this message translates to:
  /// **'Unexpected error occurred'**
  String get errorUnexpected;

  /// Auth section - User not found error message
  ///
  /// In en, this message translates to:
  /// **'404 - User not found'**
  String get errorUserNotFound;

  /// Auth section - User not found message body
  ///
  /// In en, this message translates to:
  /// **'User not found. The user may have been deleted by an administrator or does not exist.'**
  String get errorUserNotFoundMessage;

  /// Validation section - Invalid password message
  ///
  /// In en, this message translates to:
  /// **'Invalid password'**
  String get errorInvalidPassword;

  /// Validation section - Email already registered message
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get errorEmailAlreadyInUse;

  /// Global section - Default success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successDefault;

  /// Auth section - Account creation success message
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get successAccountCreated;

  /// Auth section - Registration success message
  ///
  /// In en, this message translates to:
  /// **'Registration successful!'**
  String get successRegistration;

  /// Success section - Email verification sent confirmation
  ///
  /// In en, this message translates to:
  /// **'Verification email sent successfully'**
  String get successEmailVerificationSent;

  /// Success section - Password change confirmation
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get successPasswordChanged;

  /// Success section - Reset password email sent confirmation
  ///
  /// In en, this message translates to:
  /// **'Reset password email sent successfully'**
  String get successResetPasswordEmailSent;

  /// Success section - Email change confirmation
  ///
  /// In en, this message translates to:
  /// **'Email changed successfully'**
  String get successEmailChanged;

  /// Success section - Profile update confirmation
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get successProfileUpdated;

  /// Success section - Generic save confirmation
  ///
  /// In en, this message translates to:
  /// **'Data saved successfully'**
  String get successDataSaved;

  /// Success section - Settings update confirmation
  ///
  /// In en, this message translates to:
  /// **'Settings updated successfully'**
  String get successSettingsUpdated;

  /// Settings section - Manage Account label
  ///
  /// In en, this message translates to:
  /// **'Manage Account'**
  String get settingsManageAccount;

  /// Settings section - Change Name label
  ///
  /// In en, this message translates to:
  /// **'Change Name'**
  String get settingsChangeName;

  /// Settings section - Change Email label
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get settingsChangeEmail;

  /// Settings section - Change Password label
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get settingsChangePassword;

  /// Settings section - Update Registration Questionnaire label
  ///
  /// In en, this message translates to:
  /// **'Update Registration Questionnaire'**
  String get settingsUpdateRegistrationQuestionaire;

  /// Settings section - Appearance label
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// Settings section - Dark Mode label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// Settings section - Delete Account dialog body
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone.'**
  String get settingsDeleteDialogBody;

  /// Settings section - New Password label
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get settingsNewPassword;

  /// Media section - Insert Image button text
  ///
  /// In en, this message translates to:
  /// **'Insert Image'**
  String get mediaSelectorInsertImage;

  /// Media section - Insert Video button text
  ///
  /// In en, this message translates to:
  /// **'Insert Video'**
  String get mediaSelectorInsertVideo;

  /// Media section - Insert Audio button text
  ///
  /// In en, this message translates to:
  /// **'Insert Audio'**
  String get mediaSelectorInsertAudio;

  /// Text Editor section - Insert Link button text
  ///
  /// In en, this message translates to:
  /// **'Insert Link'**
  String get textEditorInsertLink;

  /// Text Editor section - Link text to display input hint
  ///
  /// In en, this message translates to:
  /// **'Text to display'**
  String get textEditorInsertLinkTextToDisplay;

  /// Text Editor section - Editor placeholder text
  ///
  /// In en, this message translates to:
  /// **'Start typing...'**
  String get textEditorHintText;

  /// Text Editor section - Styles dropdown tooltip
  ///
  /// In en, this message translates to:
  /// **'Text Styles'**
  String get textEditorTooltipStyles;

  /// Text Editor section - Normal text style option
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get textEditorStyleMenuItemNormal;

  /// Text Editor section - H1 style option
  ///
  /// In en, this message translates to:
  /// **'Header 1'**
  String get textEditorStyleMenuItemHeader1;

  /// Text Editor section - H2 style option
  ///
  /// In en, this message translates to:
  /// **'Header 2'**
  String get textEditorStyleMenuItemHeader2;

  /// Text Editor section - H3 style option
  ///
  /// In en, this message translates to:
  /// **'Header 3'**
  String get textEditorStyleMenuItemHeader3;

  /// Text Editor section - H4 style option
  ///
  /// In en, this message translates to:
  /// **'Header 4'**
  String get textEditorStyleMenuItemHeader4;

  /// Text Editor section - H5 style option
  ///
  /// In en, this message translates to:
  /// **'Header 5'**
  String get textEditorStyleMenuItemHeader5;

  /// Text Editor section - H6 style option
  ///
  /// In en, this message translates to:
  /// **'Header 6'**
  String get textEditorStyleMenuItemHeader6;

  /// Text Editor section - Font family tooltip
  ///
  /// In en, this message translates to:
  /// **'Change Font Family'**
  String get textEditorTooltipChangeFontFamily;

  /// Text Editor section - Font size tooltip
  ///
  /// In en, this message translates to:
  /// **'Change Font Size'**
  String get textEditorTooltipChangeFontSize;

  /// Text Editor section - Bold button tooltip
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get textEditorTooltipBold;

  /// Text Editor section - Italic button tooltip
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get textEditorTooltipItalic;

  /// Text Editor section - Underline button tooltip
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get textEditorTooltipUnderline;

  /// Text Editor section - Strikethrough button tooltip
  ///
  /// In en, this message translates to:
  /// **'Strikethrough'**
  String get textEditorTooltipStrikethrough;

  /// Text Editor section - Subscript button tooltip
  ///
  /// In en, this message translates to:
  /// **'Subscript'**
  String get textEditorTooltipSubscript;

  /// Text Editor section - Superscript button tooltip
  ///
  /// In en, this message translates to:
  /// **'Superscript'**
  String get textEditorTooltipSuperscript;

  /// Text Editor section - Remove format button tooltip
  ///
  /// In en, this message translates to:
  /// **'Clear Formatting'**
  String get textEditorTooltipRemoveFormat;

  /// Text Editor section - Font color button tooltip
  ///
  /// In en, this message translates to:
  /// **'Font Color'**
  String get textEditorTooltipChangeFontColor;

  /// Text Editor section - Background color button tooltip
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get textEditorTooltipChangeBackgroundColor;

  /// Text Editor section - Bullet list button tooltip
  ///
  /// In en, this message translates to:
  /// **'Bulleted List'**
  String get textEditorTooltipInsertBulletedList;

  /// Text Editor section - Numbered list button tooltip
  ///
  /// In en, this message translates to:
  /// **'Numbered List'**
  String get textEditorTooltipInsertNumberedList;

  /// Text Editor section - List style button label
  ///
  /// In en, this message translates to:
  /// **'List Style'**
  String get textEditorChangeListStyleButtonLabel;

  /// Text Editor section - Left align button tooltip
  ///
  /// In en, this message translates to:
  /// **'Align Left'**
  String get textEditorTooltipLeftAlign;

  /// Text Editor section - Center align button tooltip
  ///
  /// In en, this message translates to:
  /// **'Center Align'**
  String get textEditorTooltipCenterAlign;

  /// Text Editor section - Right align button tooltip
  ///
  /// In en, this message translates to:
  /// **'Align Right'**
  String get textEditorTooltipRightAlign;

  /// Text Editor section - Justify align button tooltip
  ///
  /// In en, this message translates to:
  /// **'Justify'**
  String get textEditorTooltipJustifyAlign;

  /// Text Editor section - Increase indent button tooltip
  ///
  /// In en, this message translates to:
  /// **'Increase Indent'**
  String get textEditorTooltipIncreaseIndent;

  /// Text Editor section - Decrease indent button tooltip
  ///
  /// In en, this message translates to:
  /// **'Decrease Indent'**
  String get textEditorTooltipDeacreaseIndent;

  /// Text Editor section - Line spacing button tooltip
  ///
  /// In en, this message translates to:
  /// **'Line Spacing'**
  String get textEditorTooltipChangeLineSpacing;

  /// Text Editor section - Color picker dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Color'**
  String get textEditorChooseColorDialogTitle;

  /// Text Editor section - Set color button text
  ///
  /// In en, this message translates to:
  /// **'Set Color'**
  String get textEditorSetColorButtonLabel;

  /// Text Editor section - Reset color button text
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get textEditorResetColorButtonLabel;

  /// Text Editor section - Disc list style option
  ///
  /// In en, this message translates to:
  /// **'Disc'**
  String get textEditorListStyleMenuItemDisc;

  /// Text Editor section - Decimal list style option
  ///
  /// In en, this message translates to:
  /// **'Decimal'**
  String get textEditorListStyleMenuItemDecimal;

  /// Text Editor section - Square list style option
  ///
  /// In en, this message translates to:
  /// **'Square'**
  String get textEditorListStyleMenuItemSquare;

  /// Text Editor section - Circle list style option
  ///
  /// In en, this message translates to:
  /// **'Circle'**
  String get textEditorListStyleMenuItemCircle;

  /// Text Editor section - Upper roman numerals list style option
  ///
  /// In en, this message translates to:
  /// **'Upper Roman'**
  String get textEditorListStyleMenuItemUpperRomanNumerals;

  /// Text Editor section - Lower roman numerals list style option
  ///
  /// In en, this message translates to:
  /// **'Lower Roman'**
  String get textEditorListStyleMenuItemLowerRomanNumerals;

  /// Text Editor section - Uppercase letters list style option
  ///
  /// In en, this message translates to:
  /// **'ABC'**
  String get textEditorListStyleMenuItemUppercaseLetters;

  /// Text Editor section - Lowercase letters list style option
  ///
  /// In en, this message translates to:
  /// **'abc'**
  String get textEditorListStyleMenuItemLowercaseLetters;

  /// Text Editor section - Greek letters list style option
  ///
  /// In en, this message translates to:
  /// **'Greek'**
  String get textEditorListStyleMenuItemLowercaseClassicalGreek;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
