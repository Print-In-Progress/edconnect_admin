import 'dart:typed_data';

abstract class StorageDataSource {
  Future<void> uploadPdf(
    Uint8List pdfBytes,
    String fileName,
    String path,
  );

  Future<void> uploadFiles(
    List<Uint8List> files,
    List<String> fileNames,
    String path,
  );

  Future<void> deleteAllUserFiles(String uid);
}
