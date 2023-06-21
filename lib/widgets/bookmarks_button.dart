import 'package:flutter/material.dart';

class BookmarkButton extends StatefulWidget {
  const BookmarkButton({
    super.key,
    required this.initalState,
    required this.callback,
  });

  final bool initalState;
  final Function callback;

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  bool isBookmarked = false;
  @override
  void initState() {
    setState(() {
      isBookmarked = widget.initalState;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.bottomRight,
        child: IconButton(
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          ),
          onPressed: () async {
            await widget.callback();
            setState(() {
              isBookmarked = !isBookmarked;
            });
          },
        ),
      ),
    );
  }
}
