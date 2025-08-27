import 'package:flutter/material.dart';

class TextWithStroke extends StatelessWidget {
  final Color color;
  final String text;
  final double strokeWidth;
  final double fontSize;

  const TextWithStroke({super.key, required this.color, required this.text, this.strokeWidth = 4, this.fontSize = 25});

  @override
  Widget build(BuildContext context) {
    return  Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
