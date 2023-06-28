import 'package:flutter/material.dart';

class ImageIconIndicator extends StatelessWidget {
  final Image image;
  final IconData iconData;
  final bool displayIcon;
  const ImageIconIndicator({
    super.key,
    required this.image,
    required this.iconData,
    this.displayIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> childs = [
      image,
    ];

    if (displayIcon) {
      childs.add(
        Positioned(
          top: 5,
          right: 5,
          child: Icon(
            iconData,
          ),
        ),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: childs,
    );
  }
}
