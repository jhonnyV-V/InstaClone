import 'package:flutter/material.dart';
import 'package:instagram_clone/models/users.dart';
import 'package:instagram_clone/resources/auth.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  User get getUser =>
      _user ??
      const User(
          username: '',
          uid: '',
          profilePicture: '',
          bio: '',
          email: '',
          followers: [],
          following: []);
  final Auth _auth = Auth();

  Future<void> refreshUser() async {
    User user = await _auth.getUserDetails();
    _user = user;
    notifyListeners();
  }
}
