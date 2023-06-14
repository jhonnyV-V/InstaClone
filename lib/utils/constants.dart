import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/add_post.dart';
import 'package:instagram_clone/screens/feed.dart';
import 'package:instagram_clone/screens/search.dart';

const webScreenSize = 600;
const homeScreenItems = [
  Feed(),
  Search(),
  AddPost(),
  Text('notifications'),
  Text('profile'),
];
const userCollection = 'users';
const postsCollection = 'posts';
const commentCollection = 'comments';
const postStoragePath = 'post';
const profilePicturesPath = 'profilePictures';

const defaulProfilePicture =
    "https://www.chocolatebayou.org/wp-content/uploads/No-Image-Person-2048x2048.jpeg";
