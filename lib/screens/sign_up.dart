import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone/reponsive/mobile_screen.dart';
import 'package:instagram_clone/reponsive/responsive_layout_screen.dart';
import 'package:instagram_clone/reponsive/web_screen.dart';
import 'package:instagram_clone/resources/auth.dart';
import 'package:instagram_clone/screens/login.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/constants.dart';
import 'package:instagram_clone/utils/utils.dart';
import 'package:instagram_clone/widgets/text_field_input.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final bioController = TextEditingController();
  final userNameController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();
  XFile? _img;
  bool _loading = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    bioController.dispose();
    userNameController.dispose();
  }

  void selectImage() async {
    XFile? image = await imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (image != null) {
      setState(() {
        _img = image;
      });
    }
  }

  void signUpHandler() async {
    setState(() {
      _loading = true;
    });
    String res = await Auth().signUpUser(
      email: emailController.text,
      password: passwordController.text,
      username: userNameController.text,
      bio: bioController.text,
      file: _img,
    );
    if (res != "success") {
      if (mounted) {
        showSnackBar(res, context);
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const ResponsiveLayout(
              mobileScreen: MobileScreen(),
              webScreen: WebScreen(),
            ),
          ),
        );
      }
    }
    setState(() {
      _loading = false;
    });
  }

  void login() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: MediaQuery.of(context).size.width >= webScreenSize
              ? EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 3,
                )
              : const EdgeInsets.symmetric(horizontal: 32),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height / 10,
              ),
              SvgPicture.asset(
                "assets/ic_instagram.svg",
                semanticsLabel: "Instagram logo",
                colorFilter: const ColorFilter.mode(
                  primaryColor,
                  BlendMode.srcIn,
                ),
                height: 64,
              ),
              const SizedBox(height: 64),
              Stack(
                children: [
                  _img != null
                      ? CircleAvatar(
                          radius: 64,
                          backgroundImage: FileImage(File(_img!.path)),
                        )
                      : const CircleAvatar(
                          radius: 64,
                          backgroundImage: NetworkImage(defaultProfilePicture),
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                        color: Colors.white70,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              TextFieldInput(
                hint: "Enter your username",
                controller: userNameController,
                type: TextInputType.text,
              ),
              const SizedBox(height: 24),
              TextFieldInput(
                hint: "Enter your bio",
                controller: bioController,
                type: TextInputType.multiline,
              ),
              const SizedBox(height: 24),
              TextFieldInput(
                hint: "Enter your email",
                controller: emailController,
                type: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              TextFieldInput(
                hint: "Enter your password",
                controller: passwordController,
                type: TextInputType.text,
                isPassword: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: signUpHandler,
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  fixedSize: MaterialStateProperty.all<Size>(
                    Size(MediaQuery.of(context).size.width, 14),
                  ),
                ),
                child: _loading
                    ? const CircularProgressIndicator(
                        color: primaryColor,
                      )
                    : const Text("Sign up"),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: MediaQuery.of(context).size.height / 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Text(
                      "Do you have an account?",
                      style: TextStyle(
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: login,
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
