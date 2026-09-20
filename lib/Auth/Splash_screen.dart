import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



import '../Auth/login_screen.dart';
import '../screens/staff/staff_home_screen.dart';
import '../screens/organizer/organizer_home_screen.dart';
import '../screens/donor/donor_home_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    
    Future.delayed(const Duration(seconds: 2), () {
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainAuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover, 
          child: Image.asset(
            'assets/images/Splash.jpg',
          ),
        ),
      ),
    );
  }
}


class MainAuthWrapper extends StatelessWidget {
  const MainAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.red),
            ),
          );
        }
        
        if (authSnapshot.hasData) {
          return RoleBasedScreen(user: authSnapshot.data!);
        }
        
        return const LoginScreen();
      },
    );
  }
}


class RoleBasedScreen extends StatelessWidget {
  final User user;
  const RoleBasedScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.red),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data!.exists) {
          var data = snapshot.data!.data() as Map<String, dynamic>;
          String role = data['role'] ?? '';

          if (role == 'staff') {
            return const StaffRosterScreen();
          } else if (role == 'organizer') {
            return const OrganizerScreen();
          } else if (role == 'donor') {
            return const DonorMainScreen();
          }
        }

        return const LoginScreen();
      },
    );
  }
}