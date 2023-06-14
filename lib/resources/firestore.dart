import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_clone/models/comment.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/storage.dart';
import 'package:instagram_clone/utils/constants.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadPost(Uint8List image, String description) async {
    String res = "some error ocurred";
    try {
      User currentUser = _auth.currentUser!;
      String imageUrl =
          await Storage().uploadImage(image, postStoragePath, true);
      String postId = const Uuid().v4();

      Post post = Post(
        uid: currentUser.uid,
        description: description,
        imageUrl: imageUrl,
        datePublished: DateTime.now(),
        likes: [],
        likeCount: 0,
        postId: postId,
      );

      await _firestore
          .collection(postsCollection)
          .doc(postId)
          .set(post.toJson());
      res = "success";
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection(postsCollection).doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection(postsCollection).doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<String> postComment(String postId, String uid, String text) async {
    String res = "Some error has ocurred";
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v4();
        Comment comment = Comment(
          uid: uid,
          comment: text,
          commentId: commentId,
          datePublished: DateTime.now(),
          likes: [],
          likeCount: 0,
          postId: postId,
        );
        await _firestore
            .collection(postsCollection)
            .doc(postId)
            .collection(commentCollection)
            .doc(commentId)
            .set(comment.toJson());

        res = "success";
      } else {
        res = 'You need to write a comment first';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> likeComment(
      String postId, String commentId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection(postsCollection)
            .doc(postId)
            .collection(commentCollection)
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore
            .collection(postsCollection)
            .doc(postId)
            .collection(commentCollection)
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> deletePost(String postid, String imageUrl) async {
    try {
      await _firestore.collection(postsCollection).doc(postid).delete();
      await Storage().deleteImage(imageUrl);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> followUser(String userToFollowUid) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await _firestore.collection(userCollection).doc(uid).update({
        'following': FieldValue.arrayUnion([userToFollowUid]),
      });
      await _firestore.collection(userCollection).doc(userToFollowUid).update({
        'followers': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  Future<void> unFollowUser(String userToUnfollowUid) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      await _firestore.collection(userCollection).doc(uid).update({
        'following': FieldValue.arrayRemove([userToUnfollowUid]),
      });
      await _firestore
          .collection(userCollection)
          .doc(userToUnfollowUid)
          .update({
        'followers': FieldValue.arrayRemove([uid]),
      });
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
