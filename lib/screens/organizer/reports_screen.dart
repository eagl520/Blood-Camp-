import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import './add_new_staff.dart';
import './organizer_home_screen.dart';


const Color kPrimary = Color(0xFFE53935);
const Color kPrimaryDark = Color(0xFFB71C1C);
const Color kPrimaryLight = Color(0xFFFFCDD2);
const Color kSuccess = Color(0xFF2E7D32);
const Color kSuccessLight = Color(0xFFE8F5E9);
const Color kWarning = Color(0xFFEF6C00);
const Color kWarningLight = Color(0xFFFFF3E0);
const Color kInfo = Color(0xFF1565C0);
const Color kInfoLight = Color(0xFFE3F2FD);
const Color kSurface = Color(0xFFF5F6F8);
const Color kCardBackground = Colors.white;
const Color kTextPrimary = Color(0xFF1A1A2E);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kTextHint = Color(0xFF9CA3AF);
const Color kDivider = Color(0xFFF0F0F5);
const double kRadius = 22;
const double kRadiusSm = 14;

class OrganizerReportScreen extends StatefulWidget {
  const OrganizerReportScreen({super.key});

  @override
  State<OrganizerReportScreen> createState() => _OrganizerReportScreenState();
}

class _OrganizerReportScreenState extends State<OrganizerReportScreen> {
  int _currentIndex = 2;

  bool _isLoading = true;
  int totalCampsThisMonth = 0;
  int unitsCollected = 0;
  double noShowPercentage = 0.0;
  int recentBookingsCount = 0;
  Map<String, int> bloodGroupDemand = {
    'A+': 0, 'A-': 0, 'B+': 0, 'B-': 0,
    'AB+': 0, 'AB-': 0, 'O+': 0, 'O-': 0
  };

