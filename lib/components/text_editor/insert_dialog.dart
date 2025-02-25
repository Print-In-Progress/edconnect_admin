import 'package:chewie/chewie.dart';
import 'package:edconnect_admin/components/buttons.dart';
import 'package:edconnect_admin/components/snackbars.dart';
import 'package:edconnect_admin/constants/database_constants.dart';
import 'package:edconnect_admin/models/firebase_file.dart';
import 'package:edconnect_admin/models/providers/themeprovider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ImageOptions { drive, web, filesModule }

class InsertImage extends ConsumerStatefulWidget {
  final HtmlEditorController htmlController;

  const InsertImage({super.key, required this.htmlController});

  @override
  ConsumerState<InsertImage> createState() => _InsertImageState();
}

class _InsertImageState extends ConsumerState<InsertImage> {
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
    final currentColorSchemeProvider = ref.watch(colorAndLogoProvider);
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
                                          .globalSuccessSnackbarLabel);
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
                                color:
                                    currentColorSchemeProvider.secondaryColor,
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
                            widget.htmlController.insertNetworkImage(imageURL,
                                filename: fileName);
                            Navigator.pop(context);
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
                            widget.htmlController.insertNetworkImage(
                                linkFromWebController.text,
                                filename: linkFromWebController.text);
                            Navigator.pop(context);
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
                            widget.htmlController.insertNetworkImage(imageURL,
                                filename: fileName);
                            Navigator.pop(context);
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

enum VideoOptions { drive, youtube, web, filesModule }

class InsertVideo extends ConsumerStatefulWidget {
  final HtmlEditorController htmlController;
  const InsertVideo({super.key, required this.htmlController});

  @override
  ConsumerState<InsertVideo> createState() => _InsertVideoState();
}

class _InsertVideoState extends ConsumerState<InsertVideo> {
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

  VideoOptions videoOptions = VideoOptions.drive;

  String videoURL = "";
  String fileName = '';
  String filesModuleSearchQuery = '';

  double? _uploadProgress;

  final TextEditingController _youtubeEmbedController = TextEditingController();
  final TextEditingController _webVideoLinkController = TextEditingController();
  final TextEditingController _videoFilesModuleSearchController =
      TextEditingController();

