import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_screen.dart';


const Color kPrimary = Color(0xFFE53935);
const Color kPrimaryDark = Color(0xFFB71C1C);
const Color kPrimaryLight = Color(0xFFFFCDD2);
const Color kSuccess = Color(0xFF2E7D32);
const Color kWarning = Color(0xFFEF6C00);
const Color kInfo = Color(0xFF1565C0);
const Color kSurface = Color(0xFFFAFBFC);
const Color kCardBackground = Colors.white;
const Color kTextPrimary = Color(0xFF1A1A2E);
const Color kTextSecondary = Color(0xFF6B7280);
const Color kTextHint = Color(0xFF9CA3AF);
const Color kDivider = Color(0xFFF0F0F5);
const double kRadius = 18;
const double kRadiusSm = 12;

class CampDetailScreen extends StatefulWidget {
  final Map<String, dynamic> camp;
  final String campId;

  const CampDetailScreen({Key? key, required this.camp, required this.campId}) : super(key: key);

  @override
  State<CampDetailScreen> createState() => _CampDetailScreenState();
}

class _CampDetailScreenState extends State<CampDetailScreen> {
  bool _isBooking = false;

  
  Future<void> _bookSlot() async {
    setState(() {
      _isBooking = true;
    });

    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'campId': widget.campId,
        'campName': widget.camp['name'] ?? widget.camp['title'] ?? 'Blood Camp',
        'city': widget.camp['city'] ?? '',
        'venue': widget.camp['venue'] ?? '',
        'status': 'Booked',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Slot booked successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isBooking = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to book slot: $e')),
        );
      }
    }
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

  
  
  
  
  
  
  
  Map<String, dynamic> _getCampStatus() {
    final camp = widget.camp;

    
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
      return {
        'label': 'Active',
        'color': Colors.green[700]!,
        'icon': Icons.check_circle_rounded,
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
        'icon': Icons.schedule_rounded,
      };
    } else if (todayOnly.isAfter(endOnly)) {
      
      return {
        'label': 'Ended',
        'color': Colors.grey[600]!,
        'icon': Icons.event_busy_rounded,
      };
    } else {
      
      return {
        'label': 'Active',
        'color': Colors.green[700]!,
        'icon': Icons.check_circle_rounded,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final camp = widget.camp;
    final campName = camp['name'] ?? camp['title'] ?? 'Blood Camp';
    final String? imageUrl = camp['imageUrl'] ?? camp['image'];

    final String description = camp['instructions'] ?? 'No description provided for this camp.';
    final String startTime = camp['startDate'] ?? '';
    final String endTime = camp['endDate'] ?? '';
    final String venue = camp['venue'] ?? camp['address'] ?? 'N/A';
    final String city = camp['city'] ?? 'N/A';
    final String totalSeats = camp['seats']?.toString() ?? camp['seatsLeft']?.toString() ?? 'N/A';
    final String bookedSeats = camp['seatsLeft']?.toString() ?? '0';
    final String organizerPhone = camp['organizerPhone'] ?? camp['phone'] ?? 'N/A';
    final String campId= camp['campId'] ?? '';

    
    final String startStr = camp['startDate'] ?? camp['date'] ?? '';
    final String endStr = camp['endDate'] ?? '';
    final DateTime? campStart = _parseCampDate(startStr);
    final DateTime? campEnd = _parseCampDate(endStr);

    
    final status = _getCampStatus();
    final String statusLabel = status['label'] as String;
    final Color statusColor = status['color'] as Color;
    final IconData statusIcon = status['icon'] as IconData;

    return Scaffold(
      backgroundColor: kSurface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          campName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimaryDark.withOpacity(0.95), kPrimary.withOpacity(0.9)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Stack(
              children: [
                if (imageUrl != null && imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 260,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [kPrimaryLight.withOpacity(0.4), kPrimaryLight.withOpacity(0.1)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: const Center(child: Icon(Icons.broken_image_rounded, color: kTextHint, size: 50)),
                    ),
                  )
                else
                  Container(
                    height: 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [kPrimaryLight.withOpacity(0.6), kPrimaryLight.withOpacity(0.2)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: const Icon(Icons.local_hospital_rounded, size: 60, color: kPrimary),
                  ),

                
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 180,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.topRight,
                        radius: 1.2,
                        colors: [
                          Colors.black.withOpacity(0.45),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                
                Positioned(
                  top: 100, 
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 13, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          statusLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, kSurface],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          campName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor.withOpacity(0.35), width: 1),
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
                            const SizedBox(width: 6),
                            Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  
                  _SectionCard(
                    icon: Icons.description_rounded,
                    iconColor: kPrimary,
                    title: "Description",
                    child: Text(
                      description,
                      style: const TextStyle(fontSize: 14, color: kTextSecondary, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 14),

                  
                  _InfoTile(
                    icon: Icons.access_time_rounded,
                    iconColor: kPrimary,
                    label: "Time",
                    value: "$startTime - $endTime",
                  ),
                  const SizedBox(height: 10),

                  
                  _InfoTile(
                    icon: Icons.location_on_rounded,
                    iconColor: kPrimary,
                    label: "Address",
                    value: "$venue, $city",
                  ),
                  const SizedBox(height: 14),

                  
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.event_seat_rounded,
                          iconColor: kInfo,
                          label: "Total Seats",
                          value: totalSeats,
                          bgColor: kInfo.withOpacity(0.08),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.bookmark_rounded,
                          iconColor: kWarning,
                          label: "Booked Seats",
                          value: bookedSeats,
                          bgColor: kWarning.withOpacity(0.08),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  
                  _InfoTile(
                    icon: Icons.phone_rounded,
                    iconColor: kSuccess,
                    label: "Organizer Phone",
                    value: organizerPhone,
                  ),
                  const SizedBox(height: 28),

                  
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shadowColor: kPrimary.withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                       
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CampBookingScreen(
                              campName: camp['name'] ?? 'Blood Camp',
                              campStartDate: campStart,
                              campEndDate: campEnd,
                              campId: widget.campId,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.water_drop_rounded, size: 20),
                          SizedBox(width: 8),
                          Text('Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        ],
                      ),
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
}



class _SectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(kRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: kTextPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(kRadiusSm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kTextHint),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color bgColor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardBackground,
        borderRadius: BorderRadius.circular(kRadiusSm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: kTextHint),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: kTextPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}