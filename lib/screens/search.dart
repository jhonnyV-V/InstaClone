import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_clone/models/populated_post.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/users.dart' as model;
import 'package:instagram_clone/resources/auth.dart';
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
              future: FirebaseFirestore.instance
                  .collection(userCollection)
                  .where(
                    'username',
                    isGreaterThanOrEqualTo: searchController.text,
                  )
                  .get(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap) {
                if (!snap.hasData) {
                  const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return ListView.builder(
                  itemCount: snap.data != null ? snap.data!.docs.length : 0,
                  itemBuilder: (context, index) {
                    model.User user =
                        model.User.fromSnap(snap.data!.docs[index]);
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => Profile(uid: user.uid),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          user.getProfilePicture(),
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
              future: FirebaseFirestore.instance
                  .collection(postsCollection)
                  .orderBy('datePublished')
                  .limit(20)
                  .get(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
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
                            index < snapshot.data!.docs.length
                        ? InkWell(
                            onTap: () async {
                              Post post =
                                  Post.fromSnap(snapshot.data!.docs[index]);
                              model.User postUser =
                                  await Auth().getUserDetails(post.uid);
                              AggregateQuerySnapshot num =
                                  await FirebaseFirestore.instance
                                      .collection(postsCollection)
                                      .doc(post.postId)
                                      .collection(commentCollection)
                                      .count()
                                      .get();
                              PopulatedPost populatedPost =
                                  PopulatedPost.fromPost(
                                post,
                                postUser.profilePicture,
                                postUser.username,
                                num.count,
                              );
                              if (context.mounted) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      body: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          PostCard(
                                            post: populatedPost,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Image.network(
                              snapshot.data!.docs[index]['imageUrl'],
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
