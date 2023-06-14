import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/users.dart' as model;
import 'package:instagram_clone/resources/auth.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/constants.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/follow_button.dart';

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
  model.User? user;
  bool isLoading = false;
  int numberOfPost = 0;
  bool isOwner = false;
  bool isFollowing = false;
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
      String uid = FirebaseAuth.instance.currentUser!.uid;

      setState(() {
        user = userData;
        numberOfPost = numberOfPostQuery.count;
        isOwner = uid == widget.uid;
        isFollowing = userData.followers.contains(uid);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(user != null ? user!.username : ''),
        centerTitle: false,
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(user != null
                                ? user!.getProfilePicture()
                                : defaultProfilePicture),
                            backgroundColor: Colors.grey,
                            radius: 40,
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
                                      user != null ? user!.followers.length : 0,
                                      'followers',
                                    ),
                                    buildStatColum(
                                      user != null ? user!.following.length : 0,
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
                                                callback: () {},
                                              )
                                            : FollowButton(
                                                label: 'Follow',
                                                labelColor: Colors.white,
                                                borderColor: Colors.blueAccent,
                                                backgroundColor:
                                                    Colors.blueAccent,
                                                callback: () {},
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
                          user != null ? user!.username : '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          user != null ? user!.bio : '',
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
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
