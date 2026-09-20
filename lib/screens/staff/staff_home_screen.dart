import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'screening.dart';
import 'End_of_Shift.dart';
import 'WalkIn_Booking_Screen.dart';
import './profile_screen.dart';


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

class StaffRosterScreen extends StatefulWidget {
  const StaffRosterScreen({super.key});

  @override
  State<StaffRosterScreen> createState() => _StaffRosterScreenState();
}

class _StaffRosterScreenState extends State<StaffRosterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: kSurface,
      extendBody: true,
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: kPrimary.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WalkInBookingScreen(),
              ),
            );
          },
          icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Walk-in',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.2),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.groups_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Staff Roster',
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
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              showProfileMenu(context);
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
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
                
                _buildSearchBar(),
                const SizedBox(height: 18),
                
                Row(
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
                    const Text(
                      "Today's Roster",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(  
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: kPrimaryLight.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          todayDate,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: kPrimaryDark,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('bookings').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.event_busy_rounded,
                    title: "No bookings found",
                    subtitle: "There are no bookings in the database yet.",
                  );
                }

                final docs = snapshot.data!.docs;

                
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;

                  final name = (data['userName'] ?? data['donorName'] ?? '').toString().toLowerCase();
                  final phone = (data['phone'] ?? data['donorPhone'] ?? '').toString().toLowerCase();
                  final bookingDate = (data['date'] ?? '').toString();

                  bool isToday = bookingDate == todayDate;
                  if (!isToday) return false;

                  if (_searchQuery.isEmpty) return true;

                  return name.contains(_searchQuery) || phone.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.search_off_rounded,
                    title: "No matching bookings",
                    subtitle: _searchQuery.isNotEmpty
                        ? "No results for \"$_searchQuery\" today."
                        : "No bookings found for today.",
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final docId = filteredDocs[index].id;
                    final bookingData = filteredDocs[index].data() as Map<String, dynamic>;
                    return _buildBookingCard(context, docId, bookingData);
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
              currentIndex: 0,
              selectedItemColor: kPrimary,
              unselectedItemColor: kTextHint,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              onTap: (index) {
                if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EndOfShiftReportScreen(),
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

  
  
  
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusSm),
        border: Border.all(
          color: _searchQuery.isNotEmpty ? kPrimary.withOpacity(0.4) : kDivider,
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.trim().toLowerCase();
          });
        },
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextPrimary),
        decoration: InputDecoration(
          hintText: 'Search donor name or phone...',
          hintStyle: const TextStyle(fontSize: 13.5, color: kTextHint, fontWeight: FontWeight.w500),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 14, right: 10),
            child: Icon(Icons.search_rounded, color: kTextHint, size: 20),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
          suffixIcon: _searchQuery.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: IconButton(
                    icon: const Icon(Icons.close_rounded, color: kTextHint, size: 18),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  ),
                )
              : null,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  
  
  
  Widget _buildBookingCard(BuildContext context, String docId, Map<String, dynamic> bookingData) {
    final String name = bookingData['userName'] ?? bookingData['donorName'] ?? 'Unknown User';
    final String phone = bookingData['phone'] ?? bookingData['donorPhone'] ?? 'No Phone';
    final String campName = bookingData['campName'] ?? 'General Camp';
    final String slot = bookingData['slot'] ?? 'No Slot Assigned';
    final String status = bookingData['status'] ?? 'Pending';

    
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    if (status == 'Confirmed' || status == 'Completed' || status == 'Collected') {
      statusColor = kSuccess;
      statusBg = kSuccessLight;
      statusIcon = Icons.check_circle_rounded;
    } else if (status == 'Deferred' || status == 'Cancelled') {
      statusColor = kPrimary;
      statusBg = kPrimaryLight.withOpacity(0.35);
      statusIcon = Icons.cancel_rounded;
    } else if (status == 'Refreshment') {
      statusColor = kInfo;
      statusBg = kInfoLight;
      statusIcon = Icons.local_cafe_rounded;
    } else {
      statusColor = kWarning;
      statusBg = kWarningLight;
      statusIcon = Icons.schedule_rounded;
    }

    
    final String initial = name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';

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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(kRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ScreeningFormScreen(
                  bookingId: docId,
                  bookingData: bookingData,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: kPrimaryLight.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Icon(Icons.medical_services_rounded, size: 14, color: kPrimaryDark),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        campName,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: kTextSecondary,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),  
                    
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacity(0.4), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 11, color: statusColor),
                            const SizedBox(width: 4),
                            Flexible(  
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 10.5,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [kDivider, Colors.transparent],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kPrimaryDark, kPrimary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
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
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: kTextPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone_rounded, size: 12, color: kTextHint),
                              const SizedBox(width: 4),
                              Expanded(  
                                child: Text(
                                  phone,
                                  style: const TextStyle(
                                    color: kTextSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),  

                    
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 110),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kDivider, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.access_time_rounded, size: 11, color: kPrimary),
                                SizedBox(width: 4),
                                Text(
                                  "SLOT",
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    color: kTextHint,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              slot,
                              style: const TextStyle(
                                color: kTextPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
              style: const TextStyle(fontSize: 13, color: kTextHint, fontWeight: FontWeight.w500, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}