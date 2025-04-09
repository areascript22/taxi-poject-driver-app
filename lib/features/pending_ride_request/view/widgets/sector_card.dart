import 'package:flutter/material.dart';

class SectorCard extends StatelessWidget {
  final String? sector;
  const SectorCard({
    super.key,
    required this.sector,
  });

  @override
  Widget build(BuildContext context) {
    return sector != null
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber[200], // Light blue background
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
            child: Text(
              sector!, // Example request type
              style: TextStyle(
                fontSize: 14,
                color: Colors.amber[800], // Dark blue text
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        : const SizedBox();
  }
}
