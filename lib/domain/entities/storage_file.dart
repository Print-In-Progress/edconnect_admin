class StorageFile {
  final String id;
  final String name;
  final String url;
  final String contentType;
  final int size;

  const StorageFile({
    required this.id,
    required this.name,
    required this.url,
    required this.contentType,
    required this.size,
  });
}
