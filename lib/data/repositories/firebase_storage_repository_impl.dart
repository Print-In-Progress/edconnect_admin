import 'dart:typed_data';
import 'package:edconnect_admin/core/interfaces/storage_repository.dart';
import 'package:edconnect_admin/data/datasource/storage_data_source.dart';
import 'package:edconnect_admin/domain/entities/storage_file.dart';

class FirebaseStorageRepositoryImpl implements StorageRepository {
  final StorageDataSource _dataSource;

  FirebaseStorageRepositoryImpl(this._dataSource);

  @override
  Future<void> uploadPdf(
    Uint8List pdfBytes,
    String fileName,
    String path,
  ) {
    return _dataSource.uploadPdf(pdfBytes, fileName, path);
  }

  @override
  Future<void> uploadFiles(
    List<Uint8List> files,
    List<String> fileNames,
    String path,
  ) {
    // Simply delegate to the data source
    return _dataSource.uploadFiles(files, fileNames, path);
  }

  @override
  Future<StorageFile> uploadFile(
    Uint8List fileBytes,
    String fileName,
    String path,
    String contentType,
  ) async {
    return await _dataSource.uploadFile(fileBytes, fileName, path, contentType);
  }

  @override
  Future<List<StorageFile>> listFiles(String path) async {
    return await _dataSource.listFiles(path);
  }

  @override
  Future<String> getFileUrl(String path) async {
    return await _dataSource.getFileUrl(path);
  }

  @override
  Future<void> deleteFile(String path) {
    return _dataSource.deleteFile(path);
  }

  @override
  Future<void> deleteAllUserFiles(String uid) {
    // Simply delegate to the data source
    return _dataSource.deleteAllUserFiles(uid);
  }
}
