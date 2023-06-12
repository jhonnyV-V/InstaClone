import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/post.dart';

class PopulatedPost extends Post {
  final String profilePicture;
  final String username;
  final int numOfComments;
  const PopulatedPost({
    required super.uid,
    required super.description,
    required super.imageUrl,
    required super.datePublished,
    required super.likes,
    required super.likeCount,
    required super.postId,
    required this.profilePicture,
    required this.username,
    required this.numOfComments,
  });

  @override
  Map<String, dynamic> toJson() => {
        "uid": uid,
        "description": description,
        "imageUrl": imageUrl,
        "datePublished": datePublished,
        "likes": likes,
        "likeCount": likeCount,
        "postId": postId,
        "profilePicture": profilePicture,
        "username": username,
        "numOfComments": numOfComments,
      };

  static PopulatedPost fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return PopulatedPost(
      uid: snap['uid'],
      description: snap['description'],
      imageUrl: snap['imageUrl'],
      datePublished: snap['datePublished'],
      likes: snap['likes'],
      likeCount: snap['likeCount'],
      postId: snap['postId'],
      profilePicture: snap['profilePicture'],
      username: snap['username'],
      numOfComments: snap['numOfComments'],
    );
  }
}
