import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/post.dart';

class PopulatedPost extends Post {
  final String profilePicture;
  final String username;
  final int numOfComments;
  final List<String> originalImagesUrl;
  const PopulatedPost({
    required super.uid,
    required super.description,
    required super.imagesUrl,
    required super.datePublished,
    required super.likes,
    required super.likeCount,
    required super.postId,
    required this.profilePicture,
    required this.username,
    required this.numOfComments,
    required this.originalImagesUrl,
  });

  @override
  Map<String, dynamic> toJson() => {
        "uid": uid,
        "description": description,
        "imagesUrl": imagesUrl,
        "datePublished": datePublished,
        "likes": likes,
        "likeCount": likeCount,
        "postId": postId,
        "profilePicture": profilePicture,
        "username": username,
        "numOfComments": numOfComments,
        "originalImagesUrl": originalImagesUrl,
      };

  static PopulatedPost fromSnap(DocumentSnapshot snapshot) {
    var snap = snapshot.data() as Map<String, dynamic>;

    return PopulatedPost(
      uid: snap['uid'],
      description: snap['description'],
      imagesUrl: snap['imagesUrl'],
      datePublished: snap['datePublished'],
      likes: snap['likes'],
      likeCount: snap['likeCount'],
      postId: snap['postId'],
      profilePicture: snap['profilePicture'],
      username: snap['username'],
      numOfComments: snap['numOfComments'],
      originalImagesUrl: snap['imagesUrl'],
    );
  }

  static PopulatedPost fromPost(
    Post post,
    String profilePicture,
    String username,
    int numOfComments,
  ) {
    return PopulatedPost(
      uid: post.uid,
      description: post.description,
      imagesUrl: post.imagesUrl,
      datePublished: post.datePublished,
      likes: post.likes,
      likeCount: post.likeCount,
      postId: post.postId,
      profilePicture: profilePicture,
      username: username,
      numOfComments: numOfComments,
      originalImagesUrl: post.imagesUrl,
    );
  }
}
