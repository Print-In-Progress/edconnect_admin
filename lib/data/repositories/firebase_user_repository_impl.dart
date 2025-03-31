import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';
import '../../core/interfaces/user_repository.dart';
import '../../core/models/app_user.dart';
import '../datasource/user_data_source.dart';
import '../../constants/database_constants.dart';

class FirebaseUserRepositoryImpl implements UserRepository {
  final UserDataSource _userDataSource;
  final FirebaseFirestore _firestore;

  FirebaseUserRepositoryImpl(this._userDataSource,
      {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveUserDetails(AppUser user, bool withSignedPdf) async {
    // If we need to handle signed PDFs but don't have a signature or key, return an error
    if (withSignedPdf &&
        (user.registrationPdfSignature == null ||
            user.registrationPdfPublicKey == null)) {
      throw Exception(
          "Cannot save with signed PDF - missing signature or public key");
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
  Future<void> changeName(String uid, String firstName, String lastName) {
    return _userDataSource.changeName(uid, firstName, lastName);
  }

  @override
  Future<void> submitRegistrationUpdate(
      AppUser user, List<RegistrationField> registrationFields) {
    return _userDataSource.submitRegistrationUpdate(user, registrationFields);
  }

  @override
  Future<AppUser?> getUser(String userId) async {
    final doc = await _firestore
        .collection(customerSpecificCollectionUsers)
        .doc(userId)
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap(doc.data()!, doc.id);
  }

  @override
  Future<void> anonymizeUserData(String uid) {
    return _userDataSource.anonymizeUserData(uid);
  }

  @override
  Future<void> deleteUserDocument(String uid) {
    return _userDataSource.deleteUserDocument(uid);
  }

  @override
  Future<List<BaseRegistrationField>> getRegistrationFields() async {
    return await _userDataSource.getRegistrationFields();
  }
}
