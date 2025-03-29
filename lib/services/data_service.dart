import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edconnect_admin/constants/database_constants.dart';
import 'package:edconnect_admin/models/registration_fields.dart';
import 'package:edconnect_admin/services/pdf_service.dart';
import 'package:edconnect_admin/utils/crypto_utils.dart';
import 'package:edconnect_admin/utils/validation_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/export.dart' as pc;

class DataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPdf(
    Uint8List pdfBytes,
    String fileName,
    String uid,
    bool signed,
  ) async {
    final storageRef = _storage.ref();
    final pdfRef = storageRef
        .child('$customerSpecificCollectionFiles/user_data/$uid/$fileName');

    final metaData =
        SettableMetadata(contentType: 'application/pdf', customMetadata: {
      'uploaded_by': uid,
      'signed': signed ? 'true' : 'false',
    });

    final uploadTask = pdfRef.putData(pdfBytes, metaData);
    final snapshot = await uploadTask.whenComplete(() => null);

    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> uploadFiles(
      List<PlatformFile> files, String uid, String fileOrigin) async {
    List<Future<void>> uploadTasks = [];

    SettableMetadata metadata = SettableMetadata(
      customMetadata: {
        'uploaded_by': uid,
        'origin': fileOrigin,
      },
    );

    for (PlatformFile file in files) {
      if (file.path != null) {
        File localFile = File(file.path!);
        uploadTasks.add(_storage
            .ref('$customerSpecificCollectionFiles/user_data/$uid/${file.name}')
            .putFile(localFile, metadata));
      }
    }

    await Future.wait(uploadTasks);
  }

  Future uploadPdfSignature(
      pc.RSAPublicKey? publicKey, Uint8List? signatureBytes) async {
    _firestore
        .collection(customerSpecificCollectionUsers)
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'reg_pdf_public_key': convertPublicKeyToPem(publicKey!),
      'reg_pdf_signature': base64Encode(signatureBytes!),
    });
  }

  Future<void> addGroupsToUser(List<String> groups) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is currently signed in.');
    }

    DocumentReference userDocRef =
        _firestore.collection(customerSpecificCollectionUsers).doc(user.uid);

    await _firestore.runTransaction((transaction) async {
      DocumentSnapshot userDoc = await transaction.get(userDocRef);
      if (!userDoc.exists) {
        throw Exception('User data not found.');
      }

      transaction.update(userDocRef, {'groups': FieldValue.arrayUnion(groups)});
    });
  }

  Future addUserDetails(
    String firstName,
    String lastName,
    String email,
    List<String> groups,
    String uid,
    bool withSignedPdf, {
    pc.RSAPublicKey? publicKey,
    Uint8List? signatureBytes,
  }) async {
    Map<String, dynamic> userDetails = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'groups': groups,
      'registration_timestamp': FieldValue.serverTimestamp(),
      'permissions': ['user'],
      'fcm_token': []
    };

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      userDetails['fcm_token'] = [fcmToken];
    }

    if (withSignedPdf && publicKey != null && signatureBytes != null) {
      // Convert the public key to PEM format
      String publicKeyToPem = convertPublicKeyToPem(publicKey);

      // Convert the signature to a Base64 string for storage
      String signatureBase64 = base64Encode(signatureBytes);

      userDetails['reg_pdf_public_key'] = publicKeyToPem;
      userDetails['reg_pdf_signature'] = signatureBase64;
    }

    CollectionReference userCollection =
        _firestore.collection(customerSpecificCollectionUsers);

    await userCollection.doc(uid).set(userDetails);
  }

  Future<List<BaseRegistrationField>> fetchRegistrationFieldData() async {
    var snapshot = await FirebaseFirestore.instance
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

    // Recursive function to assign child subfields
    List<RegistrationSubField> assignChildSubFields(String parentId) {
      if (!subFieldsMap.containsKey(parentId)) {
        return [];
      }
      return subFieldsMap[parentId]!.map((subField) {
        return RegistrationSubField(
          id: subField.id,
          parentUid: subField.parentUid,
          type: subField.type,
          text: subField.type == 'infobox' ||
                  subField.type == 'checkbox' ||
                  subField.type == 'file_upload'
              ? subField.text
              : null,
          options: subField.type == 'dropdown' ? subField.options : null,
          checked: subField.checked,
          selectedDate: null,
          response: subField.response,
          group:
              subField.type == 'checkbox_assign_group' ? subField.group : null,
          maxFileUploads: subField.maxFileUploads,
          checkboxLabel: subField.checkboxLabel,
          title: subField.title,
          pos: subField.pos,
          childWidgets: assignChildSubFields(subField.id),
        );
      }).toList();
    }

    // Second pass: create fields and assign subfields
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
              childWidgets: assignChildSubFields(doc.id),
            );
          }
          return null;
        })
        .where((field) => field != null)
        .cast<BaseRegistrationField>()
        .toList();

    return registrationFieldList;
  }

  Future<bool> submitRegistrationUpdate({
    required List<BaseRegistrationField> registrationFields,
    required String firstName,
    required String lastName,
    required Function(double progress, String label) onProgress,
  }) async {
    try {
      onProgress(0.0, 'Validating Form');

      // Filter and validate fields
      final filteredFields = registrationFields.where((field) {
        return !(field.type == 'checkbox_section' && field.checked != true);
      }).toList();

      final flattenedList = flattenRegistrationFields(filteredFields);
      final validationResult = validateCustomRegistrationFields(flattenedList);

      if (validationResult.isNotEmpty) {
        return Future.error(validationResult);
      }

      final uid = '';
      final email = '';

      // Check if form is signed
      final hasSignature = flattenedList
          .any((field) => field.type == 'signature' && field.checked == true);

      if (hasSignature) {
        return _handleSignedSubmission(
          flattenedList: flattenedList,
          firstName: firstName,
          lastName: lastName,
          email: email,
          uid: uid,
          onProgress: onProgress,
        );
      } else {
        return _handleUnsignedSubmission(
          flattenedList: flattenedList,
          firstName: firstName,
          lastName: lastName,
          email: email,
          uid: uid,
          onProgress: onProgress,
        );
      }
    } catch (e) {
      return Future.error(e.toString());
    }
  }

  Future<bool> _handleUnsignedSubmission({
    required List<BaseRegistrationField> flattenedList,
    required String firstName,
    required String lastName,
    required String email,
    required String uid,
    required Function(double, String) onProgress,
  }) async {
    try {
      // Generate PDF without signature
      onProgress(0.2, 'Generating Document');
      final pdfBytes = await generatePdf(
          flattenedList, false, uid, customerName, lastName, firstName, email);

      // Upload PDF
      onProgress(0.4, 'Uploading PDF');
      final fileName = '${uid}_registration_form_unsigned.pdf';
      await uploadPdf(pdfBytes, fileName, uid, false);

      // Handle additional data (files and groups)
      await _handleAdditionalData(
        flattenedList: flattenedList,
        uid: uid,
        onProgress: onProgress,
        startProgress: 0.6,
      );

      return true;
    } catch (e) {
      return Future.error('Error in unsigned submission: ${e.toString()}');
    }
  }

  Future<bool> _handleSignedSubmission({
    required List<BaseRegistrationField> flattenedList,
    required String firstName,
    required String lastName,
    required String email,
    required String uid,
    required Function(double, String) onProgress,
  }) async {
    try {
      // Generate signature
      onProgress(0.1, 'Generating Documents');
      final keyPair = generateRSAKeyPair();

      // Generate PDF
      final pdfBytes = await generatePdf(
          flattenedList, true, uid, customerName, lastName, firstName, email);

      // Handle signature
      final pdfHash = hashBytes(pdfBytes);
      final signature = signHash(pdfHash, keyPair.privateKey);
      verifySignature(pdfHash, signature, keyPair.publicKey);

      // Upload signature
      onProgress(0.3, 'Uploading Signature');
      await uploadPdfSignature(keyPair.publicKey, signature);

      // Upload PDF
      onProgress(0.5, 'Uploading PDF');
      final fileName = '${uid}_registration_form.pdf';
      await uploadPdf(pdfBytes, fileName, uid, true);

      // Handle additional data
      await _handleAdditionalData(
        flattenedList: flattenedList,
        uid: uid,
        onProgress: onProgress,
        startProgress: 0.6,
      );

      return true;
    } catch (e) {
      return Future.error('Error in signed submission: ${e.toString()}');
    }
  }

  Future<void> _handleAdditionalData({
    required List<BaseRegistrationField> flattenedList,
    required String uid,
    required Function(double, String) onProgress,
    required double startProgress,
  }) async {
    // Handle files
    onProgress(startProgress, 'Uploading Files');
    final List<PlatformFile> files = flattenedList
        .where((field) => field.type == 'file_upload')
        .expand<PlatformFile>((field) => field.file ?? [])
        .toList();

    if (files.isNotEmpty) {
      await uploadFiles(files, uid, 'registration_form');
    }

    // Handle groups
    onProgress(startProgress + 0.2, 'Adding User to Groups');
    final groups = flattenedList
        .where(
            (field) => field.type == 'checkbox_assign_group' && field.checked!)
        .map((field) => field.group!)
        .toList();

    if (groups.isNotEmpty) {
      await addGroupsToUser(groups);
    }

    onProgress(1.0, 'Submission Complete!');
  }
}
