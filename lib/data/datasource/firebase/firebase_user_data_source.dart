import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edconnect_admin/core/interfaces/group_repository.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/core/utils/validation_utils.dart';
import 'package:edconnect_admin/domain/utils/registration_utils.dart';
import 'package:edconnect_admin/models/registration_fields.dart';
import 'package:edconnect_admin/services/pdf_service.dart';
import 'package:edconnect_admin/utils/crypto_utils.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../constants/database_constants.dart';
import '../user_data_source.dart';
import 'package:pointycastle/export.dart' as pc;

class FirebaseUserDataSource implements UserDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final GroupRepository _groupRepository;

  FirebaseUserDataSource({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    required GroupRepository groupRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _groupRepository = groupRepository;

  @override
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

  @override
  Future<void> changeName(String uid, String firstName, String lastName) async {
    await _firestore.collection(customerSpecificCollectionUsers).doc(uid).set({
      'firstName': firstName,
      'lastName': lastName,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> submitRegistrationUpdate(
      AppUser user, List<RegistrationField> registrationFields) async {
    final filteredFields = registrationFields.where((field) {
      return !(field.type == 'checkbox_section' && field.checked != true);
    }).toList();

    final flattenedList = flattenRegistrationFields(filteredFields);
    final validationResult = validateCustomRegistrationFields(flattenedList);

    if (validationResult.isNotEmpty) {
      throw Exception(validationResult);
    }

    final hasSignature = flattenedList
        .any((field) => field.type == 'signature' && field.checked == true);

    if (hasSignature) {
      return _handleSignedSubmission(
        flattenedList,
        user,
      );
    } else {
      return _handleUnsignedSubmission(
        flattenedList,
        user,
      );
    }
  }

  // Registration submission helper methods
  Future<void> _handleSignedSubmission(
    List<BaseRegistrationField> flattenedList,
    AppUser user,
  ) async {
    try {
      final keyPair = generateRSAKeyPair();

      final pdfBytes = await generatePdf(flattenedList, true, user.id,
          customerName, user.lastName, user.firstName, user.email);

      final pdfHash = hashBytes(pdfBytes);
      final signature = signHash(pdfHash, keyPair.privateKey);
      verifySignature(pdfHash, signature, keyPair.publicKey);

      await _uploadPdfSignature(user.id, keyPair.publicKey, signature);

      final fileName = '${user.id}_registration_form_signed.pdf';
      await _uploadPdf(pdfBytes, fileName, user.id);

      await _handleAdditionalData(
        flattenedList: flattenedList,
        user: user,
      );
    } catch (e) {
      throw Exception('Error signing PDF: $e');
    }
  }

  Future _uploadPdfSignature(
      String uid, pc.RSAPublicKey? publicKey, Uint8List? signatureBytes) async {
    _firestore.collection(customerSpecificCollectionUsers).doc(uid).update({
      'reg_pdf_public_key': convertPublicKeyToPem(publicKey!),
      'reg_pdf_signature': base64Encode(signatureBytes!),
    });
  }

  Future<void> _handleUnsignedSubmission(
    List<BaseRegistrationField> flattenedList,
    AppUser user,
  ) async {
    try {
      // Generate PDF without signature
      final pdfBytes = await generatePdf(flattenedList, false, user.id,
          customerName, user.lastName, user.firstName, user.email);

      // Upload PDF
      final fileName = '${user.id}_registration_form_unsigned.pdf';
      await _uploadPdf(pdfBytes, fileName, user.id);

      // Handle additional data (files and groups)
      await _handleAdditionalData(
        flattenedList: flattenedList,
        user: user,
      );
    } catch (e) {
      return Future.error('Error in unsigned submission: ${e.toString()}');
    }
  }

  Future<String> _uploadPdf(
    Uint8List pdfBytes,
    String fileName,
    String uid,
  ) async {
    final storageRef = _storage.ref();
    final pdfRef = storageRef.child(
        '$customerSpecificCollectionFiles/user_data/$uid/reg_file_$fileName');

    final uploadTask = pdfRef.putData(pdfBytes);
    final snapshot = await uploadTask.whenComplete(() => null);

    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _handleAdditionalData({
    required List<BaseRegistrationField> flattenedList,
    required AppUser user,
  }) async {
    // Handle files
    final fileFields = flattenedList.where((field) =>
        field.type == 'file_upload' &&
        field.file != null &&
        field.file!.isNotEmpty);

    for (final field in fileFields) {
      for (final file in field.file!) {
        // Convert PlatformFile to Uint8List
        final Uint8List fileBytes = file.bytes != null
            ? file.bytes!
            : await File(file.path!).readAsBytes();

        await _uploadPdf(fileBytes, user.id, 'registration_form');
      }
    }

    // Handle groups
    final groups = flattenedList
        .where(
            (field) => field.type == 'checkbox_assign_group' && field.checked!)
        .map((field) => field.group!)
        .toList();

    if (groups.isNotEmpty) {
      // Use the injected repository to update user groups
      await _groupRepository.updateUserGroups(user.id, groups);
    }
  }

  @override
  Future<void> anonymizeUserData(String uid) async {
    final batch = _firestore.batch();

    final commentsQuery = await _firestore
        .collection(customerSpecificCollectionComments)
        .where('author_uid', isEqualTo: uid)
        .get();

    for (var doc in commentsQuery.docs) {
      batch.update(doc.reference, {
        'author_full_name': '[Deleted User]',
        'author_uid': 'anonymous',
      });
    }

    await batch.commit();
  }

  @override
  Future<void> deleteUserDocument(String uid) async {
    await _firestore
        .collection(customerSpecificCollectionUsers)
        .doc(uid)
        .delete();
  }
}
