import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edconnect_admin/core/interfaces/group_repository.dart';
import 'package:edconnect_admin/core/models/app_user.dart';
import 'package:edconnect_admin/core/utils/crypto_utils.dart';
import 'package:edconnect_admin/core/validation/validators/registration_field_validator.dart';
import 'package:edconnect_admin/data/datasource/storage_data_source.dart';
import 'package:edconnect_admin/domain/services/pdf_service.dart';
import 'package:edconnect_admin/domain/utils/registration_utils.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/database_constants.dart';
import '../user_data_source.dart';

class FirebaseUserDataSource implements UserDataSource {
  final FirebaseFirestore _firestore;
  final StorageDataSource _storageDataSource;
  final GroupRepository _groupRepository;

  FirebaseUserDataSource({
    FirebaseFirestore? firestore,
    required StorageDataSource storageDataSource,
    required GroupRepository groupRepository,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storageDataSource = storageDataSource,
        _groupRepository = groupRepository;

  @override
  Future<void> saveUserDetails(
    String uid,
    String firstName,
    String lastName,
    String email,
    List<String> groups,
    String accountType,
    bool isSigned, {
    String? publicKeyPem,
    Uint8List? signatureBytes,
  }) async {
    final Map<String, dynamic> userData = {
      'first_name': firstName,
      'last_Name': lastName,
      'email': email,
      'groups': groups,
      'permissions': [],
      'fcm_tokens': [],
      'device_ids': {},
      'account_type': accountType,
    };

    if (isSigned && publicKeyPem != null && signatureBytes != null) {
      userData['registration_pdf_public_key'] = publicKeyPem;
      userData['registration_pdf_signature'] = signatureBytes;
    }

    await _firestore
        .collection(customerSpecificCollectionUsers)
        .doc(uid)
        .set(userData, SetOptions(merge: true));
  }

  @override
  Future<void> changeName(String uid, String firstName, String lastName) async {
    await _firestore.collection(customerSpecificCollectionUsers).doc(uid).set({
      'first_name': firstName,
      'last_name': lastName,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> submitRegistrationUpdate(
      AppUser user, List<RegistrationField> registrationFields) async {
    final filteredFields = registrationFields.where((field) {
      return !(field.type == 'checkbox_section' && field.checked != true);
    }).toList();

    final flattenedList = flattenRegistrationFields(filteredFields);
    final validator = RegistrationFieldValidator();
    validator.validate(flattenedList);

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

  Future<void> _handleSignedSubmission(
    List<BaseRegistrationField> flattenedFields,
    AppUser user,
  ) async {
    // Generate key pair and PDF
    final keyPair = generateRSAKeyPair();
    final pdfBytes = await PdfService.generateRegistrationPdf(
      flattenedFields,
      true,
      user.id,
      customerName,
      user.lastName,
      user.firstName,
      user.email,
      publicKey: keyPair.publicKey,
    );

    // Sign PDF
    final pdfHash = hashBytes(pdfBytes);
    final signatureBytes = signHash(pdfHash, keyPair.privateKey);
    final publicKeyPem = convertPublicKeyToPem(keyPair.publicKey);

    // Save signature to user document
    await _firestore
        .collection(customerSpecificCollectionUsers)
        .doc(user.id)
        .update({
      'reg_pdf_public_key': publicKeyPem,
      'reg_pdf_signature': base64Encode(signatureBytes),
    });

    // Upload signed PDF
    await _storageDataSource.uploadPdf(
      pdfBytes,
      '${user.id}_registration_form_signed.pdf',
      user.id,
    );

    // Handle additional data (groups and files)
    await _handleAdditionalData(flattenedFields, user);
  }

  Future<void> _handleUnsignedSubmission(
    List<BaseRegistrationField> flattenedFields,
    AppUser user,
  ) async {
    // Generate PDF without signature
    final pdfBytes = await PdfService.generateRegistrationPdf(
      flattenedFields,
      false,
      user.id,
      customerName,
      user.lastName,
      user.firstName,
      user.email,
    );

    // Upload unsigned PDF
    await _storageDataSource.uploadPdf(
      pdfBytes,
      '${user.id}_registration_form_unsigned.pdf',
      user.id,
    );

    // Handle additional data (groups and files)
    await _handleAdditionalData(flattenedFields, user);
  }

  Future<void> _handleAdditionalData(
    List<BaseRegistrationField> flattenedFields,
    AppUser user,
  ) async {
    // Handle file uploads
    final fileFields = flattenedFields
        .where((field) => field.type == 'file_upload' && field.file != null);

    for (var field in fileFields) {
      List<Uint8List> fileBytes = [];
      List<String> fileNames = [];

      for (var file in field.file!) {
        if (file.bytes != null) {
          fileBytes.add(file.bytes!);
          fileNames.add(file.name);
        }
      }

      if (fileBytes.isNotEmpty) {
        await _storageDataSource.uploadFiles(
          fileBytes,
          fileNames,
          'registration_form/${user.id}',
        );
      }
    }

    // Handle groups
    final groups = flattenedFields
        .where((field) =>
            field.type == 'checkbox_assign_group' && field.checked == true)
        .map((field) => field.group!)
        .toList();

    if (groups.isNotEmpty) {
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
