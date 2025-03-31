// ignore_for_file: invalid_use_of_internal_member

import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edconnect_admin/domain/entities/media_selection_options.dart';
import 'package:edconnect_admin/domain/entities/storage_file.dart';
import 'package:edconnect_admin/presentation/widgets/common/buttons.dart';
import 'package:edconnect_admin/presentation/widgets/common/media_selector_dialog.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/snackbars.dart';
import 'package:edconnect_admin/presentation/widgets/text_editor/dialogs/insert_link_dialog.dart';
import 'package:edconnect_admin/presentation/widgets/text_editor/dialogs/insert_table_dialog.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PIPStandardTextEditor extends ConsumerStatefulWidget {
  final String title;
  final String elementUID;
  final String elementCollection;
  final String saveDatabaseKey;
  final List<Widget> customWidgets;
  final String content;
  const PIPStandardTextEditor({
    super.key,
    required this.elementUID,
    required this.elementCollection,
    required this.saveDatabaseKey,
    required this.title,
    required this.content,
    required this.customWidgets,
  });

  @override
  ConsumerState<PIPStandardTextEditor> createState() =>
      _PIPStandardTextEditorState();
}

class _PIPStandardTextEditorState extends ConsumerState<PIPStandardTextEditor> {
  String result = '';
  String currentFontName = 'Sans-Serif';
  String currentFormatBlock = 'p';
  double currentFontSize = 3;

  bool isBold = false;
  bool isItalic = false;
  bool isUnderline = false;
  bool isStrikethrough = false;
  bool isSubscript = false;
  bool isSuperscript = false;

  bool isUl = false;
  bool isOl = false;

  bool isAlignLeft = false;
  bool isAlignCenter = false;
  bool isAlignRight = false;
  bool isAlignJustify = false;

  double currentLineHeight = 1.0;

  Color currentForegroundColor = Colors.black;

  final HtmlEditorController controller = HtmlEditorController();
  TextEditingController _titleController = TextEditingController();

  final MenuController _tableMenuController = MenuController();

