import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/comment.dart';

class PopulatedComment extends Comment {
  final String profilePicture;
  final String username;

  const PopulatedComment({
    required super.uid,
    required super.comment,
    required super.postId,
    required super.datePublished,
    required super.likes,
    required super.commentId,
    required super.likeCount,
    required this.profilePicture,
    required this.username,
  });

  @override
  Map<String, dynamic> toJson() => {
        "uid": uid,
        "comment": comment,
        "postId": postId,
        "datePublished": datePublished,
        "likes": likes,
        "likeCount": likeCount,
        "commentId": commentId,
        "profilePicture": profilePicture,
        "username": username,
      };

  static PopulatedComment fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return PopulatedComment(
      uid: snap['uid'],
      comment: snap['comment'],
      postId: snap['postId'],
      datePublished: snap['datePublished'],
      likes: snap['likes'],
      likeCount: snap['likeCount'],
      commentId: snap['commentId'],
      profilePicture: snap['profilePicture'],
      username: snap['username'],
    );
  }
}
