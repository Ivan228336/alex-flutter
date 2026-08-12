import 'package:flutter/material.dart';
import 'package:ptennis_2/design/colors.dart';
import 'package:ptennis_2/pages/tennis/tennis_button.dart';

class Tennis_Page extends StatelessWidget {
  const Tennis_Page({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Expanded(flex: 1, child: _playersInfo()),
        Expanded(flex: 6, child: _developPanel())
      ],
    );
  }

  Widget _playersInfo() {
    return Row(
      children: <Widget>[
      Expanded(child: _firstPlayer()),
      Expanded(child: _clearButtons()),
      Expanded(child: _secondPlayer())
    ],);
  }

  Widget _developPanel() {
    return Row(children: <Widget>[
      Expanded(flex: 1,child: _leftPanel()),
      Expanded(flex: 3,child: _centerPanel()),
      Expanded(flex: 1,child: _rightPanel())
    ],);
  }

  Widget _firstPlayer() {
    return Container(
      color: Colors.indigo,
    );
  }

  Widget _clearButtons() {
    return Container(
      color: Colors.teal,
    );
  }

  Widget _secondPlayer() {
    return Container(
      color: Colors.red,
    );
  }

  Widget _leftPanel() {
    return Row(
      children: <Widget>[
        Expanded(flex: 1, child: _leftServe()),
        Expanded(flex: 3, child: _leftButtons())
      ],
    );
  }

  Widget _centerPanel() {
    return Container(
      color: Colors.blue,
    );
  }

  Widget _rightPanel() {
    return Row(
      children: <Widget>[
        Expanded(flex: 3, child: _rightButtons()),
        Expanded(flex: 1, child: _rightServe())
      ],
    );
  }

  Widget _leftServe() {
    return Container(
      color: Colors.blueGrey,
    );
  }

  Widget _leftButtons() {

    final buttons = [
      _leftSet(),
      _leftGame(),
      _leftLess(),
      _leftMore(),
      _left40(),
      _left30(),
      _left15(),
      _left0()
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buttons.map((widget) {
        return Expanded(child:
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
          child: widget,
          ),
        );
      }).toList(),
    );
  }

  Widget _rightServe() {
    return Container(
      color: Colors.lightBlue,
    );
  }

  Widget _rightButtons() {

    final buttons = [
      _rightSet(),
      _rightGame(),
      _rightLess(),
      _rightMore(),
      _right40(),
      _right30(),
      _right15(),
      _right0()
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buttons.map((widget) {
        return Expanded(child:
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
          child: widget,
        ),
        );
      }).toList(),
    );
  }

  Widget _leftSet() {
    return TennisButton(name: "сет");
  }

  Widget _leftGame() {
    return TennisButton(name: "гейм");
  }

  Widget _leftLess() {
    return TennisButton(name: "мн");
  }

  Widget _leftMore() {
    return TennisButton(name: "бл");
  }

  Widget _left40() {
    return TennisButton(name: "40");
  }

  Widget _left30() {
    return TennisButton(name: "30");
  }

  Widget _left15() {
    return TennisButton(name: "15");
  }

  Widget _left0() {
    return TennisButton(name: "0");
  }

  Widget _rightSet() {
    return TennisButton(name: "сет");
  }

  Widget _rightGame() {
    return TennisButton(name: "гейм");
  }

  Widget _rightLess() {
    return TennisButton(name: "мн");
  }

  Widget _rightMore() {
    return TennisButton(name: "бл");
  }

  Widget _right40() {
    return TennisButton(name: "40");
  }

  Widget _right30() {
    return TennisButton(name: "30");
  }

  Widget _right15() {
    return TennisButton(name: "15");
  }

  Widget _right0() {
    return TennisButton(name: "0");
  }


}