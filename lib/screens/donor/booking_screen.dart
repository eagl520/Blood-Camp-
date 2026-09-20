import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


const Color kPrimary = Color(0xFFE53935);
const Color kPrimaryDark = Color(0xFFB71C1C);
const Color kPrimaryLight = Color(0xFFFFCDD2);
const Color kWarning = Color(0xFFEF6C00);
const Color kSuccess = Color(0xFF2E7D32);
const Color kSurface = Color(0xFFF5F6F8);
const Color kCardBackground = Colors.white;
const Color kTextPrimary = Color(0xFF1A1A2E);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kTextHint = Color(0xFF9CA3AF);
const Color kFieldFill = Color(0xFFF7F8FA);
const Color kFieldBorder = Color(0xFFE5E7EB);
const Color kFieldFocusBorder = kPrimary;
const Color kDivider = Color(0xFFF0F0F5);
const double kRadius = 22;
const double kRadiusSm = 14;

class CampBookingScreen extends StatefulWidget {
  final String campName;
  final String? campId;
  final DateTime? campStartDate;
  final DateTime? campEndDate;

  const CampBookingScreen({
    super.key,
    required this.campName,
    this.campId,
    this.campStartDate,
    this.campEndDate,
  });

  @override
  State<CampBookingScreen> createState() => _CampBookingScreenState();
}

