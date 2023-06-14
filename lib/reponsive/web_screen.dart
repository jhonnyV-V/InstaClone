import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_clone/utils/colors.dart';
import 'package:instagram_clone/utils/constants.dart';

class WebScreen extends StatefulWidget {
  const WebScreen({super.key});

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  int _page = 0;
  late PageController pageController = PageController();

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void changePage(int newPage) {
    setState(() {
      _page = newPage;
    });
    pageController.jumpToPage(newPage);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
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
          AppBarIconsItem(iconData: Icons.home),
          AppBarIconsItem(iconData: Icons.search),
          AppBarIconsItem(iconData: Icons.add_a_photo),
          AppBarIconsItem(iconData: Icons.person),
        ]
            .asMap()
            .entries
            .map(
              (e) => IconButton(
                onPressed: () {
                  changePage(e.key);
                },
                icon: Icon(e.value.iconData),
                color: _page == e.key ? primaryColor : secondaryColor,
              ),
            )
            .toList(),
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: const NeverScrollableScrollPhysics(),
        children: homeScreenItems,
      ),
    );
  }
}

class AppBarIconsItem {
  final IconData iconData;
  AppBarIconsItem({
    required this.iconData,
  });
}
