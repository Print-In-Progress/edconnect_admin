import 'dart:typed_data';

import 'package:edconnect_admin/domain/entities/storage_file.dart';

abstract class StorageRepository {
  Future<void> uploadPdf(Uint8List pdfBytes, String fileName, String path);

  Future<void> uploadFiles(
    List<Uint8List> files,
    List<String> fileNames,
    String path,
  );

  Future<void> deleteAllUserFiles(String uid);
  Future<List<StorageFile>> listFiles(String path);

  Future<StorageFile> uploadFile(
    Uint8List fileBytes,
    String fileName,
    String path,
    String contentType,
  );

  Future<String> getFileUrl(String path);
  Future<void> deleteFile(String path);
}
