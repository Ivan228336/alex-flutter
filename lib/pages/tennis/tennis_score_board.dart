import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ptennis_2/design/colors.dart';
import 'package:ptennis_2/design/demensions.dart';
import 'package:ptennis_2/pages/tennis/apiService.dart';
import 'package:ptennis_2/pages/tennis/ipDialog.dart';
import 'package:ptennis_2/pages/tennis/tennis_button.dart';
import 'package:ptennis_2/pages/tennis/tennis_inc_dec_buttons.dart';
import 'package:ptennis_2/pages/tennis/tennis_panel_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Player {
  String name;
  String score;
  int set;
  List<int>? games;

  Player({
    this.name = "",
    this.score = "0",
    this.set = 0,
    List<int>? games,
  }) : games = games ?? [0, 0, 0, 0, 0];

  String get getName => name;
  String get getScore => score;
  int get getSet => set;
  List<int>? get getGames => games;

  set setName(String name) {
    this.name = name;
  }

  set setScore(String score) {
    this.score = score;
  }

  set setSet(int set) {
    this.set = set;
  }

  set setGames(List<int> games) {
    this.games = games;
  }

  void setDec() {
    set -= 1;
  }

  void setInc() {
    set += 1;
  }

  void gameDec(int gameIndex) {
    games?[gameIndex] -= 1;
  }

  void gameInc(int gameIndex) {
    games?[gameIndex] += 1;
  }
}

class TennisScoreBoard extends StatefulWidget {
  const TennisScoreBoard({super.key});

  @override
  State<StatefulWidget> createState() => _TennisScoreBoardState();
}

class _TennisScoreBoardState extends State<TennisScoreBoard> {
  late TextEditingController firstPlayerTextController;
  late TextEditingController secondPlayerTextController;
  late FocusNode firstPlayerFocusNode;
  late FocusNode secondPlayerFocusNode;

  Player leftPlayer = Player();
  Player rightPlayer = Player();

  String serverIp = "127.0.0.1";

  late ApiService apiService;

  int currentServer = 0;

