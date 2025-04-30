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
      ErrorCode.signatureValidationFailed => l10n.validationSignatureFailed,

      // Auth errors
      ErrorCode.emailAlreadyInUse => l10n.errorEmailAlreadyInUse,
      ErrorCode.wrongPassword => l10n.errorInvalidPassword,
      ErrorCode.userNotFound => l10n.errorUserNotFound,
      ErrorCode.passwordMissingNumber => l10n.errorPasswordMissingNumber,
      ErrorCode.passwordMissingSpecial => l10n.errorPasswordMissingSpecial,
      ErrorCode.passwordsDoNotMatch => l10n.errorPasswordsDoNotMatch,
      ErrorCode.authAccountAlreadyExists => l10n.errorAuthAccountAlreadyExists,

      // Network errors
      ErrorCode.networkError => l10n.errorNetwork,

      // Group errors
      ErrorCode.groupNotFound => l10n.errorGroupNotFound,
      ErrorCode.groupUpdateFailed => l10n.errorGroupUpdateFailed,
      ErrorCode.groupDeleteFailed => l10n.errorGroupDeleteFailed,
      ErrorCode.groupCreateFailed => l10n.errorGroupCreateFailed,
      ErrorCode.invalidGroupOperation => l10n.errorInvalidGroupOperation,
      ErrorCode.userGroupUpdateFailed => l10n.errorUserGroupUpdateFailed,

      // Storage errors
      ErrorCode.fileUploadFailed => l10n.errorFileUploadFailed,
      ErrorCode.fileDeleteFailed => l10n.errorFileDeleteFailed,
      ErrorCode.fileNotFound => l10n.errorFileNotFound,
      ErrorCode.invalidFileType => l10n.errorInvalidFileType,
      ErrorCode.fileTooLarge => l10n.errorFileTooLarge,
      ErrorCode.fileListFailed => l10n.errorFileListFailed,
      ErrorCode.storageOperationFailed => l10n.errorStorageOperationFailed,

      // Calculation errors
      ErrorCode.calculationFailed => l10n.errorCalculationFailed,
      ErrorCode.calculationTimeout => l10n.errorCalculationTimeout,
      ErrorCode.calculationServerError => l10n.errorCalculationServerError,
      ErrorCode.insufficientClassCapacity =>
        l10n.errorInsufficientClassCapacity,
      ErrorCode.invalidCalculationParameters =>
        l10n.errorInvalidCalculationParameters,

      // Default
      ErrorCode.unexpected => l10n.errorUnexpected,
    };
  }
}
