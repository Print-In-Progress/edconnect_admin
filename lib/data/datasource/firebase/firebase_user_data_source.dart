import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/database_constants.dart';
import '../user_data_source.dart'; // Import the interface

// Ensure the class explicitly implements UserDataSource
class FirebaseUserDataSource implements UserDataSource {
  final FirebaseFirestore _firestore;

  FirebaseUserDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override // Include @override annotation for clarity
  Future<void> saveUserDetails(
    String uid,
    String firstName,
    String lastName,
    String email,
    List<String> groups,
    bool isSigned, {
    String? publicKeyPem,
    Uint8List? signatureBytes,
  }) async {
    final Map<String, dynamic> userData = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'groups': groups,
      'permissions': [],
      'fcmTokens': [],
      'deviceIds': {},
      'accountType': 'Student',
      'registrationComplete': isSigned,
    };

    if (isSigned && publicKeyPem != null && signatureBytes != null) {
      userData['registrationPdfPublicKey'] = publicKeyPem;
      userData['registrationPdfSignature'] = signatureBytes;
    }

    await _firestore
        .collection(customerSpecificCollectionUsers)
        .doc(uid)
        .set(userData, SetOptions(merge: true));
  }
}
