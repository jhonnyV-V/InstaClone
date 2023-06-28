import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/users.dart' as model;
import 'package:instagram_clone/resources/storage.dart';
import 'package:instagram_clone/utils/constants.dart';

class Auth {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    XFile? file,
    String bio = "",
  }) async {
    String res = "Some Error has ocurred";
    try {
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        throw ("Fill all the data");
      }
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      String picture = "";
      if (file != null) {
        List<String> temp = await Storage().uploadImage(
          [file],
          profilePicturesPath,
          false,
        );
        picture = temp.first;
      }
      model.User user = model.User(
        username: username,
        uid: cred.user!.uid,
        profilePicture: picture,
        bio: bio,
        email: email,
        followers: [],
        following: [],
        bookmarks: [],
      );

      await _firestore
          .collection(userCollection)
          .doc(cred.user!.uid)
          .set(user.toJson());
      res = "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        res = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        res = 'The account already exists for that email.';
      } else {
        res = e.code;
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    String res = "Some Error has ocurred";
    try {
      if (email.isEmpty || password.isEmpty) {
        throw ("Fill all the data");
      }
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      res = "success";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        res = 'This accound does not exist';
      } else if (e.code == 'wrong-password') {
        res = 'This is not the correct password.';
      } else {
        res = e.code;
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<model.User> getUserDetails([String? uid]) async {
    User currentUser = _auth.currentUser!;
    String id = '';
    if (uid != null) {
      id = uid;
    } else {
      id = currentUser.uid;
    }
    DocumentSnapshot snap =
        await _firestore.collection(userCollection).doc(id).get();
    return model.User.fromSnap(snap);
  }

  Future<void> logOut() async {
    await _auth.signOut();
  }
}
