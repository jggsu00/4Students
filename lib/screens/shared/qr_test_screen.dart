import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../login_screen.dart';

enum SessionStatus { upcoming, completed, rescheduled }

class _SessionInfo {
  final String title;
  final String date;
  final String time;
  final String location;
  final SessionStatus status;

  const _SessionInfo({
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.status,
  });
}

enum ConfirmationStatus { pending, confirmed, denied }

class _StudentRequest {
  final String name;
  final String scannedAt;
  ConfirmationStatus status;

  _StudentRequest({
    required this.name,
    required this.scannedAt,
    this.status = ConfirmationStatus.pending,
  });
}

class QrTestScreen extends StatefulWidget {
  const QrTestScreen({super.key});

  @override
  State<QrTestScreen> createState() => _QrTestScreenState();
}

class _QrTestScreenState extends State<QrTestScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final String randomData = 'TEST_CHECK_IN_${Random().nextInt(999999)}';

  // Hardcoded pending scan requests for current session
  final List<_StudentRequest> _requests = [
    _StudentRequest(name: 'Alice Johnson', scannedAt: '3:02 PM'),
    _StudentRequest(name: 'Bob Martinez', scannedAt: '3:04 PM'),
    _StudentRequest(
        name: 'Carol Smith',
        scannedAt: '3:05 PM',
        status: ConfirmationStatus.confirmed),
    _StudentRequest(name: 'David Lee', scannedAt: '3:07 PM'),
    _StudentRequest(
        name: 'Emma Wilson',
        scannedAt: '3:08 PM',
        status: ConfirmationStatus.denied),
  ];

  int get _pendingCount =>
      _requests.where((r) => r.status == ConfirmationStatus.pending).length;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  void _confirm(int index) =>
      setState(() => _requests[index].status = ConfirmationStatus.confirmed);

  void _deny(int index) =>
      setState(() => _requests[index].status = ConfirmationStatus.denied);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        foregroundColor: Colors.white,
        title: const Text('QR Code Generator'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle:
          const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          tabs: [
            const Tab(text: 'QR Code'),
            const Tab(text: 'Sessions'),
            // Confirmation tab with pending badge
            Tab(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Text('Confirmation'),
                  ),
                  if (_pendingCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                            minWidth: 18, minHeight: 18),
                        child: Text(
                          '$_pendingCount',
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _QrCodeTab(randomData: randomData),
          const _SessionsTab(),
          _ConfirmationTab(
            requests: _requests,
            onConfirm: _confirm,
            onDeny: _deny,
          ),
        ],
      ),
    );
  }
}


// Tab 1 — QR Code
class _QrCodeTab extends StatelessWidget {
  final String randomData;
  const _QrCodeTab({required this.randomData});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Session Check-In QR Code',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0047AB),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: QrImageView(
                data: randomData,
                version: QrVersions.auto,
                size: 250,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0047AB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                randomData,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Students can scan this code to check in',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}


// Tab 2 — Session Details
class _SessionsTab extends StatelessWidget {
  const _SessionsTab();

  static const List<_SessionInfo> sessions = [
    _SessionInfo(
      title: 'Intro to Flutter – Week 1',
      date: 'Feb 18, 2026',
      time: '3:00 PM – 4:30 PM',
      location: 'Room 204',
      status: SessionStatus.completed,
    ),
    _SessionInfo(
      title: 'Intro to Flutter – Week 2',
      date: 'Feb 25, 2026',
      time: '3:00 PM – 4:30 PM',
      location: 'Room 204',
      status: SessionStatus.completed,
    ),
    _SessionInfo(
      title: 'Intro to Flutter – Week 3',
      date: 'March 4, 2026',
      time: '4:00 PM – 5:30 PM',
      location: 'Room 101',
      status: SessionStatus.rescheduled,
    ),
    _SessionInfo(
      title: 'Intro to Flutter – Week 5',
      date: 'March 18, 2026',
      time: '3:00 PM – 4:30 PM',
      location: 'Room 204',
      status: SessionStatus.upcoming,
    ),
    _SessionInfo(
      title: 'State Management Deep Dive',
      date: 'March 25, 2026',
      time: '3:00 PM – 4:30 PM',
      location: 'Room 204',
      status: SessionStatus.upcoming,
    ),
    _SessionInfo(
      title: 'Firebase Integration',
      date: 'April 1, 2026',
      time: '3:00 PM – 4:30 PM',
      location: 'Room 204',
      status: SessionStatus.upcoming,
    ),
  ];

