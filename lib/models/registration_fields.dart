import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

abstract class BaseRegistrationField {
  final String id;
  final String type;
  String? text;
  String title;
  String? group;
  String? selectedOption;
  List? options;
  int pos;
  String? checkboxLabel;
  int? maxFileUploads;
  List<PlatformFile>? file;
  DateTime? selectedDate;

  List<RegistrationSubField>? childWidgets;
  TextEditingController? response;
  bool? checked;

  BaseRegistrationField({
    required this.id,
    required this.type,
    this.options,
    required this.title,
    this.text,
    this.response,
    this.checked,
    this.group,
    this.selectedDate,
    this.childWidgets,
    this.selectedOption,
    this.file,
    this.maxFileUploads,
    this.checkboxLabel,
    required this.pos,
  });
}

class RegistrationField extends BaseRegistrationField {
  RegistrationField({
    required String id,
    required String type,
    List? options,
    required String title,
    List<RegistrationSubField>? childWidgets,
    String? text,
    String? selectedOption,
    String? group,
    bool? checked,
    List<PlatformFile>? file,
    DateTime? selectedDate,
    TextEditingController? response,
    required int pos,
    int? maxFileUploads,
    String? checkboxLabel,
  }) : super(
          id: id,
          type: type,
          options: options,
          title: title,
          text: text,
          response: response,
          group: group,
          checked: checked,
          file: file,
          selectedDate: selectedDate,
          selectedOption: selectedOption,
          childWidgets: childWidgets,
          maxFileUploads: maxFileUploads,
          checkboxLabel: checkboxLabel,
          pos: pos,
        );
}

class RegistrationSubField extends BaseRegistrationField {
  final String parentUid;

  RegistrationSubField({
    required String id,
    required this.parentUid,
    required String type,
    List? options,
    required String title,
    String? text,
    String? group,
    bool? signed,
    List<PlatformFile>? file,
    TextEditingController? response,
    bool? checked,
    DateTime? selectedDate,
    List<RegistrationSubField>? childWidgets,
    int? maxFileUploads,
    String? checkboxLabel,
    required int pos,
  }) : super(
          id: id,
          type: type,
          options: options,
          title: title,
          checkboxLabel: checkboxLabel,
          pos: pos,
          file: file,
          response: response,
          checked: checked,
          selectedDate: selectedDate,
          group: group,
          text: text,
          maxFileUploads: maxFileUploads,
          childWidgets: childWidgets,
        );
}
