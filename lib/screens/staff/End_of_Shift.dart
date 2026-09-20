import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'staff_home_screen.dart';


const Color kPrimary = Color(0xFFE53935);
const Color kPrimaryDark = Color(0xFFB71C1C);
const Color kPrimaryLight = Color(0xFFFFCDD2);
const Color kSuccess = Color(0xFF2E7D32);
const Color kSuccessLight = Color(0xFFE8F5E9);
const Color kWarning = Color(0xFFEF6C00);
const Color kWarningLight = Color(0xFFFFF3E0);
const Color kNeutral = Color(0xFF6B7280);
const Color kNeutralLight = Color(0xFFF3F4F6);
const Color kSurface = Color(0xFFF5F6F8);
const Color kCardBackground = Colors.white;
const Color kTextPrimary = Color(0xFF1A1A2E);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kTextHint = Color(0xFF9CA3AF);
const Color kDivider = Color(0xFFF0F0F5);
const double kRadius = 22;
const double kRadiusSm = 14;

class EndOfShiftReportScreen extends StatelessWidget {
  const EndOfShiftReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: kSurface,
      extendBody: true,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.assessment_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Shift Summary',
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(
              icon: Icons.inbox_rounded,
              title: "No bookings found",
              subtitle: "There are no bookings in the database for today.",
            );
          }

          final docs = snapshot.data!.docs;

          
          int collectedCount = 0;
          int deferredCount = 0;
          int noShowCount = 0;
          int totalBooked = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final String bookingDate = (data['date'] ?? '').toString();
            final String status = data['status'] ?? 'Booked';

            if (bookingDate == todayDate) {
              totalBooked++;

              if (status == 'Collected' || status == 'Refreshment') {
                final String unitsStr = (data['bloodUnits'] ?? '').toString();
                int units = int.tryParse(unitsStr) ?? 0;
                collectedCount += units;
              } else if (status == 'Deferred' || status == 'Rejected') {
                deferredCount++;
              } else if (status == 'Booked' || status == 'No-Show') {
                noShowCount++;
              }
            }
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                _buildDateBanner(),

                const SizedBox(height: 24),

                
                _buildSectionHeader(
                  icon: Icons.dashboard_rounded,
                  title: "Shift Metrics",
                ),
                const SizedBox(height: 14),

                
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Collected',
                        subtitle: 'Total units',
                        count: collectedCount,
                        color: kSuccess,
                        bgColor: kSuccessLight,
                        icon: Icons.check_circle_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Deferred',
                        subtitle: 'Rejected donors',
                        count: deferredCount,
                        color: kWarning,
                        bgColor: kWarningLight,
                        icon: Icons.warning_amber_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'No-Show',
                        subtitle: 'Pending donors',
                        count: noShowCount,
                        color: kNeutral,
                        bgColor: kNeutralLight,
                        icon: Icons.person_off_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        title: 'Total',
                        subtitle: 'All bookings',
                        count: totalBooked,
                        color: kPrimary,
                        bgColor: kPrimaryLight.withOpacity(0.35),
                        icon: Icons.list_alt_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                
                _buildSectionHeader(
                  icon: Icons.info_outline_rounded,
                  title: "Quick Note",
                ),
                const SizedBox(height: 14),

                
                _buildNoteCard(),
              ],
            ),
          );
        },
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
              currentIndex: 1,
              selectedItemColor: kPrimary,
              unselectedItemColor: kTextHint,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              onTap: (index) {
                if (index == 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StaffRosterScreen(),
                    ),
                  );
                }
              },
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.people_alt_rounded), label: 'Roster'),
                BottomNavigationBarItem(icon: Icon(Icons.assessment_rounded), label: 'Summary'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  
  
  
  Widget _buildDateBanner() {
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
                child: const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 24),
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
                        "TODAY'S SHIFT",
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
                      DateFormat('dd MMM yyyy').format(DateTime.now()),
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

  
  
  
  Widget _buildSummaryCard({
    required String title,
    required String subtitle,
    required int count,
    required Color color,
    required Color bgColor,
    required IconData icon,
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
          const SizedBox(height: 14),

          
          Text(
            '$count',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.8,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 6),

          
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10.5,
              color: kTextHint,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildNoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kPrimaryLight.withOpacity(0.35),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.lightbulb_rounded, color: kPrimary, size: 18),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'This report summarizes all donor activities recorded during the current active shift. Please hand over this summary to the camp organizer before closing.',
              style: TextStyle(
                color: kTextSecondary,
                fontSize: 13,
                height: 1.55,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: kPrimaryLight.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 44, color: kPrimary.withOpacity(0.5)),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kTextPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: kTextHint, fontWeight: FontWeight.w500, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}