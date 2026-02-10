import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrTestScreen extends StatelessWidget {
  QrTestScreen({super.key});

  final String randomData =
      'TEST_CHECK_IN_${Random().nextInt(999999)}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test QR Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: randomData,
              version: QrVersions.auto,
              size: 250,
            ),
            const SizedBox(height: 20),
            Text(
              randomData,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