  static List<Color> defaultColors = [
    gameActiveColor,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  List<String> history = [];
  static const int maxHistory = 30;

  void _addHistoryEntry(String action, {bool clear = false}){
    if (clear) {
      history.clear();
    } else {
      final timestamp = DateTime.now().toLocal().toString().split('.')[0].split(' ')[1];
      final entry = '$timestamp $action';
      history.insert(0, entry);
      if (history.length > maxHistory) {
        history.removeLast();
      }
    }
    setState(() {});
  }

  String historyString = "";

  List<Color>? colors = List.from(defaultColors);

  int courtId = 0;

  Color configButtonColor = Colors.grey;

  bool isVisible = false;

  String visibleButtonText = visibleText;

  Future<void> sendScoreAndNotify([int? server]) async {

    server = server ?? currentServer;
    final result = await apiService.postScore(leftPlayer, rightPlayer, isVisible, server);

    if (result != "Успех") {
      setState(() {
        configButtonColor = Colors.redAccent;
      });
    } else {
      setState(() {
        configButtonColor = Colors.green;
      });
    }
    if (!mounted) return;

    // final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;
    // final leftMargin = screenWidth * 0.2; // 20% слева

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(result ?? 'Ошибка отправки'),
    //     behavior: SnackBarBehavior.floating, // плавающая плашка
    //     margin: EdgeInsets.only(bottom: screenHeight * 0.02, right: screenWidth * 0.35, left: screenWidth * 0.35, top: 0.82), // смещени
    //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),// е
    //     duration: Duration(seconds: result == "Успех" ? 1 : 3),
    //     backgroundColor: result == "Успех" ? Colors.green : Colors.red,
    //   ),
    // );
  }

  final asyncPrefs = SharedPreferencesAsync();

  @override
  void initState() {
    super.initState();
    firstPlayerTextController = TextEditingController(text: leftPlayer.name);
    secondPlayerTextController = TextEditingController(text: rightPlayer.name);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    firstPlayerFocusNode = FocusNode();
    secondPlayerFocusNode = FocusNode();
    apiService  = ApiService(serverIp: serverIp, courtId: 0);

    _loadIp();
    firstPlayerFocusNode.addListener(() {
      if (!firstPlayerFocusNode.hasFocus) {
        leftPlayer.name = firstPlayerTextController.text;
        sendScoreAndNotify();
      }
    });

    secondPlayerFocusNode.addListener(() {
      if (!secondPlayerFocusNode.hasFocus) {
        rightPlayer.name = secondPlayerTextController.text;
        sendScoreAndNotify();
      }
    });
  }

  Future<void> _loadIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      serverIp = prefs.getString('ip') ?? "168.0.0.100";
    });
  }

  Future<void> _saveIp(String newIp) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('ip', newIp);
  }

  @override
  void dispose() {
    firstPlayerTextController.dispose();
    secondPlayerTextController.dispose();
    firstPlayerFocusNode.dispose();
    secondPlayerFocusNode.dispose();
    super.dispose();
  }

  Color leftServeColor = Colors.grey;

  Color rightServeColor = Colors.grey;


  void _updateVisible() {
    setState(() {
      if (visibleButtonText == visibleText) {
        isVisible = true;
        visibleButtonText = unVisibleText;
      } else {
        isVisible = false;
        visibleButtonText = visibleText;
      }
    });
    sendScoreAndNotify();
  }

  void _clearAll() {
    setState(() {
      leftPlayer = Player();
      rightPlayer = Player();
      leftServeColor = Colors.grey;
      rightServeColor = Colors.grey;
      firstPlayerTextController.text = "";
      secondPlayerTextController.text = "";
      colors = List.from(defaultColors);
      currentServer = 0;

      sendScoreAndNotify();
    });
    _addHistoryEntry("Сброс истории", clear: true);
  }


  int flag = 52;
  int counter = 0;

  void _updateServeColor(int number) {
    if (flag == number && counter == 0) {
      setState(() {
        currentServer = 0;
        leftServeColor = Colors.grey;
        rightServeColor = Colors.grey;
      });
      sendScoreAndNotify(0);
      counter += 1;
    } else {
      counter = 0;
      sendScoreAndNotify(number);
      if (number == 1) {
        setState(() {
          currentServer = 1;
          leftServeColor = greenServe;
          rightServeColor = redServe;
        });
      } else if (number == 2) {
        setState(() {
          currentServer = 2;
          leftServeColor = redServe;
          rightServeColor = greenServe;
        });
      }
      flag = number;
    }


  }

  bool _isStreaming = false;   // текущее состояние стрима
  bool _isLoadingStream = false;

  Future<void> _toggleStream() async {
    // Показываем индикатор загрузки (можно заблокировать кнопку)
    // Для простоты используем setState для флага загрузки
    // но можно обойтись без отдельного флага, просто выключив кнопку
    // Я добавлю булевую переменную _isLoadingStream для блокировки

    setState(() {
      _isLoadingStream = true;
    });

    String? result;
    bool success = false;

    if (_isStreaming) {
      result = await apiService.stopStream();
      if (result != null && !result.startsWith('Ошибка')) {
        success = true;
      }
    } else {
      result = await apiService.startStream();
      if (result != null && !result.startsWith('Ошибка')) {
        success = true;
      }
    }

    setState(() {
      _isLoadingStream = false;
      if (success) {
        _isStreaming = !_isStreaming;
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result ?? 'Неизвестная ошибка'),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // void _updateGame(Player player) {
  //   setState(() {
  //     leftPlayer.score = "0";
  //     rightPlayer.score = "0";
  //     if (player.games![0] == 0) {
  //       player.gameInc(0);
  //     } else {
  //       int index = player.games!.indexOf(0) - 1;
  //       int temp = index != -2 ? index : 4;
  //       player.gameInc(temp);
  //     }
  //   });
  // }

  void _updateGame(Player player) {
    int setSum = (leftPlayer.set + rightPlayer.set).clamp(0, 4);
    setState(() {
      leftPlayer.score = "0";
      rightPlayer.score = "0";
      player.gameInc(setSum);
      sendScoreAndNotify();
    });
    _addHistoryEntry("Гейм - ${player.name}: ${leftPlayer.games![setSum]} - ${rightPlayer.games![setSum]}");
  }

  void _updateGameColors() {
    int setSum = (leftPlayer.set + rightPlayer.set).clamp(0, 4);
    setState(() {
      if (setSum == 0) {
        colors = List.from(defaultColors);
      } else {
        colors![setSum - 1] = Colors.white;
        colors![setSum + 1] = Colors.white;
        colors![setSum] = gameActiveColor;
      }
    });
  }

  void _updateSet(Player player) {
    setState(() {
      player.setInc();
      _updateGameColors();
      sendScoreAndNotify();
    });
    _addHistoryEntry("Сет - ${player.name}: ${leftPlayer.set} - ${rightPlayer.set}");
  }


  void _updateLeftScore(String updateText) {
    setState(() {
      leftPlayer.score = updateText;
      sendScoreAndNotify();
    });
    _addHistoryEntry("СЧЁТ - ${leftPlayer.name}: ${leftPlayer.score} - ${rightPlayer.score}");
  }

  void _updateRightScore(String updateText) {
    setState(() {
      rightPlayer.score = updateText;
      sendScoreAndNotify();
    });
    _addHistoryEntry("СЧЁТ - ${rightPlayer.name}: ${leftPlayer.score} - ${rightPlayer.score}");
  }

  void _tieScore() {
    setState(() {
      rightPlayer.score = "40";
      leftPlayer.score = "40";
      sendScoreAndNotify();
    });
    _addHistoryEntry("РОВНО");
  }

  void _makeTransition() {
    setState(() {
      Player tempPlayer = leftPlayer;
      leftPlayer = rightPlayer;
      rightPlayer = tempPlayer;
      firstPlayerTextController.text = leftPlayer.name;
      secondPlayerTextController.text = rightPlayer.name;
      sendScoreAndNotify();
    });
    _addHistoryEntry("ПЕРЕХОД");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Expanded(flex: 1, child: _playersInfo()),
        Expanded(flex: 8, child: _developPanel()),
      ],
    );
  }

  Widget _playersInfo() {
    return Row(
      children: <Widget>[
        Expanded(child: _firstPlayer()),
        Expanded(child: _clearButtons()),
        Expanded(child: _secondPlayer()),
      ],
    );
  }

  Widget _developPanel() {
    return Row(
      children: <Widget>[
        Expanded(flex: 1, child: _leftPanel()),
        Expanded(flex: 3, child: _centerPanel()),
        Expanded(flex: 1, child: _rightPanel()),
      ],
    );
  }

  Widget _firstPlayer() {
    return Center(
      child: Card(
        child: TextField(
          controller: firstPlayerTextController,
          focusNode: firstPlayerFocusNode,
          obscureText: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: backgroungColor,
            border: OutlineInputBorder(),
            labelText: "ИГРОК 1",
          ),
          onSubmitted: (text) {
            leftPlayer.name = text;
            sendScoreAndNotify();
          },
        ),
      ),
    );
  }


  Widget _clearButtons() {
    return Row(
      children: [
        Expanded(flex: 1, child: Container()),
        TennisPanelButton(
          text: "ОЧИСТИТЬ",
          heigh: 0.6,
          fontSize: 0.2,
          onPressed: () => _clearAll(),
          flex: 3,
        ),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isLoadingStream ? null : _toggleStream,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isStreaming ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isLoadingStream
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : Text(
              _isStreaming ? "СТОП" : "СТРИМ",
              style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.01),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: SizedBox(
              width: 48,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: configButtonColor,
                  shape: CircleBorder(),
                  padding: EdgeInsets.zero,
                ),
                onPressed: () {
                  showIpDialog(context, serverIp, courtId, (newIp, newCourtId) async {
                    setState(() {
                      serverIp = newIp;
                      courtId = newCourtId;
                    });
                    _saveIp(newIp);
                    apiService.updateServerIp(newIp, newCourtId);
                    String? message = await apiService.getHealth();
                    message != null && message.contains("успешно")
                        ? setState(() {
                          configButtonColor = Colors.green;
                        })
                        : setState(() {
                          configButtonColor = Colors.redAccent;
                        });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message ?? "Неизвестая ошибка"),
                            backgroundColor: message != null && message.contains("успешно")
                                ? Colors.green
                                : Colors.redAccent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            duration: const Duration(seconds: 2),
                          )
                      );
                    }

                  });
                },
                child: Icon(Icons.settings, color: Colors.white),
              ),
            ),
          ),
        ),
        TennisPanelButton(
          text: visibleButtonText,
          heigh: 0.6,
          fontSize: 0.2,
          onPressed: () => _updateVisible(),
          flex: 3,
        ),
        Expanded(flex: 1, child: Container()),
      ],
    );
  }

  Widget _secondPlayer() {
    return Center(
      child: Card(
        child: TextField(
          controller: secondPlayerTextController,
          focusNode: secondPlayerFocusNode,
          obscureText: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: backgroungColor,
            border: OutlineInputBorder(),
            labelText: "ИГРОК 2",
          ),
          onSubmitted: (text) {
            rightPlayer.name = text;
            sendScoreAndNotify();
          },
        ),
      ),
    );
  }

  Widget _leftPanel() {
    return Row(
      children: <Widget>[
        Expanded(flex: 1, child: _leftServe()),
        Expanded(flex: 3, child: _leftButtons()),
      ],
    );
  }

  Widget _rightPanel() {
    return Row(
      children: <Widget>[
        Expanded(flex: 3, child: _rightButtons()),
        Expanded(flex: 1, child: _rightServe()),
      ],
    );
  }



  Widget _leftServe() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Размер шрифта зависит от высоты кнопки (или ширины)
        final fontSize = (constraints.maxHeight * 0.12).clamp(14.0, 36.0);

        return ElevatedButton(
          onPressed: () => _updateServeColor(1),
          style: ElevatedButton.styleFrom(
            backgroundColor: leftServeColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(60, 100),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: 'ПОДАЧА'.split('').map((char) => Text(
                char,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
              )).toList(),
            ),
          ),
        );
      },
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
      _left0(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buttons.map((widget) {
        return Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
            child: widget,
          ),
        );
      }).toList(),
    );
  }

  Widget _rightServe() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Размер шрифта зависит от высоты кнопки (или ширины)
        final fontSize = (constraints.maxHeight * 0.12).clamp(14.0, 36.0);

        return ElevatedButton(
          onPressed: () => _updateServeColor(2),
          style: ElevatedButton.styleFrom(
            backgroundColor: rightServeColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            minimumSize: const Size(60, 100),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: 'ПОДАЧА'.split('').map((char) => Text(
                char,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
              )).toList(),
            ),
          ),
        );
      },
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
      _right0(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buttons.map((widget) {
        return Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
            child: widget,
          ),
        );
      }).toList(),
    );
  }

  Widget _leftSet() {
    return TennisButton(
      name: "СЕТ",
      onPressed: _isSetPlusValid() ? () => _updateSet(leftPlayer) : null,
    );
  }

  Widget _leftGame() {
    return TennisButton(name: "ГЕЙМ", onPressed: () => _updateGame(leftPlayer));
  }

  Widget _leftLess() {
    return TennisButton(name: "МН", onPressed: () => _updateLeftScore("мн"));
  }

  Widget _leftMore() {
    return TennisButton(name: "БЛ", onPressed: () => _updateLeftScore("бл"));
  }

  Widget _left40() {
    return TennisButton(name: "40", onPressed: () => _updateLeftScore("40"));
  }

  Widget _left30() {
    return TennisButton(name: "30", onPressed: () => _updateLeftScore("30"));
  }

  Widget _left15() {
    return TennisButton(name: "15", onPressed: () => _updateLeftScore("15"));
  }

  Widget _left0() {
    return TennisButton(name: "0", onPressed: () => _updateLeftScore("0"));
  }

  Widget _rightSet() {
    return TennisButton(
      name: "СЕТ",
      onPressed: _isSetPlusValid() ? () => _updateSet(rightPlayer) : null,
    );
  }

  Widget _rightGame() {
    return TennisButton(
      name: "ГЕЙМ",
      onPressed: () => _updateGame(rightPlayer),
    );
  }

  Widget _rightLess() {
    return TennisButton(name: "МН", onPressed: () => _updateRightScore("мн"));
  }

  Widget _rightMore() {
    return TennisButton(name: "БЛ", onPressed: () => _updateRightScore("бл"));
  }

  Widget _right40() {
    return TennisButton(name: "40", onPressed: () => _updateRightScore("40"));
  }

  Widget _right30() {
    return TennisButton(name: "30", onPressed: () => _updateRightScore("30"));
  }

  Widget _right15() {
    return TennisButton(name: "15", onPressed: () => _updateRightScore("15"));
  }

  Widget _right0() {
    return TennisButton(name: "0", onPressed: () => _updateRightScore("0"));
  }

  Widget _centerPanel() {
    return Column(
      children: <Widget>[
        Expanded(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
            child: _developButtons(),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
            child: _transitionButtons(),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
            child: _historyFrame(),
          ),
        ),
      ],
    );
  }

  Widget _developButtons() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Flexible(
          flex: 6,
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: _buttonsPanel(),
          ),
        ),
        // Expanded(flex: 1, child: Container(color: Colors.blue,)),
        Expanded(flex: 1, child: _sameScore()),
      ],
    );
  }

  Widget _sameScore() {
    return Row(
      children: <Widget>[
        Expanded(flex: 1, child: Container()),
        TennisPanelButton(
          text: "РОВНО",
          heigh: 0.9,
          fontSize: 0.7,
          onPressed: () => _tieScore(),
          flex: 2,
        ),
        Expanded(flex: 1, child: Container()),
      ],
    );
  }

  Widget _buttonsPanel() {
    return Row(
      children: [
        Expanded(child: _leftScoreWidget()),
        Expanded(child: _leftScorePanel()),
        Expanded(child: _rightScorePanel()),
        Expanded(child: _rightScoreWidget()),
      ],
    );
  }

  Widget _leftScoreWidget() {
    return Column(
      children: <Widget>[
        Expanded(flex: 1, child: _leftScorePlus()),
        Expanded(
          flex: 4,
          child: Container(color: Colors.white, child: _leftScoreFrame()),
        ),
        Expanded(flex: 1, child: _leftScoreMinus()),
      ],
    );
  }

  Widget _leftScorePanel() {
    double fontSize = (MediaQuery.of(context).size.width * 0.7).clamp(10, 20);
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontSize: fontSize,
                    ),
                    child: Text("СЕТ"),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    double containerSize = screenWidth * 0.03;
                    // double padding = constraints.maxWidth * 0.01;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: containerSize,
                          height: containerSize,
                          child: TennisIncDecButtons(
                            isInc: false,
                            onPressed: _isSetMinusValid(leftPlayer)
                                ? () => _onPressedSet(leftPlayer, false)
                                : null,
                          ),
                        ),
                        SizedBox(
                          width: containerSize,
                          height: containerSize,
                          child: _scoreField(
                            leftPlayer.set.toString(),
                            Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: containerSize,
                          height: containerSize,
                          child: TennisIncDecButtons(
                            isInc: true,
                            onPressed: _isSetPlusValid()
                                ? () => _onPressedSet(leftPlayer, true)
                                : null,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontSize: fontSize,
                    ),
                    child: Text("ГЕЙМЫ"),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: true,
                              onPressed: _isGamePlusValid(0)
                                  ? () => _onPressedGame(leftPlayer, true, 0)
                                  : null,
                            ),
                          ),
                          SizedBox(
                            child: _scoreField(
                              (leftPlayer.games![0]).toString(),
                              colors![0],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: false,
                              onPressed: _isGameMinusValid(leftPlayer, 0)
                                  ? () => _onPressedGame(leftPlayer, false, 0)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: true,
                              onPressed: _isGamePlusValid(1)
                                  ? () => _onPressedGame(leftPlayer, true, 1)
                                  : null,
                            ),
                          ),
                          SizedBox(
                            child: _scoreField(
                              (leftPlayer.games![1]).toString(),
                              colors![1],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: false,
                              onPressed: _isGameMinusValid(leftPlayer, 1)
                                  ? () => _onPressedGame(leftPlayer, false, 1)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: true,
                              onPressed: _isGamePlusValid(2)
                                  ? () => _onPressedGame(leftPlayer, true, 2)
                                  : null,
                            ),
                          ),
                          SizedBox(
                            child: _scoreField(
                              (leftPlayer.games![2]).toString(),
                              colors![2],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: false,
                              onPressed: _isGameMinusValid(leftPlayer, 2)
                                  ? () => _onPressedGame(leftPlayer, false, 2)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: true,
                              onPressed: _isGamePlusValid(3)
                                  ? () => _onPressedGame(leftPlayer, true, 3)
                                  : null,
                            ),
                          ),
                          SizedBox(
                            child: _scoreField(
                              (leftPlayer.games![3]).toString(),
                              colors![3],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: false,
                              onPressed: _isGameMinusValid(leftPlayer, 3)
                                  ? () => _onPressedGame(leftPlayer, false, 3)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: true,
                              onPressed: _isGamePlusValid(4)
                                  ? () => _onPressedGame(leftPlayer, true, 4)
                                  : null,
                            ),
                          ),
                          SizedBox(
                            child: _scoreField(
                              (leftPlayer.games![4]).toString(),
                              colors![4],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: false,
                              onPressed: _isGameMinusValid(leftPlayer, 4)
                                  ? () => _onPressedGame(leftPlayer, false, 4)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _rightScoreWidget() {
    return Column(
      children: <Widget>[
        Expanded(flex: 1, child: _rightScorePlus()),
        Expanded(
          flex: 4,
          child: Container(color: Colors.white, child: _rightScoreFrame()),
        ),
        Expanded(flex: 1, child: _rightScoreMinus()),
      ],
    );
  }

  Widget _rightScorePanel() {
    double fontSize = (MediaQuery.of(context).size.width * 0.7).clamp(8, 20);
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontSize: fontSize,
                    ),
                    child: Text("СЕТ"),
                  ),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    double containerSize = screenWidth * 0.03;
                    // double padding = constraints.maxWidth * 0.01;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          width: containerSize,
                          height: containerSize,
                          child: TennisIncDecButtons(
                            isInc: false,
                            onPressed: _isSetMinusValid(rightPlayer)
                                ? () => _onPressedSet(rightPlayer, false)
                                : null,
                          ),
                        ),
                        SizedBox(
                          width: containerSize,
                          height: containerSize,
                          child: _scoreField(
                            rightPlayer.set.toString(),
                            Colors.white,
                          ),
                        ),
                        SizedBox(
                          width: containerSize,
                          height: containerSize,
                          child: TennisIncDecButtons(
                            isInc: true,
                            onPressed: _isSetPlusValid()
                                ? () => _onPressedSet(rightPlayer, true)
                                : null,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Center(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none,
                      fontSize: fontSize,
                    ),
                    child: Text("ГЕЙМЫ"),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: true,
                              onPressed: _isGamePlusValid(0)
                                  ? () => _onPressedGame(rightPlayer, true, 0)
                                  : null,
                            ),
                          ),
                          SizedBox(
                            child: _scoreField(
                              (rightPlayer.games![0]).toString(),
                              colors![0],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: false,
                              onPressed: _isGameMinusValid(rightPlayer, 0)
                                  ? () => _onPressedGame(rightPlayer, false, 0)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: true,
                              onPressed: _isGamePlusValid(1)
                                  ? () => _onPressedGame(rightPlayer, true, 1)
                                  : null,
                            ),
                          ),
                          SizedBox(
                            child: _scoreField(
                              (rightPlayer.games![1]).toString(),
                              colors![1],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: false,
                              onPressed: _isGameMinusValid(rightPlayer, 1)
                                  ? () => _onPressedGame(rightPlayer, false, 1)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: true,
                              onPressed: _isGamePlusValid(2)
                                  ? () => _onPressedGame(rightPlayer, true, 2)
                                  : null,
                            ),
                          ),
                          SizedBox(
                            child: _scoreField(
                              (rightPlayer.games![2]).toString(),
                              colors![2],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: false,
                              onPressed: _isGameMinusValid(rightPlayer, 2)
                                  ? () => _onPressedGame(rightPlayer, false, 2)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: true,
                              onPressed: _isGamePlusValid(3)
                                  ? () => _onPressedGame(rightPlayer, true, 3)
                                  : null,
                            ),
                          ),
                          SizedBox(
                            child: _scoreField(
                              (rightPlayer.games![3]).toString(),
                              colors![3],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: false,
                              onPressed: _isGameMinusValid(rightPlayer, 3)
                                  ? () => _onPressedGame(rightPlayer, false, 3)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: true,
                              onPressed: _isGamePlusValid(4)
                                  ? () => _onPressedGame(rightPlayer, true, 4)
                                  : null,
                            ),
                          ),
                          SizedBox(
                            child: _scoreField(
                              (rightPlayer.games![4]).toString(),
                              colors![4],
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TennisIncDecButtons(
                              isInc: false,
                              onPressed: _isGameMinusValid(rightPlayer, 4)
                                  ? () => _onPressedGame(rightPlayer, false, 4)
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool _isSetMinusValid(Player player) {
    if (player.set <= 0) {
      return false;
    } else {
      return true;
    }
  }

  bool _isSetPlusValid() {
    if ((leftPlayer.set + rightPlayer.set) >= 5) {
      return false;
    }
    return true;
  }

  bool _isGameMinusValid(Player player, int game) {
    if (player.games![game] <= 0) {
      return false;
    } else {
      return true;
    }
  }

  bool _isGamePlusValid(int game) {
    int setSum = (leftPlayer.set + rightPlayer.set).clamp(0, 4);
    if (game <= setSum) {
      return true;
    }
    return false;
  }

  bool _isScoreValid(Player player, bool isInc) {
    List<String> validScores = [
      '0',
      '1',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      '11',
      '12',
      '13',
      '13',
    ];
    if (!isInc) {
      validScores = [
        '1',
        '2',
        '3',
        '4',
        '5',
        '6',
        '7',
        '8',
        '9',
        '10',
        '11',
        '12',
        '13',
        '14',
      ];
    }
    return validScores.contains(player.score);
  }

  void _onPressedScore(Player player, bool isInc) {
    setState(() {
      int intScore = int.parse(player.score);
      if (isInc) {
        intScore += 1;
      } else {
        intScore -= 1;
      }
      player.score = intScore.toString();
    });
    sendScoreAndNotify();
    _addHistoryEntry("СЧЁТ - ${player.name}: ${leftPlayer.score} - ${rightPlayer.score}");
  }

  void _onPressedSet(Player player, bool isInc) {
    setState(() {
      if (isInc) {
        player.setInc();
      } else {
        player.setDec();
      }
      _updateGameColors();
    });
    // sendScoreAndNotify();
    _addHistoryEntry("СЕТ - ${player.name}: ${leftPlayer.set} - ${rightPlayer.set}");
  }

  void _onPressedGame(Player player, bool isInc, int game) {
    setState(() {
      if (isInc) {
        player.gameInc(game);
      } else {
        player.gameDec(game);
      }
    });
    sendScoreAndNotify();
    _addHistoryEntry("ГЕЙМ - ${player.name}: ${leftPlayer.games?[game]} - ${rightPlayer.games?[game]}");
  }

  Widget _leftScorePlus() {
    return TennisIncDecButtons(
      isInc: true,
      onPressed: _isScoreValid(leftPlayer, true)
          ? () => _onPressedScore(leftPlayer, true)
          : null,
    );
  }

  Widget _leftScoreFrame() {
    final screenHeight = MediaQuery.of(context).size.height;
    double fontSize = screenHeight * 0.10;
    fontSize = fontSize.clamp(40.0, 120.0);

    return Center(
      child: DefaultTextStyle(
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
        ),
        child: Text(leftPlayer.score),
      ),
    );
  }

  Widget _leftScoreMinus() {
    return TennisIncDecButtons(
      isInc: false,
      onPressed: _isScoreValid(leftPlayer, false)
          ? () => _onPressedScore(leftPlayer, false)
          : null,
    );
  }

  Widget _rightScorePlus() {
    return TennisIncDecButtons(
      isInc: true,
      onPressed: _isScoreValid(rightPlayer, true)
          ? () => _onPressedScore(rightPlayer, true)
          : null,
    );
  }

  Widget _rightScoreFrame() {
    final screenHeight = MediaQuery.of(context).size.height;
    double fontSize = screenHeight * 0.10;
    fontSize = fontSize.clamp(40.0, 120.0);

    return Center(
      child: DefaultTextStyle(
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
        ),
        child: Text(rightPlayer.score),
      ),
    );
  }

  Widget _rightScoreMinus() {
    return TennisIncDecButtons(
      isInc: false,
      onPressed: _isScoreValid(rightPlayer, false)
          ? () => _onPressedScore(rightPlayer, false)
          : null,
    );
  }

  Widget _transitionButtons() {
    return Row(
      children: <Widget>[
        Expanded(flex: 1, child: Container()),
        TennisPanelButton(
          text: "ПЕРЕХОД",
          heigh: 0.86,
          fontSize: 0.63,
          onPressed: () => _makeTransition(),
          flex: 2,
        ),
        Expanded(flex: 1, child: Container()),
      ],
    );
  }

  Widget _historyFrame() {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: history.isEmpty
          ? const Center(
        child: Text(
          'История пуста',
          style: TextStyle(color: Colors.grey),
        ),
      )
          : ListView.builder(
        reverse: false, // показываем сверху вниз (самые новые сверху)
        itemCount: history.length,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: index == 0
                  ? null
                  : Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: Text(
              history[index],
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _scoreField(String text, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = (screenWidth * 0.7).clamp(8.0, 20.0);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: primaryColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: (screenWidth * 0.03).clamp(10.0, 60.0),
        height: (screenWidth * 0.03).clamp(10.0, 60.0),
        child: Center(
          child: DefaultTextStyle(
            style: TextStyle(
              decoration: TextDecoration.none,
              fontSize: fontSize,
              color: Colors.black,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }
}
