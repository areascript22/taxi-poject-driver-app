import 'package:flutter/material.dart';

class CustomElevatedButton extends StatefulWidget {
  final void Function()? onTap;
  final Widget child;
  final Color? color;
  const CustomElevatedButton({
    super.key,
    required this.onTap,
    required this.child,
  this.color,
  });

  @override
  State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onTap,
      style: widget.color!=null? ElevatedButton.styleFrom(
        backgroundColor: widget.color,
      ):null,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.child,
        ],
      ),
    );
  }
}
