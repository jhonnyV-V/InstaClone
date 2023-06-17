import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/populated_comment.dart';
import 'package:instagram_clone/resources/auth.dart';
import 'package:instagram_clone/resources/firestore.dart';
import 'package:instagram_clone/resources/temporary_storage.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/constants.dart';
import 'package:instagram_clone/widgets/comment_card.dart';
import 'package:instagram_clone/models/users.dart' as model;
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:provider/provider.dart';

class Comments extends StatefulWidget {
  final String postId;
  const Comments({super.key, required this.postId});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final TextEditingController comment = TextEditingController();
  Stream<List<PopulatedComment>>? stream;

  Future<List<PopulatedComment>> populateUserData(
      QuerySnapshot<Map<String, dynamic>> post) async {
    Map<String, model.User> uidToData = {};
    List<PopulatedComment> populatedPost = [];
    Auth auth = Auth();
    for (var element in post.docs) {
      var data = element.data();
      var uid = data['uid'];
      model.User userData;
      if (uidToData[uid] != null) {
        userData = uidToData[uid]!;
      } else {
        userData = await auth.getUserDetails(uid);
        uidToData[uid] = userData;
      }
      populatedPost.add(
        PopulatedComment(
          uid: uid,
          comment: data['comment'],
          commentId: data['commentId'],
          datePublished: data['datePublished'].toDate(),
          likes: data['likes'],
          likeCount: data['likeCount'],
          postId: data['postId'],
          profilePicture: await TemporaryStorage.getImage(
            userData.uid,
            tempProfilePicture,
            userData.getProfilePicture(),
          ),
          username: userData.username,
        ),
      );
    }
    return populatedPost;
  }

  @override
  void initState() {
    stream = FirebaseFirestore.instance
        .collection(postsCollection)
        .doc(widget.postId)
        .collection(commentCollection)
        .orderBy('likeCount', descending: true)
        .snapshots()
        .asyncMap((comments) => populateUserData(comments));
    super.initState();
  }

  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text('Comments'),
        centerTitle: false,
      ),
      body: StreamBuilder<List<PopulatedComment>>(
        stream: stream,
        builder: (context, AsyncSnapshot<List<PopulatedComment>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data != null ? snapshot.data!.length : 0,
            itemBuilder: (context, index) => CommentCard(
              comment: snapshot.data![index],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                backgroundImage: MemoryImage(
                  File(user.profilePicture).readAsBytesSync(),
                ),
                radius: 18,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16, right: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'comment as ${user.username}',
                      border: InputBorder.none,
                    ),
                    controller: comment,
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  await FirestoreMethods().postComment(
                    widget.postId,
                    user.uid,
                    comment.text,
                  );
                  comment.clear();
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  child: const Text(
                    'Post',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
