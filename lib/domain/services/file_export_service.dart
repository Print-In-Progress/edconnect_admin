import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:web/web.dart' hide ServiceWorkerRegistration;
import 'dart:js_interop';

/// A simplified service for exporting files across platforms
class FileExportService {
  Future<void> exportFile({
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    if (kIsWeb) {
      await _exportForWeb(bytes, fileName, mimeType);
    } else {
      await _exportForNonWeb(bytes, fileName, mimeType);
    }
  }

  /// Web-specific implementation using modern web APIs
  Future<void> _exportForWeb(
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    try {
      // Convert Uint8List to a format usable by the Blob constructor
      final jsArray = bytes.toJS;

      // Create the blob directly
      final blob =
          Blob([jsArray] as JSArray<JSAny>, BlobPropertyBag(type: mimeType));

      // Create object URL
      final url = URL.createObjectURL(blob);
      HTMLAnchorElement()
        ..href = url
        ..download = url
        ..click();
    } catch (e) {
      rethrow;
    }
  }

  /// Non-web implementation stub
  Future<void> _exportForNonWeb(
    Uint8List bytes,
    String fileName,
    String mimeType,
  ) async {
    throw UnsupportedError(
      'File export for non-web platforms is not implemented yet.',
    );

    // path_provider and share_plus dependencies must be added for this to work
    /*
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/$fileName';
    
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    
    await Share.shareXFiles(
      [XFile(filePath, mimeType: mimeType)],
      subject: 'Class Distribution Results',
    );
    */
  }
}
