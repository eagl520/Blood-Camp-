import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';


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
const Color kFieldFill = Color(0xFFF7F8FA);
const Color kFieldBorder = Color(0xFFE5E7EB);
const Color kDivider = Color(0xFFF0F0F5);
const double kRadius = 22;
const double kRadiusSm = 14;

class NewCampScreen extends StatefulWidget {
  const NewCampScreen({super.key});

  @override
  State<NewCampScreen> createState() => _NewCampScreenState();
}

class _NewCampScreenState extends State<NewCampScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _seatsCtrl = TextEditingController(text: '10');
  final _imageUrlController = TextEditingController();

  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  int _slotSize = 60;
  final Set<String> _neededGroups = {};

  final List<String> _selectedStaffIds = [];

  bool _isLoading = false;
  bool _isImageUploading = false;

  
  final List<String> _allBloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  
  final List<String> _bloodGroupList = ['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _uploadImageToImgBB(XFile imageFile) async {
    setState(() => _isImageUploading = true);
    try {
      const apiKey = '9d9feb3885f93cd616338d09807e3d25';
      var request = http.MultipartRequest('POST', Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'));

      if (kIsWeb) {
        Uint8List bytes = await imageFile.readAsBytes();
        request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name));
      } else {
        request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        setState(() => _imageUrlController.text = jsonResponse['data']['url']);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image uploaded successfully!')));
      } else {
        throw 'Failed to upload image';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isImageUploading = false);
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) await _uploadImageToImgBB(image);
  }

  Future<void> _submitCampToFirebase() async {
    if (!_formKey.currentState!.validate()) return;
    if (_neededGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one blood group needed.')),
      );
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date cannot be before start date.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String formattedStartDate = _fmtDate(_startDate);
      String formattedEndDate = _fmtDate(_endDate);

      final DocumentReference campRef =
          FirebaseFirestore.instance.collection('camps').doc();

      await campRef.set({
        'campId': campRef.id,
        'name': _titleCtrl.text.trim(),
        'date': formattedStartDate,
        'dateTime': Timestamp.fromDate(_startDate),
        'startDate': formattedStartDate,
        'endDate': formattedEndDate,
        'startDateTime': Timestamp.fromDate(_startDate),
        'endDateTime': Timestamp.fromDate(_endDate),
        'city': _cityCtrl.text.trim(),
        'location': _venueCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'organizerPhone': _phoneCtrl.text.trim(),
        'instructions': _instructionsCtrl.text.trim(),
        'slotSizeMinutes': _slotSize,
        'seats': _seatsCtrl.text.trim(),
        'seatsLeft': 0,
        'bookedSeats': 0,
        'bloodGroupsNeeded': _neededGroups.toList(),
        'assignedStaffIds': _selectedStaffIds,
        'imageUrl': _imageUrlController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (_selectedStaffIds.isNotEmpty) {
        for (String staffId in _selectedStaffIds) {
          await FirebaseFirestore.instance.collection('users').doc(staffId).update({
            'status': 'On Duty',
            'currentCampId': campRef.id,
          });
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _cityCtrl.dispose();
    _venueCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _instructionsCtrl.dispose();
    _seatsCtrl.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.add_business_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Create New Camp',
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
              _buildInfoBanner(),
              const SizedBox(height: 24),

              _buildSectionHeader(icon: Icons.image_rounded, title: "Camp Image"),
              const SizedBox(height: 14),
              _buildImageUploader(),
              const SizedBox(height: 28),

              _buildSectionHeader(icon: Icons.info_rounded, title: "Basic Info"),
              const SizedBox(height: 14),

              _buildFieldLabel("Camp Title"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _titleCtrl,
                icon: Icons.water_drop_rounded,
                iconColor: kPrimary,
                hint: "Enter camp title",
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _buildDatePicker(
                label: 'Start Date',
                icon: Icons.calendar_today_rounded,
                date: _startDate,
                firstDate: DateTime.now(),
                onPick: (picked) {
                  setState(() {
                    _startDate = picked;
                    if (_endDate.isBefore(_startDate)) {
                      _endDate = _startDate;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              _buildDatePicker(
                label: 'End Date',
                icon: Icons.event_available_rounded,
                date: _endDate,
                firstDate: _startDate,
                onPick: (picked) {
                  setState(() => _endDate = picked);
                },
              ),
              const SizedBox(height: 28),

              _buildSectionHeader(icon: Icons.location_on_rounded, title: "Location"),
              const SizedBox(height: 14),

              _buildFieldLabel("City"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _cityCtrl,
                icon: Icons.location_city_rounded,
                hint: "Enter city",
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel("Venue / Campus"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _venueCtrl,
                icon: Icons.location_pin,
                hint: "Enter venue name",
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel("Address / Map Note"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _addressCtrl,
                icon: Icons.map_rounded,
                hint: "Enter full address",
                maxLines: 2,
              ),
              const SizedBox(height: 28),

              _buildSectionHeader(icon: Icons.contact_phone_rounded, title: "Contact & Instructions"),
              const SizedBox(height: 14),

              _buildFieldLabel("Organizer Phone"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _phoneCtrl,
                icon: Icons.phone_rounded,
                hint: "Enter phone number",
                keyboardType: TextInputType.phone,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              _buildFieldLabel("Description"),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _instructionsCtrl,
                icon: Icons.info_rounded,
                hint: "What should donors bring?",
                maxLines: 3,
              ),
              const SizedBox(height: 28),

              _buildSectionHeader(icon: Icons.event_seat_rounded, title: "Slots & Capacity"),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel("Slot Size"),
                        const SizedBox(height: 8),
                        _buildDropdown<int>(
                          value: _slotSize,
                          icon: Icons.timer_rounded,
                          items: const [
                            DropdownMenuItem(value: 30, child: Text('30 minutes')),
                            DropdownMenuItem(value: 60, child: Text('60 minutes')),
                          ],
                          onChanged: (v) => setState(() => _slotSize = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel("Seats / Slot"),
                        const SizedBox(height: 8),
                        _buildTextField(
                          controller: _seatsCtrl,
                          icon: Icons.people_rounded,
                          hint: "10",
                          keyboardType: TextInputType.number,
                          validator: (v) => (int.tryParse(v ?? '') == null) ? 'Required' : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              _buildSectionHeader(icon: Icons.bloodtype_rounded, title: "Blood Groups Needed"),
              const SizedBox(height: 6),
              const Text(
                "Select at least one blood group",
                style: TextStyle(fontSize: 11.5, color: kTextHint, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              _buildBloodGroupSelector(),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitCampToFirebase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shadowColor: kPrimary.withOpacity(0.35),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_circle_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 10),
                            Text(
                              'Create Camp',
                              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.2),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  "Assigned staff will be marked as On Duty",
                  style: TextStyle(fontSize: 11.5, color: kTextHint, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  
  
  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryLight.withOpacity(0.35), kPrimaryLight.withOpacity(0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(kRadius),
        border: Border.all(color: kPrimaryLight.withOpacity(0.6), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add_business_rounded, color: kPrimary, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Launch a New Camp",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: kPrimaryDark,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "Fill in the details below to publish your blood donation camp.",
                  style: TextStyle(fontSize: 12, color: kTextSecondary, fontWeight: FontWeight.w500, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
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
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 1,
            color: kDivider,
          ),
        ),
      ],
    );
  }

  
  
  
  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: kTextPrimary,
        letterSpacing: 0.1,
      ),
    );
  }

  
  
  
  Widget _buildImageUploader() {
    return GestureDetector(
      onTap: _isImageUploading ? null : _pickImageFromGallery,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: kFieldFill,
          borderRadius: BorderRadius.circular(kRadius),
          border: Border.all(
            color: _imageUrlController.text.isEmpty ? kFieldBorder : kPrimary.withOpacity(0.4),
            width: 1.5,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _isImageUploading
            ? const Center(child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5))
            : _imageUrlController.text.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: kPrimaryLight.withOpacity(0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_a_photo_rounded, size: 30, color: kPrimary),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tap to add camp image',
                        style: TextStyle(color: kTextPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'JPG, PNG up to 5MB',
                        style: TextStyle(color: kTextHint, fontSize: 11.5, fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(_imageUrlController.text, fit: BoxFit.cover),
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit_rounded, size: 12, color: Colors.white),
                              SizedBox(width: 4),
                              Text(
                                'Change',
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  
  
  
  Widget _buildDatePicker({
    required String label,
    required IconData icon,
    required DateTime date,
    required DateTime firstDate,
    required ValueChanged<DateTime> onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date.isBefore(firstDate) ? firstDate : date,
                firstDate: firstDate,
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) onPick(picked);
            },
            borderRadius: BorderRadius.circular(kRadiusSm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: kFieldFill,
                borderRadius: BorderRadius.circular(kRadiusSm),
                border: Border.all(color: kFieldBorder, width: 1.2),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: kTextHint),
                  const SizedBox(width: 12),
                  Text(
                    _fmtDate(date),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary),
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: kTextHint),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  
  
  
  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required IconData icon,
    Color iconColor = kTextHint,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: kTextHint, fontWeight: FontWeight.w500),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
        filled: true,
        fillColor: kFieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kFieldBorder, width: 1.2),
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

  
  
  
  Widget _buildDropdown<T>({
    required T value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      items: items,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kTextPrimary),
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14, right: 10),
          child: Icon(icon, size: 20, color: kTextHint),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 48),
        filled: true,
        fillColor: kFieldFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kFieldBorder, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(kRadiusSm),
          borderSide: const BorderSide(color: kPrimary, width: 1.6),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: kTextHint, size: 22),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(kRadiusSm),
    );
  }

  
  
  
  Widget _buildBloodGroupSelector() {
    
    final bool allSelected = _allBloodGroups.every((g) => _neededGroups.contains(g));

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _bloodGroupList.map((bg) {
        
        final bool isAllChip = bg == 'All';
        final bool selected = isAllChip ? allSelected : _neededGroups.contains(bg);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                if (isAllChip) {
                  
                  if (allSelected) {
                    _neededGroups.clear();
                  } else {
                    _neededGroups.clear();
                    _neededGroups.addAll(_allBloodGroups);
                  }
                } else {
                  
                  if (selected) {
                    _neededGroups.remove(bg);
                  } else {
                    _neededGroups.add(bg);
                  }
                }
              });
            },
            borderRadius: BorderRadius.circular(30),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                gradient: selected
                    ? const LinearGradient(
                        colors: [kPrimaryDark, kPrimary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selected ? null : kFieldFill,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selected ? Colors.transparent : kFieldBorder,
                  width: 1.2,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: kPrimary.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    const Icon(Icons.check_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                  ],
                  
                  if (isAllChip && !selected) ...[
                    const Icon(Icons.apps_rounded, size: 14, color: kTextSecondary),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    bg,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : kTextSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}