import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'organizer_home_screen.dart';
import './reports_screen.dart';


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
const Color kFieldFill = Color(0xFFF7F8FA);
const Color kFieldBorder = Color(0xFFE5E7EB);
const Color kDivider = Color(0xFFF0F0F5);
const double kRadius = 22;
const double kRadiusSm = 14;

class StaffScreen extends StatefulWidget {
  const StaffScreen({super.key});

  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  int _currentIndex = 1;
  String _selectedCategory = 'All';

  
  
  
  void _showAddStaffDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
          contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimaryLight.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_add_alt_1_rounded, color: kPrimary, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Add New Staff',
                style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.2),
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField(
                  controller: nameController,
                  label: 'Staff Name',
                  icon: Icons.person_rounded,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter name' : null,
                ),
                const SizedBox(height: 12),
                _buildDialogField(
                  controller: emailController,
                  label: 'Staff Email',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter email' : null,
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kTextPrimary,
                        side: const BorderSide(color: kFieldBorder, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusSm)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusSm)),
                      ),
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            await FirebaseFirestore.instance.collection('staff').add({
                              'name': nameController.text.trim(),
                              'email': emailController.text.trim(),
                              'status': 'Available',
                              'assignedCamp': 'None',
                              'createdAt': FieldValue.serverTimestamp(),
                            });

                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Staff added successfully!')),
                              );
                            }
                          } catch (e) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  
  
  
  void _showAvailableStaffForCamp(BuildContext context, String campName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
          contentPadding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kSuccessLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.group_add_rounded, color: kSuccess, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Assign Staff',
                      style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: kPrimaryLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.medical_services_rounded, size: 12, color: kPrimaryDark),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        campName,
                        style: const TextStyle(
                          color: kPrimaryDark,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 380,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('staff')
                  .where('status', isEqualTo: 'Available')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: kSuccessLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.group_off_rounded, size: 36, color: kSuccess.withOpacity(0.5)),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No available staff',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: kTextPrimary),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'All staff are currently on duty.',
                          style: TextStyle(fontSize: 12, color: kTextHint, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }

                final availableStaffDocs = snapshot.data!.docs;

                return ListView.separated(
                  itemCount: availableStaffDocs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final staffDoc = availableStaffDocs[index];
                    final staffData = staffDoc.data() as Map<String, dynamic>;
                    final staffName = staffData['name'] ?? 'No Name';
                    final staffEmail = staffData['email'] ?? 'No Email';
                    final initial = staffName.isNotEmpty ? staffName.trim()[0].toUpperCase() : '?';

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: kCardBackground,
                        borderRadius: BorderRadius.circular(kRadiusSm),
                        border: Border.all(color: kDivider, width: 1),
                      ),
                      child: Row(
                        children: [
                          
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [kSuccess, Color(0xFF43A047)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: kSuccess.withOpacity(0.25),
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
                                  fontSize: 15,
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
                                  staffName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13.5,
                                    color: kTextPrimary,
                                    letterSpacing: -0.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  staffEmail,
                                  style: const TextStyle(fontSize: 11, color: kTextHint, fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          
                          SizedBox(
                            height: 36,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kPrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: () async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('staff')
                                      .doc(staffDoc.id)
                                      .update({
                                    'status': 'On Duty',
                                    'assignedCamp': campName,
                                  });

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('$staffName assigned to $campName!')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                              child: const Text('Add', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kTextPrimary,
                  side: const BorderSide(color: kFieldBorder, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusSm)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
              ),
            ),
          ],
        );
      },
    );
  }

  
  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: kTextSecondary, fontWeight: FontWeight.w600),
        floatingLabelStyle: const TextStyle(fontSize: 13, color: kPrimary, fontWeight: FontWeight.w700),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Icon(icon, size: 18, color: kTextHint),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 44),
        filled: true,
        fillColor: kFieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kFieldBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kPrimary, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kPrimary, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = ['All', 'Available', 'On Duty', 'Camps'];

    return Scaffold(
      backgroundColor: kSurface,
      extendBody: true,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.groups_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Staff Members',
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
          
          _buildCategoryBar(categories),

          
          Expanded(
            child: _selectedCategory == 'Camps'
                ? _buildCampsListView()
                : _buildStaffListView(),
          ),
        ],
      ),
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
          onPressed: () => _showAddStaffDialog(context),
          icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
          label: const Text(
            'Add Staff',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.2),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    break;
                  case 2:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const OrganizerReportScreen()),
                    );
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

  
  
  
  Widget _buildCategoryBar(List<String> categories) {
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
                'Filter Staff',
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
              children: categories.map((category) {
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
    switch (category) {
      case 'Available':
        icon = Icons.check_circle_rounded;
        break;
      case 'On Duty':
        icon = Icons.work_rounded;
        break;
      case 'Camps':
        icon = Icons.event_rounded;
        break;
      default:
        icon = Icons.apps_rounded;
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
                ? const LinearGradient(
                    colors: [kPrimaryDark, kPrimary],
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
                      color: kPrimary.withOpacity(0.3),
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

  
  
  
  Widget _buildCampsListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('camps').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.event_busy_rounded,
            title: "No camps found",
            subtitle: "Create a camp first to assign staff.",
          );
        }

        final campDocs = snapshot.data!.docs;

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          itemCount: campDocs.length,
          itemBuilder: (context, index) {
            final campData = campDocs[index].data() as Map<String, dynamic>;
            final name = campData['name'] ?? 'Unnamed Camp';
            final location = campData['location'] ?? 'No Location';
            final date = campData['date'] ?? 'No Date';
            final imageUrl = campData['imageUrl'] ?? '';

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
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildCampImageFallback(),
                              )
                            : _buildCampImageFallback(),
                      ),
                      const SizedBox(width: 14),

                      
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                                color: kTextPrimary,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, size: 12, color: kTextHint),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    location,
                                    style: const TextStyle(fontSize: 11.5, color: kTextSecondary, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 12, color: kTextHint),
                                const SizedBox(width: 3),
                                Text(
                                  date,
                                  style: const TextStyle(fontSize: 11.5, color: kTextSecondary, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      
                      Material(
                        color: kPrimaryLight.withOpacity(0.35),
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: () => _showAvailableStaffForCamp(context, name),
                          customBorder: const CircleBorder(),
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(Icons.person_add_alt_1_rounded, color: kPrimaryDark, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCampImageFallback() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: kPrimaryLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.local_hospital_rounded, color: kPrimary, size: 24),
    );
  }

  
  
  
  Widget _buildStaffListView() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('staff')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5));
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.person_off_rounded,
            title: "No staff members",
            subtitle: "Tap the + button to add one.",
          );
        }

        final allStaffDocs = snapshot.data!.docs;

        final staffDocs = allStaffDocs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'Available';

          if (_selectedCategory == 'All') {
            return true;
          }
          return status.toString().trim().toLowerCase() == _selectedCategory.toLowerCase();
        }).toList();

        if (staffDocs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.search_off_rounded,
            title: "No staff found",
            subtitle: 'No staff under "$_selectedCategory".',
          );
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
          itemCount: staffDocs.length,
          itemBuilder: (context, index) {
            final staffDoc = staffDocs[index];
            final staffData = staffDoc.data() as Map<String, dynamic>;
            final name = staffData['name'] ?? 'No Name';
            final email = staffData['email'] ?? 'No Email';
            final status = staffData['status'] ?? 'Available';
            final assignedCamp = staffData['assignedCamp'] ?? 'None';

            final bool isAvailable = status == 'Available';
            final Color statusColor = isAvailable ? kSuccess : kWarning;
            final Color statusBg = isAvailable ? kSuccessLight : kWarningLight;
            final IconData statusIcon = isAvailable ? Icons.check_circle_rounded : Icons.work_rounded;

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
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Row(
                      children: [
                        
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isAvailable
                                  ? [kSuccess, const Color(0xFF43A047)]
                                  : [kWarning, const Color(0xFFFB8C00)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.25),
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
                                fontSize: 16,
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
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: kTextPrimary,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.email_rounded, size: 11, color: kTextHint),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      email,
                                      style: const TextStyle(fontSize: 12, color: kTextSecondary, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        
                        Material(
                          color: kPrimaryLight.withOpacity(0.3),
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () async {
                              await FirebaseFirestore.instance
                                  .collection('staff')
                                  .doc(staffDoc.id)
                                  .delete();
                            },
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(9),
                              child: Icon(Icons.delete_outline_rounded, color: kPrimary, size: 18),
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
                    const SizedBox(height: 12),

                    
                    Row(
                      children: [
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(statusIcon, size: 11, color: statusColor),
                              const SizedBox(width: 4),
                              Text(
                                status,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: statusColor,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        
                        if (assignedCamp != 'None') ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: kInfoLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: kInfo.withOpacity(0.3), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.event_rounded, size: 11, color: kInfo),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      assignedCamp,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: kInfo,
                                        fontWeight: FontWeight.w800,
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
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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