import 'dart:typed_data';
import 'package:edconnect_admin/constants/database_constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../storage_data_source.dart';

class FirebaseStorageDataSource implements StorageDataSource {
  final FirebaseStorage _storage;

  FirebaseStorageDataSource({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<void> uploadPdf(
    Uint8List pdfBytes,
    String fileName,
    String uid,
    bool isSigned,
  ) async {
    final storageRef = _storage
        .ref()
        .child('$customerSpecificCollectionFiles/$uid/registration/$fileName');
    await storageRef.putData(pdfBytes);
  }

  @override
  Future<void> uploadFiles(
    List<Uint8List> files,
    List<String> fileNames,
    String uid,
    String folder,
  ) async {
    for (int i = 0; i < files.length; i++) {
      if (i < fileNames.length) {
        final fileName = fileNames[i];
        final storageRef = _storage
            .ref()
            .child('$customerSpecificCollectionFiles/$uid/$folder/$fileName');
        await storageRef.putData(files[i]);
      }
    }
  }
}