  @override
  void initState() {
    futureFiles = listAll(customerSpecificCollectionFiles);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentColorSchemeProvider = ref.watch(colorAndLogoProvider);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.textEditorInsertVideoDialogTitle,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            ),
            SegmentedButton<VideoOptions>(
              segments: <ButtonSegment<VideoOptions>>[
                ButtonSegment(
                    label: Text(AppLocalizations.of(context)!
                        .textEditorFromComputerSegmentLabel),
                    value: VideoOptions.drive,
                    icon: const Icon(Icons.computer_outlined)),
                ButtonSegment(
                  label: Text(AppLocalizations.of(context)!
                      .textEditorFromYouTubeSegmentLabel),
                  value: VideoOptions.youtube,
                ),
                ButtonSegment(
                    label: Text(AppLocalizations.of(context)!
                        .textEditorFromWebSegmentLabel),
                    value: VideoOptions.web,
                    icon: const Icon(Icons.language)),
                ButtonSegment(
                    label: Text(AppLocalizations.of(context)!
                        .textEditorFromFilesModuleSegmentLabel),
                    value: VideoOptions.filesModule,
                    icon: const Icon(
                      Icons.perm_media_outlined,
                    )),
              ],
              selected: <VideoOptions>{videoOptions},
              onSelectionChanged: (Set<VideoOptions> newSelection) {
                setState(() {
                  videoOptions = newSelection.first;
                });
              },
            ),
            switch (videoOptions) {
              VideoOptions.drive => Column(
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
                                type: FileType.video,
                              );
                              if (result != null && result.files.isNotEmpty) {
                                final fileBytes = result.files.first.bytes;
                                final path =
                                    '$customerSpecificCollectionFiles/${result.files.first.name}';

                                final ref =
                                    FirebaseStorage.instance.ref().child(path);
                                uploadTask = ref.putData(fileBytes!,
                                    SettableMetadata(contentType: 'video'));

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

                                videoURL = await snapshot.ref.getDownloadURL();
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
                                color:
                                    currentColorSchemeProvider.secondaryColor,
                              ),
                            ),
                          ),
                        fileName != ''
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    fileName = '';
                                    videoURL = '';
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
              VideoOptions.youtube => Column(
                  children: [
                    TextField(
                      controller: _youtubeEmbedController,
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!
                              .articlesPagesEmbedYoutubeVideoLinkHintText),
                    ),
                  ],
                ),
              VideoOptions.web => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(hintText: 'Link'),
                      controller: _webVideoLinkController,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              VideoOptions.filesModule => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onSubmitted: (value) {
                        setState(() {
                          filesModuleSearchQuery = value;
                        });
                      },
                      controller: _videoFilesModuleSearchController,
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!
                              .filtersSearchBarHintText,
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  filesModuleSearchQuery = '';
                                  _videoFilesModuleSearchController.clear();
                                });
                              },
                              icon: const Icon(Icons.close)),
                          prefixIcon: const Icon(Icons.search_rounded)),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(AppLocalizations.of(context)!
                        .textEditorSelectedVideoLabel(fileName)),
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
                                  List videoList = files
                                      .where((file) => file
                                          .metaData.contentType!
                                          .contains('video'))
                                      .toList();
                                  if (filesModuleSearchQuery != '') {
                                    videoList = files
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
                                            final file = videoList[index];
                                            return SizedBox(
                                              height: 100,
                                              child: Card(
                                                surfaceTintColor:
                                                    file.url == videoURL
                                                        ? Colors.grey
                                                        : Colors.transparent,
                                                clipBehavior: Clip.hardEdge,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      fileName = file.name;
                                                      videoURL = file.url;
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      AspectRatio(
                                                          aspectRatio: 16 / 9,
                                                          child: Chewie(
                                                            controller: ChewieController(
                                                                showControls:
                                                                    false,
                                                                autoInitialize:
                                                                    true,
                                                                startAt:
                                                                    const Duration(
                                                                        seconds:
                                                                            1),
                                                                aspectRatio:
                                                                    16 / 9,
                                                                videoPlayerController:
                                                                    VideoPlayerController
                                                                        .networkUrl(
                                                                            Uri.parse(file.url))),
                                                          )),
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
                                          itemCount: videoList.length,
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
                      switch (videoOptions) {
                        case VideoOptions.drive:
                          if (videoURL != '') {
                            widget.htmlController.insertHtml(
                                "<video src=\"$videoURL\" width=\"100%\" controls></video>");
                            Navigator.pop(context);
                          } else {
                            errorMessage(
                                context,
                                AppLocalizations.of(context)!
                                    .textEditorErrorMessageVideo);
                            Navigator.pop(context);
                          }
                          break;
                        case VideoOptions.youtube:
                          String link = _youtubeEmbedController.text;
                          if (link.isNotEmpty) {
                            if (link.contains('watch?v=') &&
                                link.contains('list')) {
                              List<String> splitLink = link.trim().split('&');
                              link =
                                  splitLink[0].replaceAll('watch?v=', 'embed/');
                            } else if (link.contains('watch?v=')) {
                              link = link.replaceAll('watch?v=', 'embed/');
                            } else if (link.contains('youtu.be')) {
                              List<String> splitLink = link.trim().split("/");
                              link =
                                  "https://www.youtube.com/embed/${splitLink[3]}";
                            }
                            if (!link.contains('youtube.com') &&
                                !link.contains('youtu.be')) {
                              errorMessage(
                                  context,
                                  AppLocalizations.of(context)!
                                      .articlesPagesEmbedYoutubeVideoLinkNotValidSnackbarErrorMessage);
                            } else {
                              if (_youtubeEmbedController.text
                                  .contains('iframe')) {
                                widget.htmlController
                                    .insertHtml(_youtubeEmbedController.text);
                              } else {
                                widget.htmlController.insertHtml(
                                    "<iframe src=\"$link\" allowfullscreen frameborder=\"0\"> </iframe>");
                              }
                            }
                          } else {
                            errorMessage(
                                context, 'Please provide a valid YouTube Link');
                          }
                          Navigator.of(context).pop();
                          break;
                        case VideoOptions.web:
                          if (_webVideoLinkController.text.isNotEmpty) {
                            widget.htmlController.insertHtml(
                                "<video src=\"${_webVideoLinkController.text}\" width=\"100%\" controls></video>");
                            Navigator.pop(context);
                          } else {
                            errorMessage(
                                context,
                                AppLocalizations.of(context)!
                                    .textEditorErrorMessageVideo);
                            Navigator.pop(context);
                          }
                          break;
                        case VideoOptions.filesModule:
                          if (videoURL != '') {
                            widget.htmlController.insertHtml(
                                "<video src=\"$videoURL\" width=\"100%\" controls></video>");
                            Navigator.pop(context);
                          } else {
                            errorMessage(
                                context,
                                AppLocalizations.of(context)!
                                    .textEditorErrorMessageVideo);
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

enum AudioOptions { drive, web, filesModule }

class InsertAudio extends ConsumerStatefulWidget {
  final HtmlEditorController htmlController;
  const InsertAudio({super.key, required this.htmlController});

  @override
  ConsumerState<InsertAudio> createState() => _InsertAudioState();
}

class _InsertAudioState extends ConsumerState<InsertAudio> {
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

  AudioOptions audioOptions = AudioOptions.drive;

  String audioURL = "";
  String fileName = '';
  String filesModuleSearchQuery = '';

  double? _uploadProgress;

  final TextEditingController _webAudioLinkController = TextEditingController();
  final TextEditingController _audioFilesModuleSearchController =
      TextEditingController();

  @override
  void initState() {
    futureFiles = listAll(customerSpecificCollectionFiles);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentColorSchemeProvider = ref.watch(colorAndLogoProvider);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.textEditorInsertAudioDialogTitle,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            ),
            SegmentedButton<AudioOptions>(
              segments: <ButtonSegment<AudioOptions>>[
                ButtonSegment(
                    label: Text(AppLocalizations.of(context)!
                        .textEditorFromComputerSegmentLabel),
                    value: AudioOptions.drive,
                    icon: const Icon(Icons.computer_outlined)),
                ButtonSegment(
                    label: Text(AppLocalizations.of(context)!
                        .textEditorFromWebSegmentLabel),
                    value: AudioOptions.web,
                    icon: const Icon(Icons.language)),
                ButtonSegment(
                    label: Text(AppLocalizations.of(context)!
                        .textEditorFromFilesModuleSegmentLabel),
                    value: AudioOptions.filesModule,
                    icon: const Icon(
                      Icons.perm_media_outlined,
                    )),
              ],
              selected: <AudioOptions>{audioOptions},
              onSelectionChanged: (Set<AudioOptions> newSelection) {
                setState(() {
                  audioOptions = newSelection.first;
                });
              },
            ),
            switch (audioOptions) {
              AudioOptions.drive => Column(
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
                                type: FileType.audio,
                              );
                              if (result != null && result.files.isNotEmpty) {
                                final fileBytes = result.files.first.bytes;
                                final path =
                                    '$customerSpecificCollectionFiles/${result.files.first.name}';

                                final ref =
                                    FirebaseStorage.instance.ref().child(path);
                                uploadTask = ref.putData(fileBytes!,
                                    SettableMetadata(contentType: 'audio'));

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

                                audioURL = await snapshot.ref.getDownloadURL();
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
                                color:
                                    currentColorSchemeProvider.secondaryColor,
                              ),
                            ),
                          ),
                        fileName != ''
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    fileName = '';
                                    audioURL = '';
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
              AudioOptions.web => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(hintText: 'Link'),
                      controller: _webAudioLinkController,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              AudioOptions.filesModule => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onSubmitted: (value) {
                        setState(() {
                          filesModuleSearchQuery = value;
                        });
                      },
                      controller: _audioFilesModuleSearchController,
                      decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!
                              .filtersSearchBarHintText,
                          suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  filesModuleSearchQuery = '';
                                  _audioFilesModuleSearchController.clear();
                                });
                              },
                              icon: const Icon(Icons.close)),
                          prefixIcon: const Icon(Icons.search_rounded)),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(AppLocalizations.of(context)!
                        .textEditorSelectedAudioLabel(fileName)),
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
                                  List videoList = files
                                      .where((file) => file
                                          .metaData.contentType!
                                          .contains('audio'))
                                      .toList();
                                  if (filesModuleSearchQuery != '') {
                                    videoList = files
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
                                            final file = videoList[index];
                                            AudioPlayer player = AudioPlayer();
                                            player.setUrl(file.url);
                                            return SizedBox(
                                              height: 100,
                                              child: Card(
                                                surfaceTintColor:
                                                    file.url == audioURL
                                                        ? Colors.grey
                                                        : Colors.transparent,
                                                clipBehavior: Clip.hardEdge,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      fileName = file.name;
                                                      audioURL = file.url;
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      AspectRatio(
                                                          aspectRatio: 16 / 9,
                                                          child: AudioControls(
                                                              audioPlayer:
                                                                  player)),
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
                                          itemCount: videoList.length,
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
                      switch (audioOptions) {
                        case AudioOptions.drive:
                          if (audioURL != '') {
                            widget.htmlController.insertHtml(
                                "<audio src=\"$audioURL\" controls></audio>");
                            Navigator.pop(context);
                          } else {
                            errorMessage(
                                context,
                                AppLocalizations.of(context)!
                                    .textEditorErrorMessageAudio);
                            Navigator.pop(context);
                          }
                          break;
                        case AudioOptions.web:
                          if (_webAudioLinkController.text.isNotEmpty) {
                            widget.htmlController.insertHtml(
                                "<audio src=\"${_webAudioLinkController.text}\" controls></audio>");
                            Navigator.pop(context);
                          } else {
                            errorMessage(
                                context,
                                AppLocalizations.of(context)!
                                    .textEditorErrorMessageAudio);
                            Navigator.pop(context);
                          }
                          break;
                        case AudioOptions.filesModule:
                          if (audioURL != '') {
                            widget.htmlController.insertHtml(
                                "<audio src=\"$audioURL\" controls></audio>");
                            Navigator.pop(context);
                          } else {
                            errorMessage(
                                context,
                                AppLocalizations.of(context)!
                                    .textEditorErrorMessageAudio);
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

class InsertLinkDialog extends StatefulWidget {
  final HtmlEditorController htmlController;
  const InsertLinkDialog({super.key, required this.htmlController});

  @override
  State<InsertLinkDialog> createState() => _InsertLinkDialogState();
}

class _InsertLinkDialogState extends State<InsertLinkDialog> {
  TextEditingController textController = TextEditingController();
  TextEditingController urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppLocalizations.of(context)!.textEditorInsertLinkDialogTitle,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.textEditorTextToDisplayTextFieldLabel,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Text'),
          ),
          const SizedBox(
            height: 15,
          ),
          const Text(
            'URL',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
          ),
          TextField(
            controller: urlController,
            decoration: const InputDecoration(hintText: 'URL'),
          ),
        ],
      ),
      actions: [
        const PIPCancelButton(),
        PIPDialogTextButton(
            label: 'Ok',
            onPressed: () {
              widget.htmlController
                  .insertLink(textController.text, urlController.text, true);
              Navigator.pop(context);
            })
      ],
    );
  }
}

