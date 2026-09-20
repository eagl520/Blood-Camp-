import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'camp_home.dart';
import 'camp_detail_screen.dart';
import 'History_screen.dart';
import './profile.screen.dart';
import 'Health_tips.dart';


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
const double kRadius = 24;
const double kRadiusSm = 16;

class DonorMainScreen extends StatefulWidget {
  const DonorMainScreen({super.key});

  @override
  State<DonorMainScreen> createState() => _DonorMainScreenState();
}

class _DonorMainScreenState extends State<DonorMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      extendBody: true,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.water_drop_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              ' Blood Camp',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: 0.2,
              ),
            ),
          ],
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
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
        actions: [
          
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              showProfileMenu(context);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _currentIndex == 0
          ? const DonorHomeBody()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.construction_rounded, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Screen $_currentIndex Under Development',
                      style: TextStyle(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.w600)),
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
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: kPrimary,
              unselectedItemColor: kTextHint,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
              backgroundColor: Colors.transparent,
              elevation: 0,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });

                switch (index) {
                  case 0:
                    break;
                  case 1:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const CampsFilterScreen()),
                    );
                    break;
                  case 2:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const BookingsScreen()),
                    );
                    break;
                  case 3:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HealthScreen()),
                    );
                    break;
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
}

class DonorHomeBody extends StatefulWidget {
  const DonorHomeBody({super.key});

  @override
  State<DonorHomeBody> createState() => _DonorHomeBodyState();
}

class _DonorHomeBodyState extends State<DonorHomeBody> {
  bool _isLoading = true;
  String? _lastDonationDateStr;
  String? _nextEligibleDateStr;
  DateTime? _targetDate;
  bool _timerEligible = false;

  
  String? _userBloodGroup;

  @override
  void initState() {
    super.initState();
    _fetchLastDonation();
    _fetchUserBloodGroup();   
  }

  
  
  
  Future<void> _fetchUserBloodGroup() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data() as Map<String, dynamic>;
        final String? bg = data['bloodGroup']?.toString();
        if (bg != null && bg.isNotEmpty && bg != 'Not Specified') {
          setState(() => _userBloodGroup = bg);
        }
      }
    } catch (e) {
      debugPrint('Error fetching user blood group: $e');
    }
  }

  Future<void> _fetchLastDonation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      String? userId = user?.uid;

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

          bool initiallyEligible = DateTime.now().isAfter(nextEligibleDate);

          setState(() {
            _lastDonationDateStr = lastDonationDate.toString().substring(0, 10);
            _nextEligibleDateStr = nextEligibleDate.toString().substring(0, 10);
            _targetDate = nextEligibleDate;
            _timerEligible = initiallyEligible;
          });
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

  @override
  Widget build(BuildContext context) {
    final bool isEligibleCard = _lastDonationDateStr == null || _timerEligible;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          _buildHeroCard(isEligibleCard),
          const SizedBox(height: 24),

          
          _buildQuickStats(),
          const SizedBox(height: 28),

          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Nearby Camps",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Find a camp near you",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: kTextHint,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CampsFilterScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: kPrimaryLight.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "See All",
                          style: TextStyle(color: kPrimaryDark, fontWeight: FontWeight.w700, fontSize: 12.5),
                        ),
                        const SizedBox(width: 3),
                        const Icon(Icons.arrow_forward_rounded, color: kPrimaryDark, size: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('camps').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60.0),
                    child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return _buildEmptyState();
              }

              final camps = snapshot.data!.docs;

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: camps.length,
                itemBuilder: (context, index) {
                  final campDoc = camps[index];
                  final camp = campDoc.data() as Map<String, dynamic>;
                  final campId = campDoc.id;
                  return _buildCampCard(camp, campId);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildHeroCard(bool isEligible) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEligible
              ? [const Color(0xFF2E7D32), const Color(0xFF43A047)]
              : [kPrimaryDark, kPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kRadius),
        boxShadow: [
          BoxShadow(
            color: (isEligible ? kSuccess : kPrimary).withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
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
            bottom: -50,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: _isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isEligible ? Icons.check_circle_rounded : Icons.timer_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isEligible ? "ELIGIBLE" : "COOL-DOWN",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _lastDonationDateStr == null
                            ? "Ready to Donate?"
                            : (isEligible ? "You're Ready!" : "Rest & Recover"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _lastDonationDateStr == null
                            ? "No previous donations found. Book your first camp slot now."
                            : (isEligible
                                ? "Your body has recovered. You can donate blood today."
                                : "Last donation: $_lastDonationDateStr"),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13.5,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_targetDate != null) ...[
                        const SizedBox(height: 22),
                        _CountdownTimerWidget(
                          targetDate: _targetDate!,
                          onEligibleChanged: (eligible) {
                            if (mounted && _timerEligible != eligible) {
                              setState(() {
                                _timerEligible = eligible;
                              });
                            }
                          },
                        ),
                      ] else ...[
                        const SizedBox(height: 22),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 10),
                              Text(
                                "Ready to Donate",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.bloodtype_rounded,
            label: "Blood Type",
            
            value: _userBloodGroup ?? "—",
            color: kPrimary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.calendar_today_rounded,
            label: "Last Donated",
            value: _lastDonationDateStr ?? "—",
            color: kWarning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(kRadiusSm),
        border: Border.all(color: kDivider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: kTextHint,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              color: kTextPrimary,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  
  
  
  Map<String, dynamic> _getCampStatus(Map<String, dynamic> camp) {
    DateTime? start;
    DateTime? end;

    final dynamic startTs = camp['startDateTime'] ?? camp['dateTime'];
    final dynamic endTs = camp['endDateTime'];

    if (startTs is Timestamp) {
      start = startTs.toDate();
    }
    if (endTs is Timestamp) {
      end = endTs.toDate();
    }

    if (start == null) {
      final String s = (camp['startDate'] ?? camp['date'] ?? '').toString();
      start = _parseDate(s);
    }
    if (end == null) {
      final String e = (camp['endDate'] ?? '').toString();
      end = _parseDate(e);
    }

    end ??= start;

    if (start == null && end == null) {
      return {
        'label': 'Active',
        'color': Colors.green[700]!,
      };
    }

    final DateTime today = DateTime.now();
    final DateTime todayOnly = DateTime(today.year, today.month, today.day);
    final DateTime startOnly = start != null ? DateTime(start.year, start.month, start.day) : todayOnly;
    final DateTime endOnly = end != null ? DateTime(end.year, end.month, end.day) : startOnly;

    if (todayOnly.isBefore(startOnly)) {
      return {
        'label': 'Upcoming',
        'color': Colors.orange[800]!,
      };
    } else if (todayOnly.isAfter(endOnly)) {
      return {
        'label': 'Ended',
        'color': Colors.grey[600]!,
      };
    } else {
      return {
        'label': 'Active',
        'color': Colors.green[700]!,
      };
    }
  }

  DateTime? _parseDate(String s) {
    if (s.isEmpty) return null;
    try {
      final parts = s.split('/');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
      return DateTime.tryParse(s);
    } catch (_) {
      return DateTime.tryParse(s);
    }
  }

  
  
  
  Widget _buildCampCard(Map<String, dynamic> camp, String campId) {
    final String campName = camp['name'] ?? 'Blood Camp';
    final String description = camp['instructions'] ?? 'No description provided for this camp.';
    final String city = camp['city'] ?? 'Unknown City';
    final String? imageUrl = camp['imageUrl'] ?? camp['image'];
    final String seatsLeft = camp['seatsLeft']?.toString() ?? '0';
    final String seats = camp['seats']?.toString() ?? '0';

    final status = _getCampStatus(camp);
    final String statusLabel = status['label'] as String;
    final Color statusColor = status['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
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
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(kRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CampDetailScreen(camp: camp, campId: campId),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadius)),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 160,
                              color: kPrimaryLight.withOpacity(0.25),
                              child: const Center(
                                child: Icon(Icons.broken_image_rounded, color: kTextHint, size: 40),
                              ),
                            ),
                          )
                        : Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [kPrimaryLight.withOpacity(0.7), kPrimaryLight.withOpacity(0.3)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(Icons.local_hospital_rounded, size: 48, color: kPrimary),
                          ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadius)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on_rounded, size: 13, color: kPrimary),
                          const SizedBox(width: 4),
                          Text(
                            city,
                            style: const TextStyle(
                              color: kTextPrimary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            statusLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campName,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(color: kTextSecondary, fontSize: 12.5, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: kSuccessLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.event_seat_rounded, size: 13, color: kSuccess),
                              const SizedBox(width: 4),
                              Text(
                                "$seats / $seatsLeft ",
                                style: const TextStyle(
                                  color: kSuccess,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kPrimary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CampDetailScreen(camp: camp, campId: campId),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Text('Book', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, size: 15),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  
  
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 24),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: kDivider, width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: kPrimaryLight.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_busy_rounded, size: 40, color: kPrimary.withOpacity(0.5)),
          ),
          const SizedBox(height: 18),
          const Text(
            "No Camps Available",
            style: TextStyle(color: kTextPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            "Check back later for new blood donation camps",
            textAlign: TextAlign.center,
            style: TextStyle(color: kTextHint, fontSize: 13),
          ),
        ],
      ),
    );
  }
}


