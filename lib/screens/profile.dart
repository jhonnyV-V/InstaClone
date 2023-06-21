import 'dart:io';

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
import 'package:instagram_clone/resources/temporary_storage.dart';
import 'package:instagram_clone/screens/login.dart';
import 'package:instagram_clone/screens/user_list.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/constants.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/follow_button.dart';
import 'package:instagram_clone/widgets/loader.dart';
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
  final Key bookmarkKey = const Key('Bookmar Builder');
  int tabIndex = 0;

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
      String profilePicture = await TemporaryStorage.getImage(
        userData.uid,
        tempProfilePicture,
        userData.getProfilePicture(),
      );

      setState(() {
        userProfile = model.User(
          username: userData.username,
          uid: userData.uid,
          profilePicture: profilePicture,
          bio: userData.bio,
          email: userData.email,
          followers: userData.followers,
          following: userData.following,
          bookmarks: userData.bookmarks,
        );
        numberOfPost = numberOfPostQuery.count;
        isOwner = lUid == widget.uid;
        isFollowing = userData.followers.contains(lUid);
        uid = lUid;
      });
    } catch (e) {
      if (mounted) {
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

  Future<List<Post>> getUserPost() async {
    QuerySnapshot<Map<String, dynamic>> result =
        await FirebaseFirestore.instance
            .collection(postsCollection)
            .where(
              'uid',
              isEqualTo: widget.uid,
            )
            .orderBy(
              'datePublished',
              descending: true,
            )
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

  Future<List<Post>> getUserBookmarks() async {
    model.User user = await Auth().getUserDetails(widget.uid);
    List<Post> list = [];
    if (user.bookmarks.isNotEmpty) {
      QuerySnapshot<Map<String, dynamic>> result =
          await FirebaseFirestore.instance
              .collection(postsCollection)
              .where(
                'postId',
                whereIn: user.bookmarks,
              )
              .orderBy(
                'datePublished',
                descending: true,
              )
              .get();
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
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWeb = width >= webScreenSize;

    ImageProvider getProfileImage() {
      if (userProfile != null) {
        return MemoryImage(
          File(
            userProfile!.profilePicture,
          ).readAsBytesSync(),
        );
      } else {
        return const NetworkImage(defaultProfilePicture);
      }
    }

    void displayUserList(List uids) {
      if (mounted) {
        if (uids.isNotEmpty) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UserList(
                uids: uids,
                title: 'Likes',
              ),
            ),
          );
        }
      }
    }

    Widget getBookMarks() {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 40 : 0,
        ),
        child: FutureBuilder(
          key: bookmarkKey,
          future: getUserBookmarks(),
          builder: (context, AsyncSnapshot<List<Post>> snapshot) {
            if (!snapshot.hasData) {
              const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data != null && snapshot.data!.isEmpty) {
              return const Text(
                'There are no post to display',
                textAlign: TextAlign.center,
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data != null ? snapshot.data!.length : 0,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 1.5,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                Post post = snapshot.data![index];
                return postImage(post);
              },
            );
          },
        ),
      );
    }

    Widget displayPost() {
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: isWeb ? 40 : 0,
        ),
        child: FutureBuilder(
          key: postKey,
          future: getUserPost(),
          builder: (context, AsyncSnapshot<List<Post>> snapshot) {
            if (!snapshot.hasData) {
              const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data != null && snapshot.data!.isEmpty) {
              return const Text(
                'There are no post to display',
                textAlign: TextAlign.center,
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              itemCount: snapshot.data != null ? snapshot.data!.length : 0,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 1.5,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                Post post = snapshot.data![index];
                return postImage(post);
              },
            );
          },
        ),
      );
    }

    Widget displayBookmarks() {
      List listToFunction = [
        displayPost,
        getBookMarks,
      ];
      List<IconData> icons = [
        Icons.grid_on,
        Icons.bookmark_border,
      ];
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: icons.asMap().entries.map(
              (e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: IconButton(
                    onPressed: () {
                      if (tabIndex != e.key) {
                        setState(() {
                          tabIndex = e.key;
                        });
                      }
                    },
                    icon: Icon(
                      e.value,
                      color: e.key == tabIndex
                          ? primaryColor
                          : Colors.grey.shade800,
                      size: 32,
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          listToFunction[tabIndex](),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(userProfile != null ? userProfile!.username : ''),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () async {
              Auth().logOut();
              if (mounted) {
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
      body: Loader(
        isLoading: isLoading,
        child: ListView(
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
                        backgroundImage: getProfileImage(),
                        backgroundColor: Colors.grey,
                        radius: isWeb ? 64 : 40,
                      ),
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  userProfile != null &&
                                          userProfile!.followers.isNotEmpty
                                      ? () => displayUserList(
                                            userProfile!.followers,
                                          )
                                      : null,
                                ),
                                buildStatColum(
                                  userProfile != null
                                      ? userProfile!.following.length
                                      : 0,
                                  'following',
                                  userProfile != null &&
                                          userProfile!.followers.isNotEmpty
                                      ? () => displayUserList(
                                            userProfile!.following,
                                          )
                                      : null,
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                isOwner
                                    ? FollowButton(
                                        label: 'Edit Profile',
                                        labelColor: primaryColor,
                                        borderColor: Colors.grey,
                                        backgroundColor: mobileBackgroundColor,
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
                                              if (mounted) {
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
                                            backgroundColor: Colors.blueAccent,
                                            callback: () async {
                                              await FirestoreMethods()
                                                  .followUser(widget.uid);
                                              setState(() {
                                                isFollowing = true;
                                                userProfile!.followers.add(uid);
                                              });
                                              if (mounted) {
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
            !isOwner
                ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWeb ? 40 : 0,
                    ),
                    child: Divider(
                      thickness: isWeb ? 4 : 1,
                    ),
                  )
                : const SizedBox.shrink(),
            isOwner ? displayBookmarks() : displayPost(),
          ],
        ),
      ),
    );
  }

  Column buildStatColum(int num, String label, [VoidCallback? callback]) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: callback,
          child: Text(
            num.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: InkWell(
            onTap: callback,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget postImage(Post post) {
    return InkWell(
      onTap: () async {
        model.User postUser = await Auth().getUserDetails(post.uid);
        AggregateQuerySnapshot num = await FirebaseFirestore.instance
            .collection(postsCollection)
            .doc(post.postId)
            .collection(commentCollection)
            .count()
            .get();
        String profilePicture = await TemporaryStorage.getImage(
          postUser.uid,
          tempProfilePicture,
          postUser.getProfilePicture(),
        );
        PopulatedPost populatedPost = PopulatedPost.fromPost(
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
        File(post.imageUrl),
        fit: BoxFit.cover,
      ),
    );
  }
}
