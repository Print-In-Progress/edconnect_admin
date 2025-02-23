import 'package:edconnect_admin/components/forms.dart';
import 'package:edconnect_admin/components/signature_button.dart';
import 'package:edconnect_admin/components/snackbars.dart';
import 'package:edconnect_admin/models/registration_fields.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Widget buildRegistrationCard(
    BuildContext context, List<BaseRegistrationField> fieldData, int index) {
  if (fieldData[index].type == 'infobox') {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              fieldData[index].title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Text(fieldData[index].text!),
          ],
        ),
      ),
    );
  } else if (fieldData[index].type == 'free_response') {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              fieldData[index].title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            PIPOutlinedBorderInputForm(
              label: fieldData[index].title,
              validate: false,
              width: MediaQuery.of(context).size.width,
              controller: fieldData[index].response!,
            ),
          ],
        ),
      ),
    );
  } else if (fieldData[index].type == 'dropdown') {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              fieldData[index].title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 5,
            ),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return DropdownMenu(
                  expandedInsets: const EdgeInsets.all(8),
                  requestFocusOnTap: false,
                  onSelected: (selectedOption) {
                    setState(() {
                      fieldData[index].selectedOption =
                          selectedOption.toString();
                    });
                  },
                  dropdownMenuEntries:
                      List<String>.from(fieldData[index].options!)
                          .map<DropdownMenuEntry>((group) =>
                              DropdownMenuEntry(value: group, label: group))
                          .toList());
            }),
          ],
        ),
      ),
    );
  } else if (fieldData[index].type == 'signature') {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Column(
            children: [
              Text(
                'Advanced Electronic Signature',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                'I hereby acknowledge that by clicking the button below and submitting this form, I am providing my consent to digitally sign this document. I understand that my signature will be securely generated using cryptographic techniques to ensure the authenticity and integrity of the document.',
                textAlign: TextAlign.center,
              ),
              if (fieldData[index].checked == true)
                Text(
                  'To unsign this document, click the button again',
                  textAlign: TextAlign.center,
                ),
              SignatureButton(
                isChecked: fieldData[index].checked!,
                onPressed: () {
                  setState(() {
                    fieldData[index].checked = !fieldData[index].checked!;
                  });
                },
              ),
            ],
          );
        }),
      ),
    );
  } else if (fieldData[index].type == 'checkbox') {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              fieldData[index].title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Text(fieldData[index].text!),
            const SizedBox(height: 5),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return CheckboxListTile(
                title: Text(fieldData[index].checkboxLabel!),
                value: fieldData[index].checked,
                onChanged: (value) {
                  setState(() {
                    fieldData[index].checked = value;
                  });
                },
              );
            }),
          ],
        ),
      ),
    );
  } else if (fieldData[index].type == 'file_upload') {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                fieldData[index].title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 5),
              Text(fieldData[index].text!),
              const SizedBox(height: 5),
              Text(
                '${fieldData[index].file?.length ?? '0'}/${fieldData[index].maxFileUploads} Files',
                textAlign: TextAlign.left,
              ),
              ElevatedButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      allowMultiple: true,
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
                    );
                    if (result != null) {
                      if (result.files.length >
                          fieldData[index].maxFileUploads!) {
                        errorMessage(context,
                            'You can only upload a maximum of ${fieldData[index].maxFileUploads} files');
                      } else {
                        setState(() {
                          fieldData[index].file = result.files;
                        });
                      }
                    }
                  },
                  child: Text('Upload File')),
              Wrap(
                children: [
                  if (fieldData[index].file != null)
                    for (var file in fieldData[index].file!)
                      Text(
                        file.name,
                        style: TextStyle(color: Colors.grey[600]),
                      )
                ],
              )
            ],
          ),
        ),
      );
    });
  } else if (fieldData[index].type == 'checkbox_section') {
    // Get subfields for this parent
    final ExpansionTileController expansionSectionController =
        ExpansionTileController();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return ExpansionTile(
                shape: const Border(),
                controller: expansionSectionController,
                title: Text(fieldData[index].title),
                onExpansionChanged: (value) {
                  setState(() {
                    fieldData[index].checked = value;
                  });
                },
                children: [
                  ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, subWidgetindex) {
                        return buildRegistrationCard(context,
                            fieldData[index].childWidgets!, subWidgetindex);
                      },
                      itemCount: fieldData[index].childWidgets!.length)
                ],
              );
            }),
          ],
        ),
      ),
    );
  } else if (fieldData[index].type == 'date') {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              fieldData[index].title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return OutlinedButton(
                onPressed: () async {
                  DateTime? datePicked = await showDatePicker(
                    context: context,
                    initialDate:
                        fieldData[index].selectedDate ?? DateTime.now(),
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
      ),
    );
  } else if (fieldData[index].type == 'checkbox_assign_group') {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return CheckboxListTile(
                  title: Text(fieldData[index].title),
                  value: fieldData[index].checked,
                  onChanged: (value) {
                    setState(() {
                      fieldData[index].checked = value;
                    });
                  });
            }),
          ],
        ),
      ),
    );
  } else {
    return const SizedBox.shrink();
  }
}