class _CountdownTimerWidget extends StatefulWidget {
  final DateTime targetDate;
  final ValueChanged<bool> onEligibleChanged;

  const _CountdownTimerWidget({
    required this.targetDate,
    required this.onEligibleChanged,
  });

  @override
  State<_CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<_CountdownTimerWidget> {
  Timer? _timer;
  Duration _timeLeft = Duration.zero;
  late bool _isEligible;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final difference = widget.targetDate.difference(now);

    _isEligible = difference.isNegative;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onEligibleChanged(_isEligible);
      }
    });

    _startCountdown();
  }

  void _updateParent(bool eligible) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _isEligible != eligible) {
        widget.onEligibleChanged(eligible);
      }
    });
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final nowTime = DateTime.now();
      final diff = widget.targetDate.difference(nowTime);

      if (diff.isNegative) {
        if (mounted) {
          setState(() {
            _isEligible = true;
            _timeLeft = Duration.zero;
          });
          _updateParent(true);
        }
        timer.cancel();
      } else {
        if (mounted) {
          setState(() {
            _isEligible = false;
            _timeLeft = diff;
          });
          _updateParent(false);
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEligible) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
        ),
        child: const Row(
          children: [
            Icon(Icons.verified_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              "Ready to Donate",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    int days = _timeLeft.inDays;
    int hours = _timeLeft.inHours % 24;
    int minutes = _timeLeft.inMinutes % 60;
    int seconds = _timeLeft.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeUnit("$days", "DAYS"),
          _buildDot(),
          _buildTimeUnit("$hours", "HRS"),
          _buildDot(),
          _buildTimeUnit("$minutes", "MIN"),
          _buildDot(),
          _buildTimeUnit("$seconds", "SEC"),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildTimeUnit(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value.padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}