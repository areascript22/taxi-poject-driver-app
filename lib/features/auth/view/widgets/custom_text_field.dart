import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool isObscureText;
  final TextEditingController textEditingController;
  final String? Function(String?)? validator;
  final bool enabled;
  const CustomTextField({
    super.key,
    required this.hintText,
    this.isObscureText = false,
    required this.textEditingController,
    required this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isObscureText,
      controller: textEditingController,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: hintText,
        hintText: hintText,
      ),
      validator: validator,
    );
  }
}
