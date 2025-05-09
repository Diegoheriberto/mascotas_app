import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';

class ImageUploader extends StatelessWidget {
  final Function(Uint8List) onImageSelected;

  const ImageUploader({super.key, required this.onImageSelected});

  Future<void> _pickImage() async {
    final image = await ImagePickerWeb.getImageAsBytes();
    if (image != null) onImageSelected(image);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.camera_alt, size: 40),
      onPressed: _pickImage,
    );
  }
}
