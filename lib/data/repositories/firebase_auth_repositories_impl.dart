import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edconnect_admin/core/errors/domain_exception.dart';
import 'package:edconnect_admin/core/errors/error_handler.dart';
import 'package:edconnect_admin/core/utils/crypto_utils.dart';
import 'package:edconnect_admin/core/validation/validators/registration_validator.dart';
import 'package:edconnect_admin/data/datasource/auth_data_source.dart';
import 'package:edconnect_admin/data/datasource/storage_data_source.dart';
import 'package:edconnect_admin/data/datasource/user_data_source.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';
import 'package:edconnect_admin/domain/services/pdf_service.dart';
import 'package:edconnect_admin/domain/utils/registration_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/interfaces/auth_repository.dart';
import '../../core/models/app_user.dart';
import '../../domain/entities/registration_request.dart';
import '../../core/constants/database_constants.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;
  final UserDataSource _userDataSource;
  final StorageDataSource _storageDataSource;
  final FirebaseFirestore _firestore;

  FirebaseAuthRepositoryImpl(
    this._authDataSource,
    this._userDataSource,
    this._storageDataSource, {
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> signUp(RegistrationRequest request) async {
    // Validate password match
    try {
      final validator = RegistrationValidator();
      validator.validate(request);
      final uid = await _authDataSource.createUserWithEmailAndPassword(
        request.email.trim(),
        request.password.trim(),
      );
      await _processRegistration(uid, request);

      await _authDataSource.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final snapshot = await _firestore
            .collection(customerSpecificCollectionUsers)
            .where('email', isEqualTo: request.email.trim())
            .get();

        if (snapshot.docs.isNotEmpty) {
          throw DomainException(
              code: ErrorCode.emailAlreadyInUse,
              type: ExceptionType.auth,
              originalError: e);
        } else {
          throw DomainException(
              code: ErrorCode.authAccountAlreadyExists,
              type: ExceptionType.auth,
              originalError: e);
        }
      }
      throw ErrorHandler.handle(e);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> signUpWithExistingAuthAccount(
      RegistrationRequest request) async {
    try {
      // Validate request
      final validator = RegistrationValidator();
      validator.validate(request);
      // Sign in with existing account
      final uid = await _authDataSource.signUpWithExistingAuthAccount(
        request.email.trim(),
        request.password.trim(),
      );
      if (uid == null) {
        throw const DomainException(
            code: ErrorCode.unexpected, type: ExceptionType.auth);
      }
      // Process registration
      await _processRegistration(uid, request);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> _processRegistration(
    String uid,
    RegistrationRequest request,
  ) async {
    try {
      // Filter and flatten fields
      final filteredFields = request.registrationFields
          .where((field) =>
              !(field.type == 'checkbox_section' && field.checked != true))
          .toList();
      final flattenedFields = flattenRegistrationFields(filteredFields);

      // Get checked groups to be assigned to user
      final checkedGroups = flattenedFields
          .where((field) =>
              field.type == 'checkbox_assign_group' && (field.checked ?? false))
          .map((field) => field.group!)
          .toList();

      // Check if user provided a signature
      final hasSignature = flattenedFields.any(
          (field) => field.type == 'signature' && (field.checked ?? false));

      if (hasSignature) {
        await _processSignedRegistration(
          uid,
          request,
          flattenedFields,
          checkedGroups,
        );
      } else {
        await _processUnsignedRegistration(
          uid,
          request,
          flattenedFields,
          checkedGroups,
        );
      }

      // Process file uploads if any
      await _processFileUploads(uid, flattenedFields);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> _processSignedRegistration(
    String uid,
    RegistrationRequest request,
    List<BaseRegistrationField> fields,
    List<String> groups,
  ) async {
    try {
      // Generate key pair and PDF
      final keyPair = generateRSAKeyPair();
      final pdfBytes = await PdfService.generateRegistrationPdf(
        fields,
        true,
        uid,
        request.orgName,
        capitalize(request.firstName),
        capitalize(request.lastName),
        request.email.trim(),
        publicKey: keyPair.publicKey,
      );

      // Sign the PDF
      final pdfHash = hashBytes(pdfBytes);
      final signatureBytes = signHash(pdfHash, keyPair.privateKey);

      // Verify signature
      final isVerified =
          verifySignature(pdfHash, signatureBytes, keyPair.publicKey);
      if (!isVerified) {
        throw const DomainException(
          code: ErrorCode.signatureValidationFailed,
          type: ExceptionType.validation,
        );
      }

      final publicKeyPem = convertPublicKeyToPem(keyPair.publicKey);
      // Save user details
      await _userDataSource.saveUserDetails(
        uid,
        capitalize(request.firstName),
        capitalize(request.lastName),
        request.email.trim(),
        groups,
        request.accountType,
        true,
        publicKeyPem: publicKeyPem,
        signatureBytes: signatureBytes,
      );
      print('Saved to firestore');
      // Upload signed PDF
      await _storageDataSource.uploadPdf(
        pdfBytes,
        '${uid}_registration_form_signed.pdf',
        'registration_data/$uid',
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> _processUnsignedRegistration(
    String uid,
    RegistrationRequest request,
    List<BaseRegistrationField> fields,
    List<String> groups,
  ) async {
    try {
      // Generate unsigned PDF
      final pdfBytes = await PdfService.generateRegistrationPdf(
        fields,
        false,
        uid,
        request.orgName,
        capitalize(request.firstName),
        capitalize(request.lastName),
        request.email.trim(),
      );
      print('generated pdf');
      // Save user details
      await _userDataSource.saveUserDetails(
        uid,
        capitalize(request.firstName),
        capitalize(request.lastName),
        request.email.trim(),
        groups,
        request.accountType,
        false,
      );
      // Upload unsigned PDF
      await _storageDataSource.uploadPdf(
        pdfBytes,
        '${uid}_registration_form_unsigned.pdf',
        'registration_data/$uid',
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  Future<void> _processFileUploads(
    String uid,
    List<BaseRegistrationField> fields,
  ) async {
    try {
      final fileUploadFields = fields
          .where((field) => field.type == 'file_upload' && field.file != null)
          .toList();

      if (fileUploadFields.isEmpty) return;

      List<Uint8List> fileBytes = [];
      List<String> fileNames = [];

      for (var field in fileUploadFields) {
        for (var platformFile in field.file!) {
          if (platformFile.bytes != null) {
            fileBytes.add(platformFile.bytes!);
            fileNames.add(platformFile.name);
          }
        }
      }

      if (fileBytes.isNotEmpty) {
        await _storageDataSource.uploadFiles(
          fileBytes,
          fileNames,
          'registration_data/$uid',
        );
      }
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _authDataSource.sendEmailVerification();
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Future<bool> isEmailVerified() async {
    try {
      await _authDataSource.reloadUser();
      return _authDataSource.isEmailVerified;
    } catch (e) {
      ErrorHandler.handle(e);
      return false;
    }
  }

  @override
  Stream<AppUser?> get currentUserStream {
    return _authDataSource.authStateChanges.asyncMap((uid) async {
      // If no user is logged in, return null immediately
      if (uid == null) {
        return null;
      }

      try {
        // Check email verification first since it's part of Firebase Auth
        await _authDataSource.reloadUser();
        final isVerified = _authDataSource.isEmailVerified;

        if (!isVerified) {
          // Return special unverified user state
          return AppUser.unverified(uid);
        }

        // Fetch the user document
        final doc = await _firestore
            .collection(customerSpecificCollectionUsers)
            .doc(uid)
            .get();

        // Explicitly handle the case where doc doesn't exist
        if (!doc.exists) {
          // Create a special "document not found" user object instead of null
          // This signals auth is OK but document is missing
          return AppUser.documentNotFound(uid);
        }

        return AppUser.fromMap(doc.data()!, doc.id);
      } catch (e) {
        // Create an error state user
        return AppUser.error(uid, e.toString());
      }
    });
  }

  @override
  Future<void> signOut() async {
    try {
      await _authDataSource.signOut();
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      await _authDataSource.reloadUser();
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _authDataSource.signInWithEmailAndPassword(email, password);
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _authDataSource.resetPassword(email);
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> changeEmail(String email) async {
    try {
      await _authDataSource.changeEmail(email);
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> reauthenticate(String password) async {
    try {
      await _authDataSource.reauthenticate(password);
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> changePassword(String newPassword) async {
    try {
      await _authDataSource.changePassword(newPassword);
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _authDataSource.deleteAccount();
    } catch (e) {
      ErrorHandler.handle(e);
    }
  }
}

// Helper function
String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}
