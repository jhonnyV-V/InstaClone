import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/models/users.dart' as model;
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore.dart';
import 'package:instagram_clone/resources/temporary_storage.dart';
import 'package:instagram_clone/screens/profile.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/constants.dart';
import 'package:instagram_clone/widgets/follow_button.dart';
import 'package:provider/provider.dart';

class UserList extends StatefulWidget {
  final List<dynamic> uids;
  final String title;
  const UserList({
    super.key,
    required this.uids,
    required this.title,
  });

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  Future<List<model.User>> getUsers() async {
    QuerySnapshot<Map<String, dynamic>> result =
        await FirebaseFirestore.instance
            .collection(userCollection)
            .where(
              'uid',
              whereIn: widget.uids,
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
        ),
      );
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final model.User currentUser = Provider.of<UserProvider>(context).getUser;

    Widget getFollowButton(model.User user) {
      if (user.uid == currentUser.uid) {
        return const SizedBox.shrink();
      }

      if (currentUser.following.contains(user.uid)) {
        return FollowButton(
          label: 'Unfollow',
          labelColor: primaryColor,
          borderColor: Colors.grey,
          backgroundColor: mobileBackgroundColor,
          callback: () async {
            await FirestoreMethods().unFollowUser(user.uid);
            if (context.mounted) {
              Provider.of<UserProvider>(
                context,
                listen: false,
              ).refreshUser();
            }
          },
        );
      }
      return FollowButton(
        label: 'Follow',
        labelColor: Colors.white,
        borderColor: Colors.blueAccent,
        backgroundColor: Colors.blueAccent,
        callback: () async {
          await FirestoreMethods().followUser(user.uid);
          if (context.mounted) {
            Provider.of<UserProvider>(
              context,
              listen: false,
            ).refreshUser();
          }
        },
      );
    }

    void redirectToProfile(String uid) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Profile(uid: uid),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: false,
        backgroundColor: mobileBackgroundColor,
      ),
      body: FutureBuilder(
        future: getUsers(),
        builder: (
          context,
          AsyncSnapshot<List<model.User>> snap,
        ) {
          if (!snap.hasData) {
            const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snap.data != null ? snap.data!.length : 0,
            itemBuilder: (context, index) {
              model.User user = snap.data![index];

              return Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  bottom: 20,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    InkWell(
                      onTap: () {
                        redirectToProfile(user.uid);
                      },
                      child: CircleAvatar(
                        backgroundImage: MemoryImage(
                          File(user.profilePicture).readAsBytesSync(),
                        ),
                        radius: 32,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        redirectToProfile(user.uid);
                      },
                      child: Text(
                        user.username,
                        style: const TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 140,
                      child: getFollowButton(
                        user,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
