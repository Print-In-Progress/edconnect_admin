import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edconnect_admin/core/errors/domain_exception.dart';
import 'package:edconnect_admin/core/errors/error_handler.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';
import '../../core/interfaces/user_repository.dart';
import '../../core/models/app_user.dart';
import '../datasource/user_data_source.dart';
import '../../core/constants/database_constants.dart';

class FirebaseUserRepositoryImpl implements UserRepository {
  final UserDataSource _userDataSource;
  final FirebaseFirestore _firestore;

  FirebaseUserRepositoryImpl(this._userDataSource,
      {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveUserDetails(AppUser user, bool withSignedPdf) async {
    // If we need to handle signed PDFs but don't have a signature or key, return an error
    try {
      if (withSignedPdf &&
          (user.registrationPdfSignature == null ||
              user.registrationPdfPublicKey == null)) {
        throw const DomainException(
          code: ErrorCode.signatureMissing,
          type: ExceptionType.validation,
        );
      }

      await _userDataSource.saveUserDetails(
        user.id,
        user.firstName,
        user.lastName,
        user.email,
        user.groupIds,
        withSignedPdf,
        publicKeyPem: user.registrationPdfPublicKey,
        signatureBytes: user.registrationPdfSignature,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Stream<AppUser?> getCurrentUserStream(String uid) {
    return _firestore
        .collection(customerSpecificCollectionUsers)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return AppUser.fromMap(snapshot.data()!, snapshot.id);
      }
      return null;
    });
  }

  @override
  Future<void> changeName(String uid, String firstName, String lastName) async {
    try {
      await _userDataSource.changeName(uid, firstName, lastName);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> submitRegistrationUpdate(
      AppUser user, List<RegistrationField> registrationFields) async {
    try {
      await _userDataSource.submitRegistrationUpdate(user, registrationFields);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<AppUser?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(customerSpecificCollectionUsers)
          .doc(userId)
          .get();

      if (!doc.exists || doc.data() == null) {
        throw const DomainException(
          code: ErrorCode.userNotFound,
          type: ExceptionType.database,
        );
      }

      return AppUser.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> anonymizeUserData(String uid) async {
    try {
      await _userDataSource.anonymizeUserData(uid);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> deleteUserDocument(String uid) async {
    try {
      await _userDataSource.deleteUserDocument(uid);
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<BaseRegistrationField>> getRegistrationFields() async {
    try {
      return await _userDataSource.getRegistrationFields();
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
