import 'package:flutter/material.dart';
import 'package:ptennis_2/design/colors.dart';

class HomeItem extends StatelessWidget {
  const HomeItem({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Card(
        margin: EdgeInsets.zero,
        color: surfaceColor,
        elevation: 0.06,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 16),
            child: Row(children: <Widget>[_title(), _state()]),
          ),
        ),
      ),
    );
  }

  Widget _title() {
    return const Text("пупу");
  }

  Widget _state() {
    return Container();
  }
}
