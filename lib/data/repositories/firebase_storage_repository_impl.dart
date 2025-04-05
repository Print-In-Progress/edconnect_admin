import 'dart:typed_data';
import 'package:edconnect_admin/core/errors/domain_exception.dart';
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
  ) async {
    try {
      await _dataSource.uploadPdf(pdfBytes, fileName, path);
    } catch (e) {
      throw DomainException(
        code: ErrorCode.fileUploadFailed,
        type: ExceptionType.storage,
        originalError: e,
      );
    }
  }

  @override
  Future<void> uploadFiles(
    List<Uint8List> files,
    List<String> fileNames,
    String path,
  ) async {
    try {
      await _dataSource.uploadFiles(files, fileNames, path);
    } catch (e) {
      throw DomainException(
        code: ErrorCode.fileUploadFailed,
        type: ExceptionType.storage,
        originalError: e,
      );
    }
  }

  @override
  Future<StorageFile> uploadFile(
    Uint8List fileBytes,
    String fileName,
    String path,
    String contentType,
  ) async {
    try {
      return await _dataSource.uploadFile(
          fileBytes, fileName, path, contentType);
    } catch (e) {
      throw DomainException(
        code: ErrorCode.fileUploadFailed,
        type: ExceptionType.storage,
        originalError: e,
      );
    }
  }

  @override
  Future<List<StorageFile>> listFiles(String path) async {
    try {
      return await _dataSource.listFiles(path);
    } catch (e) {
      throw DomainException(
        code: ErrorCode.fileListFailed,
        type: ExceptionType.storage,
        originalError: e,
      );
    }
  }

  @override
  Future<String> getFileUrl(String path) async {
    try {
      return await _dataSource.getFileUrl(path);
    } catch (e) {
      throw DomainException(
        code: ErrorCode.fileNotFound,
        type: ExceptionType.storage,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteFile(String path) async {
    try {
      await _dataSource.deleteFile(path);
    } catch (e) {
      throw DomainException(
        code: ErrorCode.fileDeleteFailed,
        type: ExceptionType.storage,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteAllUserFiles(String uid) async {
    try {
      await _dataSource.deleteAllUserFiles(uid);
    } catch (e) {
      throw DomainException(
        code: ErrorCode.fileDeleteFailed,
        type: ExceptionType.storage,
        originalError: e,
      );
    }
  }
}
