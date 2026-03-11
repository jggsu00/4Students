import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/session_details_page.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  bool _scanned = false; // prevents scanning twice

  Future<void> _onQRDetected(String sessionId) async {
    if (_scanned) return;
    setState(() => _scanned = true);

    final uid = _auth.currentUser!.uid;

    try {
      // Check if session exists in Firestore
      final sessionRef = _firestore.collection('sessions').doc(sessionId);
      final sessionSnap = await sessionRef.get();

      if (!sessionSnap.exists) {
        _showMessage('Invalid QR code. Session not found.');
        setState(() => _scanned = false);
        return;
      }

      // Mark student attendance in the session
      await sessionRef.update({
        'students': FieldValue.arrayUnion([uid]),
      });

      if (!mounted) return;

      // Go to session details page after successful scan
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SessionDetailsPage(sessionId: sessionId),
        ),
      );
    } catch (e) {
      _showMessage('Error: ${e.toString()}');
      setState(() => _scanned = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        title: const Text('Scan QR Code', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              final value = barcode.rawValue;
              if (value != null) {
                _onQRDetected(value);
              }
            },
          ),

          // Overlay with scan box
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Instructions at bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              color: Colors.black54,
              child: const Text(
                'Point your camera at the tutor\'s QR code to check in',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}