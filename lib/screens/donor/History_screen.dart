import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './donor_home_screen.dart';
import 'camp_home.dart';
import './Health_tips.dart';


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

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _selectedIndex = 2;
  String _selectedCategory = 'All';

  
  final List<String> _categories = ['All', 'Booked', 'Complete', 'Cancelled'];

  @override
  Widget build(BuildContext context) {
    
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: kSurface,
      extendBody: true,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.bookmark_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'My Bookings',
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
      body: Column(
        children: [
          
          _buildCategoryBar(),

          
          Expanded(
            child: userId == null
                ? _buildEmptyState(
                    icon: Icons.person_off_rounded,
                    title: "Not logged in",
                    subtitle: "Please log in to see your bookings.",
                  )
                : StreamBuilder<QuerySnapshot>(
                    
                    stream: FirebaseFirestore.instance
                        .collection('bookings')
                        .where('userId', isEqualTo: userId)
                        .orderBy('date', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5),
                        );
                      }

                      if (snapshot.hasError) {
                        return _buildEmptyState(
                          icon: Icons.error_outline_rounded,
                          title: "Something went wrong",
                          subtitle: "Please try again later.",
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return _buildEmptyState(
                          icon: Icons.history_rounded,
                          title: "No booking history found",
                          subtitle: "Your bookings will appear here once you book a slot.",
                        );
                      }

                      final allDocs = snapshot.data!.docs;

                      
                      final filteredDocs = allDocs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final String status = (data['status'] ?? 'booked').toString().toLowerCase().trim();

                        
                        if (_selectedCategory == 'All') return true;

                        
                        if (_selectedCategory == 'Booked') {
                          return status == 'booking' ||
                              status == 'booked' ||
                              status == 'pending';
                        }

                        
                        if (_selectedCategory == 'Complete') {
                          return status == 'refreshment' ||
                              status == 'complete' ||
                              status == 'completed' ||
                              status == 'collected';
                        }

                        
                        if (_selectedCategory == 'Cancelled') {
                          return status == 'cancelled' ||
                              status == 'cancel' ||
                              status == 'rejected' ||
                              status == 'deferred';
                        }

                        return true;
                      }).toList();

                      if (filteredDocs.isEmpty) {
                        return _buildEmptyState(
                          icon: Icons.search_off_rounded,
                          title: "No $_selectedCategory bookings",
                          subtitle: "Try a different category filter.",
                        );
                      }

                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final booking = doc.data() as Map<String, dynamic>;
                          return _buildBookingCard(booking);
                        },
                      );
                    },
                  ),
          ),
        ],
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
              currentIndex: _selectedIndex,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: kPrimary,
              unselectedItemColor: kTextHint,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
              backgroundColor: Colors.transparent,
              elevation: 0,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                switch (index) {
                  case 0:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DonorMainScreen()),
                    );
                    break;
                  case 1:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const CampsFilterScreen()),
                    );
                    break;
                  case 2:
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

  
  
  
  Widget _buildCategoryBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: kCardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: kPrimary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Filter by status',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _categories.map((category) {
                final bool isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: _buildCategoryChip(category, isSelected),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildCategoryChip(String category, bool isSelected) {
    IconData icon;
    Color selectedColor = kPrimary; 

    switch (category) {
      case 'Booked':
        icon = Icons.schedule_rounded;
        selectedColor = kWarning;
        break;
      case 'Complete':
        icon = Icons.check_circle_rounded;
        selectedColor = kSuccess;
        break;
      case 'Cancelled':
        icon = Icons.cancel_rounded;
        selectedColor = kPrimary;
        break;
      default:
        icon = Icons.apps_rounded;
        selectedColor = kPrimary;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedCategory = category;
          });
        },
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [selectedColor.withOpacity(0.85), selectedColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : kSurface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isSelected ? Colors.transparent : kDivider,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: selectedColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : kTextSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                category,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : kTextSecondary,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  
  
  Widget _buildBookingCard(Map<String, dynamic> booking) {
    String campName = booking['campName'] ?? booking['title'] ?? 'Blood Donation Camp';
    final String rawStatus = (booking['status'] ?? 'booked').toString();
    final String statusLower = rawStatus.toLowerCase().trim();
    String date = booking['date'] ?? booking['createdAt']?.toString().substring(0, 10) ?? 'N/A';
    String? venue = booking['venue'];
    String? city = booking['city'];

    
    Color statusColor;
    Color statusBg;
    Color statusBorder;
    IconData statusIcon;
    String statusLabel;

    if (statusLower == 'refreshment' || statusLower == 'complete' || statusLower == 'completed' || statusLower == 'collected') {
      statusColor = kSuccess;
      statusBg = kSuccessLight;
      statusBorder = kSuccess.withOpacity(0.3);
      statusIcon = Icons.check_circle_rounded;
      
      statusLabel = rawStatus;
    } else if (statusLower == 'cancelled' || statusLower == 'cancel' || statusLower == 'rejected' || statusLower == 'deferred') {
      statusColor = kPrimary;
      statusBg = kPrimaryLight.withOpacity(0.35);
      statusBorder = kPrimary.withOpacity(0.3);
      statusIcon = Icons.cancel_rounded;
      statusLabel = rawStatus;
    } else if (statusLower == 'booking' || statusLower == 'booked' || statusLower == 'pending') {
      statusColor = kWarning;
      statusBg = kWarningLight;
      statusBorder = kWarning.withOpacity(0.3);
      statusIcon = Icons.schedule_rounded;
      statusLabel = rawStatus;
    } else {
      statusColor = kInfo;
      statusBg = kInfoLight;
      statusBorder = kInfo.withOpacity(0.3);
      statusIcon = Icons.info_rounded;
      statusLabel = rawStatus;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: statusBorder, width: 1),
              ),
              child: Icon(statusIcon, color: statusColor, size: 22),
            ),
            const SizedBox(width: 14),

            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    campName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if ((venue != null && venue.isNotEmpty) || (city != null && city.isNotEmpty)) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 12, color: kTextHint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [
                              if (venue != null && venue.isNotEmpty) venue,
                              if (city != null && city.isNotEmpty) city,
                            ].join(', '),
                            style: const TextStyle(fontSize: 11.5, color: kTextHint, fontWeight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 11, color: kTextSecondary),
                            const SizedBox(width: 4),
                            Text(
                              date,
                              style: const TextStyle(fontSize: 11, color: kTextSecondary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: statusBorder, width: 1),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
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
              style: const TextStyle(fontSize: 13, color: kTextHint, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}