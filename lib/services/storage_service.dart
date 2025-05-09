import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPetImage(Uint8List image, String userId) async {
    try {
      final ref = _storage.ref('mascotas/$userId/${DateTime.now()}.jpg');
      await ref.putData(image);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }
}
