import 'dart:typed_data';
import 'package:edconnect_admin/core/interfaces/storage_repository.dart';
import 'package:edconnect_admin/data/datasource/storage_data_source.dart';

class FirebaseStorageRepositoryImpl implements StorageRepository {
  final StorageDataSource _dataSource;

  FirebaseStorageRepositoryImpl(this._dataSource);

  @override
  Future<void> uploadPdf(
    Uint8List pdfBytes,
    String fileName,
    String userId,
    bool isSigned,
  ) {
    return _dataSource.uploadPdf(pdfBytes, fileName, userId, isSigned);
  }

  @override
  Future<void> uploadFiles(
    List<Uint8List> files,
    List<String> fileNames,
    String userId,
    String folder,
  ) {
    // Simply delegate to the data source
    return _dataSource.uploadFiles(files, fileNames, userId, folder);
  }
}
