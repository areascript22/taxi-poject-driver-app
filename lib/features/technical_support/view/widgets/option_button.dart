import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';

class OptionButton extends StatelessWidget {
  final void Function()? onTap;
  final String title;
  final String? subtitle;

  const OptionButton({
    super.key,
    required this.onTap,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: const TextStyle(fontSize: 17),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(
        Ionicons.chevron_forward,
        size: 28,
        color: Colors.grey,
      ),
    );
  }
}
