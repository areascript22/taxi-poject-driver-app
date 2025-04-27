import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class ColorizedText extends StatelessWidget {
  const ColorizedText({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: AnimatedTextKit(
        animatedTexts: [
          ColorizeAnimatedText(
            'Buscando dirección',
            textStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.surface),
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.inversePrimary,
            ],
          ),
        ],
        isRepeatingAnimation: true,
      ),
    );
  }
}
