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

  /// Global section - Edit button text
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get globalEdit;

  /// Global section - Edit with name button text
  ///
  /// In en, this message translates to:
  /// **'Edit {name}'**
  String globalEditWithName(String name);

  /// Global section - Yes button text
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get globalYes;

  /// Global section - Sign in to your account label
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get globalWelcomeLabelSignIn;

  /// Global section - No button text
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get globalNo;

  /// Global section - Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get globalAdd;

  /// Global section - User label
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {User} other {Users}}'**
  String globalUserLabel(num count);

  /// Global section - Add with name button text
  ///
  /// In en, this message translates to:
  /// **'Add {name}'**
  String globalAddX(String name);

  /// Global section - From with name label
  ///
  /// In en, this message translates to:
  /// **'From {name}'**
  String globalFromX(String name);

  /// Global section - Filters label
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get globalFiltersLabel;

  /// Global section - Filter by group label
  ///
  /// In en, this message translates to:
  /// **'Filter by group'**
  String get globalFilterByGroup;

  /// Global section - Required label
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get globalRequiredLabel;

  /// Global section - Not Required label
  ///
  /// In en, this message translates to:
  /// **'Not Required'**
  String get globalNotRequiredLabel;

  /// Global section - Statistics label
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get globalStatisticsLabel;

  /// Global section - Other label
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get globalOtherLabel;

  /// Global section - Enabled status text
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get globalEnabledLabel;

  /// Global section - Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get globalConfirm;

  /// Global section - Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get globalDelete;

  /// Global section - Actions label
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get globalActionsLabel;

  /// Global section - View All label
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get globalViewAllLabel;

  /// Global section - Select with name button text
  ///
  /// In en, this message translates to:
  /// **'Select {name}'**
  String globalSelectX(String name);

  /// Global section - Draft status text
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get globalDraft;

  /// Global section - Published status text
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get globalPublished;

  /// Global section - Pending status text
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get globalClosed;

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

  /// Global section - Editors label
  ///
  /// In en, this message translates to:
  /// **'Editors'**
  String get globalEditorsLabel;

  /// Global section - Delete confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this {name}?'**
  String globalDeleteConfirmationDialogWithName(String name);

  /// Global section - Delete all confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all {name}?'**
  String globalDeleteConfirmationDialogAllWithName(String name);

  /// Global section - Unsaved changes warning message
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes'**
  String get globalYouHaveUnsavedChanges;

  /// Global section - Discard button text
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get globaDiscard;

  /// Global section - Disabled status text
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get globalDisabledLabel;

  /// Global section - Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get globalStatusLabel;

  /// Global section - Created By label
  ///
  /// In en, this message translates to:
  /// **'Created by'**
  String get globalCreatedByLabel;

  /// Global section - Created At label
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get globalCreatedAtLabel;

  /// Global section - Title label
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get globalTitle;

  /// Global section - Type label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get globalTypeLabel;

  /// Global section - Retry button text
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get globalRetry;

  /// Global section - No groups selected message
  ///
  /// In en, this message translates to:
  /// **'No groups selected'**
  String get globalNoGroupsSelected;

  /// Global section - Feature not implemented message
  ///
  /// In en, this message translates to:
  /// **'Feature not implemented yet'**
  String get globalFeatureNotImplementedYet;

  /// Global section - No users selected message
  ///
  /// In en, this message translates to:
  /// **'No users selected'**
  String get globalNoUsersSelected;

  /// Global section - Title with prefix label
  ///
  /// In en, this message translates to:
  /// **'{prefix} Title'**
  String globalTitleWithPrefix(String prefix);

  /// Global section - Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get globalDescription;

  /// Global section - Name label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get globalName;

  /// Global section - Gender label
  ///
  /// In en, this message translates to:
  /// **'Biological Sex'**
  String get globalBiologicalSexLabel;

  /// Global section - Description with prefix label
  ///
  /// In en, this message translates to:
  /// **'{prefix} Description'**
  String globalDescriptionWithPrefix(String prefix);

  /// Global section - Supported formats message
  ///
  /// In en, this message translates to:
  /// **'Supported formats: {formats}'**
  String globalSupportedFormatsWithFormats(String formats);

  /// Global section - Select file to import button text
  ///
  /// In en, this message translates to:
  /// **'Select file to import'**
  String get globalSelectFileToImport;

  /// Global section - Import with name button text
  ///
  /// In en, this message translates to:
  /// **'Import {name}'**
  String globalImportX(String name);

  /// Global section - Preview label
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get globalPreviewLabel;

  /// Global section - Select page size label
  ///
  /// In en, this message translates to:
  /// **'Select page size'**
  String get globalSelectPageSize;

  /// Global section - edConnect registration form title
  ///
  /// In en, this message translates to:
  /// **'edConnect Registration Form'**
  String get globalEdConnectRegistrationForm;

  /// Global section - Page size label
  ///
  /// In en, this message translates to:
  /// **'Page size'**
  String get globalPageSize;

  /// Global section - Form cryptographically signed message
  ///
  /// In en, this message translates to:
  /// **'This form was cryptographically signed by the user using the edConnect System.'**
  String get globalFormCryptographicallySigned;

  /// Global section - Create button label
  ///
  /// In en, this message translates to:
  /// **'Create {prefix}'**
  String globalCreateButtonLabel(String prefix);

  /// Global section - Loading with name message
  ///
  /// In en, this message translates to:
  /// **'Loading {name}...'**
  String globalLoadingWithName(String name);

  /// Global section - Not found with name message
  ///
  /// In en, this message translates to:
  /// **'{name} not found'**
  String globalNotFoundWithName(String name);

  /// Global section - No items found message
  ///
  /// In en, this message translates to:
  /// **'No {name} found'**
  String globalNoXFound(String name);

  /// Global section - Export with name button text
  ///
  /// In en, this message translates to:
  /// **'Export {name}'**
  String globalExportX(String name);

  /// Global section - Delete All button text
  ///
  /// In en, this message translates to:
  /// **'Delete All {name}'**
  String globalDeleteAllX(String name);

  /// Global section - Group label
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {Group} other {Groups}}'**
  String globalGroupLabel(num count);

  /// Global section - Filter by status label
  ///
  /// In en, this message translates to:
  /// **'Filter by status'**
  String get globalFilterStatus;

  /// Global section - Adjust filters message
  ///
  /// In en, this message translates to:
  /// **'Adjust filters to see more results'**
  String get globalAdjustFilters;

  /// Global section - Clear filters button text
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get globalClearFilters;

  /// Global section - Sort by label
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get globalSortBy;

  /// Global section - Filter by name A-Z label
  ///
  /// In en, this message translates to:
  /// **'Name A-Z'**
  String get globalFilterByNameAZ;

  /// Global section - Filter by name Z-A label
  ///
  /// In en, this message translates to:
  /// **'Name Z-A'**
  String get globalFilterByNameZA;

  /// Global section - Filter by newest first label
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get globalFilterByNewestFirst;

  /// Global section - Filter by oldest first label
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get globalFilterByOldestFirst;

  /// Global section - Filter by alphabetical label
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get globalFilterByAlphabetical;

  /// Global section - Select groups label
  ///
  /// In en, this message translates to:
  /// **'Select groups'**
  String get globalSelectGroups;

  /// Global section - Basic information label
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get globalBasicInfo;

  /// Global section - Select users label
  ///
  /// In en, this message translates to:
  /// **'Select Users'**
  String get globalSelectUsers;

  /// Global section - Select user label
  ///
  /// In en, this message translates to:
  /// **'Select User'**
  String get globalSelectUser;

  /// Global section - Search button text
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get globalSearch;

  /// Global section - Number of items selected message
  ///
  /// In en, this message translates to:
  /// **'{number} selected'**
  String globalXSelected(num number);

  /// Global section - All label
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get globalAllLabel;

  /// Global section - Save changes confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to save these changes?'**
  String get globalSaveChangesConfirmationDialog;

  /// Global section - Access control label
  ///
  /// In en, this message translates to:
  /// **'Access Control'**
  String get globalAccessControlLabel;

  /// Global section - Search with name placeholder
  ///
  /// In en, this message translates to:
  /// **'Search {name} ...'**
  String globalSearchWithName(String name);

  /// Global section - Creating with name message
  ///
  /// In en, this message translates to:
  /// **'Creating {name}...'**
  String globalCreatingX(String name);

  /// Global section - Export options label
  ///
  /// In en, this message translates to:
  /// **'Export Options'**
  String get globalExportOptions;

  /// Global section - Male label
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get globalMaleLabel;

  /// Global section - Details label
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get globalDetailsLabel;

  /// Global section - Female label
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get globalFemaleLabel;

  /// Global section - Non-binary label
  ///
  /// In en, this message translates to:
  /// **'Non-binary'**
  String get globalNonBinaryLabel;

  /// Global - male legend text
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get globalMaleLegend;

  /// Global - female legend text
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get globalFemaleLegend;

  /// Global - non-binary legend text
  ///
  /// In en, this message translates to:
  /// **'NB'**
  String get globalNonBinaryLegend;

  /// Global section - Publish button text
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get globalPublish;

  /// Global section - Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get globalClose;

  /// Global section - Editor groups label
  ///
  /// In en, this message translates to:
  /// **'Editor Groups'**
  String get globalEditorGroups;

  /// Global section - Editor users label
  ///
  /// In en, this message translates to:
  /// **'Editor Users'**
  String get globalEditorUsers;

  /// Global section - Respondent groups label
  ///
  /// In en, this message translates to:
  /// **'Respondent Groups'**
  String get globalRespondentGroups;

  /// Global section - Group name label
  ///
  /// In en, this message translates to:
  /// **'Group Name'**
  String get globalGroupName;

  /// Global section - Respondent users label
  ///
  /// In en, this message translates to:
  /// **'Respondent Users'**
  String get globalRespondentUsers;

  /// Global section - Clear button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get globalClear;

  /// Global section - Minutes with number message
  ///
  /// In en, this message translates to:
  /// **'{number, plural, one {minute} other {minutes}}'**
  String globalMintuesWithNumber(num number);

  /// Global section - Seconds with number message
  ///
  /// In en, this message translates to:
  /// **'{number, plural, one {second} other {seconds}}'**
  String globalSecondsWithNumber(num number);

  /// Global section - No results found message
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get globalNoResults;

  /// Global section - Logout button text
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get globalLogout;

  /// Global section - Delete account button text
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

  /// Global section - Dismiss button text
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get globalDismiss;

  /// Global section - Greeting message with first name
  ///
  /// In en, this message translates to:
  /// **'Hi, {firstName}!'**
  String globalGreetingOne(String firstName);

  /// Global section - Delete with name message
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String globalDeleteWithName(String name);

  /// Global section - No responses match filter message
  ///
  /// In en, this message translates to:
  /// **'No responses match the current filter'**
  String get globalNoResponsesMatchFilter;

  /// Global section - Terms of Service text
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get globalToS;

  /// Global section - Additional information requested by your organization label
  ///
  /// In en, this message translates to:
  /// **'Additional Informaiton (Requested by your organization)'**
  String get globalAdditionalInfoRequestedByYourOrg;

  /// Global section - Back button text
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get globalBack;

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

  /// Auth section - Sign document button text
  ///
  /// In en, this message translates to:
  /// **'Sign Document'**
  String get authSignDocument;

  /// Auth section - Sign document message body
  ///
  /// In en, this message translates to:
  /// **'I hereby confirm that by checking this box and submitting this form, I give my consent to digitally sign this document. I understand that my signature will be generated securely using cryptographic techniques to ensure the authenticity and integrity of the document. This signature is legally binding and I certify that the information provided is correct to the best of my knowledge and belief.'**
  String get authSignDocumentBody;

  /// Auth section - Document signed message
  ///
  /// In en, this message translates to:
  /// **'Document Signed'**
  String get authDocumentSigned;

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

  /// Auth section - Account type label
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get authAccountTypeLabel;

  /// Auth section - Account type placeholder text
  ///
  /// In en, this message translates to:
  /// **'Select Account Type'**
  String get authAccountTypePlaceholder;

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

  /// Navigation section - Hide sidebar button text
  ///
  /// In en, this message translates to:
  /// **'Hide Sidebar'**
  String get navHideSidebar;

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
  /// **'Sorting Module'**
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

  /// Validation section - Generic validation error message
  ///
  /// In en, this message translates to:
  /// **'Validation error'**
  String get validationError;

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

  /// Validation section - Signature validation failed message
  ///
  /// In en, this message translates to:
  /// **'Signature validation failed'**
  String get validationSignatureFailed;

  /// Validation section - Text too short message
  ///
  /// In en, this message translates to:
  /// **'Text is too short'**
  String get validationTextTooShort;

  /// Validation section - Text too long message
  ///
  /// In en, this message translates to:
  /// **'Text is too long'**
  String get validationTextTooLong;

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

  /// Error section - Unexpected error message
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String errorUnexpectedWithError(String error);

  /// Error section - Calculation failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to calculate classes. Please try again'**
  String get errorCalculationFailed;

  /// Error section - Invalid calculation parameters message
  ///
  /// In en, this message translates to:
  /// **'Invalid calculation parameters. Please check your inputs.'**
  String get errorInvalidCalculationParameters;

  /// Error section - Calculation timeout message
  ///
  /// In en, this message translates to:
  /// **'Calculation timed out. Try reducing complexity or increasing time limit.'**
  String get errorCalculationTimeout;

  /// Error section - Insufficient class capacity message
  ///
  /// In en, this message translates to:
  /// **'Total class capacity must be at least equal to the number of students'**
  String get errorInsufficientClassCapacity;

  /// Error section - Calculation server error message
  ///
  /// In en, this message translates to:
  /// **'Unable to reach calculation server. Please check your connection and try again.'**
  String get errorCalculationServerError;

  /// Error section - Terms acceptance message
  ///
  /// In en, this message translates to:
  /// **'You must accept the Terms & Conditions and Privacy Policy'**
  String get errorAcceptToSAndPrivacyPolicy;

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

  /// Error section - File selection error message
  ///
  /// In en, this message translates to:
  /// **'Please select a file'**
  String get errorSelectFile;

  /// Error section - Save failed message
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get errorSaveFailed;

  /// Error section - Export failed message
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get errorExportFailed;

  /// Error section - Error loading item message
  ///
  /// In en, this message translates to:
  /// **'Error loading {name}'**
  String errorLoadingX(String name);

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

  /// Validation section - Password missing number message
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one number'**
  String get errorPasswordMissingNumber;

  /// Validation section - Password missing special character message
  ///
  /// In en, this message translates to:
  /// **'Password must contain at least one special character'**
  String get errorPasswordMissingSpecial;

  /// Validation section - Passwords do not match message
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get errorPasswordsDoNotMatch;

  /// Validation section - Email already registered message
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get errorEmailAlreadyInUse;

  /// Error section - Group not found message
  ///
  /// In en, this message translates to:
  /// **'Group not found'**
  String get errorGroupNotFound;

  /// Error section - Group update failed message
  ///
  /// In en, this message translates to:
  /// **'Group update failed'**
  String get errorGroupUpdateFailed;

  /// Error section - Group deletion failed message
  ///
  /// In en, this message translates to:
  /// **'Group deletion failed'**
  String get errorGroupDeleteFailed;

  /// Error section - Invalid group operation message
  ///
  /// In en, this message translates to:
  /// **'Invalid group operation'**
  String get errorInvalidGroupOperation;

  /// Error section - User group update failed message
  ///
  /// In en, this message translates to:
  /// **'User group update failed'**
  String get errorUserGroupUpdateFailed;

  /// Error section - File upload failed message
  ///
  /// In en, this message translates to:
  /// **'File upload failed'**
  String get errorFileUploadFailed;

  /// Error section - File download failed message
  ///
  /// In en, this message translates to:
  /// **'File download failed'**
  String get errorFileDownloadFailed;

  /// Error section - File deletion failed message
  ///
  /// In en, this message translates to:
  /// **'File deletion failed'**
  String get errorFileDeleteFailed;

  /// Error section - Auth Account Already exists message
  ///
  /// In en, this message translates to:
  /// **'Auth account already exists'**
  String get errorAuthAccountAlreadyExists;

  /// Error section - File not found message
  ///
  /// In en, this message translates to:
  /// **'File not found'**
  String get errorFileNotFound;

  /// Error section - Invalid file type message
  ///
  /// In en, this message translates to:
  /// **'Invalid file type'**
  String get errorInvalidFileType;

  /// Error section - File too large message
  ///
  /// In en, this message translates to:
  /// **'File too large'**
  String get errorFileTooLarge;

  /// Error section - Creation failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to create {name}'**
  String errorCreateFailed(String name);

  /// Error section - File list retrieval failed message
  ///
  /// In en, this message translates to:
  /// **'File list retrieval failed'**
  String get errorFileListFailed;

  /// Error section - Storage operation failed message
  ///
  /// In en, this message translates to:
  /// **'Storage operation failed'**
  String get errorStorageOperationFailed;

  /// Global section - Default success message
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get successDefault;

  /// Success section - Classes calculated successfully message
  ///
  /// In en, this message translates to:
  /// **'Classes calculated successfully! Navigate to results page to view them.'**
  String get successClassesCalculated;

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

  /// Success section - Published successfully with name confirmation
  ///
  /// In en, this message translates to:
  /// **'{name} published successfully'**
  String successPublishedSuccessfullyWithName(String name);

  /// Success section - Closed successfully with name confirmation
  ///
  /// In en, this message translates to:
  /// **'{name} closed successfully'**
  String successClosedSuccessfullyWithName(String name);

  /// Success section - Settings update confirmation
  ///
  /// In en, this message translates to:
  /// **'Settings updated successfully'**
  String get successSettingsUpdated;

  /// Success section - Export confirmation
  ///
  /// In en, this message translates to:
  /// **'Export successful'**
  String get successExport;

  /// Success section - Created with prefix confirmation
  ///
  /// In en, this message translates to:
  /// **'{prefix} created successfully'**
  String successCreatedWithPrefix(String prefix);

  /// Success section - Deleted with name confirmation
  ///
  /// In en, this message translates to:
  /// **'{name} deleted successfully'**
  String successDeletedWithName(String name);

  /// Success section - Added successfully confirmation
  ///
  /// In en, this message translates to:
  /// **'{name} added successfully'**
  String successXAdded(String name);

  /// Success section - Updated successfully confirmation
  ///
  /// In en, this message translates to:
  /// **'{name} updated successfully'**
  String successXUpdated(String name);

  /// Settings section - Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsLabel;

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

  /// User Management section - Group information label
  ///
  /// In en, this message translates to:
  /// **'Group Information'**
  String get userManagementGroupInformationLabel;

  /// User Management section - Members label
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get userManagementMembersLabel;

  /// User Management section - Permissions label
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {Permissions} one {Permission} other {Permissions}}'**
  String userManagementPermissionsLabel(num count);

  /// User Management section - Filter by permissions label
  ///
  /// In en, this message translates to:
  /// **'Filter by Permissions'**
  String get userManagementFilterbyPermissions;

  /// User Management section - Faculty & Staff account type label
  ///
  /// In en, this message translates to:
  /// **'Faculty & Staff'**
  String get userManagementAccountTypeLabelFacultyAndStaff;

  /// User Management section - Student account type label
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get userManagementAccountTypeLabelStudent;

  /// User Management section - Parent account type label
  ///
  /// In en, this message translates to:
  /// **'Parent'**
  String get userManagementAccountTypeLabelParent;

  /// User Management section - No permissions assigned message
  ///
  /// In en, this message translates to:
  /// **'No permissions assigned to this group'**
  String get userManagementNoPermissiosnAssignedToGroup;

  /// User Management section - No members in group message
  ///
  /// In en, this message translates to:
  /// **'No members in this group'**
  String get userManagementNoMembersInGroup;

  /// User Management section - Assign members label
  ///
  /// In en, this message translates to:
  /// **'Assign Members'**
  String get userManagementAssignMembersLabel;

  /// User Management section - Select users to add to group message
  ///
  /// In en, this message translates to:
  /// **'Select users to add to this group'**
  String get userManagementSelectUsersToAddToGroup;

  /// User Management section - Selected members label
  ///
  /// In en, this message translates to:
  /// **'Selected Members ({count})'**
  String userManagementSelectedMembers(num count);

  /// User Management section - Selected permissions label
  ///
  /// In en, this message translates to:
  /// **'Selected Permissions ({count})'**
  String userManagementSelectedPermissions(num count);

  /// User Management section - Select groups to assign message
  ///
  /// In en, this message translates to:
  /// **'Select groups to assign to this user'**
  String get userManagementSelectGroupsToAssign;

  /// User Management section - Roles label
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get userManagementRolesLabel;

  /// User Management section - No groups assigned message
  ///
  /// In en, this message translates to:
  /// **'No groups assigned to this user'**
  String get userManagementNoGroupsAssignedToUser;

  /// User Management section - No groups created message
  ///
  /// In en, this message translates to:
  /// **'No groups created yet'**
  String get userManagementNoGroupsCreatedYet;

  /// User Management section - Content management label
  ///
  /// In en, this message translates to:
  /// **'Content Management'**
  String get userManagementContentManagementLabel;

  /// User Management section - Media label
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get userManagementMediaLabel;

  /// User Management section - Assigned permissions label
  ///
  /// In en, this message translates to:
  /// **'Assigned Permissions'**
  String get userManagementAssignedPermissions;

  /// User Management section - No permissions from groups message
  ///
  /// In en, this message translates to:
  /// **'No permissions from groups'**
  String get userManagementNoPermissionsFromGroups;

  /// User Management section - No direct permissions assigned message
  ///
  /// In en, this message translates to:
  /// **'No direct permissions assigned to this user'**
  String get userManagementNoDirectPermissionsAssigned;

  /// User Management section - Assign groups label
  ///
  /// In en, this message translates to:
  /// **'Assign Groups'**
  String get userManagementAssignGroupsLabel;

  /// User Management section - Permissions from groups label
  ///
  /// In en, this message translates to:
  /// **'Permissions from Groups'**
  String get userManagementPermissionsFromGroups;

  /// User Management section - Notifications label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get userManagementNotificationsLabel;

  /// User Management section - User management label
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagementUserManagementLabel;

  /// User Management section - Surveys label
  ///
  /// In en, this message translates to:
  /// **'Surveys'**
  String get userManagementSurveysLabel;

  /// Sorting Module section - Access control description
  ///
  /// In en, this message translates to:
  /// **'Users and groups that can edit this survey'**
  String get sortingModuleAccessControlDescription;

  /// Sorting Module section - Respondents label
  ///
  /// In en, this message translates to:
  /// **'Respondents'**
  String get sortingModuleRespondents;

  /// Sorting Module section - Respondents description
  ///
  /// In en, this message translates to:
  /// **'Users and groups that can respond to this survey'**
  String get sortingModuleRespondentsDescription;

  /// Sorting Module section - Total responses label
  ///
  /// In en, this message translates to:
  /// **'Total Responses'**
  String get sortingModuleTotalResponsesLabel;

  /// Sorting Module section - Sorting survey label
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {Sorting Surveys} one {Sorting Survey} other {Sorting Surveys}}'**
  String sortingSurvey(num count);

  /// Sorting Module section - Preferences label
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {Preferences} one {Preference} other {Preferences}}'**
  String sortingModulePreferences(num count);

  /// Sorting Module section - Sorting parameters label
  ///
  /// In en, this message translates to:
  /// **'Sorting Parameters'**
  String get sortingModuleParameters;

  /// Sorting Module section - No responses yet message
  ///
  /// In en, this message translates to:
  /// **'No responses yet'**
  String get sortingModuleNoResponsesYet;

  /// Sorting Module section - Ask for biological
  ///
  /// In en, this message translates to:
  /// **'Ask respondents for their biological sex'**
  String get sortingModuleAskForBiologicalSex;

  /// Sorting Module section - Ask for preferences
  ///
  /// In en, this message translates to:
  /// **'Ask respondents to select preferred people'**
  String get sortingModuleAskForPreferences;

  /// Sorting Module section - Maximum preferences label
  ///
  /// In en, this message translates to:
  /// **'Maximum Preferences'**
  String get sortingModuleMaximumPreferencesLabel;

  /// Sorting Module section - Maximum number of preferences label
  ///
  /// In en, this message translates to:
  /// **'Maximum number of people that can be selected'**
  String get sortingModuleMaximumPreferencesDescription;

  /// Sorting Module section - No responses import manually label
  ///
  /// In en, this message translates to:
  /// **'Start by adding responses manually or import from a file'**
  String get sortingModuleNoResponsesImportManuallyLabel;

  /// Sorting Module section - Publish sorting survey no responses label
  ///
  /// In en, this message translates to:
  /// **'Publish Sorting Survey to start collecting responses'**
  String get sortingModulePublishSortingSurveyNoResponsesLabel;

  /// Sorting Module section - Parameter name label
  ///
  /// In en, this message translates to:
  /// **'Parameter Name'**
  String get sortingModuleParameterName;

  /// Sorting Module section - Strategy label
  ///
  /// In en, this message translates to:
  /// **'Strategy'**
  String get sortingModuleStrategy;

  /// Sorting Module section - Distribute strategy label
  ///
  /// In en, this message translates to:
  /// **'Distribute evenly'**
  String get sortingModuleStrategyDistribute;

  /// Sorting Module section - Concentrate strategy label
  ///
  /// In en, this message translates to:
  /// **'Concentrate in one class'**
  String get sortingModuleStrategyConcentrate;

  /// Sorting Module section - Binary type label
  ///
  /// In en, this message translates to:
  /// **'Binary (Yes/No)'**
  String get sortingModuleTypeBinary;

  /// Sorting Module section - Categorical type label
  ///
  /// In en, this message translates to:
  /// **'Categorical (Text)'**
  String get sortingModuleTypeCategorical;

  /// Sorting Module section - Priority label
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get sortingModulePriorityLabel;

  /// Sorting Module section - Priority description
  ///
  /// In en, this message translates to:
  /// **'Lower number means higher priority (1-10)'**
  String get sortingModulePriorityDescription;

  /// Sorting Module section - Overview label
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get sortingModuleOverview;

  /// Sorting Module section - Calculate button text
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get sortingModuleCalculate;

  /// Sorting Module section - Results label
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get sortingModuleResults;

  /// Sorting Module section - Calculating message
  ///
  /// In en, this message translates to:
  /// **'Calculating...'**
  String get sortingModuleCalculating;

  /// Sorting Module section - Results available message
  ///
  /// In en, this message translates to:
  /// **'Results available'**
  String get sortingModuleResultsAvailable;

  /// Sorting Module section - Variables label
  ///
  /// In en, this message translates to:
  /// **'Variables'**
  String get sortingModuleVariables;

  /// Sorting Module section - Problem size label
  ///
  /// In en, this message translates to:
  /// **'Problem Size'**
  String get sortingModuleProblemSize;

  /// Sorting Module section - Number of students label
  ///
  /// In en, this message translates to:
  /// **'Students: {count}'**
  String sortingModuleNumOfStudents(num count);

  /// Sorting Module section - Number of classes label
  ///
  /// In en, this message translates to:
  /// **'Classes: {count}'**
  String sortingModuleNumOfClasses(num count);

  /// Sorting Module section - Number of parameters label
  ///
  /// In en, this message translates to:
  /// **'Parameters: {count}'**
  String sortingModuleNumOfParams(num count);

  /// Sorting Module section - Number of preferences label
  ///
  /// In en, this message translates to:
  /// **'Preferences: {count}'**
  String sortingModuleNumOfPreferences(num count);

  /// Sorting Module section - Max calculation time label
  ///
  /// In en, this message translates to:
  /// **'Max Calculation Time'**
  String get sortingModuleMaxCalcTimeLabel;

  /// Sorting Module section - Max calculation time description
  ///
  /// In en, this message translates to:
  /// **'The algorithm will attempt to find the best solution within this time limit. In most cases, it will find a solution faster.'**
  String get sortingModuleMaxCalcTimeDescription;

  /// Sorting Module section - Time limit label
  ///
  /// In en, this message translates to:
  /// **'Time Limit'**
  String get sortingModuleTimeLimitLabel;

  /// Sorting Module section - Calculate loading label
  ///
  /// In en, this message translates to:
  /// **'The algorithm will attempt to find the best solution within this time limit. In most cases, it will find a solution faster.'**
  String get sortingModuleCalculateLoadingLabel;

  /// Sorting Module section - Class configuration label
  ///
  /// In en, this message translates to:
  /// **'Class Configuration'**
  String get sortingModuleClassConfigLabel;

  /// Sorting Module section - Classes label
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get sortingModuleClassesLabel;

  /// Sorting Module section - Select classes label
  ///
  /// In en, this message translates to:
  /// **'Select classes to export'**
  String get sortingModuleSelectClassesToExportLabel;

  /// Sorting Module section - Select all classes label
  ///
  /// In en, this message translates to:
  /// **'Select All Classes'**
  String get sortingModuleSelectAllClasses;

  /// Sorting Module section - Distribution settings label
  ///
  /// In en, this message translates to:
  /// **'Distribution Settings'**
  String get sortingModuleDistributionSettingsLabel;

  /// Sorting Module section - Distribute by biological
  ///
  /// In en, this message translates to:
  /// **'Distribute by Biological Sex'**
  String get sortingModuleDistributeByBiologicalSexLabel;

  /// Sorting Module section - Distribute by biological
  ///
  /// In en, this message translates to:
  /// **'Attempt to achieve an even male/female distribution in each class'**
  String get sortingModuleDistributeByBiologicalSexDescription;

  /// Sorting Module section - Capacity information label
  ///
  /// In en, this message translates to:
  /// **'Capacity Information'**
  String get sortingModuleCapacityInfoLabel;

  /// Sorting Module section - Class name label
  ///
  /// In en, this message translates to:
  /// **'Class Name'**
  String get sortingModuleClassNameLabel;

  /// Sorting Module section - Include Gender label
  ///
  /// In en, this message translates to:
  /// **'Include Gender'**
  String get sortingModuleIncludeGender;

  /// Sorting Module section - Select information to include label
  ///
  /// In en, this message translates to:
  /// **'Select information to include'**
  String get sortingModuleSelectInfoToIncludeLabel;

  /// Sorting Module section - Class size label
  ///
  /// In en, this message translates to:
  /// **'Class Size'**
  String get sortingModuleClassSizeLabel;

  /// Sorting Module section - New class name label
  ///
  /// In en, this message translates to:
  /// **'New Class Name'**
  String get sortingModuleNewClassNameLabel;

  /// Sorting Module section - New class name hint
  ///
  /// In en, this message translates to:
  /// **'Leave empty for automatic numbering'**
  String get sortingModuleNewClassNameHint;

  /// Sorting Module section - Total capacity label
  ///
  /// In en, this message translates to:
  /// **'Total Capacity: {count} students'**
  String sortingModuleTotalCapacity(num count);

  /// Sorting Module section - Minimum required capacity label
  ///
  /// In en, this message translates to:
  /// **'Minimum Required Capacity: {count} students'**
  String sortingModuleMinimumRequiredCapacity(num count);

  /// Sorting Module section - Warning minimum required capacity message
  ///
  /// In en, this message translates to:
  /// **'Warning: Total Capacity must be at least equal to the number of students'**
  String get sortingModuleWarningMinimumRequiredCapacity;

  /// Sorting Module section - Capacity recommendation message
  ///
  /// In en, this message translates to:
  /// **'Recommendation: Consider leaving space for at least one additional student in each class for better alogrithm flexibility.'**
  String get sortingModuleCapacityRecommendation;

  /// Sorting Module section - Parameters configuration title
  ///
  /// In en, this message translates to:
  /// **'Parameters Configuration'**
  String get sortingModuleParametersConfigurationTitle;

  /// Sorting Module section - Parameter disabled description
  ///
  /// In en, this message translates to:
  /// **'This parameter is disabled and will not be used in calculations'**
  String get sortingModuleParameterDisabledDescription;

  /// Sorting Module section - Close survey before calculating message
  ///
  /// In en, this message translates to:
  /// **'Please close the survey before starting the calculation process.'**
  String get sortingModuleCloseSurveyBeforeCalculating;

  /// Sorting Module section - No parameters defined message
  ///
  /// In en, this message translates to:
  /// **'No parameters defined'**
  String get sortingModuleNoParamsDefined;

  /// Sorting Module section - Add manually label
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get sortingModuleAddManuallyLabel;

  /// Sorting Module section - Responses label
  ///
  /// In en, this message translates to:
  /// **'{count, plural, zero {Responses} one {Response} other {Responses}}'**
  String sortingModuleResponses(num count);

  /// Sorting Module section - Total number of preferences label
  ///
  /// In en, this message translates to:
  /// **'Total Number of Preferences'**
  String get sortingModuleTotalNumOfPreferences;

  /// Sorting Module section - Max preferences per user label
  ///
  /// In en, this message translates to:
  /// **'(max {count} per user)'**
  String sortingModuleMaxPreferencesPerUser(num count);

  /// Sorting Module section - Manual entry label
  ///
  /// In en, this message translates to:
  /// **'Manual Entry'**
  String get sortingModuleManualEntry;

  /// Sorting Module section - Select up to X preferences label
  ///
  /// In en, this message translates to:
  /// **'Select up to {count} preferences'**
  String sortingModuleSelectUpToXPreferencesLabel(num count);

  /// Sorting Module section - Duplicate names found message
  ///
  /// In en, this message translates to:
  /// **'Duplicate names found'**
  String get sortingModuleDuplicateNamesFound;

  /// Sorting Module section - Unique values count label
  ///
  /// In en, this message translates to:
  /// **'Unique Values: {count}'**
  String sortingModuleUniqueValuesCount(num count);

  /// Sorting Module section - Select information to include label
  ///
  /// In en, this message translates to:
  /// **'Select information to include'**
  String get sortingModuleSelectInformationToIncludeLabel;

  /// Sorting Module section - Number of students label
  ///
  /// In en, this message translates to:
  /// **'({count} students)'**
  String sortingModuleNumOfStudentsForPdf(num count);

  /// Sorting Module section - Include summary statistics label
  ///
  /// In en, this message translates to:
  /// **'Include Summary Statistics'**
  String get sortingModuleExportIncludeSummaryStatistics;

  /// Sorting Module section - Include class statistics label
  ///
  /// In en, this message translates to:
  /// **'Include Class Statistics'**
  String get sortingModuleIncludeClassStatistics;

  /// Sorting Module section - Response statistics label
  ///
  /// In en, this message translates to:
  /// **'Response Statistics'**
  String get sortingModuleResponseStatisticsLabel;

  /// Sorting Module section - Parameter distribution label
  ///
  /// In en, this message translates to:
  /// **'Parameter Distribution'**
  String get sortingModuleParameterDistributionLabel;

  /// Sorting Module section - Individual responses label
  ///
  /// In en, this message translates to:
  /// **'Individual Responses'**
  String get sortingModuleIndividualResponsesLabel;

  /// Sorting Module section - Select at least one class for export message
  ///
  /// In en, this message translates to:
  /// **'Please select at least one class to export'**
  String get sortingModuleSelectAtLeastOneClassForExport;

  /// Sorting Module section - Additional parameters label
  ///
  /// In en, this message translates to:
  /// **'Additional Parameters'**
  String get sortingModuleAdditionalParametersLabel;

  /// Sorting Module section - Select all parameters label
  ///
  /// In en, this message translates to:
  /// **'Select All Parameters'**
  String get sortingModuleSelectAllParameters;

  /// Sorting Module section - Class distribution results label
  ///
  /// In en, this message translates to:
  /// **'Class Distribution Results'**
  String get sortingModuleClassDistributionResultsLabel;

  /// Sorting Module section - Total students label
  ///
  /// In en, this message translates to:
  /// **'Total Students'**
  String get sortingModuleTotalStudentsLabel;

  /// Sorting Module section - Total classes label
  ///
  /// In en, this message translates to:
  /// **'Total Classes'**
  String get sortingModuleTotalClassesLabel;

  /// Sorting Module section - Average students per class label
  ///
  /// In en, this message translates to:
  /// **'Average Students per Class'**
  String get sortingModuleAverageStudentsPerClassLabel;

  /// Sorting Module section - Preferences satisfied label
  ///
  /// In en, this message translates to:
  /// **'Preferences Satisfied'**
  String get sortingModulePreferencesSatisfiedLabel;

  /// Sorting Module section - Students with at least one preference satisfied label
  ///
  /// In en, this message translates to:
  /// **'Students with at least one preference satisfied'**
  String get sortingModuleStudentsWithAtLeastOnePreferenceSatisfiedLabel;

  /// Sorting Module section - Show class statistics label
  ///
  /// In en, this message translates to:
  /// **'Show Class Statistics'**
  String get sortingModuleShowClassStatisticssLabel;

  /// Sorting Module section - No preferences selected message
  ///
  /// In en, this message translates to:
  /// **'No preferences selected'**
  String get sortingModuleNoPreferencesSelected;

  /// Sorting Module section - Drag students here placeholder
  ///
  /// In en, this message translates to:
  /// **'Drag students here to add them to the class'**
  String get sortingModuleDragStudentsHerePlaceholder;

  /// Sorting Module section - No calculation results message
  ///
  /// In en, this message translates to:
  /// **'No calculation results available'**
  String get sortingModuleNoCalcResults;

  /// Sorting Module section - Go to calculate button text
  ///
  /// In en, this message translates to:
  /// **'Go to Calculate'**
  String get sortingModuleGoToCalculate;
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