class _CampBookingScreenState extends State<CampBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _campNameController;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedSlot;
  String? _selectedBloodGroup;
  bool _isLoading = false;

  final List<String> _slotList = [
    '09:00 AM - 10:00 AM',
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '01:00 PM - 02:00 PM',
    '02:00 PM - 03:00 PM',
  ];

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  @override
  void initState() {
    super.initState();
    _campNameController = TextEditingController(text: widget.campName);
  }

  @override
  void dispose() {
    _campNameController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  
  
  
  ({DateTime first, DateTime last, String helper}) _computeAllowedRange() {
    final DateTime today = DateTime.now();
    final DateTime todayOnly = DateTime(today.year, today.month, today.day);

    
    final DateTime tomorrowOnly = todayOnly.add(const Duration(days: 1));

    final DateTime? campStart = widget.campStartDate != null
        ? DateTime(widget.campStartDate!.year, widget.campStartDate!.month, widget.campStartDate!.day)
        : null;
    final DateTime? campEnd = widget.campEndDate != null
        ? DateTime(widget.campEndDate!.year, widget.campEndDate!.month, widget.campEndDate!.day)
        : null;

    if (campStart != null && campEnd != null) {
      
      
      
      final DateTime first = campStart.isAfter(tomorrowOnly) ? campStart : tomorrowOnly;
      final DateTime last = campEnd;

      String helper;
      if (last.isBefore(first)) {
        helper = "This camp has ended or is not available for booking";
      } else if (todayOnly.isBefore(campStart)) {
        helper = "Available: ${_fmt(campStart)} → ${_fmt(campEnd)}";
      } else {
        helper = "Available: tomorrow → ${_fmt(campEnd)}";
      }
      return (first: first, last: last, helper: helper);
    }

    
    return (
      first: tomorrowOnly,
      last: tomorrowOnly.add(const Duration(days: 365)),
      helper: "You can book from tomorrow onwards",
    );
  }

  String _fmt(DateTime d) =>
      "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  Future<void> _selectDate(BuildContext context) async {
    final range = _computeAllowedRange();

    
    if (range.last.isBefore(range.first)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This camp is not available for booking.')),
      );
      return;
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: range.first,   
      firstDate: range.first,     
      lastDate: range.last,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: kPrimaryDark,
              onPrimary: Colors.white,
              onSurface: kTextPrimary,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateController.text =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  
  
  
  Future<void> _submitBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a booking date')),
      );
      return;
    }
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a booking slot')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      String? userId = currentUser?.uid;

      
      if (widget.campId != null && widget.campId!.isNotEmpty) {
        final DocumentSnapshot campSnap = await FirebaseFirestore.instance
            .collection('camps')
            .doc(widget.campId!)
            .get();

        if (campSnap.exists) {
          final data = campSnap.data() as Map<String, dynamic>? ?? {};

          final int totalSeats = (data['seats'] is int)
              ? data['seats'] as int
              : int.tryParse(data['seats']?.toString() ?? '0') ?? 0;

          final int leftSeats = (data['seatsLeft'] is int)
              ? data['seatsLeft'] as int
              : int.tryParse(data['seatsLeft']?.toString() ?? '0') ?? 0;

          if (totalSeats > 0 && leftSeats >= totalSeats) {
            setState(() => _isLoading = false);
            _showSeatsFullPopup();
            return;
          }
        }
      }

      
      QuerySnapshot querySnapshot;
      if (userId != null) {
        querySnapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .where('userId', isEqualTo: userId)
            .where('status', whereIn: ['Refreshment', 'refreshment'])
            .orderBy('date', descending: true)
            .limit(1)
            .get();
      } else {
        querySnapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .where('status', whereIn: ['Refreshment', 'refreshment'])
            .orderBy('date', descending: true)
            .limit(1)
            .get();
      }

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        var rawDate = data['date'];

        DateTime? lastDonationDate;
        if (rawDate != null) {
          if (rawDate is Timestamp) {
            lastDonationDate = rawDate.toDate();
          } else if (rawDate is String && rawDate.isNotEmpty) {
            lastDonationDate = DateTime.tryParse(rawDate);
          }
        }

        if (lastDonationDate != null) {
          DateTime nextEligibleDate = lastDonationDate.add(const Duration(days: 56));

          if (DateTime.now().isBefore(nextEligibleDate)) {
            setState(() => _isLoading = false);

            String nextDateStr = nextEligibleDate.toString().substring(0, 10);

            _showCooldownPopup(nextDateStr);
            return;
          }
        }
      }

      
      if (widget.campId != null && widget.campId!.isNotEmpty) {
        final DocumentReference campRef =
            FirebaseFirestore.instance.collection('camps').doc(widget.campId!);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          DocumentSnapshot campSnap = await transaction.get(campRef);
          if (!campSnap.exists) {
            throw Exception("Camp does not exist!");
          }

          final data = campSnap.data() as Map<String, dynamic>? ?? {};

          final int currentSeatsLeft = (data['seatsLeft'] is int)
              ? data['seatsLeft'] as int
              : int.tryParse(data['seatsLeft']?.toString() ?? '0') ?? 0;

          final int currentBookedSeats = (data['bookedSeats'] is int)
              ? data['bookedSeats'] as int
              : int.tryParse(data['bookedSeats']?.toString() ?? '0') ?? 0;

          transaction.update(campRef, {
            'seatsLeft': currentSeatsLeft + 1,
            'bookedSeats': currentBookedSeats + 1,
          });
        });
      }

      
      await FirebaseFirestore.instance.collection('bookings').add({
        'userId': userId ?? 'anonymous',
        'campId': widget.campId,
        'campName': _campNameController.text.trim(),
        'userName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'age': _ageController.text.trim(),
        'bloodGroup': _selectedBloodGroup ?? 'Not Specified',
        'date': _dateController.text.trim(),
        'slot': _selectedSlot,
        'status': 'Booking',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking saved successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  
  
  
  void _showSeatsFullPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: kPrimaryLight.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_busy_rounded, color: kPrimary, size: 44),
              ),
              const SizedBox(height: 18),
              const Text(
                "Seats Full",
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: kTextPrimary, letterSpacing: -0.3),
              ),
              const SizedBox(height: 10),
              const Text(
                "All seats for this camp have already been booked. Please try another camp or check back later.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: kTextSecondary, height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: kPrimaryLight.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(kRadiusSm),
                  border: Border.all(color: kPrimaryLight, width: 1.2),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 16, color: kPrimaryDark),
                    SizedBox(width: 8),
                    Text(
                      "Booking is currently closed",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: kPrimaryDark,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusSm)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCooldownPopup(String nextAvailableDate) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: kWarning.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.timer_off_rounded, color: kWarning, size: 44),
              ),
              const SizedBox(height: 18),
              const Text(
                "Cool-down Active",
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: kTextPrimary, letterSpacing: -0.3),
              ),
              const SizedBox(height: 10),
              const Text(
                "You are currently in your mandatory cool-down period after your last donation.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: kTextSecondary, height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: kPrimaryLight.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(kRadiusSm),
                  border: Border.all(color: kPrimaryLight, width: 1.2),
                ),
                child: Column(
                  children: [
                    const Text(
                      "NEXT AVAILABLE DATE",
                      style: TextStyle(fontSize: 10.5, color: kPrimaryDark, fontWeight: FontWeight.w800, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nextAvailableDate,
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: kPrimaryDark, letterSpacing: -0.2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Please apply again after this date.",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kTextHint),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 22),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusSm)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Got it", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final range = _computeAllowedRange();

    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Camp Booking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.2),
        ),
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
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoBanner(),
              const SizedBox(height: 24),

              _buildSectionHeader(icon: Icons.local_hospital_rounded, title: "Camp Details"),
              const SizedBox(height: 14),
              _buildFieldLabel("Camp Name"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _campNameController,
                readOnly: true,
                icon: Icons.medical_services_rounded,
                iconColor: kPrimary,
                hint: "Camp Name",
                fillColor: kPrimaryLight.withOpacity(0.15),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(icon: Icons.person_rounded, title: "Personal Information"),
              const SizedBox(height: 14),

              _buildFieldLabel("Full Name"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                icon: Icons.person_rounded,
                hint: "Enter your full name",
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel("Phone Number"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                icon: Icons.phone_rounded,
                hint: "Enter your phone number",
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel("Age"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                icon: Icons.cake_rounded,
                hint: "Enter your age (18 - 60)",
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Please enter age';
                  if (int.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildFieldLabel("Blood Group (Optional)"),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedBloodGroup,
                icon: Icons.bloodtype_rounded,
                hint: "Select blood group",
                items: _bloodGroups,
                onChanged: (val) => setState(() => _selectedBloodGroup = val),
              ),
              const SizedBox(height: 24),

              _buildSectionHeader(icon: Icons.event_available_rounded, title: "Schedule Your Slot"),
              const SizedBox(height: 14),

              _buildFieldLabel("Booking Date"),
              const SizedBox(height: 4),
              Text(
                range.helper,
                style: const TextStyle(fontSize: 11.5, color: kTextHint, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _dateController,
                readOnly: true,
                icon: Icons.calendar_today_rounded,
                hint: "Select a date",
                onTap: () => _selectDate(context),
                suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTextHint, size: 20),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Please select a date' : null,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel("Booking Slot"),
              const SizedBox(height: 8),
              _buildDropdown(
                value: _selectedSlot,
                icon: Icons.access_time_rounded,
                hint: "Select a time slot",
                items: _slotList,
                onChanged: (val) => setState(() => _selectedSlot = val),
                validator: (v) => v == null ? 'Please select a slot' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: kPrimary.withOpacity(0.35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                            Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                            SizedBox(width: 10),
                            Text(
                              'Confirm Booking',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  "By confirming, you agree to our terms & conditions",
                  style: TextStyle(fontSize: 11.5, color: kTextHint, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryLight.withOpacity(0.35), kPrimaryLight.withOpacity(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: kPrimaryLight.withOpacity(0.6), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.water_drop_rounded, color: kPrimary, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reserve Your Slot",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kPrimaryDark, letterSpacing: -0.2),
                ),
                SizedBox(height: 3),
                Text(
                  "Fill in your details to reserve a donation slot.",
                  style: TextStyle(fontSize: 12, color: kTextSecondary, fontWeight: FontWeight.w500, height: 1.35),
                ),
              ],
            ),
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
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kTextPrimary, letterSpacing: -0.2),
        ),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 1, color: kDivider)),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: kTextPrimary, letterSpacing: 0.1),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    required IconData icon,
    Color iconColor = kTextHint,
    String? hint,
    VoidCallback? onTap,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    Color? fillColor,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      onTap: onTap,
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
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor ?? kFieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kFieldBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kFieldFocusBorder, width: 1.6),
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
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kFieldBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kFieldFocusBorder, width: 1.6),
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
          child: Text(item, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTextHint, size: 22),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(kRadiusSm),
    );
  }
}