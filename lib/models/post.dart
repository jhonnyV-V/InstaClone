import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String uid;
  final String postId;
  final String imageUrl;
  final String description;
  final DateTime datePublished;
  final List likes;
  final int likeCount;
  const Post({
    required this.uid,
    required this.description,
    required this.imageUrl,
    required this.datePublished,
    required this.likes,
    required this.postId,
    required this.likeCount,
  });

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "description": description,
        "imageUrl": imageUrl,
        "datePublished": datePublished,
        "likes": likes,
        "likeCount": likeCount,
        "postId": postId,
      };

  static Post fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return Post(
      uid: snap['uid'],
      description: snap['description'],
      imageUrl: snap['imageUrl'],
      datePublished: snap['datePublished'].runtimeType == Timestamp
          ? snap['datePublished'].toDate()
          : snap['datePublished'],
      likes: snap['likes'],
      likeCount: snap['likeCount'],
      postId: snap['postId'],
    );
  }
}
