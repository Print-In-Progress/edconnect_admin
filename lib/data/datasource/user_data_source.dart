import 'dart:typed_data';

abstract class UserDataSource {
  Future<void> saveUserDetails(
    String uid,
    String firstName,
    String lastName,
    String email,
    List<String> groups,
    bool isSigned, {
    String? publicKeyPem,
    Uint8List? signatureBytes,
  });
}
