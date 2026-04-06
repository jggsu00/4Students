// The login process checks the user's role in Firestore and routes them to the appropriate dashboard (Student or Tutor).

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../register_screen.dart';
import '../../screens/student/student_home_dashboard.dart';
import '../../screens/tutor/tutor_home_dashboard.dart';

// Login screen that authenticates users and routes based on their role
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Text controllers for email and password input fields
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  // Firebase authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore database instance (used to get user role)
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Login Process
  Future<void> _login() async {
    try {
      // 1. Sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _email.text, password: _password.text);

      // 2. Get user role from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (!mounted) return;

      // 3. Route to the correct dashboard based on user role
      if (userDoc.exists) {
        String role = userDoc.get('role') ?? 'student';

        // Navigate to Tutor Dashboard
        if (role == 'tutor') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TutorHomeDashboard()),
          );
        // Navigate to Student Dashboard
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentHomeDashboard()),
          );
        }
      } else {
        // If user does not exist in Firestore, show role selector page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RoleSelector()),
        );
      }
      // Shiw error message if the login fails
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
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
          "LOGIN",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Email Input field
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.black),
              ),
            ),
            // Password Input Field
            TextField(
              controller: _password,
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.black),
              ),
              obscureText: true, // Hide password characters
            ),
            const SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: _login,
              child: const Text(
                'Login',
                style: TextStyle(color: Colors.black),
              ),
            ),

            // Register Link Button
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text(
                "Don't have an account? Register",
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
      ),
    );
  }
}

/* Role Selector — shown first, navigates to LoginScreen 
  This will be the first screen users will see when they open the app
  There will be 2 buttons users can click on (one for students & one for tutors)
  Both buttons will go to the login screen, after user logs in the routing will happen
*/
class RoleSelector extends StatelessWidget {
  const RoleSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Role',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            // Student Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0047AB),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text(
                'Student Dashboard',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Tutor Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0047AB),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text(
                'Tutor Dashboard',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}