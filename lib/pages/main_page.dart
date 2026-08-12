import 'package:flutter/material.dart';
import 'package:ptennis_2/design/colors.dart';
import 'package:ptennis_2/design/demensions.dart';

import 'home_list.dart';

class main_page extends StatelessWidget {
  const main_page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Теннис',
          style: TextStyle(
            color: primaryColor,
            fontSize: fontSize16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: surfaceColor,
      ),
      body: Container(color: backgroungColor, child: HomeList()),
    );
  }
}
