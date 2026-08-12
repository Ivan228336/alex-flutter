import 'package:flutter/material.dart';


void showIpDialog(BuildContext context, String currentIp, int courtId, Function(String, int) onSave) {
  final ipController = TextEditingController(text: currentIp);
  final courtController = TextEditingController(text: courtId.toString());

  showDialog(
    context: context,
    builder: (context) => Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 40, left: 16, right: 16),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text('Настройка IP', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ipController,
                      decoration: const InputDecoration(hintText: "IP адрес", labelText: "IP"),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: courtController,
                      decoration: const InputDecoration(hintText: "Номер корта", labelText: "Корт"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Отмена")),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final ip = ipController.text.trim();
                      final courtStr = courtController.text.trim();
                      if (courtStr.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Введите номер корта')),
                        );
                        return;
                      }
                      final court = int.tryParse(courtStr);
                      if (court == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Номер корта должен быть числом')),
                        );
                        return;
                      }
                      onSave(ip, court);
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}