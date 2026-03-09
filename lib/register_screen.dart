import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _fullName = TextEditingController();

  // Student-specific fields
  final TextEditingController _studentId = TextEditingController();
  final TextEditingController _university = TextEditingController();
  final TextEditingController _major = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedRole = 'student';

  // Year options for college students
  String _selectedYear = 'Freshman';

  Future<void> _register() async {
    if (_email.text.isEmpty || _password.text.isEmpty || _fullName.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    try {
      // Create Firebase Auth account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );

      final uid = userCredential.user!.uid;

      // Base user data for all roles
      Map<String, dynamic> userData = {
        'uid': uid,
        'fullName': _fullName.text.trim(),
        'email': _email.text.trim(),
        'role': _selectedRole,
        'profilePicUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add extra fields if registering as a student
      if (_selectedRole == 'student') {
        userData.addAll({
          'studentId': _studentId.text.trim(),
          'university': _university.text.trim(),
          'major': _major.text.trim(),
          'year': _selectedYear,
          'enrolledCourses': [],
        });
      }

      // Save user data to Firestore
      await _firestore.collection('users').doc(uid).set(userData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please log in.')),
      );

      // Go back to login after registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.white,
        title: const Text(
          "REGISTER",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _fullName,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.black),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.black),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Role selector dropdown
            Row(
              children: [
                const Text(
                  'Register as:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    dropdownColor: Colors.grey[300],
                    items: const [
                      DropdownMenuItem(value: 'student', child: Text('Student')),
                      DropdownMenuItem(value: 'tutor', child: Text('Tutor')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                ),
              ],
            ),

            // Show these fields only when student is selected
            if (_selectedRole == 'student') ...[
              const SizedBox(height: 10),
              TextField(
                controller: _studentId,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              TextField(
                controller: _university,
                decoration: const InputDecoration(
                  labelText: 'University',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              TextField(
                controller: _major,
                decoration: const InputDecoration(
                  labelText: 'Major',
                  labelStyle: TextStyle(color: Colors.black),
                ),
              ),
              const SizedBox(height: 10),

              // Year dropdown for college students
              Row(
                children: [
                  const Text(
                    'Year:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedYear,
                      isExpanded: true,
                      dropdownColor: Colors.grey[300],
                      items: const [
                        DropdownMenuItem(value: 'Freshman', child: Text('Freshman')),
                        DropdownMenuItem(value: 'Sophomore', child: Text('Sophomore')),
                        DropdownMenuItem(value: 'Junior', child: Text('Junior')),
                        DropdownMenuItem(value: 'Senior', child: Text('Senior')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedYear = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 45),
              ),
              child: const Text(
                'Register',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}