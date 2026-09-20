import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './signup.dart';
import '../screens/organizer/organizer_home_screen.dart';
import '../screens/staff/staff_home_screen.dart';
import '../screens/donor/donor_home_screen.dart';


const Color kPrimary = Color(0xFFE53935);
const Color kPrimaryDark = Color(0xFFB71C1C);
const Color kPrimaryLight = Color(0xFFFFCDD2);
const Color kSuccess = Color(0xFF2E7D32);
const Color kSurface = Color(0xFFF5F6F8);
const Color kCardBackground = Colors.white;
const Color kTextPrimary = Color(0xFF1A1A2E);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kTextHint = Color(0xFF9CA3AF);
const Color kFieldFill = Color(0xFFF7F8FA);
const Color kFieldBorder = Color(0xFFE5E7EB);
const Color kDivider = Color(0xFFF0F0F5);
const double kRadius = 28;
const double kRadiusSm = 14;

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final emailText = _emailController.text.trim();

        
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailText,
          password: _passwordController.text.trim(),
        );

        String uid = userCredential.user!.uid;

        
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (userDoc.exists) {
          String role = userDoc.data()?['role'] ?? 'donor';

          if (mounted) {
            if (role == 'organizer') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const OrganizerScreen()),
              );
            } else if (role == 'staff') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const StaffRosterScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DonorMainScreen()),
              );
            }
          }
        } else {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DonorMainScreen()),
            );
          }
        }

      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Login failed!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: Stack(
        children: [
          
          _buildHeroBackground(),

          
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  
                  _buildHeroContent(),

                  
                  _buildFormCard(),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildHeroBackground() {
    return Container(
      height: 360,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryDark, kPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Stack(
        children: [
          
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Positioned(
            top: 40,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Positioned(
            bottom: 40,
            right: 40,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildHeroContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                ),
                child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Blood Camp',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 36),

          
          const Text(
            'Welcome\nBack 👋',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to continue saving lives.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildFormCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(kRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: kPrimary.withOpacity(0.05),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            const Text(
              'Sign In',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Enter your credentials to access your account',
              style: TextStyle(
                fontSize: 12.5,
                color: kTextHint,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 24),

            
            _buildFieldLabel("Email Address"),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _emailController,
              icon: Icons.email_rounded,
              hint: "you@example.com",
              keyboardType: TextInputType.emailAddress,
              validator: (value) => value == null || !value.contains('@')
                  ? 'Please enter a valid email'
                  : null,
            ),

            const SizedBox(height: 18),

            
            _buildFieldLabel("Password"),
            const SizedBox(height: 8),
            _buildPasswordField(),

            const SizedBox(height: 12),

            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            

            const SizedBox(height: 16),

            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: kPrimary.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            
            Row(
              children: [
                Expanded(child: Container(height: 1, color: kDivider)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'New here?',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: kTextHint,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                Expanded(child: Container(height: 1, color: kDivider)),
              ],
            ),

            const SizedBox(height: 16),

            
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SignupScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: BorderSide(color: kPrimary.withOpacity(0.4), width: 1.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_rounded, size: 18, color: kPrimary),
                    SizedBox(width: 8),
                    Text(
                      'Create Account',
                      style: TextStyle(fontSize: 14.5, color: kPrimary, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  
  
  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w700,
        color: kTextPrimary,
        letterSpacing: 0.1,
      ),
    );
  }

  
  
  
  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: kTextHint, fontWeight: FontWeight.w500),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, size: 20, color: kTextHint),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
        filled: true,
        fillColor: kFieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kFieldBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kPrimary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kPrimary, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kPrimary, width: 1.6),
        ),
      ),
    );
  }

  
  
  
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary),
      decoration: InputDecoration(
        hintText: "Enter your password",
        hintStyle: const TextStyle(fontSize: 14, color: kTextHint, fontWeight: FontWeight.w500),
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 14, right: 10),
          child: Icon(Icons.lock_rounded, size: 20, color: kTextHint),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 6),
          child: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
              color: kTextHint,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        filled: true,
        fillColor: kFieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kFieldBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kPrimary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kPrimary, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kPrimary, width: 1.6),
        ),
      ),
      validator: (value) => value == null || value.length < 6
          ? 'Password must be at least 6 characters'
          : null,
    );
  }
}