  List fonts = [
    "Arial",
    "Calibri",
    "Cambria",
    "Century Gothic",
    "Comic Sans MS",
    "Consolas",
    "Copperplate Gothic",
    "Courier New",
    "Garamond",
    "Georgia",
    "Goudy Old Style",
    "Helvetica",
    "Impact",
    "Lucida Bright",
    "Lucida Console",
    "Lucida Handwriting",
    "Perpetua",
    "Rage",
    "Rockwell",
    "Sans-Serif",
    "Script MT",
    "Segoe UI",
    "Segoe script",
    "Tahoma",
    "Times New Roman",
    "Verdana",
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _getYoutubeEmbedUrl(String url) {
    String embedLink = '';
    if (url.contains('watch?v=') && url.contains('list')) {
      List<String> splitLink = url.trim().split('&');
      url = splitLink[0].replaceAll('watch?v=', 'embed/');
    } else if (url.contains('watch?v=')) {
      url = url.replaceAll('watch?v=', 'embed/');
    } else if (url.contains('youtu.be')) {
      List<String> splitLink = url.trim().split("/");
      url = "https://www.youtube.com/embed/${splitLink[3]}";
    }
    if (url.contains('iframe')) {
      return url;
    }

    return embedLink;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(appThemeProvider);
    return GestureDetector(
      onTap: () {
        if (!kIsWeb) {
          controller.clearFocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          elevation: 0,
          actions: [],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              HtmlEditor(
                controller: controller,
                htmlEditorOptions: HtmlEditorOptions(
                    hint: AppLocalizations.of(context)!.textEditorHintText,
                    shouldEnsureVisible: true,
                    initialText: widget.content,
                    webInitialScripts: UnmodifiableListView([
                      WebScript(script: """
          var script = document.createElement('script');
          script.src = 'https://polyfill.io/v3/polyfill.min.js?features=es6';
          document.head.appendChild(script);
          var script2 = document.createElement('script');
          script2.src = 'https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js';
          script2.async = true;
          document.head.appendChild(script2);
          """, name: "mathJax")
                    ])),
                htmlToolbarOptions: HtmlToolbarOptions(
                  toolbarPosition: ToolbarPosition.aboveEditor, //by default
                  toolbarType: ToolbarType.nativeGrid, //by default
                  defaultToolbarButtons: [],
                  customToolbarButtons: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () {
                              controller.undo();
                            },
                            icon: const Icon(Icons.undo)),
                        IconButton(
                            onPressed: () {
                              controller.redo();
                            },
                            icon: const Icon(Icons.redo)),
                      ],
                    ),
                    TextButton.icon(
                        label: Text(
                          AppLocalizations.of(context)!
                              .globalSaveChangesButtonLabel,
                          style: const TextStyle(color: Colors.green),
                        ),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection(widget.elementCollection)
                              .doc(widget.elementUID)
                              .update({
                            widget.saveDatabaseKey: await controller.getText(),
                          }).then((value) {
                            successMessage(
                              context,
                              AppLocalizations.of(context)!
                                  .globalSuccessSnackbarLabel,
                            );
                          }).catchError((e) {
                            errorMessage(context, e);
                          });
                        },
                        icon: const Icon(
                          Icons.save_as,
                          color: Colors.green,
                        )),
                    Tooltip(
                      message:
                          AppLocalizations.of(context)!.textEditorTooltipStyles,
                      child: MenuAnchor(
                          builder: (context, controller, child) {
                            return TextButton(
                              onPressed: () {
                                if (controller.isOpen) {
                                  controller.close();
                                  return;
                                }
                                controller.open();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (currentFormatBlock == 'p' ||
                                      currentFormatBlock == '')
                                    Text(
                                      AppLocalizations.of(context)!
                                          .textEditorStyleMenuItemNormal,
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                  if (currentFormatBlock == 'h1')
                                    Text(
                                        AppLocalizations.of(context)!
                                            .textEditorStyleMenuItemHeader1,
                                        style: const TextStyle(fontSize: 16.0)),
                                  if (currentFormatBlock == 'h2')
                                    Text(
                                        AppLocalizations.of(context)!
                                            .textEditorStyleMenuItemHeader2,
                                        style: const TextStyle(fontSize: 16.0)),
                                  if (currentFormatBlock == 'h3')
                                    Text(
                                        AppLocalizations.of(context)!
                                            .textEditorStyleMenuItemHeader3,
                                        style: const TextStyle(fontSize: 16.0)),
                                  if (currentFormatBlock == 'h4')
                                    Text(
                                        AppLocalizations.of(context)!
                                            .textEditorStyleMenuItemHeader4,
                                        style: const TextStyle(fontSize: 16.0)),
                                  if (currentFormatBlock == 'h5')
                                    Text(
                                        AppLocalizations.of(context)!
                                            .textEditorStyleMenuItemHeader5,
                                        style: const TextStyle(fontSize: 16.0)),
                                  if (currentFormatBlock == 'h6')
                                    Text(
                                        AppLocalizations.of(context)!
                                            .textEditorStyleMenuItemHeader6,
                                        style: const TextStyle(fontSize: 16.0)),
                                  const Icon(Icons.arrow_drop_down_rounded)
                                ],
                              ),
                            );
                          },
                          menuChildren: [
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.execCommand('formatBlock',
                                        argument: 'p');
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .textEditorStyleMenuItemNormal,
                                    style: const TextStyle(fontSize: 16.0),
                                  )),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.execCommand('formatBlock',
                                        argument: 'h1');
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorStyleMenuItemHeader1,
                                      style: const TextStyle(
                                          fontSize: 34.0,
                                          fontWeight: FontWeight.bold))),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.execCommand('formatBlock',
                                        argument: 'h2');
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorStyleMenuItemHeader2,
                                      style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold))),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.execCommand('formatBlock',
                                        argument: 'h3');
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorStyleMenuItemHeader3,
                                      style: const TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold))),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.execCommand('formatBlock',
                                        argument: 'h4');
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorStyleMenuItemHeader4,
                                      style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold))),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.execCommand('formatBlock',
                                        argument: 'h5');
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorStyleMenuItemHeader5,
                                      style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold))),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.execCommand('formatBlock',
                                        argument: 'h6');
                                  },
                                  child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorStyleMenuItemHeader6,
                                      style: const TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold))),
                            ),
                          ]),
                    ),
                    Tooltip(
                      message: AppLocalizations.of(context)!
                          .textEditorTooltipChangeFontFamily,
                      child: MenuAnchor(
                          builder: (context, controller, child) {
                            return TextButton(
                              onPressed: () {
                                if (controller.isOpen) {
                                  controller.close();
                                  return;
                                }
                                controller.open();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currentFontName,
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        fontFamily: currentFontName),
                                  ),
                                  const Icon(Icons.arrow_drop_down_rounded)
                                ],
                              ),
                            );
                          },
                          menuChildren: fonts
                              .map((i) => PointerInterceptor(
                                      child: MenuItemButton(
                                    onPressed: () {
                                      controller.execCommand('fontName',
                                          argument: i);
                                    },
                                    child: Text(i,
                                        style: TextStyle(
                                            fontSize: 16.0, fontFamily: i)),
                                  )))
                              .toList()),
                    ),
                    // font size button
                    Tooltip(
                      message: AppLocalizations.of(context)!
                          .textEditorTooltipChangeFontSize,
                      child: MenuAnchor(
                          builder: (context, controller, child) {
                            return TextButton(
                              onPressed: () {
                                if (controller.isOpen) {
                                  controller.close();
                                  return;
                                }
                                controller.open();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (currentFontSize == 1)
                                    const Text('8 pt',
                                        style: TextStyle(fontSize: 16.0)),
                                  if (currentFontSize == 2)
                                    const Text('10 pt',
                                        style: TextStyle(fontSize: 16.0)),
                                  if (currentFontSize == 3)
                                    const Text('12 pt',
                                        style: TextStyle(fontSize: 16.0)),
                                  if (currentFontSize == 4)
                                    const Text('14 pt',
                                        style: TextStyle(fontSize: 16.0)),
                                  if (currentFontSize == 5)
                                    const Text('18 pt',
                                        style: TextStyle(fontSize: 16.0)),
                                  if (currentFontSize == 6)
                                    const Text('24 pt',
                                        style: TextStyle(fontSize: 16.0)),
                                  if (currentFontSize == 7)
                                    const Text('36 pt',
                                        style: TextStyle(fontSize: 16.0)),
                                  const Icon(Icons.arrow_drop_down_rounded)
                                ],
                              ),
                            );
                          },
                          menuChildren: [
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.execCommand('fontSize',
                                        argument: '1');
                                  },
                                  child: const Text(
                                    '8 pt',
                                    style: TextStyle(fontSize: 11.0),
                                  )),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.execCommand('fontSize',
                                        argument: '2');
                                  },
                                  child: const Text(
                                    '10 pt',
                                    style: TextStyle(fontSize: 13.0),
                                  )),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.execCommand('fontSize',
                                        argument: '3');
                                  },
                                  child: const Text(
                                    '12 pt',
                                    style: TextStyle(fontSize: 16.0),
                                  )),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.execCommand('fontSize',
                                        argument: '4');
                                  },
                                  child: const Text(
                                    '14 pt',
                                    style: TextStyle(fontSize: 19.0),
                                  )),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.execCommand('fontSize',
                                        argument: '5');
                                  },
                                  child: const Text(
                                    '18 pt',
                                    style: TextStyle(fontSize: 24.0),
                                  )),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.execCommand('fontSize',
                                        argument: '6');
                                  },
                                  child: const Text(
                                    '24 pt',
                                    style: TextStyle(fontSize: 32.0),
                                  )),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.execCommand('fontSize',
                                        argument: '7');
                                  },
                                  child: const Text(
                                    '36 pt',
                                    style: TextStyle(fontSize: 48.0),
                                  )),
                            ),
                          ]),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Ink(
                          decoration: ShapeDecoration(
                              color: isBold
                                  ? theme.secondaryColor
                                  : Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipBold,
                              onPressed: () {
                                controller.execCommand('bold');
                                isBold = !isBold;
                              },
                              padding: const EdgeInsets.all(3),
                              icon: Icon(
                                Icons.format_bold,
                                color: isBold ? Colors.white : Colors.black,
                              )),
                        ),
                        Ink(
                          decoration: ShapeDecoration(
                              color: isItalic
                                  ? theme.secondaryColor
                                  : Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipItalic,
                              onPressed: () {
                                controller.execCommand('italic');
                                isItalic = !isItalic;
                              },
                              icon: Icon(
                                Icons.format_italic,
                                color: isItalic ? Colors.white : Colors.black,
                              )),
                        ),
                        Ink(
                          decoration: ShapeDecoration(
                              color: isUnderline
                                  ? theme.secondaryColor
                                  : Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipUnderline,
                              onPressed: () {
                                controller.execCommand('underline');
                                isUnderline = !isUnderline;
                              },
                              icon: Icon(
                                Icons.format_underline,
                                color:
                                    isUnderline ? Colors.white : Colors.black,
                              )),
                        ),
                        Ink(
                          decoration: const ShapeDecoration(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipRemoveFormat,
                              onPressed: () {
                                controller.execCommand('removeFormat');
                                isUnderline = !isUnderline;
                              },
                              icon: const Icon(
                                Icons.format_clear,
                                color: Colors.black,
                              )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Ink(
                          decoration: ShapeDecoration(
                              color: isStrikethrough
                                  ? theme.secondaryColor
                                  : Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipStrikethrough,
                              onPressed: () {
                                controller.execCommand('strikeThrough');
                                isStrikethrough = !isStrikethrough;
                              },
                              icon: Icon(
                                Icons.format_strikethrough,
                                color: isStrikethrough
                                    ? Colors.white
                                    : Colors.black,
                              )),
                        ),
                        Ink(
                          decoration: ShapeDecoration(
                              color: isSuperscript
                                  ? theme.secondaryColor
                                  : Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipSuperscript,
                              onPressed: () {
                                controller.execCommand('superscript');
                                isSuperscript = !isSuperscript;
                              },
                              icon: Icon(
                                Icons.superscript,
                                color:
                                    isSuperscript ? Colors.white : Colors.black,
                              )),
                        ),
                        Ink(
                          decoration: ShapeDecoration(
                              color: isSubscript
                                  ? theme.secondaryColor
                                  : Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipSubscript,
                              onPressed: () {
                                controller.execCommand('subscript');
                                isSubscript = !isSubscript;
                              },
                              icon: Icon(
                                Icons.subscript,
                                color:
                                    isSubscript ? Colors.white : Colors.black,
                              )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            tooltip: AppLocalizations.of(context)!
                                .textEditorTooltipChangeFontColor,
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) => PointerInterceptor(
                                        child: ChangeFontColorDialog(
                                            htmlController: controller,
                                            currentColor:
                                                currentForegroundColor),
                                      ));
                            },
                            icon: Icon(
                              Icons.format_color_text,
                              color: currentForegroundColor,
                            )),
                        IconButton(
                            tooltip: AppLocalizations.of(context)!
                                .textEditorTooltipChangeBackgroundColor,
                            onPressed: () async {
                              await showDialog(
                                  context: context,
                                  builder: (context) => PointerInterceptor(
                                        child: ChangeBackgroundColorDialog(
                                            htmlController: controller,
                                            currentColor: Colors.white),
                                      ));
                            },
                            icon: const Icon(
                              Icons.format_color_fill,
                            )),
                      ],
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Ink(
                          decoration: ShapeDecoration(
                              color: isUl
                                  ? theme.secondaryColor
                                  : Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipInsertBulletedList,
                              onPressed: () {
                                controller.execCommand('insertUnorderedList');
                              },
                              icon: Icon(
                                Icons.format_list_bulleted,
                                color: isUl ? Colors.white : Colors.black,
                              )),
                        ),
                        Ink(
                          decoration: ShapeDecoration(
                              color: isOl
                                  ? theme.secondaryColor
                                  : Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipInsertNumberedList,
                              onPressed: () {
                                controller.execCommand('insertOrderedList');
                              },
                              icon: Icon(
                                Icons.format_list_numbered,
                                color: isOl ? Colors.white : Colors.black,
                              )),
                        ),
                        MenuAnchor(
                            builder: (context, controller, child) {
                              return TextButton(
                                onPressed: () {
                                  if (controller.isOpen) {
                                    controller.close();
                                    return;
                                  }
                                  controller.open();
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                        AppLocalizations.of(context)!
                                            .textEditorChangeListStyleButtonLabel,
                                        style: const TextStyle(fontSize: 16.0)),
                                    const Icon(Icons.arrow_drop_down_rounded)
                                  ],
                                ),
                              );
                            },
                            menuChildren: [
                              PointerInterceptor(
                                child: MenuItemButton(
                                    onPressed: () {
                                      controller.changeListStyle('disc');
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorListStyleMenuItemDisc,
                                      style: const TextStyle(fontSize: 16.0),
                                    )),
                              ),
                              PointerInterceptor(
                                child: MenuItemButton(
                                    onPressed: () {
                                      controller.changeListStyle('decimal');
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorListStyleMenuItemDecimal,
                                      style: const TextStyle(fontSize: 16.0),
                                    )),
                              ),
                              PointerInterceptor(
                                child: MenuItemButton(
                                    onPressed: () {
                                      controller.changeListStyle('square');
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorListStyleMenuItemSquare,
                                      style: const TextStyle(fontSize: 16.0),
                                    )),
                              ),
                              PointerInterceptor(
                                child: MenuItemButton(
                                    onPressed: () {
                                      controller.changeListStyle('circle');
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorListStyleMenuItemCircle,
                                      style: const TextStyle(fontSize: 16.0),
                                    )),
                              ),
                              PointerInterceptor(
                                child: MenuItemButton(
                                    onPressed: () {
                                      controller.changeListStyle('upper-roman');
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorListStyleMenuItemUpperRomanNumerals,
                                      style: const TextStyle(fontSize: 16.0),
                                    )),
                              ),
                              PointerInterceptor(
                                child: MenuItemButton(
                                    onPressed: () {
                                      controller.changeListStyle('lower-roman');
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorListStyleMenuItemLowerRomanNumerals,
                                      style: const TextStyle(fontSize: 16.0),
                                    )),
                              ),
                              PointerInterceptor(
                                child: MenuItemButton(
                                    onPressed: () {
                                      controller.changeListStyle('upper-alpha');
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorListStyleMenuItemUppercaseLetters,
                                      style: const TextStyle(fontSize: 16.0),
                                    )),
                              ),
                              PointerInterceptor(
                                child: MenuItemButton(
                                    onPressed: () {
                                      controller.changeListStyle('lower-alpha');
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorListStyleMenuItemLowercaseLetters,
                                      style: const TextStyle(fontSize: 16.0),
                                    )),
                              ),
                              PointerInterceptor(
                                child: MenuItemButton(
                                    onPressed: () {
                                      controller.changeListStyle('lower-greek');
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .textEditorListStyleMenuItemLowercaseClassicalGreek,
                                      style: const TextStyle(fontSize: 16.0),
                                    )),
                              ),
                            ]),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Ink(
                          decoration: ShapeDecoration(
                              color: isAlignLeft
                                  ? theme.secondaryColor
                                  : Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipLeftAlign,
                              onPressed: () {
                                controller.execCommand('justifyLeft');
                              },
                              icon: Icon(
                                Icons.format_align_left,
                                color:
                                    isAlignLeft ? Colors.white : Colors.black,
                              )),
                        ),
                        Ink(
                          decoration: ShapeDecoration(
                              color: isAlignCenter
                                  ? theme.secondaryColor
                                  : Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipCenterAlign,
                              onPressed: () {
                                controller.execCommand('justifyCenter');
                              },
                              icon: Icon(
                                Icons.format_align_center,
                                color:
                                    isAlignCenter ? Colors.white : Colors.black,
                              )),
                        ),
                        Ink(
                          decoration: ShapeDecoration(
                              color: isAlignRight
                                  ? theme.secondaryColor
                                  : Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipRightAlign,
                              onPressed: () {
                                controller.execCommand('justifyRight');
                              },
                              icon: Icon(
                                Icons.format_align_right,
                                color:
                                    isAlignRight ? Colors.white : Colors.black,
                              )),
                        ),
                        Ink(
                          decoration: ShapeDecoration(
                              color: isAlignJustify
                                  ? theme.secondaryColor
                                  : Colors.transparent,
                              shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipJustifyAlign,
                              onPressed: () {
                                controller.execCommand('justifyFull');
                              },
                              icon: Icon(
                                Icons.format_align_justify,
                                color: isAlignJustify
                                    ? Colors.white
                                    : Colors.black,
                              )),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Ink(
                          decoration: const ShapeDecoration(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipIncreaseIndent,
                              onPressed: () {
                                controller.execCommand('indent');
                              },
                              icon: const Icon(
                                Icons.format_indent_increase,
                                color: Colors.black,
                              )),
                        ),
                        Ink(
                          decoration: const ShapeDecoration(
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)))),
                          child: IconButton(
                              tooltip: AppLocalizations.of(context)!
                                  .textEditorTooltipDeacreaseIndent,
                              onPressed: () {
                                controller.execCommand('outdent');
                              },
                              icon: const Icon(
                                Icons.format_indent_decrease,
                                color: Colors.black,
                              )),
                        ),
                      ],
                    ),

                    Tooltip(
                      message: AppLocalizations.of(context)!
                          .textEditorTooltipChangeLineSpacing,
                      child: MenuAnchor(
                          builder: (context, controller, child) {
                            return TextButton(
                              onPressed: () {
                                if (controller.isOpen) {
                                  controller.close();
                                  return;
                                }
                                controller.open();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.format_line_spacing),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(currentLineHeight.toString(),
                                      style: const TextStyle(fontSize: 16.0)),
                                  const Icon(Icons.arrow_drop_down_rounded)
                                ],
                              ),
                            );
                          },
                          menuChildren: [
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.changeLineHeight('1.0');
                                  },
                                  child: const Text(
                                    '1.0',
                                    style: TextStyle(fontSize: 16.0),
                                  )),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.changeLineHeight('1.2');
                                  },
                                  child: const Text(
                                    '1.2',
                                    style: TextStyle(fontSize: 16.0),
                                  )),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.changeLineHeight('1.4');
                                  },
                                  child: const Text(
                                    '1.4',
                                    style: TextStyle(fontSize: 16.0),
                                  )),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.changeLineHeight('1.6');
                                  },
                                  child: const Text(
                                    '1.6',
                                    style: TextStyle(fontSize: 16.0),
                                  )),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.changeLineHeight('1.8');
                                  },
                                  child: const Text(
                                    '1.8',
                                    style: TextStyle(fontSize: 16.0),
                                  )),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.changeLineHeight('2.0');
                                  },
                                  child: const Text(
                                    '2.0',
                                    style: TextStyle(fontSize: 16.0),
                                  )),
                            ),
                            PointerInterceptor(
                              child: MenuItemButton(
                                  onPressed: () {
                                    controller.changeLineHeight('3.0');
                                  },
                                  child: const Text(
                                    '3.0',
                                    style: TextStyle(fontSize: 16.0),
                                  )),
                            ),
                          ]),
                    ),

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Tooltip(
                          message: AppLocalizations.of(context)!
                              .textEditorTooltipInsertTable,
                          child: MenuAnchor(
                              controller: _tableMenuController,
                              builder: (context, controller, child) {
                                return TextButton(
                                  onPressed: () {
                                    if (controller.isOpen) {
                                      controller.close();
                                      return;
                                    }
                                    controller.open();
                                  },
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [Icon(Icons.grid_on_rounded)],
                                  ),
                                );
                              },
                              menuChildren: [
                                SizedBox(
                                  width: 200,
                                  height: 200,
                                  child: PointerInterceptor(child: TablePicker(
                                      onTablePicked: (int row, int column) {
                                    controller.insertTable('${row}x$column');
                                    _tableMenuController.close();
                                  })),
                                ),
                              ]),
                        ),
                        IconButton(
                            tooltip: AppLocalizations.of(context)!
                                .textEditorTooltipInsertLink,
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => PointerInterceptor(
                                    child:
                                        LinkDialog(htmlController: controller)),
                              );
                            },
                            icon: const Icon(Icons.link)),
                        IconButton(
                          tooltip: AppLocalizations.of(context)!
                              .textEditorTooltipInsertImage,
                          onPressed: () async {
                            final file = await showDialog<StorageFile>(
                              context: context,
                              builder: (context) => PointerInterceptor(
                                child: MediaSelectorDialog(
                                  options: MediaSelectionOptions(
                                    allowedSources: [
                                      MediaSource.local,
                                      MediaSource.web,
                                      MediaSource.storage
                                    ],
                                    allowedModules: [
                                      StorageModule.articles,
                                      StorageModule.library,
                                      StorageModule.personalStorage,
                                    ],
                                    mediaType: MediaType.image,
                                    allowedContentTypes: [
                                      'image/jpeg',
                                      'image/png',
                                      'image/gif'
                                    ],
                                  ),
                                  onFileSelected: (file) =>
                                      Navigator.pop(context, file),
                                ),
                              ),
                            );

                            if (file != null) {
                              controller.insertNetworkImage(
                                file.url,
                                filename: file.name,
                              );
                            }
                          },
                          icon: const Icon(Icons.image_outlined),
                        ),
                        IconButton(
                          tooltip: AppLocalizations.of(context)!
                              .textEditorTooltipInsertInsertVideo,
                          onPressed: () async {
                            final file = await showDialog<StorageFile>(
                              context: context,
                              builder: (context) => MediaSelectorDialog(
                                options: MediaSelectionOptions(
                                  allowedSources: [
                                    MediaSource.local,
                                    MediaSource.web,
                                    MediaSource.storage
                                  ],
                                  allowedModules: [
                                    StorageModule.articles,
                                    StorageModule.library,
                                    StorageModule.personalStorage,
                                  ],
                                  mediaType: MediaType.video,
                                  allowedContentTypes: [
                                    'video/mp4',
                                    'video/webm',
                                    'video/ogg'
                                  ],
                                ),
                                onFileSelected: (file) =>
                                    Navigator.pop(context, file),
                              ),
                            );

                            if (file != null) {
                              if (file.url.contains('youtube.com') ||
                                  file.url.contains('youtu.be')) {
                                final embedUrl = _getYoutubeEmbedUrl(file.url);
                                controller.insertHtml(
                                  "<iframe src=\"$embedUrl\" allowfullscreen frameborder=\"0\"> </iframe>",
                                );
                              } else {
                                controller.insertHtml(
                                  "<video src=\"${file.url}\" width=\"100%\" controls></video>",
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.videocam_outlined),
                        ),
                        IconButton(
                          tooltip: AppLocalizations.of(context)!
                              .textEditorTooltipInsertInsertAudio,
                          onPressed: () async {
                            final file = await showDialog<StorageFile>(
                              context: context,
                              builder: (context) => MediaSelectorDialog(
                                options: MediaSelectionOptions(
                                  allowedSources: [
                                    MediaSource.local,
                                    MediaSource.web,
                                    MediaSource.storage
                                  ],
                                  allowedModules: [
                                    StorageModule.articles,
                                    StorageModule.library,
                                    StorageModule.personalStorage,
                                  ],
                                  mediaType: MediaType.audio,
                                  allowedContentTypes: [
                                    'audio/mp3',
                                    'audio/wav',
                                    'audio/ogg'
                                  ],
                                ),
                                onFileSelected: (file) =>
                                    Navigator.pop(context, file),
                              ),
                            );

                            if (file != null) {
                              controller.insertHtml(
                                "<audio src=\"${file.url}\" controls></audio>",
                              );
                            }
                          },
                          icon: const Icon(Icons.audiotrack_outlined),
                        ),
                      ],
                    ),
                    // The following Button should be used for debugging purposes only
                    // IconButton(
                    //     onPressed: () {
                    //       controller.toggleCodeView();
                    //     },
                    //     icon: Icon(Icons.code)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: widget.customWidgets,
                    )
                  ],
                  onButtonPressed:
                      (ButtonType type, bool? status, Function? updateStatus) {
                    return true;
                  },
                  onDropdownChanged: (DropdownType type, dynamic changed,
                      Function(dynamic)? updateSelectedItem) {
                    return true;
                  },
                  mediaLinkInsertInterceptor:
                      (String url, InsertFileType type) {
                    return true;
                  },
                  mediaUploadInterceptor:
                      (PlatformFile file, InsertFileType type) async {
                    return true;
                  },
                ),
                otherOptions: OtherOptions(
                    height: MediaQuery.of(context).size.height -
                        kToolbarHeight * 2),
                callbacks: Callbacks(
                  onInit: () {
                    controller.setFullScreen();
                    controller.setFocus();
                    controller.evaluateJavascriptWeb("mathJax");
                  },
                  onChangeSelection: (EditorSettings settings) {
                    setState(() {
                      currentFormatBlock = settings.parentElement;
                      currentFontName = settings.fontName;
                      currentFontSize = settings.fontSize;

                      isBold = settings.isBold;
                      isItalic = settings.isItalic;
                      isUnderline = settings.isUnderline;

                      isOl = settings.isOl;
                      isUl = settings.isUl;

                      isAlignRight = settings.isAlignRight;
                      isAlignCenter = settings.isAlignCenter;
                      isAlignLeft = settings.isAlignLeft;
                      isAlignJustify = settings.isAlignJustify;

                      currentLineHeight = settings.lineHeight;

                      currentForegroundColor = settings.foregroundColor;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChangeFontColorDialog extends StatefulWidget {
  final HtmlEditorController htmlController;
  final Color currentColor;
  const ChangeFontColorDialog(
      {super.key, required this.htmlController, required this.currentColor});

  @override
  State<ChangeFontColorDialog> createState() => _ChangeFontColorDialogState();
}

class _ChangeFontColorDialogState extends State<ChangeFontColorDialog> {
  late Color newColor;

  @override
  void initState() {
    super.initState();
    newColor = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: ColorPicker(
        color: newColor,
        onColorChanged: (color) {
          newColor = color;
        },
        title: Text(
          AppLocalizations.of(context)!.textEditorChooseColorDialogTitle,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        width: 40,
        height: 40,
        spacing: 0,
        runSpacing: 0,
        borderRadius: 0,
        wheelDiameter: 165,
        enableOpacity: false,
        showColorCode: true,
        colorCodeHasColor: true,
        pickersEnabled: const <ColorPickerType, bool>{
          ColorPickerType.wheel: true,
        },
        copyPasteBehavior: const ColorPickerCopyPasteBehavior(
          parseShortHexCode: true,
        ),
        actionButtons: const ColorPickerActionButtons(
          dialogActionButtons: true,
        ),
      ),
      actions: <Widget>[
        const PIPCancelButton(),
        TextButton(
            onPressed: () {
              setState(() {
                newColor = Colors.black;
              });
              widget.htmlController
                  .execCommand('removeFormat', argument: 'foreColor');
              Navigator.of(context).pop();
            },
            child: Text(
                AppLocalizations.of(context)!.textEditorResetColorButtonLabel)),
        TextButton(
          onPressed: () {
            widget.htmlController.execCommand('foreColor',
                argument: (newColor.value & 0xFFFFFF)
                    .toRadixString(16)
                    .padLeft(6, '0')
                    .toUpperCase());

            Navigator.of(context).pop();
          },
          child:
              Text(AppLocalizations.of(context)!.textEditorSetColorButtonLabel),
        )
      ],
    );
  }
}

class ChangeBackgroundColorDialog extends StatefulWidget {
  final HtmlEditorController htmlController;
  final Color currentColor;
  const ChangeBackgroundColorDialog(
      {super.key, required this.htmlController, required this.currentColor});

  @override
  State<ChangeBackgroundColorDialog> createState() =>
      _ChangeBackgroundColorDialogState();
}

class _ChangeBackgroundColorDialogState
    extends State<ChangeBackgroundColorDialog> {
  late Color newColor;

  @override
  void initState() {
    super.initState();
    newColor = widget.currentColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: ColorPicker(
        color: newColor,
        onColorChanged: (color) {
          newColor = color;
        },
        title: Text(
          AppLocalizations.of(context)!.textEditorChooseColorDialogTitle,
        ),
        width: 40,
        height: 40,
        spacing: 0,
        runSpacing: 0,
        borderRadius: 0,
        wheelDiameter: 165,
        enableOpacity: false,
        showColorCode: true,
        colorCodeHasColor: true,
        pickersEnabled: const <ColorPickerType, bool>{
          ColorPickerType.wheel: true,
        },
        copyPasteBehavior: const ColorPickerCopyPasteBehavior(
          parseShortHexCode: true,
        ),
        actionButtons: const ColorPickerActionButtons(
          dialogActionButtons: true,
        ),
      ),
      actions: <Widget>[
        const PIPCancelButton(),
        TextButton(
            onPressed: () {
              setState(() {
                newColor = Colors.white;
              });
              widget.htmlController
                  .execCommand('removeFormat', argument: 'hiliteColor');
              Navigator.of(context).pop();
            },
            child: Text(
                AppLocalizations.of(context)!.textEditorResetColorButtonLabel)),
        TextButton(
          onPressed: () {
            widget.htmlController.execCommand('hiliteColor',
                argument: (newColor.value & 0xFFFFFF)
                    .toRadixString(16)
                    .padLeft(6, '0')
                    .toUpperCase());

            Navigator.of(context).pop();
          },
          child:
              Text(AppLocalizations.of(context)!.textEditorSetColorButtonLabel),
        )
      ],
    );
  }
}
