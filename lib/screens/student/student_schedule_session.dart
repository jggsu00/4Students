import 'package:flutter/material.dart';

class StudentScheduleSession extends StatefulWidget {
  const StudentScheduleSession({super.key});

  @override
  State<StudentScheduleSession> createState() => _StudentScheduleSessionState();
}

class _StudentScheduleSessionState extends State<StudentScheduleSession> {
  int _currentPage = 1;
  final int _totalPages = 3;

  final List<Map<String, dynamic>> _sessions = [
    {
      'id': '435021',
      'course': 'MATH 2212 - Calculus of One Variable II',
      'tutor': 'Joseph Doughier',
      'date': 'Nov 12, 2025, 11:00 AM - 12:30 PM',
      'room': 'Room 476',
    },
    {
      'id': '342978',
      'course': 'MATH 2212 - Calculus of One Variable II',
      'tutor': 'Erika Dawn',
      'date': 'Oct 15 2025, 11:00 AM - 12:00 PM',
      'room': 'Room 258',
    },
    {
      'id': '115321',
      'course': 'MATH 2212 - Calculus of One Variable II',
      'tutor': 'Zain Mohammed',
      'date': 'Oct 05, 2025, 10:30 AM - 11:30 AM',
      'room': 'Room 238',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Schedule Session',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        'Available Sessions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0047AB),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._sessions.map((session) => Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: _buildSessionCard(session),
                          )),
                    ],
                  ),
                ),
              ),
            ),

            // Pagination
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _currentPage > 1
                        ? () {
                            setState(() {
                              _currentPage--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    color: const Color(0xFF0047AB),
                  ),
                  const SizedBox(width: 10),
                  ..._buildPageNumbers(),
                  const SizedBox(width: 10),
                  IconButton(
                    onPressed: _currentPage < _totalPages
                        ? () {
                            setState(() {
                              _currentPage++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    color: const Color(0xFF0047AB),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];
    for (int i = 1; i <= _totalPages; i++) {
      pages.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _currentPage = i;
            });
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 5),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: _currentPage == i ? const Color(0xFF0047AB) : Colors.white,
              border: Border.all(
                color: const Color(0xFF0047AB),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              '$i',
              style: TextStyle(
                color: _currentPage == i ? Colors.white : const Color(0xFF0047AB),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }
    return pages;
  }

  Widget _buildSessionCard(Map<String, dynamic> session) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF0047AB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session['course'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Colors.white70),
              const SizedBox(width: 5),
              Text(
                session['tutor'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.white70),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  session['date'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.white70),
              const SizedBox(width: 5),
              Text(
                session['room'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Session ID: ${session['id']}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
