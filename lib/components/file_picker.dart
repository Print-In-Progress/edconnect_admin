import 'package:edconnect_admin/components/buttons.dart';
import 'package:edconnect_admin/components/snackbars.dart';
import 'package:edconnect_admin/constants/database_constants.dart';
import 'package:edconnect_admin/models/firebase_file.dart';
import 'package:edconnect_admin/models/providers/themeprovider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ImageOptions { drive, web, filesModule }

class ImagePicker extends ConsumerStatefulWidget {
  const ImagePicker({super.key});

  @override
  ConsumerState<ImagePicker> createState() => _ImagePickerState();
}

class _ImagePickerState extends ConsumerState<ImagePicker> {
  static Future<List<String>> _getDownloadLinks(List<Reference> refs) =>
      Future.wait(refs.map((ref) => ref.getDownloadURL()).toList());

  static Future<List<FullMetadata>> _getMetaData(List<Reference> refs) =>
      Future.wait(refs.map((ref) => ref.getMetadata()).toList());

  static Future<List<FirebaseFile>> listAll(String path) async {
    final ref = FirebaseStorage.instance.ref(path);
    final result = await ref.listAll();

    final urls = await _getDownloadLinks(result.items);
    final metaDataAll = await _getMetaData(result.items);

    return urls
        .asMap()
        .map((index, url) {
          List<FullMetadata> metaDataList = metaDataAll
              .asMap()
              .map((index, metaData) {
                return MapEntry(index, metaData);
              })
              .values
              .toList();

          final ref = result.items[index];
          final name = ref.name;

          final file = FirebaseFile(
              ref: ref, name: name, url: url, metaData: metaDataList[index]);

          return MapEntry(index, file);
        })
        .values
        .toList();
  }

  late Future<List<FirebaseFile>> futureFiles;

  ImageOptions imageOption = ImageOptions.drive;
  String imageURL = "";
  String fileName = '';
  String filesModuleSearchQuery = '';

  double? _uploadProgress;

  TextEditingController linkFromWebController = TextEditingController();
  TextEditingController imageFilesModuleSearchController =
      TextEditingController();

