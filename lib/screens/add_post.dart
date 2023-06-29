import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/models/users.dart' as model;
import 'package:instagram_clone/providers/user_provider.dart';
import 'package:instagram_clone/resources/firestore.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/post_preview.dart';
import 'package:provider/provider.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  List<XFile> _image = [];
  bool _isLoading = false;
  final TextEditingController description = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();
  _selectImage(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Create Post'),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Take photo'),
              onPressed: () async {
                Navigator.of(context).pop();
                XFile? file = await imagePicker.pickImage(
                  source: ImageSource.camera,
                );
                if (file != null) {
                  setState(() {
                    _image = [file];
                  });
                }
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Choose from gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                List<XFile> file = await imagePicker.pickMultiImage();
                if (file.isNotEmpty) {
                  setState(() {
                    _image = file;
                  });
                }
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.all(20),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _createPost() async {
    if (mounted && !_isLoading) {
      setState(() {
        _isLoading = true;
      });
      try {
        String res = await FirestoreMethods().uploadPost(
          _image,
          description.text,
        );
        if (res == 'success') {
          setState(() {
            _isLoading = false;
          });
          clearImage();
          if (mounted) {
            showSnackBar('Posted', context);
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            showSnackBar(res, context);
          }
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        showSnackBar(e.toString(), context);
      }
    }
  }

  void clearImage() {
    setState(() {
      _image = [];
    });
  }

  @override
  void dispose() {
    super.dispose();
    description.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model.User user = Provider.of<UserProvider>(context).getUser;
    if (_image.isEmpty) {
      return Center(
        child: IconButton(
          icon: const Icon(Icons.upload),
          onPressed: () => _selectImage(context),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: clearImage,
        ),
        title: const Text('Create a post'),
        actions: [
          TextButton(
            onPressed: _createPost,
            child: const Text(
              'Post',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _isLoading
                ? const LinearProgressIndicator()
                : const SizedBox.shrink(),
            const Divider(),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PostPreview(
                  username: user.username,
                  profileImage: user.getProfilePicture(),
                  images: _image,
                  descriptionController: description,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
