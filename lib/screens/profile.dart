import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/populated_post.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/models/users.dart' as model;
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/auth.dart';
import 'package:instagram_clone/resources/firestore.dart';
import 'package:instagram_clone/screens/login.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/constants.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/follow_button.dart';
import 'package:instagram_clone/widgets/post_card.dart';
import 'package:provider/provider.dart';

class Profile extends StatefulWidget {
  final String uid;
  const Profile({
    super.key,
    required this.uid,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  model.User? userProfile;
  bool isLoading = false;
  int numberOfPost = 0;
  bool isOwner = false;
  bool isFollowing = false;
  String uid = '';
  final Key postKey = const Key('Post Builder');

  @override
  void initState() {
    getData();
    super.initState();
  }

  void getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      model.User userData = await Auth().getUserDetails(widget.uid);
      AggregateQuerySnapshot numberOfPostQuery = await FirebaseFirestore
          .instance
          .collection(postsCollection)
          .where('uid', isEqualTo: userData.uid)
          .count()
          .get();
      String lUid = FirebaseAuth.instance.currentUser!.uid;

      setState(() {
        userProfile = userData;
        numberOfPost = numberOfPostQuery.count;
        isOwner = lUid == widget.uid;
        isFollowing = userData.followers.contains(lUid);
        uid = lUid;
      });
    } catch (e) {
      if (context.mounted) {
        if (kDebugMode) {
          print(e.toString());
        }
        showSnackBar(e.toString(), context);
      }
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = width >= webScreenSize;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(userProfile != null ? userProfile!.username : ''),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () async {
              Auth().logOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const Login(),
                  ),
                );
              }
            },
            child: const Text(
              'Log out',
              style: TextStyle(
                color: primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : ListView(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: isWeb ? width * 0.2 : 16,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                              userProfile != null
                                  ? userProfile!.getProfilePicture()
                                  : defaultProfilePicture,
                            ),
                            backgroundColor: Colors.grey,
                            radius: isWeb ? 64 : 40,
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    buildStatColum(
                                      numberOfPost,
                                      'posts',
                                    ),
                                    buildStatColum(
                                      userProfile != null
                                          ? userProfile!.followers.length
                                          : 0,
                                      'followers',
                                    ),
                                    buildStatColum(
                                      userProfile != null
                                          ? userProfile!.following.length
                                          : 0,
                                      'following',
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    isOwner
                                        ? FollowButton(
                                            label: 'Edit Profile',
                                            labelColor: primaryColor,
                                            borderColor: Colors.grey,
                                            backgroundColor:
                                                mobileBackgroundColor,
                                            callback: () {},
                                          )
                                        : isFollowing
                                            ? FollowButton(
                                                label: 'Unfollow',
                                                labelColor: primaryColor,
                                                borderColor: Colors.grey,
                                                backgroundColor:
                                                    mobileBackgroundColor,
                                                callback: () async {
                                                  await FirestoreMethods()
                                                      .unFollowUser(widget.uid);
                                                  setState(() {
                                                    isFollowing = false;
                                                    userProfile!.followers
                                                        .remove(uid);
                                                  });
                                                  if (context.mounted) {
                                                    Provider.of<UserProvider>(
                                                      context,
                                                      listen: false,
                                                    ).refreshUser();
                                                  }
                                                },
                                              )
                                            : FollowButton(
                                                label: 'Follow',
                                                labelColor: Colors.white,
                                                borderColor: Colors.blueAccent,
                                                backgroundColor:
                                                    Colors.blueAccent,
                                                callback: () async {
                                                  await FirestoreMethods()
                                                      .followUser(widget.uid);
                                                  setState(() {
                                                    isFollowing = true;
                                                    userProfile!.followers
                                                        .add(uid);
                                                  });
                                                  if (context.mounted) {
                                                    Provider.of<UserProvider>(
                                                      context,
                                                      listen: false,
                                                    ).refreshUser();
                                                  }
                                                },
                                              ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          userProfile != null ? userProfile!.username : '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          userProfile != null ? userProfile!.bio : '',
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 40 : 0,
                  ),
                  child: Divider(
                    thickness: isWeb ? 4 : 1,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWeb ? 40 : 0,
                  ),
                  child: FutureBuilder(
                    key: postKey,
                    future: FirebaseFirestore.instance
                        .collection(postsCollection)
                        .where(
                          'uid',
                          isEqualTo: widget.uid,
                        )
                        .orderBy(
                          'datePublished',
                          descending: true,
                        )
                        .get(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (!snapshot.hasData) {
                        const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data != null
                            ? snapshot.data!.docs.length
                            : 0,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 1.5,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (context, index) {
                          Post post = Post.fromSnap(snapshot.data!.docs[index]);
                          return InkWell(
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
                            child: Image(
                              image: NetworkImage(post.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Column buildStatColum(int num, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          num.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
