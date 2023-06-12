import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String uid;
  final String commentId;
  final String postId;
  final String comment;
  final DateTime datePublished;
  final List likes;
  final int likeCount;
  const Comment({
    required this.uid,
    required this.comment,
    required this.postId,
    required this.datePublished,
    required this.likes,
    required this.likeCount,
    required this.commentId,
  });

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "comment": comment,
        "postId": postId,
        "datePublished": datePublished,
        "likes": likes,
        "likeCount": likeCount,
        "commentId": commentId,
      };

  static Comment fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return Comment(
        uid: snap['uid'],
        comment: snap['comment'],
        postId: snap['postId'],
        datePublished: snap['datePublished'],
        likes: snap['likes'],
        likeCount: snap['likeCount'],
        commentId: snap['commentId']);
  }
}
