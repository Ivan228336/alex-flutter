import 'package:flutter/cupertino.dart';
import 'package:ptennis_2/design/colors.dart';
import 'package:ptennis_2/pages/home_item.dart';

class HomeList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[_list(), _updateButton()]);
  }

  Widget _list() {
    return ListView.separated(
      itemCount: 15,
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 8);
      },
      itemBuilder: (BuildContext context, int index) {
        return const HomeItem();
      },
    );
  }

  Widget _updateButton() {
    return Container();
  }
}
