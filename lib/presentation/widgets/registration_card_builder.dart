import 'package:edconnect_admin/core/design_system/foundations.dart';
import 'package:edconnect_admin/domain/entities/registration_fields.dart';
import 'package:edconnect_admin/presentation/providers/theme_provider.dart';
import 'package:edconnect_admin/presentation/widgets/common/cards/base_card.dart';
import 'package:edconnect_admin/presentation/widgets/common/checkbox.dart';
import 'package:edconnect_admin/presentation/widgets/common/dropdown/single_select_dropdown.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/base_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/file_input.dart';
import 'package:edconnect_admin/presentation/widgets/common/signature_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

Widget buildRegistrationCard(BuildContext context,
    List<BaseRegistrationField> fieldData, int index, bool isDarkMode) {
  Widget wrapWithCard(Widget child) {
    return BaseCard(
      variant: CardVariant.elevated,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.all(Foundations.spacing.lg),
      child: child,
    );
  }

  // Common field title styling
  Widget buildFieldTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: Foundations.spacing.sm),
      child: Text(
        title,
        style: TextStyle(
          fontSize: Foundations.typography.lg,
          fontWeight: Foundations.typography.semibold,
          color: isDarkMode
              ? Foundations.darkColors.textPrimary
              : Foundations.colors.textPrimary,
        ),
      ),
    );
  }

  if (fieldData[index].type == 'infobox') {
    return wrapWithCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildFieldTitle(fieldData[index].title),
          Text(
            fieldData[index].text ?? '',
            style: TextStyle(
              fontSize: Foundations.typography.base,
              color: isDarkMode
                  ? Foundations.darkColors.textSecondary
                  : Foundations.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  } else if (fieldData[index].type == 'free_response') {
    return wrapWithCard(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BaseInput(
            controller: fieldData[index].response,
            label: fieldData[index].title,
            isRequired: fieldData[index].isRequired,
            variant: InputVariant.default_,
            size: InputSize.medium,
          ),
        ],
      ),
    );
  } else if (fieldData[index].type == 'dropdown') {
    return Consumer(
      builder: (context, ref, _) {
        final options = List<String>.from(fieldData[index].options ?? [])
            .map((option) => SelectOption(value: option, label: option))
            .toList();

        return wrapWithCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BaseSelect<String>(
                label: fieldData[index].title,
                value: fieldData[index].selectedOption,
                options: options,
                isRequired: fieldData[index].isRequired,
                onChanged: (selectedOption) {
                  fieldData[index].selectedOption = selectedOption;
                  (context as Element).markNeedsBuild();
                },
                size: SelectSize.medium,
                variant: SelectVariant.default_,
              ),
            ],
          ),
        );
      },
    );
  } else if (fieldData[index].type == 'signature') {
    return Consumer(
      builder: (context, ref, _) {
        return wrapWithCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildFieldTitle('Advanced Electronic Signature'),
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: Foundations.spacing.md,
                  horizontal: Foundations.spacing.md,
                ),
                child: Text(
                  'I hereby acknowledge that by clicking the button below and submitting this form, I am providing my consent to digitally sign this document. I understand that my signature will be securely generated using cryptographic techniques to ensure the authenticity and integrity of the document.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Foundations.typography.sm,
                    color: isDarkMode
                        ? Foundations.darkColors.textSecondary
                        : Foundations.colors.textSecondary,
                  ),
                ),
              ),
              if (fieldData[index].checked == true)
                Padding(
                  padding: EdgeInsets.only(bottom: Foundations.spacing.md),
                  child: Text(
                    'To unsign this document, click the button again',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Foundations.typography.sm,
                      color: isDarkMode
                          ? Foundations.darkColors.textMuted
                          : Foundations.colors.textMuted,
                    ),
                  ),
                ),
              SignatureButton(
                isChecked: fieldData[index].checked ?? false,
                onPressed: () {
                  // Using StatefulBuilder isn't ideal here
                  // Instead, we should update the state and rebuild
                  fieldData[index].checked =
                      !(fieldData[index].checked ?? false);
                  (context as Element).markNeedsBuild();
                },
              ),
            ],
          ),
        );
      },
    );
  } else if (fieldData[index].type == 'checkbox') {
    return Consumer(
      builder: (context, ref, _) {
        return wrapWithCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildFieldTitle(fieldData[index].title),
              Text(
                fieldData[index].text ?? '',
                style: TextStyle(
                  fontSize: Foundations.typography.sm,
                  color: isDarkMode
                      ? Foundations.darkColors.textSecondary
                      : Foundations.colors.textSecondary,
                ),
              ),
              SizedBox(height: Foundations.spacing.md),
              BaseCheckbox(
                value: fieldData[index].checked ?? false,
                onChanged: (value) {
                  fieldData[index].checked = value;
                  (context as Element).markNeedsBuild();
                },
                label: fieldData[index].checkboxLabel,
                size: CheckboxSize.medium,
              ),
            ],
          ),
        );
      },
    );
  } else if (fieldData[index].type == 'file_upload') {
    return Consumer(
      builder: (context, ref, _) {
        return wrapWithCard(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildFieldTitle(fieldData[index].title),
              Text(
                fieldData[index].text ?? '',
                style: TextStyle(
                  fontSize: Foundations.typography.sm,
                  color: isDarkMode
                      ? Foundations.darkColors.textSecondary
                      : Foundations.colors.textSecondary,
                ),
              ),
              SizedBox(height: Foundations.spacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${fieldData[index].file?.length ?? 0}/${fieldData[index].maxFileUploads} Files',
                      style: TextStyle(
                        fontSize: Foundations.typography.sm,
                        fontWeight: Foundations.typography.medium,
                        color: isDarkMode
                            ? Foundations.darkColors.textSecondary
                            : Foundations.colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: Foundations.spacing.sm),
              FileInput(
                label: 'Upload Files',
                hint: 'Click to select files',
                selectedFiles: fieldData[index].file,
                allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
                maxFiles: fieldData[index].maxFileUploads,
                onFilesChanged: (files) {
                  // Using the Element.markNeedsBuild pattern to update the UI
                  fieldData[index].file = files;
                  (context as Element).markNeedsBuild();
                },
              ),
            ],
          ),
        );
      },
    );
  } else if (fieldData[index].type == 'checkbox_section') {
    // Get subfields for this parent

    return Consumer(
      builder: (context, ref, _) {
        final theme = ref.watch(appThemeProvider);
        final isDarkMode = theme.isDarkMode;

        return BaseCard(
          variant: CardVariant.elevated,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          child: Theme(
            // Use a custom theme with no divider for ExpansionTile
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              colorScheme: Theme.of(context).colorScheme.copyWith(
                    primary: theme.primaryColor,
                  ),
            ),
            child: ExpansionTile(
              onExpansionChanged: (value) {
                fieldData[index].checked = value;
                (context as Element).markNeedsBuild();
              },
              iconColor: isDarkMode
                  ? Foundations.darkColors.textSecondary
                  : Foundations.colors.textSecondary,
              collapsedIconColor: isDarkMode
                  ? Foundations.darkColors.textSecondary
                  : Foundations.colors.textSecondary,
              tilePadding: EdgeInsets.symmetric(
                horizontal: Foundations.spacing.lg,
                vertical: Foundations.spacing.sm,
              ),
              title: Text(
                fieldData[index].title,
                style: TextStyle(
                  fontSize: Foundations.typography.lg,
                  fontWeight: Foundations.typography.medium,
                  color: isDarkMode
                      ? Foundations.darkColors.textPrimary
                      : Foundations.colors.textPrimary,
                ),
              ),
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: Foundations.spacing.lg,
                    right: Foundations.spacing.lg,
                    bottom: Foundations.spacing.lg,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: fieldData[index].childWidgets?.length ?? 0,
                    separatorBuilder: (context, index) => SizedBox(
                      height: Foundations.spacing.md,
                    ),
                    itemBuilder: (context, subWidgetIndex) {
                      return buildRegistrationCard(
                          context,
                          fieldData[index].childWidgets!,
                          subWidgetIndex,
                          isDarkMode);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  } else if (fieldData[index].type == 'date') {
    return wrapWithCard(
      Column(
        children: [
          buildFieldTitle(fieldData[index].title),
          StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return OutlinedButton(
              onPressed: () async {
                DateTime? datePicked = await showDatePicker(
                  context: context,
                  initialDate: fieldData[index].selectedDate ?? DateTime.now(),
                  firstDate:
                      DateTime.now().subtract(const Duration(days: 36500)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                setState(() {
                  if (datePicked != null) {
                    fieldData[index].selectedDate = datePicked;
                  }
                });
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    fieldData[index].selectedDate == null
                        ? 'Tap to select date'
                        : DateFormat.yMd()
                            .format(fieldData[index].selectedDate!)
                            .toString(),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 5),
                  const Icon(Icons.calendar_today),
                ],
              ),
            );
          })
        ],
      ),
    );
  } else if (fieldData[index].type == 'checkbox_assign_group') {
    return Consumer(
      builder: (context, ref, _) {
        return wrapWithCard(
          BaseCheckbox(
            value: fieldData[index].checked ?? false,
            onChanged: (value) {
              fieldData[index].checked = value;
              (context as Element).markNeedsBuild();
            },
            label: fieldData[index].title,
            size: CheckboxSize.medium,
          ),
        );
      },
    );
  } else {
    return const SizedBox.shrink();
  }
}
