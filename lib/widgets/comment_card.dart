import 'package:flutter/material.dart';
import 'package:instagram_clone/models/populated_comment.dart';
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/models/users.dart' as model;
import 'package:instagram_clone/resources/firestore.dart';
import 'package:instagram_clone/widgets/like_animation.dart';
import 'package:jiffy/jiffy.dart';
import 'package:provider/provider.dart';

class CommentCard extends StatefulWidget {
  final PopulatedComment comment;
  const CommentCard({super.key, required this.comment});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    final userLiked = widget.comment.likes.contains(user.uid);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(widget.comment.profilePicture),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: widget.comment.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: ' ${widget.comment.comment}',
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      Jiffy.parseFromDateTime(widget.comment.datePublished)
                          .fromNow(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding:
                const EdgeInsets.only(bottom: 10, left: 8, right: 8, top: 0),
            child: Column(
              children: [
                LikeAnimation(
                  isAnimating: userLiked,
                  smallLike: true,
                  child: IconButton(
                    onPressed: () async {
                      await FirestoreMethods().likeComment(
                        widget.comment.postId,
                        widget.comment.commentId,
                        user.uid,
                        widget.comment.likes,
                      );
                    },
                    icon: userLiked
                        ? const Icon(Icons.favorite, color: Colors.red)
                        : const Icon(
                            Icons.favorite_border_outlined,
                            color: Colors.white,
                          ),
                  ),
                ),
                Text(
                  '${widget.comment.likes.length}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
