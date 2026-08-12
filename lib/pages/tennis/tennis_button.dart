import 'package:flutter/material.dart';
import 'package:ptennis_2/design/colors.dart';

class TennisButton extends StatelessWidget {
  final String name;
  final VoidCallback? onPressed;

  static void _defaultCallback() {}

  const TennisButton({
    super.key,
    required this.name,
    this.onPressed = _defaultCallback,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = (screenWidth * 0.04).clamp(12.0, 70.0);
    return ElevatedButton(
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
          child: Text(name),
    );
  }
}
