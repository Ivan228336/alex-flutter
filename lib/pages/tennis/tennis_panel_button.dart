import 'package:flutter/material.dart';

import '../../design/colors.dart';

class TennisPanelButton extends StatelessWidget{
  final String text;
  final double heigh;
  final double fontSize;
  final VoidCallback onPressed;
  final int flex;

  const TennisPanelButton({
    super.key,
    required this.text,
    required this.heigh,
    required this.fontSize,
    required this.onPressed,
    required this.flex
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight * heigh,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroungColor,
                foregroundColor: Colors.black,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: TextStyle(fontSize: constraints.maxHeight * fontSize),
              ),
              child: Text(text),
            ),
          );
        },
      ),
    );
  }
}