  @override
  void initState() {
    super.initState();
    _fetchMonthlyReport();
  }

  
  
  
  Future<void> _fetchMonthlyReport() async {
    try {
      DateTime now = DateTime.now();
      DateTime startOfMonth = DateTime(now.year, now.month, 1);
      DateTime endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      DateTime oneMonthAgo = now.subtract(const Duration(days: 30));

      QuerySnapshot campSnapshot = await FirebaseFirestore.instance
          .collection('camps')
          .get();

      int tempCampsCount = 0;

      for (var campDoc in campSnapshot.docs) {
        Map<String, dynamic> campData = campDoc.data() as Map<String, dynamic>;

        var dateField = campData['dateTime'] ?? campData['date'];
        DateTime? campDate;

        if (dateField is Timestamp) {
          campDate = dateField.toDate();
        } else if (dateField is String) {
          try {
            campDate = DateFormat('dd/MM/yyyy').parse(dateField);
          } catch (_) {
            campDate = DateTime.tryParse(dateField);
          }
        }

        if (campDate != null) {
          if (campDate.isAfter(startOfMonth.subtract(const Duration(seconds: 1))) &&
              campDate.isBefore(endOfMonth.add(const Duration(seconds: 1)))) {
            tempCampsCount++;
          }
        }
      }

      int tempUnits = 0;
      int totalAppointments = 0;
      int totalNoShows = 0;
      int tempRecentBookings = 0;

      Map<String, int> tempBloodDemand = {
        'A+': 0, 'A-': 0, 'B+': 0, 'B-': 0,
        'AB+': 0, 'AB-': 0, 'O+': 0, 'O-': 0
      };

      QuerySnapshot bookingSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .get();

      totalAppointments = bookingSnapshot.docs.length;

      for (var doc in bookingSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        String status = data['status'] ?? '';

        if (status == 'Booked') {
          totalNoShows++;
        } else if (status == 'Refreshment') {
          var rawUnits = data['bloodUnits'] ?? data['units'] ?? 0;
          int parsedUnits = rawUnits is int ? rawUnits : int.tryParse(rawUnits.toString()) ?? 0;
          tempUnits += parsedUnits;

          String bGroup = data['bloodGroup'] ?? '';
          if (tempBloodDemand.containsKey(bGroup)) {
            tempBloodDemand[bGroup] = tempBloodDemand[bGroup]! + 1;
          }
        }

        var bookingDateField = data['date'] ?? data['createdAt'];
        DateTime? bookingDate;

        if (bookingDateField is Timestamp) {
          bookingDate = bookingDateField.toDate();
        } else if (bookingDateField is String) {
          try {
            bookingDate = DateFormat('dd/MM/yyyy').parse(bookingDateField);
          } catch (_) {
            bookingDate = DateTime.tryParse(bookingDateField);
          }
        }

        if (bookingDate != null) {
          if (bookingDate.isAfter(oneMonthAgo) && bookingDate.isBefore(now.add(const Duration(days: 1)))) {
            tempRecentBookings++;
          }
        }
      }

      setState(() {
        totalCampsThisMonth = tempCampsCount;
        unitsCollected = tempUnits;
        noShowPercentage = totalAppointments > 0 ? (totalNoShows / totalAppointments) * 100 : 0.0;
        recentBookingsCount = tempRecentBookings;
        bloodGroupDemand = tempBloodDemand;
        _isLoading = false;
      });

    } catch (e) {
      print("Error fetching report: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String currentMonthName = DateFormat('MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: kSurface,
      extendBody: true,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bar_chart_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Monthly Report',
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchMonthlyReport();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  _buildMonthBanner(currentMonthName),
                  const SizedBox(height: 24),

                  
                  _buildSectionHeader(
                    icon: Icons.dashboard_rounded,
                    title: "Performance Metrics",
                  ),
                  const SizedBox(height: 14),

                  
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.05,
                    children: [
                      _buildStatCard(
                        title: 'Camps This Month',
                        value: '$totalCampsThisMonth',
                        subtitle: 'Active camps',
                        icon: Icons.event_note_rounded,
                        color: kInfo,
                        bgColor: kInfoLight,
                      ),
                      _buildStatCard(
                        title: 'Units Collected',
                        value: '$unitsCollected',
                        subtitle: 'Blood units',
                        icon: Icons.water_drop_rounded,
                        color: kPrimary,
                        bgColor: kPrimaryLight.withOpacity(0.35),
                      ),
                      _buildStatCard(
                        title: 'No-Show Rate',
                        value: '${noShowPercentage.toStringAsFixed(1)}%',
                        subtitle: 'Pending donors',
                        icon: Icons.person_off_rounded,
                        color: kWarning,
                        bgColor: kWarningLight,
                      ),
                      _buildStatCard(
                        title: 'Bookings',
                        value: '$recentBookingsCount',
                        subtitle: 'Last 1 month',
                        icon: Icons.groups_rounded,
                        color: kSuccess,
                        bgColor: kSuccessLight,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  
                  _buildSectionHeader(
                    icon: Icons.bloodtype_rounded,
                    title: "Blood Group Demand",
                  ),
                  const SizedBox(height: 14),

                  _buildBloodDemandCard(),
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
              selectedItemColor: kPrimary,
              unselectedItemColor: kTextHint,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
                switch (index) {
                  case 0:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const OrganizerScreen()),
                    );
                    break;
                  case 1:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const StaffScreen()),
                    );
                    break;
                  case 2:
                    break;
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_month_rounded),
                  label: 'Camps',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group_add_rounded),
                  label: 'Staff',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_rounded),
                  label: 'Reports',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  
  
  Widget _buildMonthBanner(String monthName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimaryDark, kPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kRadius),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.35),
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
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -40,
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "REPORTING PERIOD",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      monthName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
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
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        Icon(icon, size: 16, color: kPrimary.withOpacity(0.4)),
      ],
    );
  }

  
  
  
  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
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
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const Spacer(),

          
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.6,
              height: 1.05,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              letterSpacing: -0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: kTextHint,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildBloodDemandCard() {
    
    final int maxValue = bloodGroupDemand.values.isEmpty
        ? 1
        : bloodGroupDemand.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: kDivider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: bloodGroupDemand.entries.map((entry) {
          final double progress = maxValue == 0 ? 0 : entry.value / maxValue;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [kPrimaryDark, kPrimary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimary.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      entry.key,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Blood Group ${entry.key}',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: kTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${entry.value} ${entry.value == 1 ? "Unit" : "Units"}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: kTextPrimary,
                              letterSpacing: -0.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: kPrimaryLight.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(kPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}