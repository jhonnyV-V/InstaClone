import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Storage {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImage(
      Uint8List picture, String childName, bool isPost) async {
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);
    if (isPost) {
      String id = const Uuid().v4();
      ref = ref.child(id);
    }

    UploadTask task = ref.putData(picture);
    TaskSnapshot snap = await task;
    String url = await snap.ref.getDownloadURL();
    return url;
  }

  Future<bool> deleteImage(String imageUrl) async {
    Reference ref = _storage.refFromURL(imageUrl);
    bool success = true;
    try {
      await ref.delete();
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      success = false;
    }
    return success;
  }
}
