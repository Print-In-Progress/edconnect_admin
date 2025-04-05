import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'domain_exception.dart';

extension ErrorMessages on DomainException {
  String getLocalizedMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return switch (code) {
      // Validation errors
      ErrorCode.signatureMissing => l10n.validationSignatureMissing,
      ErrorCode.questionMissing => l10n.validationRequiredSnackbar,
      ErrorCode.fieldRequired => l10n.validationRequired,
      ErrorCode.fieldTooShort => l10n.validationTextTooShort,
      ErrorCode.fieldTooLong => l10n.validationTextTooLong,
      ErrorCode.invalidEmail => l10n.validationEmail,

      // Auth errors
      ErrorCode.emailAlreadyInUse => l10n.errorEmailAlreadyInUse,
      ErrorCode.wrongPassword => l10n.errorInvalidPassword,
      ErrorCode.userNotFound => l10n.errorUserNotFound,
      ErrorCode.passwordMissingNumber => l10n.errorPasswordMissingNumber,
      ErrorCode.passwordMissingSpecial => l10n.errorPasswordMissingSpecial,
      ErrorCode.passwordsDoNotMatch => l10n.errorPasswordsDoNotMatch,

      // Network errors
      ErrorCode.networkError => l10n.errorNetwork,

      // Default
      ErrorCode.unexpected => l10n.errorUnexpected,
    };
  }
}
