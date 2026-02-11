class Session {
  final String id;
  final String courseCode;
  final String courseName;
  final String tutor;
  final DateTime dateTime;
  final String room;
  final String status; // 'active', 'upcoming', 'completed'
  final int currentStudents;
  final int maxStudents;

  Session({
    required this.id,
    required this.courseCode,
    required this.courseName,
    required this.tutor,
    required this.dateTime,
    required this.room,
    this.status = 'upcoming',
    this.currentStudents = 0,
    this.maxStudents = 0,
  });

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      id: map['id'] ?? '',
      courseCode: map['courseCode'] ?? '',
      courseName: map['courseName'] ?? '',
      tutor: map['tutor'] ?? '',
      dateTime: DateTime.parse(map['dateTime'] ?? DateTime.now().toString()),
      room: map['room'] ?? '',
      status: map['status'] ?? 'upcoming',
      currentStudents: map['currentStudents'] ?? 0,
      maxStudents: map['maxStudents'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseCode': courseCode,
      'courseName': courseName,
      'tutor': tutor,
      'dateTime': dateTime.toIso8601String(),
      'room': room,
      'status': status,
      'currentStudents': currentStudents,
      'maxStudents': maxStudents,
    };
  }
}