  @override
  void initState() {
    futureFiles = listAll(customerSpecificCollectionFiles);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorState = ref.watch(colorAndLogoProvider);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.textEditorInsertImageDialogTitle,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            ),
            SegmentedButton<ImageOptions>(
              segments: <ButtonSegment<ImageOptions>>[
                ButtonSegment(
                    label: Text(AppLocalizations.of(context)!
                        .textEditorFromComputerSegmentLabel),
                    value: ImageOptions.drive,
                    icon: const Icon(Icons.computer_outlined)),
                ButtonSegment(
                    label: Text(AppLocalizations.of(context)!
                        .textEditorFromWebSegmentLabel),
                    value: ImageOptions.web,
                    icon: const Icon(Icons.language)),
                ButtonSegment(
                    label: Text(AppLocalizations.of(context)!
                        .textEditorFromFilesModuleSegmentLabel),
                    value: ImageOptions.filesModule,
                    icon: const Icon(
                      Icons.perm_media_outlined,
                    )),
              ],
              selected: <ImageOptions>{imageOption},
              onSelectionChanged: (Set<ImageOptions> newSelection) {
                setState(() {
                  imageOption = newSelection.first;
                });
              },
            ),
            switch (imageOption) {
              ImageOptions.drive => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                            onPressed: () async {
                              UploadTask? uploadTask;
                              final result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.image,
                              );
                              if (result != null && result.files.isNotEmpty) {
                                final fileBytes = result.files.first.bytes;
                                final path =
                                    '$customerSpecificCollectionFiles/${result.files.first.name}';

                                final ref =
                                    FirebaseStorage.instance.ref().child(path);
                                uploadTask = ref.putData(fileBytes!,
                                    SettableMetadata(contentType: 'image'));

                                uploadTask.snapshotEvents.listen((event) {
                                  setState(() {
                                    _uploadProgress =
                                        event.bytesTransferred.toDouble() /
                                            event.totalBytes.toDouble();
                                  });
                                  if (event.state == TaskState.success) {
                                    _uploadProgress = null;
                                  }
                                }).onError((error) {
                                  errorMessage(context, error.toString());
                                });

                                final snapshot =
                                    await uploadTask.whenComplete(() {
                                  successMessage(
                                    context,
                                    durationMilliseconds: 10000,
                                    AppLocalizations.of(context)!
                                        .globalSuccessSnackbarLabel,
                                  );
                                });

                                imageURL = await snapshot.ref.getDownloadURL();
                                setState(() {
                                  fileName = result.files.first.name;
                                });
                                uploadTask = null;
                                if (!context.mounted) return;
                              }
                            },
                            icon: const Icon(Icons.upload),
                            label: Text(AppLocalizations.of(context)!
                                .globalUploadLabel)),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(fileName),
                        if (_uploadProgress != null)
                          SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            child: ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(10)),
                              child: LinearProgressIndicator(
                                minHeight: 8,
                                value: _uploadProgress,
                                color: colorState.primaryColor,
                              ),
                            ),
                          ),
                        fileName != ''
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    fileName = '';
                                    imageURL = '';
                                  });
                                },
                                icon: const Icon(Icons.close))
                            : const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ImageOptions.web => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(hintText: 'Link'),
                      controller: linkFromWebController,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ImageOptions.filesModule => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onSubmitted: (value) {
                        setState(() {
                          filesModuleSearchQuery = value;
                        });
                      },
                      controller: imageFilesModuleSearchController,
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!
                              .filtersSearchBarHintText,
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  filesModuleSearchQuery = '';
                                  imageFilesModuleSearchController.clear();
                                });
                              },
                              icon: const Icon(Icons.close)),
                          prefixIcon: const Icon(Icons.search_rounded)),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(AppLocalizations.of(context)!
                        .textEditorSelectedImageLabel(fileName)),
                    SizedBox(
                      width: double.maxFinite,
                      height: MediaQuery.of(context).size.height / 2,
                      child: FutureBuilder<List<FirebaseFile>>(
                          future: futureFiles,
                          builder: (context, snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return const Center(
                                    child: CircularProgressIndicator());
                              default:
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text('Error: ${snapshot.error}'));
                                } else {
                                  final files = snapshot.data!;
                                  List imgList = files
                                      .where((file) => file
                                          .metaData.contentType!
                                          .contains('image'))
                                      .toList();
                                  if (filesModuleSearchQuery != '') {
                                    imgList = files
                                        .where((file) => file.metaData.name
                                            .toLowerCase()
                                            .contains(filesModuleSearchQuery
                                                .toLowerCase()))
                                        .toList();
                                  }
                                  return SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          itemBuilder:
                                              (BuildContext context, index) {
                                            final file = imgList[index];
                                            return SizedBox(
                                              height: 100,
                                              child: Card(
                                                surfaceTintColor:
                                                    file.url == imageURL
                                                        ? Colors.grey
                                                        : Colors.transparent,
                                                clipBehavior: Clip.hardEdge,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      fileName = file.name;
                                                      imageURL = file.url;
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      AspectRatio(
                                                        aspectRatio: 16 / 9,
                                                        child: Image.network(
                                                          file.url,
                                                          fit: BoxFit.fill,
                                                          loadingBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  Widget child,
                                                                  ImageChunkEvent?
                                                                      loadingProgress) {
                                                            if (loadingProgress ==
                                                                null) {
                                                              return child;
                                                            }
                                                            return Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                                value: loadingProgress
                                                                            .expectedTotalBytes !=
                                                                        null
                                                                    ? loadingProgress
                                                                            .cumulativeBytesLoaded /
                                                                        loadingProgress
                                                                            .expectedTotalBytes!
                                                                    : null,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        file.name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                          itemCount: imgList.length,
                                        )
                                      ],
                                    ),
                                  );
                                }
                            }
                          }),
                    ),
                  ],
                ),
            },
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const PIPCancelButton(),
                PIPDialogTextButton(
                    label: 'Ok',
                    onPressed: () {
                      switch (imageOption) {
                        case ImageOptions.drive:
                          if (imageURL != '') {
                            Navigator.pop(context, imageURL);
                          } else {
                            errorMessage(
                                context,
                                AppLocalizations.of(context)!
                                    .textEditorErrorMessageImage);
                            Navigator.pop(context);
                          }
                          break;
                        case ImageOptions.web:
                          if (linkFromWebController.text != '') {
                            Navigator.pop(context, linkFromWebController.text);
                          } else {
                            errorMessage(
                                context,
                                AppLocalizations.of(context)!
                                    .textEditorErrorMessageImage);
                            Navigator.pop(context);
                          }
                          break;
                        case ImageOptions.filesModule:
                          if (imageURL != '') {
                            Navigator.pop(context, imageURL);
                          } else {
                            errorMessage(
                                context,
                                AppLocalizations.of(context)!
                                    .textEditorErrorMessageImage);
                            Navigator.pop(context);
                          }
                          break;
                      }
                    })
              ],
            )
          ],
        ),
      ),
    );
  }
}
