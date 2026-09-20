import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


const Color kPrimary = Color(0xFFE53935);
const Color kPrimaryDark = Color(0xFFB71C1C);
const Color kPrimaryLight = Color(0xFFFFCDD2);
const Color kSuccess = Color(0xFF2E7D32);
const Color kSuccessLight = Color(0xFFE8F5E9);
const Color kWarning = Color(0xFFEF6C00);
const Color kSurface = Color(0xFFF5F6F8);
const Color kCardBackground = Colors.white;
const Color kTextPrimary = Color(0xFF1A1A2E);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kTextHint = Color(0xFF9CA3AF);
const Color kFieldFill = Color(0xFFF7F8FA);
const Color kFieldBorder = Color(0xFFE5E7EB);
const Color kDivider = Color(0xFFF0F0F5);
const double kRadius = 22;
const double kRadiusSm = 14;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();

  String? _selectedBloodGroup;
  String? _selectedGender;

  bool _isLoading = true;
  bool _isSaving = false;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  
  
  
  Future<void> _fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';

      
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        _nameController.text = data['name'] ?? data['fullName'] ?? _nameController.text;
        _emailController.text = data['email'] ?? _emailController.text;
        _phoneController.text = data['phone']?.toString() ?? '';
        _ageController.text = data['age']?.toString() ?? '';

        final String? bg = data['bloodGroup'];
        if (bg != null && _bloodGroups.contains(bg)) {
          _selectedBloodGroup = bg;
        }

        final String? g = data['gender'];
        if (g != null && _genders.contains(g)) {
          _selectedGender = g;
        }
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  
  
  
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw 'No user logged in';
      }

      final updateData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'age': _ageController.text.trim(),
        'bloodGroup': _selectedBloodGroup ?? 'Not Specified',
        'gender': _selectedGender ?? 'Not Specified',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updateData);

      
      if (_nameController.text.trim() != user.displayName) {
        await user.updateDisplayName(_nameController.text.trim());
      }

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: kSuccess,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: kPrimary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.edit_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Edit Profile',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.2),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryDark, kPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    _buildAvatarHeader(),
                    const SizedBox(height: 28),

                    
                    _buildSectionHeader(
                      icon: Icons.lock_outline_rounded,
                      title: "Account Info",
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Name and email cannot be changed here.",
                      style: TextStyle(fontSize: 11.5, color: kTextHint, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 14),

                    _buildFieldLabel("Full Name"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _nameController,
                      icon: Icons.person_rounded,
                      hint: "Your name",
                      enabled: true,
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel("Email Address"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      icon: Icons.email_rounded,
                      hint: "your@email.com",
                      enabled: false,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 28),

                    
                    _buildSectionHeader(
                      icon: Icons.person_outline_rounded,
                      title: "Personal Info",
                    ),
                    const SizedBox(height: 14),

                    _buildFieldLabel("Phone Number"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _phoneController,
                      icon: Icons.phone_rounded,
                      hint: "Enter your phone number",
                      keyboardType: TextInputType.phone,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter phone number';
                        if (v.trim().length < 10) return 'Enter a valid phone number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel("Age"),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _ageController,
                      icon: Icons.cake_rounded,
                      hint: "Enter your age",
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Please enter age';
                        final int? age = int.tryParse(v.trim());
                        if (age == null) return 'Enter a valid number';
                        if (age < 18 || age > 65) return 'Age must be between 18 and 65';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel("Blood Group"),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedBloodGroup,
                      icon: Icons.bloodtype_rounded,
                      iconColor: kPrimary,
                      hint: "Select blood group",
                      items: _bloodGroups,
                      onChanged: (val) => setState(() => _selectedBloodGroup = val),
                      validator: (v) => v == null ? 'Please select blood group' : null,
                    ),
                    const SizedBox(height: 16),

                    _buildFieldLabel("Gender"),
                    const SizedBox(height: 8),
                    _buildDropdown(
                      value: _selectedGender,
                      icon: Icons.wc_rounded,
                      hint: "Select gender",
                      items: _genders,
                      onChanged: (val) => setState(() => _selectedGender = val),
                      validator: (v) => v == null ? 'Please select gender' : null,
                    ),
                    const SizedBox(height: 32),

                    
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveChanges,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: kPrimary.withOpacity(0.35),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 10),
                                  Text(
                                    'Save Changes',
                                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  
  
  
  Widget _buildAvatarHeader() {
    final String initial = _nameController.text.isNotEmpty
        ? _nameController.text.trim()[0].toUpperCase()
        : '?';

    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [kPrimaryDark, kPrimary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 42,
                backgroundColor: kPrimaryLight,
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    color: kPrimaryDark,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text.isNotEmpty ? _nameController.text : 'Your Name',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            _emailController.text.isNotEmpty ? _emailController.text : 'your@email.com',
            style: const TextStyle(
              fontSize: 13,
              color: kTextSecondary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: kPrimary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: kPrimary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(height: 1, color: kDivider),
        ),
      ],
    );
  }

  
  
  
  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: kTextPrimary,
        letterSpacing: 0.1,
      ),
    );
  }

  
  
  
  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    Color iconColor = kTextHint,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      validator: validator,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: enabled ? kTextPrimary : kTextHint,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: kTextHint, fontWeight: FontWeight.w500),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, size: 20, color: enabled ? iconColor : kTextHint),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
        
        suffixIcon: enabled
            ? null
            : const Padding(
                padding: EdgeInsets.only(right: 14),
                child: Icon(Icons.lock_rounded, size: 16, color: kTextHint),
              ),
        filled: true,
        fillColor: enabled ? kFieldFill : kSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kFieldBorder, width: 1.2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kDivider, width: 1.2),
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

  
  
  
  Widget _buildDropdown({
    required String? value,
    required IconData icon,
    Color iconColor = kTextHint,
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: kTextHint, fontWeight: FontWeight.w500),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
        filled: true,
        fillColor: kFieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary),
          ),
        );
      }).toList(),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTextHint, size: 22),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(kRadiusSm),
    );
  }
}