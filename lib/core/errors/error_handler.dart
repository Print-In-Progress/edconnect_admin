import 'package:edconnect_admin/core/errors/domain_exception.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ErrorHandler {
  static DomainException handle(dynamic error, BuildContext context) {
    if (error is DomainException) return error;

    // Handle Firebase Auth Errors
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthError(error, context);
    }

    if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException')) {
      return DomainException(
        message: AppLocalizations.of(context)!.errorNetwork,
        type: ExceptionType.network,
      );
    }

    // Handle Validation Errors
    if (error.toString().contains('SignatureMissing')) {
      return DomainException(
        message: AppLocalizations.of(context)!.validationSignatureMissing,
        type: ExceptionType.validation,
      );
    }

    if (error.toString().contains('QuestionMissing')) {
      return DomainException(
        message: AppLocalizations.of(context)!.validationRequiredSnackbar,
        type: ExceptionType.validation,
      );
    }

    // Default error
    return DomainException(
      message: AppLocalizations.of(context)!.errorUnexpected,
      type: ExceptionType.unexpected,
      originalError: error,
    );
  }

  static DomainException _handleFirebaseAuthError(
      FirebaseAuthException error, BuildContext context) {
    final message = switch (error.code) {
      'email-already-in-use' =>
        AppLocalizations.of(context)!.errorEmailAlreadyInUse,
      'wrong-password' => AppLocalizations.of(context)!.errorInvalidPassword,
      'user-not-found' => AppLocalizations.of(context)!.errorUserNotFound,
      _ => AppLocalizations.of(context)!.errorUnexpected
    };

    return DomainException(
      message: message,
      type: ExceptionType.auth,
      originalError: error,
    );
  }
}
