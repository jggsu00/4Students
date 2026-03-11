import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_schedule_session.dart';

class StudentScanQR extends StatefulWidget {
  const StudentScanQR({super.key});

  @override
  State<StudentScanQR> createState() => _StudentScanQRState();
}

class _StudentScanQRState extends State<StudentScanQR> {
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

      // Go to session schedule page after successful scan
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const StudentScheduleSession(),
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
        title: const Text('Scan QR Code',
            style: TextStyle(fontWeight: FontWeight.bold)),
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

          // Scan box overlay
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