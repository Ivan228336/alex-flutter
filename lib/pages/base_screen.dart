import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final bool isStreaming;
  final bool isLoadingStream;
  final VoidCallback onStreamToggle;
  final VoidCallback onEnterProMode;

  const BaseScreen({
    super.key,
    required this.isStreaming,
    required this.isLoadingStream,
    required this.onStreamToggle,
    required this.onEnterProMode,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _streamButton(context),
            _proButton(),
          ],
        ),
      ),
    );
  }

  Widget _streamButton(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return ElevatedButton(
      onPressed: isLoadingStream ? null : onStreamToggle,
      style: ElevatedButton.styleFrom(
        backgroundColor: isStreaming ? Colors.red : Colors.green,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.03,
          vertical: w * 0.015,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: isLoadingStream
          ? const SizedBox(
        width: 24, height: 24,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      )
          : Text(
        isStreaming ? "ОСТАНОВИТЬ ТРАНСЛЯЦИЮ" : "ЗАПУСТИТЬ ТРАНСЛЯЦИЮ",
        style: TextStyle(fontSize: w * 0.02, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _proButton() {
    return Builder(builder: (context) {
      final w = MediaQuery.of(context).size.width;
      return ElevatedButton.icon(
        onPressed: onEnterProMode,
        icon: const Icon(Icons.dashboard),
        label: Text("ПРО РЕЖИМ", style: TextStyle(fontSize: w * 0.02)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: w * 0.03,
            vertical: w * 0.015,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    });
  }
}