import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/models/populated_post.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/users.dart' as model;
import 'package:instagram_clone/resources/auth.dart';
import 'package:instagram_clone/resources/temporary_storage.dart';
import 'package:instagram_clone/screens/profile.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/constants.dart';
import 'package:instagram_clone/widgets/post_card.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController searchController = TextEditingController();
  final Key searchBuilderKey = const Key('Search Builder');
  final Key postsBuilderKey = const Key('Posts Builder');
  bool displayResults = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<List<model.User>> getUsers() async {
    QuerySnapshot<Map<String, dynamic>> result =
        await FirebaseFirestore.instance
            .collection(userCollection)
            .where(
              'username',
              isGreaterThanOrEqualTo: searchController.text,
            )
            .get();
    List<model.User> list = [];

    for (var element in result.docs) {
      model.User snap = model.User.fromSnap(element);
      list.add(
        model.User(
          username: snap.username,
          uid: snap.uid,
          profilePicture: await TemporaryStorage.getImage(
            snap.uid,
            tempProfilePicture,
            snap.getProfilePicture(),
          ),
          bio: snap.bio,
          email: snap.email,
          followers: snap.followers,
          following: snap.following,
          bookmarks: snap.bookmarks,
        ),
      );
    }

    return list;
  }

  Future<List<Post>> getPostFromUser() async {
    QuerySnapshot<Map<String, dynamic>> result = await FirebaseFirestore
        .instance
        .collection(postsCollection)
        .orderBy('datePublished')
        .limit(20)
        .get();
    List<Post> list = [];
    for (var element in result.docs) {
      Post snapPost = Post.fromSnap(element);
      list.add(
        Post(
          uid: snapPost.uid,
          description: snapPost.description,
          imageUrl: await TemporaryStorage.getImage(
            '1',
            '$tempPostImage/${snapPost.postId}',
            snapPost.imageUrl,
          ),
          datePublished: snapPost.datePublished,
          likes: snapPost.likes,
          postId: snapPost.postId,
          likeCount: snapPost.likeCount,
        ),
      );
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: TextFormField(
          decoration: const InputDecoration(
            labelText: 'Search for an user',
          ),
          controller: searchController,
          onFieldSubmitted: (String _) {
            setState(() {
              displayResults = true;
            });
          },
        ),
        centerTitle: false,
      ),
      body: displayResults
          ? FutureBuilder(
              key: searchBuilderKey,
              future: getUsers(),
              builder: (context, AsyncSnapshot<List<model.User>> snap) {
                if (!snap.hasData) {
                  const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: snap.data != null ? snap.data!.length : 0,
                  itemBuilder: (context, index) {
                    model.User user = snap.data![index];
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Profile(uid: user.uid),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundImage: MemoryImage(
                          File(user.profilePicture).readAsBytesSync(),
                        ),
                      ),
                      title: Text(user.username),
                    );
                  },
                );
              },
            )
          : FutureBuilder(
              key: postsBuilderKey,
              future: getPostFromUser(),
              builder: (context, AsyncSnapshot<List<Post>> snapshot) {
                if (!snapshot.hasData) {
                  const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return GridView.custom(
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: 4,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    repeatPattern: QuiltedGridRepeatPattern.inverted,
                    pattern: [
                      const QuiltedGridTile(3, 2),
                      const QuiltedGridTile(1, 1),
                      const QuiltedGridTile(1, 1),
                      const QuiltedGridTile(2, 2),
                    ],
                  ),
                  childrenDelegate: SliverChildBuilderDelegate(
                    (context, index) => snapshot.data != null &&
                            index < snapshot.data!.length
                        ? InkWell(
                            onTap: () async {
                              Post post = snapshot.data![index];
                              model.User postUser =
                                  await Auth().getUserDetails(post.uid);
                              AggregateQuerySnapshot num =
                                  await FirebaseFirestore.instance
                                      .collection(postsCollection)
                                      .doc(post.postId)
                                      .collection(commentCollection)
                                      .count()
                                      .get();
                              String profilePicture =
                                  await TemporaryStorage.getImage(
                                postUser.uid,
                                tempProfilePicture,
                                postUser.getProfilePicture(),
                              );
                              PopulatedPost populatedPost =
                                  PopulatedPost.fromPost(
                                post,
                                profilePicture,
                                postUser.username,
                                num.count,
                              );
                              if (mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      appBar: AppBar(
                                        backgroundColor: mobileBackgroundColor,
                                      ),
                                      body: PostCard(
                                        post: populatedPost,
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Image.file(
                              File(snapshot.data![index].imageUrl),
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
    );
  }
}
