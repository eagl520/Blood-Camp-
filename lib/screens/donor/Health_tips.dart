import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'camp_home.dart';
import 'donor_home_screen.dart';
import 'History_screen.dart';


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
const Color kDivider = Color(0xFFF0F0F5);
const double kRadius = 22;
const double kRadiusSm = 14;

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  bool _isLoading = true;
  String? _lastDonationDateStr;
  String? _nextEligibleDateStr;
  bool _isEligible = false;

  @override
  void initState() {
    super.initState();
    _fetchLastDonationAndStartTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  
  
  
  Future<void> _fetchLastDonationAndStartTimer() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String? userId = user?.uid;

      if (userId == null) {
        setState(() => _isLoading = false);
        return;
      }

      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      
      final validStatuses = {
        
        'refreshment',
        
      };

      final matched = querySnapshot.docs.where((doc) {
        final data = doc.data();
        final status = (data['status'] ?? '').toString().toLowerCase().trim();
        return validStatuses.contains(status);
      }).toList();

      if (matched.isNotEmpty) {
        
        final data = matched.first.data();
        var rawDate = data['date'];

        DateTime? lastDonationDate;
        if (rawDate != null) {
          if (rawDate is Timestamp) {
            lastDonationDate = rawDate.toDate();
          } else if (rawDate is String && rawDate.isNotEmpty) {
            
            lastDonationDate = DateTime.tryParse(rawDate) ?? _parseDateDDMMYYYY(rawDate);
          }
        }

        if (lastDonationDate != null) {
          DateTime nextEligibleDate = lastDonationDate.add(const Duration(days: 56));

          setState(() {
            _lastDonationDateStr = lastDonationDate.toString().substring(0, 10);
            _nextEligibleDateStr = nextEligibleDate.toString().substring(0, 10);
          });

          _startCountdown(nextEligibleDate);
        }
      }
    } catch (e) {
      debugPrint("Error fetching donation history: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  
  DateTime? _parseDateDDMMYYYY(String s) {
    try {
      final parts = s.split('/');
      if (parts.length == 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return null;
  }

  void _startCountdown(DateTime targetDate) {
    
    final initialDiff = targetDate.difference(DateTime.now());
    if (initialDiff.isNegative) {
      setState(() {
        _isEligible = true;
        _timeLeft = Duration.zero;
      });
      return; 
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final difference = targetDate.difference(now);

      if (difference.isNegative) {
        setState(() {
          _isEligible = true;
          _timeLeft = Duration.zero;
        });
        timer.cancel();
      } else {
        setState(() {
          _isEligible = false;
          _timeLeft = difference;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int days = _timeLeft.inDays;
    int hours = _timeLeft.inHours % 24;
    int minutes = _timeLeft.inMinutes % 60;
    int seconds = _timeLeft.inSeconds % 60;

    return Scaffold(
      backgroundColor: kSurface,
      extendBody: true,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Health & Recovery',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.2),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
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
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            _buildSectionHeader(
              icon: Icons.water_drop_rounded,
              title: "Donation Status",
            ),
            const SizedBox(height: 14),

            
            _buildDonationCard(days, hours, minutes, seconds),

            const SizedBox(height: 28),

            
            _buildSectionHeader(
              icon: Icons.lightbulb_rounded,
              title: "Health Tips",
            ),
            const SizedBox(height: 14),

            _buildHealthTipCard(
              icon: Icons.restaurant_menu_rounded,
              title: 'Eat well beforehand',
              description: 'Have a healthy, iron-rich meal 3 hours before donating. Avoid fatty foods on donation day.',
            ),
            const SizedBox(height: 12),
            _buildHealthTipCard(
              icon: Icons.water_drop_rounded,
              title: 'Hydrate generously',
              description: 'Drink an extra 500ml of water before and after donating to help your body recover fluid volume.',
            ),
            const SizedBox(height: 12),
            _buildHealthTipCard(
              icon: Icons.nightlight_round,
              title: 'Rest afterward',
              description: 'Avoid strenuous exercise or heavy lifting for 24 hours. Keep the bandage on for at least 4-6 hours.',
            ),
            const SizedBox(height: 12),
            _buildHealthTipCard(
              icon: Icons.fastfood_rounded,
              title: 'Refuel with a snack',
              description: 'Enjoy the refreshments offered at the camp — a snack and juice help stabilize your blood sugar.',
            ),
            const SizedBox(height: 12),
            _buildHealthTipCard(
              icon: Icons.local_cafe_rounded,
              title: 'Avoid caffeine & smoking',
              description: 'Skip tea, coffee, and smoking for a few hours after donating. They can dehydrate you and slow down recovery.',
            ),
            const SizedBox(height: 12),
            _buildHealthTipCard(
              icon: Icons.bedtime_rounded,
              title: 'Get proper rest',
              description: 'Aim for 7–8 hours of sleep tonight. Your body produces new blood cells best during deep rest.',
            ),
            const SizedBox(height: 12),
            _buildHealthTipCard(
              icon: Icons.spa_rounded,
              title: 'Stay calm & thankful',
              description: 'Donating blood is an act of charity. Relax, offer a prayer of gratitude, and let your body recover peacefully.',
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kDivider, width: 1),
        ),
        child: SafeArea(
          top: false,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BottomNavigationBar(
              currentIndex: 3,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: kPrimary,
              unselectedItemColor: kTextHint,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
              backgroundColor: Colors.transparent,
              elevation: 0,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const DonorMainScreen()),
                  );
                } else if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const CampsFilterScreen()),
                  );
                } else if (index == 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const BookingsScreen()),
                  );
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Camps'),
                BottomNavigationBarItem(icon: Icon(Icons.bookmark_rounded), label: 'Bookings'),
                BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Health'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  
  
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: kPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        Icon(icon, size: 18, color: kPrimary.withOpacity(0.4)),
      ],
    );
  }

  
  
  
  Widget _buildDonationCard(int days, int hours, int minutes, int seconds) {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        decoration: _cardDecoration(),
        child: const Center(
          child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5),
        ),
      );
    }

    if (_lastDonationDateStr == null) {
      return Container(
        width: double.infinity,
        decoration: _cardDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [kSuccessLight, kSuccessLight.withOpacity(0.5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(kRadiusSm),
                  border: Border.all(color: kSuccess.withOpacity(0.25), width: 1.2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: kSuccess, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Ready to Donate",
                      style: TextStyle(
                        color: Color(0xFF1B5E20),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(kRadiusSm),
                  border: Border.all(color: kDivider, width: 1),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: kSuccessLight,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.check_rounded, size: 14, color: kSuccess),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "No previous donations",
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: kTextPrimary,
                              letterSpacing: -0.1,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            "You're eligible to donate. Book your first camp slot now.",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: kTextSecondary,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildDateBlock(
                    label: "Last Donation",
                    date: _lastDonationDateStr!,
                    icon: Icons.history_rounded,
                    color: kTextSecondary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: kDivider,
                ),
                Expanded(
                  child: _buildDateBlock(
                    label: "Next Eligible",
                    date: _nextEligibleDateStr!,
                    icon: Icons.event_available_rounded,
                    color: kPrimary,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),

          
          Container(
            height: 1,
            color: kDivider,
          ),

          
          Padding(
            padding: const EdgeInsets.all(20),
            child: _isEligible
                ? _buildEligibleWithDates()
                : _buildTimerSection(days, hours, minutes, seconds),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildEligibleWithDates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kSuccessLight, kSuccessLight.withOpacity(0.5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(kRadiusSm),
            border: Border.all(color: kSuccess.withOpacity(0.25), width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: kSuccess, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                "Ready to Donate",
                style: TextStyle(
                  color: Color(0xFF1B5E20),
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(kRadiusSm),
            border: Border.all(color: kDivider, width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: kSuccessLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.check_rounded, size: 14, color: kSuccess),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your 56-day cool-down is complete",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      "Last donated on $_lastDonationDateStr — you can donate again today.",
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: kTextSecondary,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  
  
  
  Widget _buildTimerSection(int days, int hours, int minutes, int seconds) {
    return Column(
      children: [
        const Text(
          "Time remaining for next donation",
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: kTextSecondary, letterSpacing: 0.3),
        ),
        const SizedBox(height: 14),
        _buildTimerRow(days, hours, minutes, seconds),
      ],
    );
  }

  Widget _buildDateBlock({
    required String label,
    required String date,
    required IconData icon,
    required Color color,
    bool alignEnd = false,
  }) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: kTextHint, fontWeight: FontWeight.w700, letterSpacing: 0.3),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          date,
          style: TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            color: alignEnd ? kPrimary : kTextPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerRow(int days, int hours, int minutes, int seconds) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeUnit("$days", "DAYS"),
        _buildSeparator(),
        _buildTimeUnit("$hours", "HRS"),
        _buildSeparator(),
        _buildTimeUnit("$minutes", "MIN"),
        _buildSeparator(),
        _buildTimeUnit("$seconds", "SEC"),
      ],
    );
  }

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Container(
        width: 3,
        height: 3,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: kPrimary.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: kPrimaryLight.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: kPrimaryLight, width: 1),
          ),
          child: Text(
            value.padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: kPrimaryDark,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: kTextHint, fontWeight: FontWeight.w700, letterSpacing: 1),
        ),
      ],
    );
  }

  
  
  
  Widget _buildHealthTipCard({required IconData icon, required String title, required String description}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(kRadiusSm),
        border: Border.all(color: kDivider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: kPrimaryLight.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: kPrimary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: kTextPrimary, letterSpacing: -0.2),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: const TextStyle(fontSize: 12.5, color: kTextSecondary, height: 1.45, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: kCardBackground,
      borderRadius: BorderRadius.circular(kRadius),
      border: Border.all(color: kDivider, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}