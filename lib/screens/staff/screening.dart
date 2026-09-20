import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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

class ScreeningFormScreen extends StatefulWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const ScreeningFormScreen({
    super.key,
    required this.bookingId,
    required this.bookingData,
  });

  @override
  State<ScreeningFormScreen> createState() => _ScreeningFormScreenState();
}

class _ScreeningFormScreenState extends State<ScreeningFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _weightController;
  late TextEditingController _tempController;
  late TextEditingController _bpController;
  late TextEditingController _notesController;

  late TextEditingController _bagNumberController;
  late TextEditingController _unitsController;
  late TextEditingController _collectionNotesController;
  String? _selectedSavedBloodGroup;

  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'
  ];

  late String _currentStatus;
  bool _isLoading = false;

  final List<String> _stages = ['Booked', 'Screening', 'Collected', 'Refreshment'];

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.bookingData['status'] ?? 'Booked';

    _weightController = TextEditingController(text: widget.bookingData['weight'] ?? '');
    _tempController = TextEditingController(text: widget.bookingData['temperature'] ?? '');
    _bpController = TextEditingController(text: widget.bookingData['bloodPressure'] ?? '');
    _notesController = TextEditingController(text: widget.bookingData['screeningNotes'] ?? '');

    _bagNumberController = TextEditingController(text: widget.bookingData['bagNumber'] ?? '');
    _unitsController = TextEditingController(text: widget.bookingData['bloodUnits'] ?? '1');
    _collectionNotesController = TextEditingController(text: widget.bookingData['collectionNotes'] ?? '');

    String? existingBg = widget.bookingData['savedBloodGroup'] ?? widget.bookingData['bloodGroup'];
    if (_bloodGroups.contains(existingBg)) {
      _selectedSavedBloodGroup = existingBg;
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _tempController.dispose();
    _bpController.dispose();
    _notesController.dispose();
    _bagNumberController.dispose();
    _unitsController.dispose();
    _collectionNotesController.dispose();
    super.dispose();
  }

  
  Future<void> _updateStatusAndData(String newStatus, {bool validateForm = false, Map<String, dynamic>? extraData}) async {
    if (validateForm && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> updateData = {
        'status': newStatus,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (extraData != null) {
        updateData.addAll(extraData);
      }

      if (newStatus == 'Collected' || newStatus == 'Refreshment' || newStatus == 'Confirmed') {
        updateData['weight'] = _weightController.text.trim();
        updateData['temperature'] = _tempController.text.trim();
        updateData['bloodPressure'] = _bpController.text.trim();
        updateData['screeningNotes'] = _notesController.text.trim();
      }

      if (newStatus == 'Collected' || newStatus == 'Refreshment') {
        updateData['savedBloodGroup'] = _selectedSavedBloodGroup ?? 'Not Specified';
        updateData['bagNumber'] = _bagNumberController.text.trim();
        updateData['bloodUnits'] = _unitsController.text.trim();
        updateData['collectionNotes'] = _collectionNotesController.text.trim();
      }

      await FirebaseFirestore.instance.collection('bookings').doc(widget.bookingId).update(updateData);

      setState(() {
        _currentStatus = newStatus;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to: $newStatus')),
        );

        if (newStatus == 'Refreshment' || newStatus == 'Deferred' || newStatus == 'Rejected' || newStatus == 'Cancelled') {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  
  void _showCancellationReasonDialog() {
    String selectedReasonType = 'Deferred';
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
              contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kPrimaryLight.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cancel_rounded, color: kPrimary, size: 32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'Select Cancellation Reason',
                        style: TextStyle(color: kTextPrimary, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Please choose whether the donor is Deferred or Rejected:',
                        style: TextStyle(fontSize: 12, color: kTextSecondary, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 18),
                    
                    _buildReasonOption(
                      isSelected: selectedReasonType == 'Deferred',
                      title: 'Deferred',
                      subtitle: 'Temporary hold (can donate later)',
                      onTap: () => setDialogState(() => selectedReasonType = 'Deferred'),
                    ),
                    const SizedBox(height: 10),
                    
                    _buildReasonOption(
                      isSelected: selectedReasonType == 'Rejected',
                      title: 'Rejected',
                      subtitle: 'Permanent or strict medical unfitness',
                      onTap: () => setDialogState(() => selectedReasonType = 'Rejected'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Reason Details (Optional)',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: kTextPrimary, letterSpacing: 0.1),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: reasonController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextPrimary),
                      decoration: InputDecoration(
                        hintText: 'Add any notes here...',
                        hintStyle: const TextStyle(fontSize: 13, color: kTextHint, fontWeight: FontWeight.w500),
                        filled: true,
                        fillColor: kFieldFill,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kRadiusSm),
                          borderSide: const BorderSide(color: kFieldBorder, width: 1.2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(kRadiusSm),
                          borderSide: const BorderSide(color: kPrimary, width: 1.5),
                        ),
                      ),
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
                          onPressed: () {
                            Navigator.pop(context);
                            _updateStatusAndData(
                              selectedReasonType,
                              extraData: {'cancellationReason': reasonController.text.trim()},
                            );
                          },
                          child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildReasonOption({
    required bool isSelected,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kRadiusSm),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryLight.withOpacity(0.25) : kFieldFill,
            borderRadius: BorderRadius.circular(kRadiusSm),
            border: Border.all(
              color: isSelected ? kPrimary : kFieldBorder,
              width: isSelected ? 1.6 : 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? kPrimary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? kPrimary : kTextHint,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Center(
                        child: Icon(Icons.check_rounded, color: Colors.white, size: 13),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isSelected ? kPrimaryDark : kTextPrimary,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: kTextSecondary, fontWeight: FontWeight.w500),
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

  @override
  Widget build(BuildContext context) {
    final data = widget.bookingData;
    final String campName = data['campName'] ?? 'General Camp';
    final String userName = data['userName'] ?? data['donorName'] ?? 'Unknown';
    final String phone = data['phone'] ?? data['donorPhone'] ?? 'N/A';
    final String age = data['age'] ?? 'N/A';
    final String bloodGroup = data['bloodGroup'] ?? 'Not Specified';
    final String slot = data['slot'] ?? 'N/A';

    bool isMedicalEditable = ( _currentStatus == 'Booking' || _currentStatus == 'Screening' || _currentStatus == 'Pending' );
    bool showCollectionFields = (_currentStatus == 'Collected' || _currentStatus == 'Refreshment');

    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.medical_services_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Donor Screening',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: 0.2),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
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
              
              _buildTimelineView(),
              const SizedBox(height: 24),

              
              _buildSectionHeader(
                icon: Icons.person_rounded,
                title: "Donor Details",
              ),
              const SizedBox(height: 12),
              _buildDonorInfoCard(
                campName: campName,
                userName: userName,
                phone: phone,
                age: age,
                bloodGroup: bloodGroup,
                slot: slot,
              ),
              const SizedBox(height: 24),

              
              Row(
                children: [
                  _buildSectionHeader(
                    icon: Icons.monitor_heart_rounded,
                    title: "Medical Assessment",
                  ),
                  const Spacer(),
                  if (!isMedicalEditable)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: kTextHint.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: kTextHint.withOpacity(0.3), width: 1),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_rounded, size: 11, color: kTextSecondary),
                          SizedBox(width: 4),
                          Text(
                            'Read-Only',
                            style: TextStyle(fontSize: 10.5, color: kTextSecondary, fontWeight: FontWeight.w700, letterSpacing: 0.2),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: _weightController,
                enabled: isMedicalEditable,
                keyboardType: TextInputType.number,
                icon: Icons.monitor_weight_rounded,
                label: 'Weight (kg)',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter weight' : null,
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: _tempController,
                enabled: isMedicalEditable,
                icon: Icons.thermostat_rounded,
                label: 'Temperature (°F)',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter temperature' : null,
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: _bpController,
                enabled: isMedicalEditable,
                icon: Icons.speed_rounded,
                label: 'Blood Pressure',
                hint: 'e.g., 120/80',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter blood pressure' : null,
              ),
              const SizedBox(height: 14),

              _buildTextField(
                controller: _notesController,
                enabled: isMedicalEditable,
                icon: Icons.note_alt_rounded,
                label: ' feeling well (yes/no).',
               
              ),

              
              if (showCollectionFields) ...[
                const SizedBox(height: 28),
                _buildSectionHeader(
                  icon: Icons.bloodtype_rounded,
                  title: "Collection Details",
                ),
                const SizedBox(height: 14),

                _buildDropdown(
                  value: _selectedSavedBloodGroup,
                  icon: Icons.bloodtype_rounded,
                  iconColor: kPrimary,
                  label: 'Save Blood Group',
                  items: _bloodGroups,
                  enabled: _currentStatus == 'Collected',
                  onChanged: _currentStatus == 'Collected'
                      ? (val) => setState(() => _selectedSavedBloodGroup = val)
                      : null,
                  validator: (v) => (v == null) ? 'Please select blood group' : null,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _bagNumberController,
                  enabled: _currentStatus == 'Collected',
                  icon: Icons.qr_code_rounded,
                  iconColor: kPrimary,
                  label: 'Bag Number',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter bag number' : null,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _unitsController,
                  enabled: _currentStatus == 'Collected',
                  keyboardType: TextInputType.number,
                  icon: Icons.numbers_rounded,
                  iconColor: kPrimary,
                  label: 'Blood Units',
                  hint: 'e.g., 1',
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter blood units' : null,
                ),
                const SizedBox(height: 14),

                _buildTextField(
                  controller: _collectionNotesController,
                  enabled: _currentStatus == 'Collected',
                  icon: Icons.note_rounded,
                  iconColor: kPrimary,
                  label: 'Collection Notes',
                  maxLines: 2,
                ),
              ],

              const SizedBox(height: 32),

              
              _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5),
                      ),
                    )
                  : _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  
  
  
  Widget _buildTimelineView() {
    int currentIndex = _stages.indexOf(_currentStatus);
    if (currentIndex == -1) currentIndex = 1;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
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
      child: Row(
        children: List.generate(_stages.length, (index) {
          bool isPassed = index <= currentIndex;
          bool isCurrent = index == currentIndex;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == 0
                            ? Colors.transparent
                            : (index <= currentIndex ? kPrimary : kDivider),
                      ),
                    ),
                    
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: isCurrent ? 30 : 26,
                      height: isCurrent ? 30 : 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPassed ? kPrimary : kDivider,
                        border: isCurrent
                            ? Border.all(color: kPrimaryLight, width: 3)
                            : null,
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: kPrimary.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: isPassed
                            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: const TextStyle(fontSize: 10, color: kTextHint, fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                    
                    Expanded(
                      child: Container(
                        height: 2,
                        color: index == _stages.length - 1
                            ? Colors.transparent
                            : (index < currentIndex ? kPrimary : kDivider),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _stages[index],
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                    color: isCurrent ? kPrimaryDark : (isPassed ? kTextSecondary : kTextHint),
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  
  
  
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  
  
  
  Widget _buildDonorInfoCard({
    required String campName,
    required String userName,
    required String phone,
    required String age,
    required String bloodGroup,
    required String slot,
  }) {
    final String initial = userName.isNotEmpty ? userName.trim()[0].toUpperCase() : '?';

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
        children: [
          
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
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
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 16,
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
                        const Icon(Icons.medical_services_rounded, size: 12, color: kTextHint),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            campName,
                            style: const TextStyle(fontSize: 12, color: kTextSecondary, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [kDivider, Colors.transparent],
              ),
            ),
          ),
          const SizedBox(height: 14),
          
          _buildDetailRow(Icons.phone_rounded, 'Phone', phone),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.cake_rounded, 'Age', age),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.bloodtype_rounded, 'Blood Group', bloodGroup, valueColor: kPrimary),
          const SizedBox(height: 10),
          _buildDetailRow(Icons.access_time_rounded, 'Slot', slot),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 13, color: kTextSecondary),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 12.5, color: kTextHint, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: valueColor ?? kTextPrimary,
            letterSpacing: -0.1,
          ),
        ),
      ],
    );
  }

  
  
  
  Widget _buildTextField({
    required TextEditingController controller,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    required IconData icon,
    Color iconColor = kTextHint,
    required String label,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: kTextHint, fontWeight: FontWeight.w500),
        labelStyle: TextStyle(
          fontSize: 13,
          color: enabled ? kTextSecondary : kTextHint,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 13,
          color: enabled ? kPrimary : kTextHint,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, size: 20, color: enabled ? iconColor : kTextHint),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
        filled: true,
        fillColor: enabled ? kFieldFill : kSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kFieldBorder, width: 1.2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: BorderSide(color: kDivider, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kPrimary, width: 1.6),
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
    Color iconColor = kTextHint,
    required String label,
    required List<String> items,
    required ValueChanged<String?>? onChanged,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: enabled ? kTextSecondary : kTextHint,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: TextStyle(
          fontSize: 13,
          color: enabled ? kPrimary : kTextHint,
          fontWeight: FontWeight.w700,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, size: 20, color: enabled ? iconColor : kTextHint),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
        filled: true,
        fillColor: enabled ? kFieldFill : kSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kFieldBorder, width: 1.2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: BorderSide(color: kDivider, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
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
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTextHint, size: 22),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(kRadiusSm),
    );
  }

  
  
  
  Widget _buildActionButtons() {
    if (_currentStatus == 'Booking' || _currentStatus == 'Screening' || _currentStatus == 'Pending') {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 54,
              child: OutlinedButton(
                onPressed: _showCancellationReasonDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kPrimary,
                  side: const BorderSide(color: kPrimary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_rounded, size: 18, color: kPrimary),
                    SizedBox(width: 8),
                    Text('Cancelled', style: TextStyle(color: kPrimary, fontWeight: FontWeight.w800, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: () => _updateStatusAndData('Collected', validateForm: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSuccess,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: kSuccess.withOpacity(0.35),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Confirm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14)),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else if (_currentStatus == 'Collected') {
      return SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => _updateStatusAndData('Refreshment', validateForm: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: kInfo,
            foregroundColor: Colors.white,
            elevation: 0,
            shadowColor: kInfo.withOpacity(0.35),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_drink_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Text(
                'Send to Refreshment',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.2),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: kSuccessLight,
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
              child: const Icon(Icons.check_circle_rounded, color: kSuccess, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'Process completed for this donor',
              style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.w800, fontSize: 13.5),
            ),
          ],
        ),
      );
    }
  }
}