class TablePicker extends StatefulWidget {
  ///[TablePicker] a widget to interactively selected the number of rows and columns to insert in editor
  const TablePicker(
      {super.key,
      this.rowCount = 10,
      required this.onTablePicked,
      this.width = 200});

  ///[onTablePicked] a callback function that returns the selected row and column index
  final Function(int row, int column) onTablePicked;

  ///[rowCount] to define the table row*column matrix
  final int? rowCount;

  ///[width] to set the min width of the table picker
  final double? width;

  @override
  State<TablePicker> createState() => _TablePickerState();
}

class _TablePickerState extends State<TablePicker> {
  final Set<int> _selectedIndexes = <int>{};
  final Set<_CellBox> _trackTaped = <_CellBox>{};
  int _selectedRow = 0;
  int _selectedColumn = 0;
  final _cellKey = GlobalKey();
  @override
  initState() {
    super.initState();
  }

  _detectTapedItem(PointerEvent event) {
    _clearSelection();
    final RenderBox box =
        _cellKey.currentContext!.findAncestorRenderObjectOfType<RenderBox>()!;
    final result = BoxHitTestResult();
    Offset local = box.globalToLocal(event.position);
    if (box.hitTest(result, position: local)) {
      for (final hit in result.path) {
        /// temporary variable so that the [is] allows access of [index]
        final target = hit.target;
        if (target is _CellBox && !_trackTaped.contains(target)) {
          _trackTaped.add(target);
          _selectIndex(target.index);
        }
      }
    }
  }

