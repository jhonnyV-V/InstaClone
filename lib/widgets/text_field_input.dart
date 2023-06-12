import 'package:flutter/material.dart';

class TextFieldInput extends StatefulWidget {
  const TextFieldInput({
    super.key,
    required this.hint,
    required this.controller,
    required this.type,
    this.isPassword = false,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType type;
  final bool isPassword;

  @override
  State<TextFieldInput> createState() => _TextFieldInputState();
}

class _TextFieldInputState extends State<TextFieldInput> {
  bool _isObscure = false;
  @override
  void initState() {
    _isObscure = widget.isPassword;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );
    changeVisibility() {
      setState(() {
        _isObscure = !_isObscure;
      });
    }

    return TextField(
      controller: widget.controller,
      decoration: InputDecoration(
          hintText: widget.hint,
          border: border,
          focusedBorder: border,
          enabledBorder: border,
          filled: true,
          contentPadding: const EdgeInsets.all(8),
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: changeVisibility,
                  icon: Icon(
                      _isObscure ? Icons.visibility : Icons.visibility_off))
              : const SizedBox.shrink()),
      keyboardType: widget.type,
      obscureText: _isObscure,
    );
  }
}
