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
  bool isRequired;

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
    this.isRequired = false,
    required this.pos,
  });
}

class RegistrationField extends BaseRegistrationField {
  RegistrationField({
    required super.id,
    required super.type,
    super.options,
    required super.title,
    super.childWidgets,
    super.text,
    super.selectedOption,
    super.group,
    super.checked,
    super.file,
    super.selectedDate,
    super.response,
    required super.pos,
    super.maxFileUploads,
    super.checkboxLabel,
  });
}

class RegistrationSubField extends BaseRegistrationField {
  final String parentUid;

  RegistrationSubField({
    required super.id,
    required this.parentUid,
    required super.type,
    super.options,
    required super.title,
    super.text,
    super.group,
    bool? signed,
    super.file,
    super.response,
    super.checked,
    super.selectedDate,
    super.childWidgets,
    super.maxFileUploads,
    super.checkboxLabel,
    required super.pos,
  });
}
