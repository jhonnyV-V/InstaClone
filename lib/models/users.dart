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
  final List bookmarks;
  const User({
    required this.username,
    required this.uid,
    required this.profilePicture,
    required this.bio,
    required this.email,
    required this.followers,
    required this.following,
    required this.bookmarks,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "profilePicture": profilePicture,
        "bio": bio,
        "followers": followers,
        "following": following,
        "bookmarks": bookmarks,
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
      following: snap['following'],
      bookmarks: snap['bookmarks'],
    );
  }

  String getProfilePicture() {
    if (profilePicture.isEmpty) {
      return defaultProfilePicture;
    } else {
      return profilePicture;
    }
  }
}
