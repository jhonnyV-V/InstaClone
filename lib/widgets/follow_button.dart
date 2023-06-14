import 'package:flutter/material.dart';

class FollowButton extends StatefulWidget {
  final VoidCallback? callback;
  final Color backgroundColor;
  final Color borderColor;
  final Color labelColor;
  final String label;
  const FollowButton({
    super.key,
    this.callback,
    required this.backgroundColor,
    required this.borderColor,
    required this.labelColor,
    required this.label,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 2),
      child: TextButton(
        onPressed: widget.callback,
        child: Container(
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            border: Border.all(
              color: widget.borderColor,
            ),
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          width: 250,
          height: 27,
          child: Text(
            widget.label,
            style: TextStyle(
              color: widget.labelColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
