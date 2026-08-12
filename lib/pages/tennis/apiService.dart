import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ptennis_2/pages/tennis/tennis_score_board.dart';

class ApiService {
  String? serverIp = "localhost";
  int? courtId = 0;
  Uri serverUrl;

  ApiService({this.serverIp, this.courtId, Uri? serverUrl})
    : serverUrl = Uri.parse('http://$serverIp:8000/post_score/$courtId');

  void updateServerIp(String newIp, int newCourtId) {
    serverIp = newIp;
    courtId = newCourtId;
    serverUrl = Uri.parse('http://$newIp:8000/post_score/$newCourtId');
  }

  // final serverUrl = Uri.parse('http://$serverIp:8000/health');

  Future<String?> getHealth() async {
    try {
      final response = await http
          .get(Uri.parse('http://$serverIp:8000/health'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final int statusCodeFromBody = data[0];
        final Map<String, dynamic> messageObj =
            data[1]; // {"message": "Подключение успешно"}
        final String message = messageObj['message'];
        return message; // Возвращаем само сообщение
      } else {
        return "Ошибка сервера: ${response.statusCode}";
      }
    } catch (e) {
      print(serverIp);
      print(e);
      return "Не удалось связаться с сервером";
    }
  }

    Future<String?> postScore(Player leftPlayer, Player rightPlayer, bool isVisible, [int? server]) async {
    try {
      Map<String, dynamic> tennisData = {
        "first_player": leftPlayer.name,
        "second_player": rightPlayer.name,
        "first_point": leftPlayer.score,
        "second_point": rightPlayer.score,
        "first_game_1": leftPlayer.games?[0],
        "first_game_2": leftPlayer.games?[1],
        "first_game_3": leftPlayer.games?[2],
        "second_game_1": rightPlayer.games?[0],
        "second_game_2": rightPlayer.games?[1],
        "second_game_3": rightPlayer.games?[2],
        "server": server,
        "is_visible": isVisible,
      };

      final updateDataResponse = await http.post(
        serverUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(tennisData),
      );
      if (updateDataResponse.statusCode != 200) {
        print('не получилось');
        return null;
      }
      return "Успех";
    } catch (e) {
      print(e);
      return "Непредвиденная ошибка $e";
    }
  }


  Future<String?> startStream() async {
    try {
      final response = await http
          .post(Uri.parse('http://$serverIp:8000/vmix/stream/start/$courtId'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return "Трансляция запущена";
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return "Ошибка: ${errorBody['detail'] ?? response.statusCode}";
        } catch (_) {
          return "Ошибка сервера: ${response.statusCode}";
        }
      }
    } catch (e) {
      print(e);
      return "Не удалось подключиться к серверу";
    }
  }

  Future<String?> stopStream() async {
    try {
      final response = await http
          .post(Uri.parse('http://$serverIp:8000/vmix/stream/stop/$courtId'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return "Трансляция остановлена";
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          return "Ошибка: ${errorBody['detail'] ?? response.statusCode}";
        } catch (_) {
          return "Ошибка сервера: ${response.statusCode}";
        }
      }
    } catch (e) {
      print(e);
      return "Не удалось подключиться к серверу";
    }
  }
}
