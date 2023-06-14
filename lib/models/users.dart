import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/utils/constants.dart';

class User {
  final String username;
  final String email;
  final String profilePicture;
  final String uid;
  final String bio;
  final List followers;
  final List following;
  const User(
      {required this.username,
      required this.uid,
      required this.profilePicture,
      required this.bio,
      required this.email,
      required this.followers,
      required this.following});

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "profilePicture": profilePicture,
        "bio": bio,
        "followers": followers,
        "following": following,
      };

  static User fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return User(
        username: snap['username'],
        uid: snap['uid'],
        profilePicture: snap['profilePicture'],
        bio: snap['bio'],
        email: snap['email'],
        followers: snap['followers'],
        following: snap['following']);
  }

  String getProfilePicture() {
    if (profilePicture.isEmpty) {
      return defaulProfilePicture;
    } else {
      return profilePicture;
    }
  }
}
