import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/models/populated_post.dart';
import 'package:instagram_clone/models/users.dart' as model;
import 'package:instagram_clone/resources/auth.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/constants.dart';
import 'package:instagram_clone/widgets/post_card.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  Stream<List<PopulatedPost>>? stream;
  int numberOfComments = 0;

  Future<List<PopulatedPost>> populateUserData(
      QuerySnapshot<Map<String, dynamic>> post) async {
    Map<String, model.User> uidToData = {};
    List<PopulatedPost> populatedPost = [];
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
      AggregateQuerySnapshot num = await FirebaseFirestore.instance
          .collection(postsCollection)
          .doc(data['postId'])
          .collection(commentCollection)
          .count()
          .get();

      populatedPost.add(
        PopulatedPost(
          uid: uid,
          description: data['description'],
          imageUrl: data['imageUrl'],
          datePublished: data['datePublished'].toDate(),
          likes: data['likes'],
          likeCount: data['likeCount'],
          postId: data['postId'],
          profilePicture: userData.getProfilePicture(),
          username: userData.username,
          numOfComments: num.count,
        ),
      );
    }
    return populatedPost;
  }

  @override
  void initState() {
    stream = FirebaseFirestore.instance
        .collection(postsCollection)
        .orderBy('datePublished', descending: true)
        .snapshots()
        .asyncMap((posts) => populateUserData(posts));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        centerTitle: false,
        title: SvgPicture.asset(
          'assets/ic_instagram.svg',
          height: 32,
          colorFilter: const ColorFilter.mode(primaryColor, BlendMode.srcIn),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.send_outlined))
        ],
      ),
      body: StreamBuilder<List<PopulatedPost>>(
        stream: stream,
        builder: (context, AsyncSnapshot<List<PopulatedPost>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data != null ? snapshot.data!.length : 0,
            itemBuilder: (context, index) => PostCard(
              post: snapshot.data![index],
            ),
          );
        },
      ),
    );
  }
}