  _selectIndex(int index) {
    setState(() {
      _selectedIndexes.add(index);
      List<int> tempList = _selectedIndexes.toList();
      tempList.sort((a, b) => a - b);
      _selectedColumn = tempList.last ~/ widget.rowCount!;
      _selectedRow = tempList.last % widget.rowCount!;
      int count = 0;
      _selectedIndexes.clear();
      for (int i = 0; i < widget.rowCount!; i++) {
        for (int j = 0; j < widget.rowCount!; j++) {
          if (i <= _selectedColumn && j <= _selectedRow) {
            _selectedIndexes.add(count);
          }
          count++;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _detectTapedItem,
      onPointerMove: _detectTapedItem,
      onPointerHover: _detectTapedItem,
      onPointerUp: _onSelectionDone,
      child: GridView.builder(
        key: _cellKey,
        shrinkWrap: true,
        itemCount: widget.rowCount! * widget.rowCount!,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 1, crossAxisCount: widget.rowCount!),
        itemBuilder: (context, index) {
          return _CellSelectionWidget(
            index: index,
            child: Container(
              // width: widget.width! / widget.rowCount!,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                  color: _selectedIndexes.contains(index)
                      ? Colors.lightBlue.shade50
                      : Colors.transparent,
                  border: Border.all(
                    width: _selectedIndexes.contains(index) ? 2 : 1,
                    color: _selectedIndexes.contains(index)
                        ? Colors.lightBlue.shade100
                        : Colors.black45,
                  )),
            ),
          );
        },
      ),
    );
  }

  void _clearSelection() {
    _trackTaped.clear();
    setState(() {
      _selectedIndexes.clear();
    });
  }

  void _onSelectionDone(PointerUpEvent event) {
    widget.onTablePicked(_selectedRow + 1, _selectedColumn + 1);
  }
}

class _CellSelectionWidget extends SingleChildRenderObjectWidget {
  final int index;

