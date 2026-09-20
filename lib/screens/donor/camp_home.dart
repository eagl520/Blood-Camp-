import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './donor_home_screen.dart';
import 'Health_tips.dart';
import 'camp_detail_screen.dart';
import 'History_screen.dart';


const Color kPrimary = Color(0xFFE53935);
const Color kPrimaryDark = Color(0xFFB71C1C);
const Color kPrimaryLight = Color(0xFFFFCDD2);
const Color kSuccess = Color(0xFF2E7D32);
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

class CampsFilterScreen extends StatefulWidget {
  const CampsFilterScreen({super.key});

  @override
  State<CampsFilterScreen> createState() => _CampsFilterScreenState();
}

class _CampsFilterScreenState extends State<CampsFilterScreen> {
  int _selectedIndex = 1;
  String _selectedCity = 'All cities';
  String _selectedBloodGroup = 'Any group';

  final List<String> _cities = ['All cities', 'Rawalpindi', 'Islamabad', 'Lahore', 'Karachi'];
  final List<String> _bloodGroups = ['Any group', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      extendBody: true,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Find Camps',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.2),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DonorMainScreen()),
            );
          },
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
                      'Refine Your Search',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildFilterDropdown(
                        icon: Icons.location_on_rounded,
                        value: _selectedCity,
                        items: _cities,
                        onChanged: (val) {
                          setState(() {
                            _selectedCity = val!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildFilterDropdown(
                        icon: Icons.bloodtype_rounded,
                        value: _selectedBloodGroup,
                        items: _bloodGroups,
                        onChanged: (val) {
                          setState(() {
                            _selectedBloodGroup = val!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('camps').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: "No camps available",
                    subtitle: "There are currently no camps in the database.",
                  );
                }

                final allCamps = snapshot.data!.docs;

                final filteredCamps = allCamps.where((doc) {
                  final camp = doc.data() as Map<String, dynamic>;

                  String campCity = camp['city'] ?? '';
                  bool matchesCity = (_selectedCity == 'All cities') ||
                      (campCity.trim().toLowerCase() == _selectedCity.trim().toLowerCase());

                  bool matchesBloodGroup = true;
                  if (_selectedBloodGroup != 'Any group') {
                    var neededGroups = camp['bloodGroupsNeeded'];
                    if (neededGroups is List) {
                      matchesBloodGroup = neededGroups.contains(_selectedBloodGroup);
                    } else if (neededGroups is String) {
                      matchesBloodGroup = neededGroups.contains(_selectedBloodGroup);
                    } else {
                      matchesBloodGroup = false;
                    }
                  }

                  return matchesCity && matchesBloodGroup;
                }).toList();

                if (filteredCamps.isEmpty) {
                  return _buildEmptyState(
                    icon: Icons.search_off_rounded,
                    title: "No camps match your filters",
                    subtitle: "Try a different city or blood group.",
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: filteredCamps.length,
                  itemBuilder: (context, index) {
                    final doc = filteredCamps[index];
                    final camp = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;
                    return _buildCampCard(camp, docId);
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

  
  
  
  Widget _buildFilterDropdown({
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(kRadiusSm),
        border: Border.all(color: kFieldBorder, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          icon: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.keyboard_arrow_down_rounded, color: kTextHint, size: 20),
          ),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Row(
                children: [
                  Icon(icon, size: 16, color: kPrimary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: kTextPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(kRadiusSm),
        ),
      ),
    );
  }

  
  
  
  DateTime? _parseCampDate(String s) {
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

  Map<String, dynamic> _getCampStatus(Map<String, dynamic> camp) {
    DateTime? start;
    DateTime? end;

    final dynamic startTs = camp['startDateTime'] ?? camp['dateTime'];
    final dynamic endTs = camp['endDateTime'];

    if (startTs is Timestamp) start = startTs.toDate();
    if (endTs is Timestamp) end = endTs.toDate();

    if (start == null) {
      final String s = (camp['startDate'] ?? camp['date'] ?? '').toString();
      start = _parseCampDate(s);
    }
    if (end == null) {
      final String e = (camp['endDate'] ?? '').toString();
      end = _parseCampDate(e);
    }

    end ??= start;

    if (start == null && end == null) {
      return {'label': 'Active', 'color': Colors.green[700]!};
    }

    final DateTime now = DateTime.now();
    final DateTime todayOnly = DateTime(now.year, now.month, now.day);
    final DateTime startOnly = start != null ? DateTime(start.year, start.month, start.day) : todayOnly;
    final DateTime endOnly = end != null ? DateTime(end.year, end.month, end.day) : startOnly;

    if (todayOnly.isBefore(startOnly)) {
      return {'label': 'Upcoming', 'color': Colors.orange[800]!};
    } else if (todayOnly.isAfter(endOnly)) {
      return {'label': 'Ended', 'color': Colors.grey[600]!};
    } else {
      return {'label': 'Active', 'color': Colors.green[700]!};
    }
  }

  
  
  
  Widget _buildCampCard(Map<String, dynamic> camp, String docId) {
    final String title = camp['title'] ?? camp['name'] ?? 'Blood Donation Camp';
    final String description = camp['instructions'] ?? 'No description provided for this camp.';
    final String city = camp['city'] ?? camp['location'] ?? 'Unknown City';
    final String seatsLeft = "${camp['seatsLeft'] ?? '0'}";
    final String seats = "${camp['seats'] ?? '0'}";
    final String? imageUrl = camp['imageUrl'];
    final List<dynamic> rawBloodGroups = camp['bloodGroupsNeeded'] ?? [];
    final String bloodGroupsNeeded = rawBloodGroups.join(', ');

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
                builder: (context) => CampDetailScreen(
                  camp: camp,
                  campId: docId,
                ),
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
                    child: imageUrl != null && imageUrl.toString().isNotEmpty
                        ? Image.network(
                            imageUrl,
                            height: 160,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => _buildImageFallback(),
                          )
                        : _buildImageFallback(),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadius)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withOpacity(0.35)],
                          stops: const [0.55, 1.0],
                        ),
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
                          const Icon(Icons.location_on_rounded, size: 13, color: kPrimary),
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
                ],
              ),

              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: kTextPrimary,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: kPrimaryLight.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.event_seat_rounded, size: 12, color: kPrimaryDark),
                              const SizedBox(width: 4),
                              Text(
                                '$seats / $seatsLeft',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: kPrimaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Text(
                      description,
                      style: const TextStyle(fontSize: 13, color: kTextSecondary, height: 1.45),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'BloodGroup $bloodGroupsNeeded',
                      style: const TextStyle(fontSize: 13, color: kTextSecondary, height: 1.45),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 40,
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
                                  builder: (context) => CampDetailScreen(
                                    camp: camp,
                                    campId: docId,
                                  ),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Text('Book Slot', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
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

  
  
  
  Widget _buildImageFallback() {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryLight.withOpacity(0.6), kPrimaryLight.withOpacity(0.2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Icon(Icons.local_hospital_rounded, size: 48, color: kPrimary),
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
              style: const TextStyle(fontSize: 13, color: kTextHint, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}