import 'package:flutter/material.dart';
import 'package:instagram_clone/screens/add_post.dart';
import 'package:instagram_clone/screens/feed.dart';

const webScreenSize = 600;
const homeScreenItems = [
  Feed(),
  Text('search'),
  AddPost(),
  Text('notifications'),
  Text('profile'),
];
const userCollection = 'users';
const postsCollection = 'posts';
const commentCollection = 'comments';
const postStoragePath = 'post';
const profilePicturesPath = 'profilePictures';