  const _CellSelectionWidget(
      {required Widget child, required this.index, Key? key})
      : super(child: child, key: key);

  @override
  _CellBox createRenderObject(BuildContext context) {
    return _CellBox(index);
  }

  @override
  void updateRenderObject(BuildContext context, _CellBox renderObject) {
    renderObject.index = index;
  }
}

class _CellBox extends RenderProxyBox {
  int index;

  _CellBox(this.index);
}

class AudioControls extends StatefulWidget {
  final AudioPlayer audioPlayer;
  const AudioControls({super.key, required this.audioPlayer});

  @override
  State<AudioControls> createState() => _AudioControlsState();
}

class _AudioControlsState extends State<AudioControls> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
        stream: widget.audioPlayer.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final processingState = playerState?.processingState;
          final playing = playerState?.playing;
          if (!(playing ?? false)) {
            return IconButton(
              onPressed: widget.audioPlayer.play,
              icon: const Icon(Icons.play_arrow_rounded),
              color: Colors.grey[700],
              iconSize: 50,
            );
          } else if (processingState != ProcessingState.completed) {
            return IconButton(
              onPressed: widget.audioPlayer.pause,
              icon: const Icon(Icons.pause_rounded),
              color: Colors.grey[700],
              iconSize: 50,
            );
          }
          return const Icon(Icons.play_arrow_rounded);
        });
  }
}
