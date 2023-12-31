import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  // ignore: no_leading_underscores_for_local_identifiers
  final ImagePicker _picker = ImagePicker();

  // ignore: no_leading_underscores_for_local_identifiers
  XFile? _file = await _picker.pickImage(source: source);

  if (_file != null) {
    return await _file.readAsBytes();
  }
}

showSnackBar(String content, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}
