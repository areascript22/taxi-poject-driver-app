import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final double? radius;
  const UserAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 35,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.transparent,
      child: ClipOval(
        child: Stack(
          children: [
            // Default image (shown until network image loads)
            Image.asset(
              'assets/img/default_profile.png',
              fit: BoxFit.cover,
              width: 100,
              height: 100,
            ),
            // Network image (once loaded, it appears over the default image)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: 100,
              height: 100,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child; // Image is loaded
                }

                return const SizedBox(); // Keep showing the default image
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(); // Keep showing the default image if error occurs
              },
            ),
          ],
        ),
      ),
    );
  }
}
