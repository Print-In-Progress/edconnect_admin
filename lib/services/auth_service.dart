import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edconnect_admin/constants/database_constants.dart';
import 'package:edconnect_admin/models/registration_fields.dart';
import 'package:edconnect_admin/services/pdf_service.dart';
import 'package:edconnect_admin/services/data_service.dart';
import 'package:edconnect_admin/utils/crypto_utils.dart';
import 'package:edconnect_admin/utils/validation_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  unverified,
  authenticated,
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signUp(
    String email,
    String firstName,
    String lastName,
    String password,
    String confirmedPassword,
    String orgName,
    List<BaseRegistrationField> registrationFields,
  ) async {
    if (!passwordConfirmed(password, confirmedPassword)) {
      return 'PasswordsDoNotMatch';
    }
    // Create User
    try {
      List<BaseRegistrationField> filteredFields =
          registrationFields.where((field) {
        return !(field.type == 'checkbox_section' && field.checked != true);
      }).toList();

      // Flatten the filtered list of fields
      List<BaseRegistrationField> flattenedRegistrationList =
          flattenRegistrationFields(filteredFields);

      String validateRegistrationFields =
          validateCustomRegistrationFields(flattenedRegistrationList);

      if (validateRegistrationFields.isEmpty) {
        bool hasCheckedSignatureField = flattenedRegistrationList
            .any((field) => field.type == 'signature' && field.checked == true);
        if (registrationFields.isEmpty) {
          await _auth
              .createUserWithEmailAndPassword(
                  email: firstName.trim(), password: password.trim())
              .then((value) async {
            final uid = FirebaseAuth.instance.currentUser!.uid;
            List<String> checkedCheckboxAssignGroupValues =
                flattenedRegistrationList
                    .where((field) =>
                        field.type == 'checkbox_assign_group' &&
                        field.checked == true)
                    .map((field) => field.group!)
                    .toList();

            await DataService().addUserDetails(
              firstName.trim()[0].toUpperCase() + firstName.trim().substring(1),
              lastName.trim()[0].toUpperCase() + lastName.trim().substring(1),
              email.trim(),
              checkedCheckboxAssignGroupValues,
              uid,
              false,
            );
          });
        } else if (hasCheckedSignatureField) {
          await _auth
              .createUserWithEmailAndPassword(
                  email: email.trim(), password: password.trim())
              .then((value) async {
            final uid = FirebaseAuth.instance.currentUser!.uid;
            List<String> checkedCheckboxAssignGroupValues =
                flattenedRegistrationList
                    .where((field) =>
                        field.type == 'checkbox_assign_group' &&
                        field.checked == true)
                    .map((field) => field.group!)
                    .toList();

            final keyPair = generateRSAKeyPair();
            final pdfBytes = await generatePdf(
                flattenedRegistrationList,
                true,
                uid,
                orgName,
                lastName.trim()[0].toUpperCase() + lastName.trim().substring(1),
                firstName.trim()[0].toUpperCase() +
                    firstName.trim().substring(1),
                email.trim(),
                publicKey: keyPair.publicKey);
            final pdfHash = hashBytes(pdfBytes);

            final signature = signHash(pdfHash, keyPair.privateKey);

            verifySignature(pdfHash, signature, keyPair.publicKey);

            await DataService()
                .addUserDetails(
              firstName.trim()[0].toUpperCase() + firstName.trim().substring(1),
              lastName.trim()[0].toUpperCase() + lastName.trim().substring(1),
              email.trim(),
              checkedCheckboxAssignGroupValues,
              uid,
              true,
              publicKey: keyPair.publicKey,
              signatureBytes: signature,
            )
                .then((value) async {
              final fileName = '${uid}_registration_form.pdf';

              await DataService().uploadPdf(
                pdfBytes,
                fileName,
                uid,
                true,
              );
              List<PlatformFile> files = [];
              for (var field in flattenedRegistrationList) {
                if (field.type == 'file_upload') {
                  files.addAll(field.file ?? []);
                }
              }
              if (files.isNotEmpty) {
                await DataService()
                    .uploadFiles(files, uid, 'registration_form');
              }
            });
          });
        } else {
          await _auth
              .createUserWithEmailAndPassword(
                  email: email.trim(), password: password.trim())
              .then((value) async {
            final uid = FirebaseAuth.instance.currentUser!.uid;
            List<String> checkedCheckboxAssignGroupValues =
                flattenedRegistrationList
                    .where((field) =>
                        field.type == 'checkbox_assign_group' &&
                        field.checked == true)
                    .map((field) => field.group!)
                    .toList();

            await DataService()
                .addUserDetails(
              firstName.trim()[0].toUpperCase() + firstName.trim().substring(1),
              lastName.trim()[0].toUpperCase() + lastName.trim().substring(1),
              email.trim(),
              checkedCheckboxAssignGroupValues,
              uid,
              false,
            )
                .then((value) async {
              final pdfBytes = await generatePdf(
                flattenedRegistrationList,
                false,
                uid,
                orgName,
                firstName.trim()[0].toUpperCase() +
                    firstName.trim().substring(1),
                lastName.trim()[0].toUpperCase() + lastName.trim().substring(1),
                email.trim(),
              );

              final fileName = '${uid}_registration_form.pdf';

              await DataService().uploadPdf(
                pdfBytes,
                fileName,
                uid,
                false,
              );
              List<PlatformFile> files = [];
              for (var field in flattenedRegistrationList) {
                if (field.type == 'file_upload') {
                  files.addAll(field.file!);
                }
              }
              if (files.isNotEmpty) {
                await DataService()
                    .uploadFiles(files, uid, 'registration_form');
              }
            });
          });
        }
      } else {
        return validateRegistrationFields;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final snapshot = await FirebaseFirestore.instance
            .collection(customerSpecificCollectionUsers)
            .where('email', isEqualTo: email.trim())
            .get();
        if (snapshot.docs.isEmpty) {
          return 'AccountAlreadyExistsWithOtherOrg';
        } else {
          return 'EmailAlreadyInUse';
        }
      } else {
        return 'AuthError ${e.code}';
      }
    } on Exception catch (e) {
      return 'UnexpectedError $e';
    }
    return null;
  }

  Future<String?> signUpToOrg(
    String email,
    String firstName,
    String lastName,
    String password,
    String confirmedPassword,
    String orgName,
    List<BaseRegistrationField> registrationFields,
  ) async {
    if (!passwordConfirmed(password, confirmedPassword)) {
      return 'PasswordsDoNotMatch';
    }
    // Create User
    try {
      // Filter out fields of type 'checkbox_section' whose 'checked' parameter is not true
      List<BaseRegistrationField> filteredFields =
          registrationFields.where((field) {
        return !(field.type == 'checkbox_section' && field.checked != true);
      }).toList();

      // Flatten the filtered list of fields
      List<BaseRegistrationField> flattenedRegistrationList =
          flattenRegistrationFields(filteredFields);

      String validateRegistrationFields =
          validateCustomRegistrationFields(flattenedRegistrationList);

      if (validateRegistrationFields.isEmpty) {
        bool hasCheckedSignatureField = flattenedRegistrationList
            .any((field) => field.type == 'signature' && field.checked == true);
        if (registrationFields.isEmpty) {
          await _auth
              .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
              .then((value) async {
            final uid = FirebaseAuth.instance.currentUser!.uid;
            List<String> checkedCheckboxAssignGroupValues =
                flattenedRegistrationList
                    .where((field) =>
                        field.type == 'checkbox_assign_group' &&
                        field.checked == true)
                    .map((field) => field.group!)
                    .toList();

            await DataService().addUserDetails(
              firstName.trim()[0].toUpperCase() + firstName.trim().substring(1),
              lastName.trim()[0].toUpperCase() + lastName.trim().substring(1),
              email.trim(),
              checkedCheckboxAssignGroupValues,
              uid,
              false,
            );
          });
        } else if (hasCheckedSignatureField) {
          await _auth
              .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
              .then((value) async {
            final uid = FirebaseAuth.instance.currentUser!.uid;
            List<String> checkedCheckboxAssignGroupValues =
                flattenedRegistrationList
                    .where((field) =>
                        field.type == 'checkbox_assign_group' &&
                        field.checked == true)
                    .map((field) => field.group!)
                    .toList();

            final keyPair = generateRSAKeyPair();
            final pdfBytes = await generatePdf(
                flattenedRegistrationList,
                true,
                uid,
                orgName,
                lastName.trim()[0].toUpperCase() + lastName.trim().substring(1),
                firstName.trim()[0].toUpperCase() +
                    firstName.trim().substring(1),
                email.trim(),
                publicKey: keyPair.publicKey);
            final pdfHash = hashBytes(pdfBytes);

            final signature = signHash(pdfHash, keyPair.privateKey);

            verifySignature(pdfHash, signature, keyPair.publicKey);
            await DataService()
                .addUserDetails(
                    firstName.trim()[0].toUpperCase() +
                        firstName.trim().substring(1),
                    lastName.trim()[0].toUpperCase() +
                        lastName.trim().substring(1),
                    email.trim(),
                    checkedCheckboxAssignGroupValues,
                    uid,
                    true,
                    publicKey: keyPair.publicKey,
                    signatureBytes: signature)
                .then((value) async {
              final fileName = '${uid}_registration_form.pdf';

              await DataService().uploadPdf(
                pdfBytes,
                fileName,
                uid,
                true,
              );
              List<PlatformFile> files = [];
              for (var field in flattenedRegistrationList) {
                if (field.type == 'file_upload') {
                  files.addAll(field.file ?? []);
                }
              }
              if (files.isNotEmpty) {
                await DataService()
                    .uploadFiles(files, uid, 'registration_form');
              }
            });
          });
        } else {
          await _auth
              .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          )
              .then((value) async {
            final uid = FirebaseAuth.instance.currentUser!.uid;
            List<String> checkedCheckboxAssignGroupValues =
                flattenedRegistrationList
                    .where((field) =>
                        field.type == 'checkbox_assign_group' &&
                        field.checked == true)
                    .map((field) => field.group!)
                    .toList();

            await DataService()
                .addUserDetails(
              firstName.trim()[0].toUpperCase() + firstName.trim().substring(1),
              lastName.trim()[0].toUpperCase() + lastName.trim().substring(1),
              email.trim(),
              checkedCheckboxAssignGroupValues,
              uid,
              false,
            )
                .then((value) async {
              final pdfBytes = await generatePdf(
                flattenedRegistrationList,
                false,
                uid,
                orgName,
                firstName.trim()[0].toUpperCase() +
                    firstName.trim().substring(1),
                lastName.trim()[0].toUpperCase() + lastName.trim().substring(1),
                email.trim(),
              );

              final fileName = '${uid}_registration_form.pdf';

              await DataService().uploadPdf(
                pdfBytes,
                fileName,
                uid,
                false,
              );
              List<PlatformFile> files = [];
              for (var field in flattenedRegistrationList) {
                if (field.type == 'file_upload') {
                  files.addAll(field.file!);
                }
              }
              if (files.isNotEmpty) {
                await DataService()
                    .uploadFiles(files, uid, 'registration_form');
              }
            });
          });
        }
      } else {
        return validateRegistrationFields;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        final snapshot = await FirebaseFirestore.instance
            .collection(customerSpecificCollectionUsers)
            .where('email', isEqualTo: email.trim())
            .get();
        if (snapshot.docs.isEmpty) {
          return 'AccountAlreadyExistsWithOtherOrg';
        } else {
          return 'EmailAlreadyInUse';
        }
      } else {
        return 'AuthError ${e.code}';
      }
    } on Exception catch (e) {
      return 'UnexpectedError $e';
    }
    return null;
  }

  Future<String> signIn(
    String email,
    String password,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      return 'Success';
    } on FirebaseAuthException catch (e) {
      return 'AuthError ${e.message}';
    } catch (e) {
      return 'UnexpectedError $e';
    }
  }

  Future<void> deleteUserAccount({
    required String password,
  }) async {
    // Reauthenticate first
    await _auth.currentUser!.reauthenticateWithCredential(
      EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: password,
      ),
    );

    final uid = _auth.currentUser!.uid;

    // Create batch for Firestore operations
    var batch = FirebaseFirestore.instance.batch();

    // Update comments
    final querySnapshot = await FirebaseFirestore.instance
        .collection(customerSpecificCollectionComments)
        .where('author_uid', isEqualTo: uid)
        .get();

    for (var doc in querySnapshot.docs) {
      batch.update(doc.reference, {'author_full_name': '', 'author_uid': ''});
    }

    // Delete user document
    batch.delete(FirebaseFirestore.instance
        .collection(customerSpecificCollectionUsers)
        .doc(uid));

    // Commit batch
    await batch.commit();

    // Delete storage files
    await _deleteUserFiles(uid);

    // Finally delete the auth account
    await _auth.currentUser!.delete();
  }

  Future<void> _deleteUserFiles(String uid) async {
    final userFolderRef = FirebaseStorage.instance
        .ref()
        .child('$customerSpecificCollectionFiles/user_data/$uid');

    try {
      final listResult = await userFolderRef.listAll();
      final deleteFutures = listResult.items.map((item) => item.delete());
      await Future.wait(deleteFutures);
    } catch (e) {
      // Log error but don't stop deletion process
      debugPrint('Error deleting user files: $e');
    }
  }

  Future<void> updateUserName({
    required String firstName,
    required String lastName,
  }) async {
    try {
      final uid = _auth.currentUser!.uid;
      await FirebaseFirestore.instance
          .collection(customerSpecificCollectionUsers)
          .doc(uid)
          .update({
        'first_name': firstName,
        'last_name': lastName,
      });

      // Log the event
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmedPassword,
  }) async {
    final currentUser = _auth.currentUser;
    if (!passwordConfirmed(newPassword, confirmedPassword)) {
      throw FirebaseAuthException(
        code: 'passwords-do-not-match',
        message: 'Passwords do not match.',
      );
    }
    if (currentUser == null || currentUser.email == null) {
      throw FirebaseAuthException(
        code: 'no-user',
        message: 'No user is currently signed in.',
      );
    }

    // Reauthenticate user
    final credential = EmailAuthProvider.credential(
      email: currentUser.email!,
      password: currentPassword,
    );
    await currentUser.reauthenticateWithCredential(credential);

    // Update password
    await currentUser.updatePassword(newPassword);
  }

  Future<String> updateEmail(newEmail) async {
    try {
      await FirebaseAuth.instance.currentUser!
          .verifyBeforeUpdateEmail(newEmail);

      final uid = FirebaseAuth.instance.currentUser!.uid;
      var userCollection = FirebaseFirestore.instance
          .collection(customerSpecificCollectionUsers);

      await userCollection.doc(uid).update({'email': newEmail});
      return 'Success';
    } catch (e) {
      return 'UnexpectedError';
    }
  }
}
