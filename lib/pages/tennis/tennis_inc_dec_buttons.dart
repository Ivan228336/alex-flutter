import 'package:flutter/material.dart';
import '../../design/colors.dart';

class TennisIncDecButtons extends StatelessWidget {
  final bool isInc;
  final VoidCallback? onPressed;
  final double? width;
  const TennisIncDecButtons({super.key, required this.isInc, this.onPressed, this.width});

  String getIcon() {
    if (isInc) {
      return "+";
    }
    return "-";
  }

  @override
  Widget build(BuildContext context) {
    String icon = getIcon();
    double screenWidth = MediaQuery.of(context).size.width;
    final fontSize = (screenWidth * 0.04).clamp(8.0, 16.0);

    if (width != null) {
      screenWidth *= width!;
    } else {
      screenWidth *= 0.03;
    }

    return SizedBox(
      width: screenWidth,
      height: screenWidth,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: backgroungColor,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: TextStyle(fontSize: fontSize, color: backgroungColor),
        ),
        child: Text(icon),
      ),
    );
  }
}
