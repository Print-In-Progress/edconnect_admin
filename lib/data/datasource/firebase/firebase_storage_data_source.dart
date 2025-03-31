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
    String path,
  ) async {
    final storageRef = _storage
        .ref()
        .child('$customerSpecificCollectionFiles/$path/$fileName');
    await storageRef.putData(pdfBytes);
  }

  @override
  Future<void> uploadFiles(
    List<Uint8List> files,
    List<String> fileNames,
    String path,
  ) async {
    for (int i = 0; i < files.length; i++) {
      if (i < fileNames.length) {
        final fileName = fileNames[i];
        final storageRef = _storage
            .ref()
            .child('$customerSpecificCollectionFiles/$path/$fileName');
        await storageRef.putData(files[i]);
      }
    }
  }

  @override
  Future<void> deleteAllUserFiles(String uid) async {
    final userStorageRef =
        _storage.ref().child('$customerSpecificCollectionFiles/$uid');

    // List all items in user's directory
    final ListResult result = await userStorageRef.listAll();

    // Delete all files in the root directory
    await Future.wait(result.items.map((ref) => ref.delete()));

    // Recursively delete all prefixes (folders) and their contents
    await Future.wait(result.prefixes.map(_deleteFolder));
  }

  Future<void> _deleteFolder(Reference folderRef) async {
    final ListResult result = await folderRef.listAll();

    await Future.wait([
      ...result.items.map((ref) => ref.delete()),
      ...result.prefixes.map(_deleteFolder),
    ]);
  }
}
