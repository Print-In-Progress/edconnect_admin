import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edconnect_admin/core/utils/crypto_utils.dart';
import 'package:edconnect_admin/data/datasource/auth_data_source.dart';
import 'package:edconnect_admin/data/datasource/storage_data_source.dart';
import 'package:edconnect_admin/data/datasource/user_data_source.dart';
import 'package:edconnect_admin/domain/services/pdf_service.dart';
import 'package:edconnect_admin/domain/utils/registration_utils.dart';
import 'package:edconnect_admin/domain/utils/validation_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/interfaces/auth_repository.dart';
import '../../core/models/app_user.dart';
import '../../domain/entities/registration_request.dart';
import '../../constants/database_constants.dart';

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
  Future<String?> signUp(RegistrationRequest request) async {
    // Validate password match
    if (!passwordConfirmed(request.password, request.confirmedPassword)) {
      return 'Passwords do not match';
    }

    // Filter registration fields
    final filteredFields = request.registrationFields.where((field) {
      return !(field.type == 'checkbox_section' && field.checked != true);
    }).toList();

    // Flatten and validate
    final flattenedFields = flattenRegistrationFields(filteredFields);
    final validationError = validateCustomRegistrationFields(flattenedFields);
    if (validationError.isNotEmpty) {
      return validationError;
    }

    try {
      // Create user
      final uid = await _authDataSource.createUserWithEmailAndPassword(
        request.email.trim(),
        request.password.trim(),
      );

      // Determine groups
      final checkedGroups = flattenedFields
          .where((field) =>
              field.type == 'checkbox_assign_group' && (field.checked ?? false))
          .map((field) => field.group!)
          .toList();

      // Check if user provided a signature
      final hasSignature = flattenedFields.any(
          (field) => field.type == 'signature' && (field.checked ?? false));

      Uint8List pdfBytes;
      Uint8List? signatureBytes;
      String? publicKeyPem;
      if (hasSignature) {
        // Generate signed PDF
        final keyPair = generateRSAKeyPair();
        pdfBytes = await PdfService.generateRegistrationPdf(
          flattenedFields,
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
        signatureBytes = signHash(pdfHash, keyPair.privateKey);

        // Verify signature
        bool isVerified = false;
        try {
          isVerified =
              verifySignature(pdfHash, signatureBytes, keyPair.publicKey);
        } catch (e) {
          // Handle explicit verification exceptions
          return 'SignatureVerificationFailed: ${e.toString()}';
        }

        // Double-check verification result
        if (!isVerified) {
          // Clean up any created user account first
          return 'SignatureVerificationFailed: Signature did not match document';
        }
        publicKeyPem = convertPublicKeyToPem(keyPair.publicKey);

        // Save user with signature
        await _userDataSource.saveUserDetails(
          uid,
          capitalize(request.firstName),
          capitalize(request.lastName),
          request.email.trim(),
          checkedGroups,
          true,
          publicKeyPem: publicKeyPem,
          signatureBytes: signatureBytes,
        );

        // Upload signed PDF
        await _storageDataSource.uploadPdf(
          pdfBytes,
          '${uid}_registration_form_signed.pdf',
          'registration_data/$uid',
        );
      } else {
        // Generate unsigned PDF
        pdfBytes = await PdfService.generateRegistrationPdf(
          flattenedFields,
          false,
          uid,
          request.orgName,
          capitalize(request.firstName),
          capitalize(request.lastName),
          request.email.trim(),
        );

        // Save user without signature
        await _userDataSource.saveUserDetails(
          uid,
          capitalize(request.firstName),
          capitalize(request.lastName),
          request.email.trim(),
          checkedGroups,
          false,
        );

        // Upload unsigned PDF
        await _storageDataSource.uploadPdf(
          pdfBytes,
          '${uid}_registration_form_unsigned.pdf',
          'registration_data/$uid',
        );
      }

      // Process file uploads if any
      final fileUploadFields = flattenedFields
          .where((field) => field.type == 'file_upload' && field.file != null)
          .toList();
      if (fileUploadFields.isNotEmpty) {
        List<Uint8List> fileBytes = [];
        List<String> fileNames = [];

        // Extract bytes and names from PlatformFile objects
        for (var field in fileUploadFields) {
          for (var platformFile in field.file!) {
            if (platformFile.bytes != null) {
              fileBytes.add(platformFile.bytes!);
              fileNames.add(platformFile.name);
            }
          }
        }

        // Call the updated interface with both lists
        if (fileBytes.isNotEmpty) {
          await _storageDataSource.uploadFiles(
            fileBytes,
            fileNames,
            'registration_form/$uid',
          );
        }
      }

      // Send verification email
      await _authDataSource.sendEmailVerification();

      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Check if the email is in our Firestore database
        final snapshot = await _firestore
            .collection(customerSpecificCollectionUsers)
            .where('email', isEqualTo: request.email.trim())
            .get();
        if (snapshot.docs.isEmpty) {
          return 'AccountAlreadyExistsWithOtherOrg';
        } else {
          return 'EmailAlreadyInUse';
        }
      }
      return 'AuthError: ${e.code}';
    } catch (e) {
      return 'UnexpectedError: $e';
    }
  }

  @override
  Future<String?> signUpWithExistingAuthAccount(
      RegistrationRequest request) async {
    try {
      // Filter registration fields
      final filteredFields = request.registrationFields.where((field) {
        return !(field.type == 'checkbox_section' && field.checked != true);
      }).toList();

      // Flatten and validate
      final flattenedFields = flattenRegistrationFields(filteredFields);
      final validationError = validateCustomRegistrationFields(flattenedFields);
      if (validationError.isNotEmpty) {
        return validationError;
      }

      // Try to sign in with existing account
      final signInResult = await _authDataSource.signUpWithExistingAuthAccount(
        request.email.trim(),
        request.password.trim(),
      );

      // Check for auth errors
      if (signInResult == null ||
          signInResult.startsWith('AuthError') ||
          signInResult.startsWith('UnexpectedError')) {
        return signInResult ?? 'Failed to authenticate';
      }

      // Get groups from registration fields
      final checkedGroups = flattenedFields
          .where((field) =>
              field.type == 'checkbox_assign_group' && (field.checked ?? false))
          .map((field) => field.group!)
          .toList();

      // Check if user provided a signature
      final hasSignature = flattenedFields.any(
          (field) => field.type == 'signature' && (field.checked ?? false));

      Uint8List pdfBytes;
      if (hasSignature) {
        // Generate signed PDF
        final keyPair = generateRSAKeyPair();
        pdfBytes = await PdfService.generateRegistrationPdf(
          flattenedFields,
          true,
          signInResult,
          request.orgName,
          capitalize(request.firstName),
          capitalize(request.lastName),
          request.email.trim(),
          publicKey: keyPair.publicKey,
        );

        // Sign the PDF
        final pdfHash = hashBytes(pdfBytes);
        final signatureBytes = signHash(pdfHash, keyPair.privateKey);
        final publicKeyPem = convertPublicKeyToPem(keyPair.publicKey);

        // Save user with signature
        await _userDataSource.saveUserDetails(
          signInResult,
          capitalize(request.firstName),
          capitalize(request.lastName),
          request.email.trim(),
          checkedGroups,
          true,
          publicKeyPem: publicKeyPem,
          signatureBytes: signatureBytes,
        );

        // Upload signed PDF
        await _storageDataSource.uploadPdf(
          pdfBytes,
          '${signInResult}_registration_form_signed.pdf',
          'registration_data/$signInResult',
        );
      } else {
        // Generate unsigned PDF
        pdfBytes = await PdfService.generateRegistrationPdf(
          flattenedFields,
          false,
          signInResult,
          request.orgName,
          capitalize(request.firstName),
          capitalize(request.lastName),
          request.email.trim(),
        );

        // Save user without signature
        await _userDataSource.saveUserDetails(
          signInResult,
          capitalize(request.firstName),
          capitalize(request.lastName),
          request.email.trim(),
          checkedGroups,
          false,
        );

        // Upload unsigned PDF
        await _storageDataSource.uploadPdf(
          pdfBytes,
          '${signInResult}_registration_form_unsigned.pdf',
          'registration_data/$signInResult',
        );
      }

      // Process any file uploads
      final fileUploadFields = flattenedFields
          .where((field) => field.type == 'file_upload' && field.file != null)
          .toList();

      if (fileUploadFields.isNotEmpty) {
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
            'registration_form/$signInResult',
          );
        }
      }

      return null; // Success
    } catch (e) {
      return 'UnexpectedError: $e';
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    await _authDataSource.sendEmailVerification();
  }

  @override
  Future<bool> isEmailVerified() async {
    await _authDataSource.reloadUser();
    return _authDataSource.isEmailVerified;
  }

  @override
  Stream<AppUser?> get currentUserStream {
    return _authDataSource.authStateChanges.asyncMap((uid) async {
      // If no user is logged in, return null immediately
      if (uid == null) {
        return null;
      }

      // Check email verification first since it's part of Firebase Auth
      await _authDataSource.reloadUser();
      final isVerified = _authDataSource.isEmailVerified;

      if (!isVerified) {
        // Return special unverified user state
        return AppUser.unverified(uid);
      }

      try {
        final doc = await _firestore
            .collection(customerSpecificCollectionUsers)
            .doc(uid)
            .get();

        if (doc.exists) {
          return AppUser.fromMap(doc.data()!, doc.id);
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }

      return null;
    });
  }

  @override
  Future<void> signOut() async {
    await _authDataSource.signOut();
  }

  @override
  Future<void> reloadUser() async {
    await _authDataSource.reloadUser();
  }

  @override
  Future<String?> signInWithEmailAndPassword(
      String email, String password) async {
    return await _authDataSource.signInWithEmailAndPassword(email, password);
  }

  @override
  Future<String?> resetPassword(String email) async {
    return await _authDataSource.resetPassword(email);
  }

  @override
  Future<String?> changeEmail(String email) async {
    return await _authDataSource.changeEmail(email);
  }

  @override
  Future<String?> reauthenticate(String password) async {
    return await _authDataSource.reauthenticate(password);
  }

  @override
  Future<String?> changePassword(String newPassword) async {
    return await _authDataSource.changePassword(newPassword);
  }

  @override
  Future<void> deleteAccount() async {
    await _authDataSource.deleteAccount();
  }
}

// Helper function
String capitalize(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}
