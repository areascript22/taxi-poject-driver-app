import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class PasswordTextfield extends StatefulWidget {
  final String hintText;
  final bool isObscureText;
  final TextEditingController textEditingController;
  final String? Function(String?)? validator;
  const PasswordTextfield({
    super.key,
    required this.hintText,
    this.isObscureText = false,
    required this.textEditingController,
    required this.validator,
  });

  @override
  State<PasswordTextfield> createState() => _PasswordTextfieldState();
}

class _PasswordTextfieldState extends State<PasswordTextfield> {
  bool _isObscured = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: _isObscured,
      controller: widget.textEditingController,
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: IconButton(
          icon: Icon(
            _isObscured ? Ionicons.eye_off_outline : Ionicons.eye_outline,
          ),
          onPressed: () {
            setState(() {
              _isObscured = !_isObscured;
            });
          },
        ),
      ),
      validator: widget.validator,
    );
  }
}
