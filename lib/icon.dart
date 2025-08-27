import 'package:flutter/material.dart';
import 'package:justlevelup/text.dart';

class IconWithText extends StatelessWidget {
  final String iconName, text;
  const IconWithText(this.iconName, {super.key, this.text = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      color: Colors.transparent,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/icons/$iconName.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              width: 46,
              height: 46,
            ),
            SizedBox(width: 70),
            Positioned(
              bottom: 0,
              left: 32,
              child: TextWithStroke(color: Colors.white, text: text, fontSize: 14)
            ),
          ],
        ),
      ),
    );
  }
}
