import 'package:edconnect_admin/core/errors/domain_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ErrorHandler {
  static DomainException handle(dynamic error, BuildContext context) {
    if (error is DomainException) return error;

    // Handle Firebase Auth Errors
    if (error is FirebaseAuthException) {
      return _handleFirebaseAuthError(error, context);
    }

    // Handle Network Errors
    if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException')) {
      return DomainException(
        message:
            AppLocalizations.of(context)!.globalNoInternetConnectionErrorLabel,
        type: ExceptionType.network,
      );
    }

    // Handle Validation Errors
    if (error.toString().contains('SignatureMissing')) {
      return DomainException(
        message: AppLocalizations.of(context)!.authPagesSignatureMissing,
        type: ExceptionType.validation,
      );
    }

    if (error.toString().contains('QuestionMissing')) {
      return DomainException(
        message: AppLocalizations.of(context)!.authPagesFieldMissing,
        type: ExceptionType.validation,
      );
    }

    // Default error
    return DomainException(
      message: AppLocalizations.of(context)!.globalUnexpectedErrorLabel,
      type: ExceptionType.unexpected,
      originalError: error,
    );
  }

  static DomainException _handleFirebaseAuthError(
      FirebaseAuthException error, BuildContext context) {
    final message = switch (error.code) {
      'email-already-in-use' =>
        AppLocalizations.of(context)!.firebaseAuthErrorMessageEmailAlreadyInUse,
      'wrong-password' => 'Invalid password',
      'user-not-found' =>
        AppLocalizations.of(context)!.authPagesUserNotFoundErrorMessage,
      _ => AppLocalizations.of(context)!.globalUnexpectedErrorLabel
    };

    return DomainException(
      message: message,
      type: ExceptionType.auth,
      originalError: error,
    );
  }
}
