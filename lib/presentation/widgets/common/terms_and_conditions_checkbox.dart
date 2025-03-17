import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/services/url_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TermsAndConditionsCheckbox extends ConsumerStatefulWidget {
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const TermsAndConditionsCheckbox({
    Key? key,
    required this.isChecked,
    required this.onChanged,
  }) : super(key: key);

  @override
  ConsumerState<TermsAndConditionsCheckbox> createState() =>
      _TermsAndConditionsCheckboxState();
}

class _TermsAndConditionsCheckboxState
    extends ConsumerState<TermsAndConditionsCheckbox> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = ref.watch(appThemeProvider);

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Checkbox(
            value: widget.isChecked,
            onChanged: (value) {
              widget.onChanged(value!);
            },
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: localizations.termsAndConditionsPrefix,
                    style: TextStyle(
                      color: theme.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 10,
                    ),
                  ),
                  TextSpan(
                    text: localizations.termsAndConditionsLinkText,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => UrlService.launchWebUrl(
                          'https://printinprogress.net/terms'),
                  ),
                  TextSpan(
                    text: localizations.termsAndConditionsMiddle,
                    style: TextStyle(
                      color: theme.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 10,
                    ),
                  ),
                  TextSpan(
                    text: localizations.privacyPolicyLinkText,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => UrlService.launchWebUrl(
                          'https://printinprogress.net/privacy'),
                  ),
                  TextSpan(
                    text: localizations.termsAndConditionsSuffix,
                    style: TextStyle(
                      color: theme.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