  Color _color(SessionStatus s) {
    switch (s) {
      case SessionStatus.upcoming:
        return Colors.blue.shade600;
      case SessionStatus.completed:
        return Colors.green.shade600;
      case SessionStatus.rescheduled:
        return Colors.orange.shade700;
    }
  }

  Color _bg(SessionStatus s) {
    switch (s) {
      case SessionStatus.upcoming:
        return Colors.blue.shade50;
      case SessionStatus.completed:
        return Colors.green.shade50;
      case SessionStatus.rescheduled:
        return Colors.orange.shade50;
    }
  }

  IconData _icon(SessionStatus s) {
    switch (s) {
      case SessionStatus.upcoming:
        return Icons.event_available;
      case SessionStatus.completed:
        return Icons.check_circle_outline;
      case SessionStatus.rescheduled:
        return Icons.update;
    }
  }

  String _label(SessionStatus s) {
    switch (s) {
      case SessionStatus.upcoming:
        return 'Upcoming';
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.rescheduled:
        return 'Rescheduled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sessions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final s = sessions[index];
        final color = _color(s.status);
        final bg = _bg(s.status);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration:
                  BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: Icon(_icon(s.status), color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0047AB))),
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.calendar_today,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(s.date,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ]),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.access_time,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(s.time,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ]),
                      const SizedBox(height: 3),
                      Row(children: [
                        const Icon(Icons.location_on,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(s.location,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ]),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Text(_label(s.status),
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


// Tab 3 — Confirmation
class _ConfirmationTab extends StatelessWidget {
  final List<_StudentRequest> requests;
  final void Function(int) onConfirm;
  final void Function(int) onDeny;

  const _ConfirmationTab({
    required this.requests,
    required this.onConfirm,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    final pending = requests
        .where((r) => r.status == ConfirmationStatus.pending)
        .toList();
    final resolved = requests
        .where((r) => r.status != ConfirmationStatus.pending)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Current session label
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0047AB).withOpacity(0.07),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('CURRENT SESSION',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                      letterSpacing: 1.1)),
              SizedBox(height: 2),
              Text('Intro to Flutter – Week 4',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0047AB))),
              SizedBox(height: 2),
              Text('March 11, 2026  •  3:00 PM – 4:30 PM',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),

        // Pending
        if (pending.isNotEmpty) ...[
          Row(children: [
            Text('Awaiting Confirmation',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange.shade700)),
            const SizedBox(width: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${pending.length}',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700)),
            ),
          ]),
          const SizedBox(height: 10),
          ...pending.map((req) {
            final index = requests.indexOf(req);
            return _PendingCard(
              request: req,
              onConfirm: () => onConfirm(index),
              onDeny: () => onDeny(index),
            );
          }),
          const SizedBox(height: 24),
        ],

        // Resolved
        if (resolved.isNotEmpty) ...[
          const Text('Resolved',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey)),
          const SizedBox(height: 10),
          ...resolved.map((req) => _ResolvedCard(request: req)),
        ],

        if (pending.isEmpty && resolved.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: Text('No check-in requests yet.',
                  style: TextStyle(color: Colors.grey, fontSize: 15)),
            ),
          ),
      ],
    );
  }
}

class _PendingCard extends StatelessWidget {
  final _StudentRequest request;
  final VoidCallback onConfirm;
  final VoidCallback onDeny;

  const _PendingCard({
    required this.request,
    required this.onConfirm,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor:
              const Color(0xFF0047AB).withOpacity(0.1),
              child: Text(request.name[0],
                  style: const TextStyle(
                      color: Color(0xFF0047AB),
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text('Scanned at ${request.scannedAt}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            // Deny
            GestureDetector(
              onTap: onDeny,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Icon(Icons.close,
                    color: Colors.red.shade500, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            // Confirm
            GestureDetector(
              onTap: onConfirm,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Icon(Icons.check,
                    color: Colors.green.shade600, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResolvedCard extends StatelessWidget {
  final _StudentRequest request;
  const _ResolvedCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final confirmed = request.status == ConfirmationStatus.confirmed;
    final color =
    confirmed ? Colors.green.shade600 : Colors.red.shade400;
    final bg = confirmed ? Colors.green.shade50 : Colors.red.shade50;
    final label = confirmed ? 'Confirmed' : 'Denied';
    final icon = confirmed ? Icons.check_circle : Icons.cancel;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: bg,
          child: Text(request.name[0],
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold)),
        ),
        title: Text(request.name,
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w500)),
        subtitle: Text('Scanned at ${request.scannedAt}',
            style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}