import 'dart:typed_data';
import 'package:edconnect_admin/constants/database_constants.dart';
import 'package:edconnect_admin/domain/entities/storage_file.dart';
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
  Future<StorageFile> uploadFile(
    Uint8List fileBytes,
    String fileName,
    String path,
    String contentType,
  ) async {
    final fullPath = '$customerSpecificCollectionFiles/$path/$fileName';
    final ref = _storage.ref().child(fullPath);

    final uploadTask = await ref.putData(
      fileBytes,
      SettableMetadata(contentType: contentType),
    );

    final url = await ref.getDownloadURL();

    return StorageFile(
      id: fullPath,
      name: fileName,
      url: url,
      contentType: contentType,
      size: uploadTask.totalBytes,
    );
  }

  @override
  Future<List<StorageFile>> listFiles(String path) async {
    final fullPath = '$customerSpecificCollectionFiles/$path';
    final result = await _storage.ref().child(fullPath).listAll();

    final files = <StorageFile>[];
    for (var item in result.items) {
      final url = await item.getDownloadURL();
      final data = await item.getMetadata();

      files.add(StorageFile(
        id: item.fullPath,
        name: item.name,
        url: url,
        contentType: data.contentType ?? 'application/octet-stream',
        size: data.size ?? 0,
      ));
    }

    return files;
  }

  @override
  Future<String> getFileUrl(String path) async {
    return await _storage.ref().child(path).getDownloadURL();
  }

  @override
  Future<void> deleteFile(String path) async {
    await _storage
        .ref()
        .child("$customerSpecificCollectionFiles/$path")
        .delete();
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
