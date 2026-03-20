import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_schedule_session.dart';

class StudentScanQR extends StatefulWidget {
  final VoidCallback onBack;
  const StudentScanQR({super.key, required this.onBack});

  @override
  State<StudentScanQR> createState() => _StudentScanQRState();
}

class _StudentScanQRState extends State<StudentScanQR> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _scanned = false;

  Future<void> _onQRDetected(String sessionId) async {
    if (_scanned) return;
    setState(() => _scanned = true);

    final uid = _auth.currentUser!.uid;

    try {
      final sessionRef = _firestore.collection('sessions').doc(sessionId);
      final sessionSnap = await sessionRef.get();

      if (!sessionSnap.exists) {
        _showMessage('Invalid QR code. Session not found.');
        setState(() => _scanned = false);
        return;
      }

      await sessionRef.update({
        'students': FieldValue.arrayUnion([uid]),
      });

      if (!mounted) return;

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
        backgroundColor: const Color(0xFF0047AB),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: const Text('Scan QR Code',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final barcode = capture.barcodes.first;
              final value = barcode.rawValue;
              if (value != null) {
                _onQRDetected(value);
              }
            },
          ),
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