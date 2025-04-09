import 'package:flutter/material.dart';

class DriverAvatarQueue extends StatelessWidget {
  final double radius;
  final String position;
  final Color color;
  const DriverAvatarQueue({
    super.key,
    required this.imageUrl,
    this.radius = 35,
    required this.position,
    required this.color,
  });

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: ClipOval(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Default image (shown until network image loads)
            Text(
              position,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Network image (once loaded, it appears over the default image)
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: (radius + radius) - 5,
              height: (radius + radius) - 5,
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
