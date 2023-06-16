import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/add_post.dart';
import 'package:instagram_clone/screens/feed.dart';
import 'package:instagram_clone/screens/profile.dart';
import 'package:instagram_clone/screens/search.dart';

const webScreenSize = 600;
List<Widget> homeScreenItems = [
  const Feed(),
  const Search(),
  const AddPost(),
  Profile(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
const userCollection = 'users';
const postsCollection = 'posts';
const commentCollection = 'comments';
const postStoragePath = 'post';
const profilePicturesPath = 'profilePictures';
const tempProfilePicture = 'profilePicture';
const tempPostImage = 'post';

const defaultProfilePicture =
    "https://www.chocolatebayou.org/wp-content/uploads/No-Image-Person-2048x2048.jpeg";
