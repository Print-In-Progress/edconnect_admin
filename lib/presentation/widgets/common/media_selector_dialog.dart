import 'package:edconnect_admin/domain/entities/media_selection_options.dart';
import 'package:edconnect_admin/domain/entities/storage_file.dart';
import 'package:edconnect_admin/domain/entities/storage_module.dart';
import 'package:edconnect_admin/presentation/providers/action_providers.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons.dart';
import 'package:edconnect_admin/presentation/widgets/common/snackbars.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MediaSelectorDialog extends ConsumerStatefulWidget {
  final MediaSelectionOptions options;
  final Function(StorageFile file) onFileSelected;

  const MediaSelectorDialog({
    super.key,
    required this.options,
    required this.onFileSelected,
  });

  @override
  ConsumerState<MediaSelectorDialog> createState() =>
      _MediaSelectorDialogState();
}

class _MediaSelectorDialogState extends ConsumerState<MediaSelectorDialog> {
  MediaSource _selectedSource = MediaSource.storage;
  final Set<StorageModule> _selectedModules = {};
  final _webUrlController = TextEditingController();
  final _searchController = TextEditingController();
  double? _uploadProgress;
  String _searchQuery = '';
  StorageFile? _selectedFile;

  @override
  void initState() {
    super.initState();
    _selectedModules.addAll(widget.options.allowedModules);
  }

  @override
  void dispose() {
    _webUrlController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildStorageBrowser() {
    return Column(
      children: [
        // Module selection
        Wrap(
          spacing: 8,
          children: widget.options.allowedModules.map((module) {
            return FilterChip(
              selected: _selectedModules.contains(module),
              label: Text(module.displayName),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedModules.add(module);
                  } else {
                    _selectedModules.remove(module);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 8),

        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search files...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
          ),
          onChanged: (value) => setState(() => _searchQuery = value),
        ),
        const SizedBox(height: 16),

        // Files list
        Expanded(
          child: ref.watch(moduleStorageFilesProvider(_selectedModules)).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
                data: (files) {
                  final filteredFiles = files.where((file) =>
                      widget.options.allowedContentTypes
                          .contains(file.contentType) &&
                      (file.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()) ||
                          _searchQuery.isEmpty));

                  return ListView.builder(
                    itemCount: filteredFiles.length,
                    itemBuilder: (context, index) {
                      final file = filteredFiles.elementAt(index);
                      final module = _getModuleFromPath(file.id);
                      final isSelected = _selectedFile?.id == file.id;

                      return ListTile(
                        leading: _buildMediaPreview(file),
                        title: Text(file.name),
                        subtitle: Text(
                            '${module.displayName} • ${file.size ~/ 1024} KB'),
                        selected: isSelected,
                        selectedTileColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        onTap: () => setState(() => _selectedFile = file),
                      );
                    },
                  );
                },
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getDialogTitle(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 24.0),
              ),
              const SizedBox(height: 16),

              // Source selection
              SegmentedButton<MediaSource>(
                segments: widget.options.allowedSources
                    .map((source) => ButtonSegment<MediaSource>(
                          value: source,
                          label: Text(source.label),
                          icon: Icon(source.icon),
                        ))
                    .toList(),
                selected: {_selectedSource},
                onSelectionChanged: (Set<MediaSource> selection) {
                  setState(() {
                    _selectedSource = selection.first;
                    _selectedFile = null;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Content based on selected source
              Expanded(
                child: switch (_selectedSource) {
                  MediaSource.local => _buildLocalUploader(),
                  MediaSource.web => _buildWebUrlInput(),
                  MediaSource.storage => _buildStorageBrowser(),
                },
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const PIPCancelButton(),
                  PIPDialogTextButton(
                    label: 'Ok',
                    onPressed: _handleSubmit,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  StorageModule _getModuleFromPath(String path) {
    return StorageModule.values.firstWhere(
      (module) => path.startsWith(module.path),
      orElse: () => StorageModule.personalStorage,
    );
  }

  Widget _buildMediaPreview(StorageFile file) {
    if (file.contentType.startsWith('image/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Image.network(
          file.url,
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.broken_image, size: 48);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          },
        ),
      );
    }

    // Return appropriate icon based on media type
    IconData icon = switch (file.contentType) {
      String s when s.startsWith('video/') => Icons.video_file,
      String s when s.startsWith('audio/') => Icons.audio_file,
      _ => Icons.insert_drive_file,
    };

    return Icon(icon, size: 48);
  }

  Widget _buildLocalUploader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: Text('File Selecter'),
          onPressed: _handleLocalFileSelection,
        ),
        if (_uploadProgress != null) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(value: _uploadProgress),
        ],
      ],
    );
  }

  Widget _buildWebUrlInput() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: _webUrlController,
          decoration: InputDecoration(
            labelText: 'URL',
            hintText: 'Enter the URL of the media file',
          ),
        ),
      ],
    );
  }

  Widget _buildFilesList() {
    return ref.watch(moduleStorageFilesProvider(_selectedModules)).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (files) {
            final filteredFiles = files.where((file) =>
                widget.options.allowedContentTypes.contains(file.contentType) &&
                (file.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                    _searchQuery.isEmpty));

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filteredFiles.length,
              itemBuilder: (context, index) {
                final file = filteredFiles.elementAt(index);
                return _buildFileGridItem(file);
              },
            );
          },
        );
  }

  Widget _buildFileGridItem(StorageFile file) {
    final isSelected = _selectedFile?.id == file.id;

    return InkWell(
      onTap: () => setState(() => _selectedFile = file),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildFilePreview(file),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                file.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview(StorageFile file) {
    if (file.contentType.startsWith('image/')) {
      return Image.network(
        file.url,
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      );
    } else {
      return Icon(
        _getFileTypeIcon(file.contentType),
        size: 48,
      );
    }
  }

  IconData _getFileTypeIcon(String contentType) {
    if (contentType.startsWith('video/')) return Icons.video_file;
    if (contentType.startsWith('audio/')) return Icons.audio_file;
    return Icons.insert_drive_file;
  }

  Future<void> _handleLocalFileSelection() async {
    final result = await FilePicker.platform.pickFiles(
      type: _getFileType(),
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      // Handle file upload using your storage provider
    }
  }

  FileType _getFileType() {
    return switch (widget.options.mediaType) {
      MediaType.image => FileType.image,
      MediaType.video => FileType.video,
      MediaType.audio => FileType.audio,
    };
  }

  String _getDialogTitle() {
    return switch (widget.options.mediaType) {
      MediaType.image =>
        AppLocalizations.of(context)!.textEditorInsertImageDialogTitle,
      MediaType.video =>
        AppLocalizations.of(context)!.textEditorInsertVideoDialogTitle,
      MediaType.audio =>
        AppLocalizations.of(context)!.textEditorInsertAudioDialogTitle,
    };
  }

  void _handleSubmit() {
    switch (_selectedSource) {
      case MediaSource.local:
        // Handle local file
        break;
      case MediaSource.web:
        // Handle web URL
        break;
      case MediaSource.storage:
        if (_selectedFile != null) {
          widget.onFileSelected(_selectedFile!);
          Navigator.of(context).pop();
        } else {
          errorMessage(context, 'Please select a file');
        }
        break;
    }
  }
}
