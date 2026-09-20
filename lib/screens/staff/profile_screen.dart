import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'End_of_Shift.dart';
import 'WalkIn_Booking_Screen.dart';
import '../../Auth/Help&Support_Screen.dart';
import '../../Auth/login_screen.dart';



const Color kPrimary = Color(0xFFE53935);
const Color kPrimaryDark = Color(0xFFB71C1C);
const Color kPrimaryLight = Color(0xFFFFCDD2);
const Color kSuccess = Color(0xFF2E7D32);
const Color kSuccessLight = Color(0xFFE8F5E9);
const Color kSurface = Color(0xFFF5F6F8);
const Color kCardBackground = Colors.white;
const Color kTextPrimary = Color(0xFF1A1A2E);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kTextHint = Color(0xFF9CA3AF);
const Color kDivider = Color(0xFFF0F0F5);
const double kRadius = 22;
const double kRadiusSm = 14;

void showProfileMenu(BuildContext context) {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final double screenHeight = MediaQuery.of(context).size.height;
  const double topMargin = 80.0;

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Profile',
    barrierColor: Colors.black.withOpacity(0.55),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: topMargin),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.82,
              height: screenHeight - topMargin,
              decoration: const BoxDecoration(
                color: kCardBackground,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(kRadius),
                  bottomRight: Radius.circular(kRadius),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 30,
                    offset: Offset(6, 0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(kRadius),
                  bottomRight: Radius.circular(kRadius),
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      _buildStaffHeader(context, currentUser),

                      
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel("Quick Actions"),
                              _buildMenuItem(
                                context: context,
                                icon: Icons.person_add_alt_1_rounded,
                                title: 'Add Donor',
                                subtitle: 'Register a walk-in donor',
                                iconColor: kPrimary,
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const WalkInBookingScreen(),
                                    ),
                                  );
                                },
                              ),
                              _buildMenuItem(
                                context: context,
                                icon: Icons.assessment_rounded,
                                title: 'Daily Report',
                                subtitle: 'View shift summary',
                                iconColor: kPrimary,
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const EndOfShiftReportScreen(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 12),
                              _buildDivider(),
                              const SizedBox(height: 12),
                              _buildSectionLabel("Support"),
                              _buildMenuItem(
                                context: context,
                                icon: Icons.help_outline_rounded,
                                title: 'Help & Support',
                                subtitle: 'Get help with your account',
                                iconColor: kTextSecondary,
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HelpSupportScreen(),
                                    ),
                                  );
                                },
                              ),
                             
                            ],
                          ),
                        ),
                      ),

                      
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1.0, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}




Widget _buildStaffHeader(BuildContext context, User? currentUser) {
  return Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        colors: [kPrimaryDark, kPrimary],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.only(topRight: Radius.circular(kRadius)),
    ),
    child: Stack(
      children: [
        
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: -20,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'LifeDrop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  Material(
                    color: Colors.white.withOpacity(0.18),
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(7.0),
                        child: Icon(Icons.close_rounded, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'STAFF ACCESS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              
              StreamBuilder<DocumentSnapshot>(
                stream: currentUser != null
                    ? FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .snapshots()
                    : null,
                builder: (context, snapshot) {
                  String displayName = currentUser?.displayName ?? 'Staff User';
                  String displayEmail = currentUser?.email ?? 'No Email';

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final data = snapshot.data!.data() as Map<String, dynamic>;
                    displayName = data['name'] ?? data['fullName'] ?? displayName;
                    displayEmail = data['email'] ?? displayEmail;
                  }

                  return Row(
                    children: [
                      
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 26,
                            backgroundColor: kPrimaryLight,
                            child: Icon(Icons.person_rounded, size: 30, color: kPrimaryDark),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayEmail,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}




Widget _buildSectionLabel(String label) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
    child: Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        color: kTextHint,
        letterSpacing: 1.4,
      ),
    ),
  );
}




Widget _buildMenuItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required Color iconColor,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),

              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: kTextHint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              
              Icon(Icons.chevron_right_rounded, color: kTextHint, size: 20),
            ],
          ),
        ),
      ),
    ),
  );
}




Widget _buildDivider() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Container(
      height: 1,
      color: kDivider,
    ),
  );
}




Widget _buildLogoutButton(BuildContext context) {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
    decoration: const BoxDecoration(
      color: kCardBackground,
      border: Border(
        top: BorderSide(color: kDivider, width: 1),
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
  try {
    await FirebaseAuth.instance.signOut(); 

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout Error: $e')),
      );
    }
  }
},
        borderRadius: BorderRadius.circular(kRadiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(kRadiusSm),
            border: Border.all(color: kPrimary.withOpacity(0.2), width: 1.2),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimary.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(Icons.logout_rounded, color: kPrimary, size: 20),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: kPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sign out of your account',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: kTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: kPrimary, size: 18),
            ],
          ),
        ),
      ),
    ),
  );
}