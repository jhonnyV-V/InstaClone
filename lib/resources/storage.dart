import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class Storage {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<String>> uploadImage(
    List<XFile> picture,
    String childName,
    bool isPost,
  ) async {
    Reference baseRef = _storage
        .ref()
        .child(
          childName,
        )
        .child(
          _auth.currentUser!.uid,
        );
    List<Reference> references = [];
    if (isPost) {
      String id = const Uuid().v4();
      baseRef = baseRef.child(id);
      for (var i = 0; i < picture.length; i++) {
        references.add(baseRef.child('$i'));
      }
    } else {
      references.add(baseRef);
    }

    List<UploadTask> tasks = [];
    for (var i = 0; i < references.length; i++) {
      tasks.add(
        references[i].putFile(
          File(
            picture[i].path,
          ),
        ),
      );
    }

    List<TaskSnapshot> snaps = await Future.wait(tasks);
    List<String> urls = await Future.wait(
      snaps.map((snap) {
        return snap.ref.getDownloadURL();
      }),
    );
    return urls;
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
