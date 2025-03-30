import 'dart:typed_data';

abstract class StorageDataSource {
  Future<void> uploadPdf(
    Uint8List pdfBytes,
    String fileName,
    String uid,
    bool isSigned,
  );

  Future<void> uploadFiles(
    List<Uint8List> files,
    List<String> fileNames,
    String uid,
    String folder,
  );

  Future<void> deleteAllUserFiles(String uid);
}
