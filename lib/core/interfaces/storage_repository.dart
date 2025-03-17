import 'dart:typed_data';

abstract class StorageRepository {
  Future<void> uploadPdf(
      Uint8List pdfBytes, String fileName, String userId, bool isSigned);

  Future<void> uploadFiles(List<Uint8List> files, List<String> fileNames,
      String userId, String folder);
}
