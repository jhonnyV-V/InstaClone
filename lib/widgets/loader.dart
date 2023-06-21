import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/colors.dart';

class Loader extends StatelessWidget {
  final bool isLoading;
  final Widget? child;
  const Loader({
    super.key,
    required this.isLoading,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryColor),
      );
    }
    if (child != null) {
      return child!;
    }
    return const SizedBox.shrink();
  }
}
