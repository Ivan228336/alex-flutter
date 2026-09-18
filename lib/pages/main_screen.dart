import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ptennis_2/pages/tennis/apiService.dart';
import 'package:ptennis_2/pages/base_screen.dart';
import 'package:ptennis_2/pages/tennis/tennis_score_board.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // 0 — база, 1 — про

  // ===== Общее состояние =====
  late ApiService apiService;
  String serverIp = "192.168.0.10";
  int courtId = 0;

  bool isStreaming = false;
  bool isLoadingStream = false;

  @override
  void initState() {
    super.initState();
    apiService = ApiService(serverIp: serverIp, courtId: courtId);
    _loadIp();
  }

  Future<void> _loadIp() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      serverIp = prefs.getString('ip') ?? "192.168.0.10";
      courtId = prefs.getInt('courtId') ?? 0;
      apiService.updateServerIp(serverIp, courtId);
    });
  }

  Future<void> _saveIp(String ip, int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ip', ip);
    await prefs.setInt('courtId', id);
    if (!mounted) return;
    setState(() {
      serverIp = ip;
      courtId = id;
    });
  }

  // Логика переехала сюда из TennisScoreBoard
  Future<void> _toggleStream() async {
    setState(() => isLoadingStream = true);
    final result = isStreaming
        ? await apiService.stopStream()
        : await apiService.startStream();
    final success = result != null && result.contains('Трансляция');
    if (!mounted) return;
    setState(() {
      isLoadingStream = false;
      if (success) isStreaming = !isStreaming;
    });
    _showSnack(result ?? 'Неизвестная ошибка', success);
  }

  void _showSnack(String text, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(text),
      backgroundColor: success ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          BaseScreen(
            isStreaming: isStreaming,
            isLoadingStream: isLoadingStream,
            onStreamToggle: _toggleStream,
            onEnterProMode: () => setState(() => _currentIndex = 1),
          ),
          TennisScoreBoard(
            apiService: apiService,
            serverIp: serverIp,
            courtId: courtId,
            onServerConfigChanged: _saveIp,
            onExit: () => setState(() => _currentIndex = 0),
            isStreaming: isStreaming,
            isLoadingStream: isLoadingStream,
            onStreamToggle: _toggleStream,
          ),
        ],
      ),
    );
  }
}