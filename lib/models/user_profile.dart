class UserProfile {
  final String uid;
  final String fullName;
  final String email;
  final String role; // 'student' or 'tutor'
  final String? password; // Hashed, stored securely

  UserProfile({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    this.password,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
    };
  }
}
