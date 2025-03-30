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
import 'package:flutter/material.dart';
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

  @override
  Future<List<BaseRegistrationField>> getRegistrationFields() async {
    var snapshot = await _firestore
        .collection(customerSpecificCollectionRegistration)
        .get();

    var docs = snapshot.docs;

    if (snapshot.docs.isEmpty) {
      return [];
    }

    // Sort documents locally in ascending order by 'pos'
    docs.sort((a, b) {
      var aPos = a.data().containsKey('pos') ? a['pos'] : double.maxFinite;
      var bPos = b.data().containsKey('pos') ? b['pos'] : double.maxFinite;
      return aPos.compareTo(bPos);
    });

    // Create a map to hold subfields grouped by parentUid
    Map<String, List<RegistrationSubField>> subFieldsMap = {};

    // First pass: create subfields and group them by parentUid
    for (var doc in docs) {
      var data = doc.data();
      if (data.containsKey('parent_uid')) {
        var subField = RegistrationSubField(
          id: doc.id,
          parentUid: data['parent_uid'] ?? '',
          type: data['type'] ?? '',
          text: data['type'] == 'infobox' ||
                  data['type'] == 'checkbox' ||
                  data['type'] == 'file_upload'
              ? data['text'] ?? ''
              : null,
          options: data['type'] == 'dropdown' ? data['options'] : null,
          group: data['type'] == 'checkbox_assign_group' ? data['group'] : null,
          response: TextEditingController(),
          selectedDate: null,
          checked: false,
          maxFileUploads: data['type'] == 'file_upload'
              ? data['max_file_uploads']?.toInt() ?? 0
              : null,
          checkboxLabel:
              data['type'] == 'checkbox' ? data['checkbox_label'] ?? '' : null,
          title: data['title'] ?? '',
          pos: data['sub_pos']?.toInt() ?? 0,
        );

        if (!subFieldsMap.containsKey(subField.parentUid)) {
          subFieldsMap[subField.parentUid] = [];
        }
        subFieldsMap[subField.parentUid]!.add(subField);
      }
    }

    // Sort subfields by 'pos' within each parentUid group
    subFieldsMap.forEach((key, value) {
      value.sort((a, b) => a.pos.compareTo(b.pos));
    });

    // Create fields and assign subfields
    List<BaseRegistrationField> registrationFieldList = docs
        .map((doc) {
          var data = doc.data();
          if (!data.containsKey('parent_uid')) {
            return RegistrationField(
              id: doc.id,
              type: data['type'] ?? '',
              text: data['type'] == 'infobox' ||
                      data['type'] == 'checkbox' ||
                      data['type'] == 'file_upload'
                  ? data['text'] ?? ''
                  : null,
              options: data['type'] == 'dropdown' ? data['options'] : null,
              group: data['type'] == 'checkbox_assign_group'
                  ? data['group']
                  : null,
              selectedDate: null,
              maxFileUploads: data['type'] == 'file_upload'
                  ? data['max_file_uploads']?.toInt()
                  : null,
              checkboxLabel: data['type'] == 'checkbox'
                  ? data['checkbox_label'] ?? ''
                  : null,
              response: TextEditingController(),
              checked: false,
              title: data['title'] ?? '',
              pos: data['pos']?.toInt() ?? 0,
              childWidgets: subFieldsMap[doc.id] ?? [],
            );
          }
          return null;
        })
        .where((field) => field != null)
        .cast<BaseRegistrationField>()
        .toList();

    return registrationFieldList;
  }
}
