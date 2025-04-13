import 'package:edconnect_admin/presentation/widgets/common/buttons/base_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:edconnect_admin/l10n/app_localizations.dart';

class LinkDialog extends ConsumerStatefulWidget {
  final HtmlEditorController htmlController;

  const LinkDialog({
    super.key,
    required this.htmlController,
  });

  @override
  ConsumerState<LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends ConsumerState<LinkDialog> {
  final _textController = TextEditingController();
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.textEditorInsertLink,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 24.0),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!
                    .textEditorInsertLinkTextToDisplay,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                BaseButton(
                    label: l10n.globalCancel,
                    variant: ButtonVariant.text,
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                BaseButton(
                  label: l10n.globalOk,
                  onPressed: () {
                    widget.htmlController.insertLink(
                      _textController.text,
                      _urlController.text,
                      true,
                    );
                    Navigator.pop(context);
                  },
                  variant: ButtonVariant.filled,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
