import 'package:flutter/material.dart';
import 'package:edconnect_admin/presentation/widgets/common/input/number_input.dart';

class ClassConfig {
  final TextEditingController nameController;
  final NumberInputController sizeController;

  ClassConfig({
    required String name,
    required this.sizeController,
  }) : nameController = TextEditingController(text: name);

  void dispose() {
    nameController.dispose();
    sizeController.dispose();
  }
}
