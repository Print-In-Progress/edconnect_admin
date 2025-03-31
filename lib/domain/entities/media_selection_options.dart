import 'package:edconnect_admin/domain/entities/storage_module.dart';
import 'package:flutter/material.dart';

enum MediaSource {
  local("From Computer", Icons.computer_outlined),
  web("From Web", Icons.language),
  storage("From Storage", Icons.perm_media_outlined);

  final String label;
  final IconData icon;
  const MediaSource(this.label, this.icon);
}

enum MediaType { image, video, audio }

class MediaSelectionOptions {
  final List<MediaSource> allowedSources;
  final List<StorageModule> allowedModules;
  final MediaType mediaType;
  final List<String> allowedContentTypes;
  final int? maxFileSize;

  const MediaSelectionOptions({
    required this.allowedSources,
    required this.allowedModules,
    required this.mediaType,
    required this.allowedContentTypes,
    this.maxFileSize,
  });
}
