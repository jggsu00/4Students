import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SessionDetailsPage extends StatefulWidget {
  final String sessionId;
  const SessionDetailsPage({super.key, required this.sessionId});

  @override
  State<SessionDetailsPage> createState() => _SessionDetailsPageState();
}

class _SessionDetailsPageState extends State<SessionDetailsPage> {
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? sessionData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch session details when page loads
    fetchSessionData();
  }

  Future<void> fetchSessionData() async {
    final snap = await _firestore.collection('sessions').doc(widget.sessionId).get();
    setState(() {
      sessionData = snap.data();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        title: const Text('Session Details', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      backgroundColor: Colors.grey,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Check-in success banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 10),
                  Text('Checked in successfully!',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Session details card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Session Details',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(color: Colors.grey),
                  const SizedBox(height: 12),
                  _detailRow(Icons.person, 'Tutor', sessionData?['tutorName'] ?? '—'),
                  _detailRow(Icons.tag, 'Schedule ID', sessionData?['scheduleId'] ?? '—'),
                  _detailRow(Icons.calendar_today, 'Date', sessionData?['date'] ?? '—'),
                  _detailRow(Icons.access_time, 'Time', sessionData?['time'] ?? '—'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for each detail row
  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(width: 12),
          Text('$label: ', style: const TextStyle(color: Colors.white70, fontSize: 16)),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}