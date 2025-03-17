import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      user.groups,
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
}
