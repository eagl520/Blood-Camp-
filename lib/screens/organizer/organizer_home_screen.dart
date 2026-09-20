import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'create_camp.dart';
import 'add_new_staff.dart';
import './reports_screen.dart';
import 'profile_screen.dart';


const Color kPrimary = Color(0xFFE53935);
const Color kPrimaryDark = Color(0xFFB71C1C);
const Color kPrimaryLight = Color(0xFFFFCDD2);
const Color kSuccess = Color(0xFF2E7D32);
const Color kSuccessLight = Color(0xFFE8F5E9);
const Color kInfo = Color(0xFF1565C0);
const Color kInfoLight = Color(0xFFE3F2FD);
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

class OrganizerScreen extends StatefulWidget {
  const OrganizerScreen({super.key});

  @override
  State<OrganizerScreen> createState() => _OrganizerScreenState();
}

class _OrganizerScreenState extends State<OrganizerScreen> {
  int _currentIndex = 0;

  
  final List<String> _allBloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _bloodGroupListDisplay = ['All', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  
  
  
  void _showEditCampDialog(BuildContext context, String campId, Map<String, dynamic> currentData) {
    final nameController = TextEditingController(text: currentData['name'] ?? '');
    final locationController = TextEditingController(text: currentData['location'] ?? '');
    final cityController = TextEditingController(text: currentData['city'] ?? '');
    final addressController = TextEditingController(text: currentData['address'] ?? '');
    final coordinatorController = TextEditingController(text: currentData['coordinator'] ?? '');
    final seatsController = TextEditingController(text: currentData['seats']?.toString() ?? '');
    final phoneController = TextEditingController(text: currentData['organizerPhone'] ?? '');
    final instructionsController = TextEditingController(text: currentData['instructions'] ?? '');
    final imageUrlController = TextEditingController(text: currentData['imageUrl'] ?? '');

    final formKey = GlobalKey<FormState>();

    
    final Set<String> _selectedGroups = {};
    final List<dynamic> existingGroups = currentData['bloodGroupsNeeded'] ?? [];
    for (var g in existingGroups) {
      if (_allBloodGroups.contains(g.toString())) {
        _selectedGroups.add(g.toString());
      }
    }

    
    DateTime? startDate;
    DateTime? endDate;

    final String existingStartStr = currentData['startDate'] ?? currentData['date'] ?? '';
    if (existingStartStr.isNotEmpty) {
      try {
        final parts = existingStartStr.split('/');
        if (parts.length == 3) {
          startDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        } else {
          startDate = DateTime.tryParse(existingStartStr);
        }
      } catch (_) {
        startDate = DateTime.tryParse(existingStartStr);
      }
    }

    final String existingEndStr = currentData['endDate'] ?? '';
    if (existingEndStr.isNotEmpty) {
      try {
        final parts = existingEndStr.split('/');
        if (parts.length == 3) {
          endDate = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
        } else {
          endDate = DateTime.tryParse(existingEndStr);
        }
      } catch (_) {
        endDate = DateTime.tryParse(existingEndStr);
      }
    }
    endDate ??= startDate;

    bool isImageUploading = false;

    String fmtDate(DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickAndUploadImage() async {
              try {
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image == null) return;

                setDialogState(() => isImageUploading = true);

                const apiKey = '9d9feb3885f93cd616338d09807e3d25';
                var request = http.MultipartRequest(
                  'POST',
                  Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'),
                );

                if (kIsWeb) {
                  Uint8List bytes = await image.readAsBytes();
                  request.files.add(http.MultipartFile.fromBytes('image', bytes, filename: image.name));
                } else {
                  request.files.add(await http.MultipartFile.fromPath('image', image.path));
                }

                var streamedResponse = await request.send();
                var response = await http.Response.fromStream(streamedResponse);

                if (response.statusCode == 200) {
                  var jsonResponse = jsonDecode(response.body);
                  setDialogState(() {
                    imageUrlController.text = jsonResponse['data']['url'];
                    isImageUploading = false;
                  });
                } else {
                  throw 'Upload failed';
                }
              } catch (e) {
                setDialogState(() => isImageUploading = false);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Image upload error: $e')),
                  );
                }
              }
            }

            
            final bool allSelected = _allBloodGroups.every((g) => _selectedGroups.contains(g));

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
              contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: kPrimaryLight.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.edit_rounded, color: kPrimary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Edit Camp',
                      style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.w800, fontSize: 17, letterSpacing: -0.2),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        
                        
                        const Text(
                          'Camp Image',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: kTextPrimary, letterSpacing: 0.1),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: isImageUploading ? null : pickAndUploadImage,
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: kFieldFill,
                              borderRadius: BorderRadius.circular(kRadiusSm),
                              border: Border.all(
                                color: imageUrlController.text.isEmpty ? kFieldBorder : kPrimary.withOpacity(0.4),
                                width: 1.4,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: isImageUploading
                                ? const Center(
                                    child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5),
                                  )
                                : imageUrlController.text.isEmpty
                                    ? Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: kPrimaryLight.withOpacity(0.35),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.add_a_photo_rounded, size: 26, color: kPrimary),
                                          ),
                                          const SizedBox(height: 10),
                                          const Text(
                                            'Tap to add image',
                                            style: TextStyle(color: kTextPrimary, fontSize: 13, fontWeight: FontWeight.w700),
                                          ),
                                        ],
                                      )
                                    : Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            imageUrlController.text,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: kPrimaryLight.withOpacity(0.3),
                                              child: const Center(
                                                child: Icon(Icons.broken_image_rounded, size: 40, color: kTextHint),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 10,
                                            right: 10,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.7),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.camera_alt_rounded, size: 12, color: Colors.white),
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
                        ),
                        const SizedBox(height: 16),

                        
                        
                        
                        _buildDialogSectionLabel("Basic Info"),
                        const SizedBox(height: 10),

                        _buildDialogField(
                          controller: nameController,
                          label: 'Camp Name',
                          icon: Icons.local_hospital_rounded,
                        ),
                        const SizedBox(height: 12),

                        _buildDialogDatePicker(
                          label: 'Start Date',
                          icon: Icons.calendar_today_rounded,
                          date: startDate,
                          onPick: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                            );
                            if (picked != null) {
                              setDialogState(() {
                                startDate = picked;
                                if (endDate != null && endDate!.isBefore(picked)) {
                                  endDate = picked;
                                }
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        _buildDialogDatePicker(
                          label: 'End Date',
                          icon: Icons.event_available_rounded,
                          date: endDate,
                          onPick: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: endDate ?? startDate ?? DateTime.now(),
                              firstDate: startDate ?? DateTime(2020),
                              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                            );
                            if (picked != null) {
                              setDialogState(() => endDate = picked);
                            }
                          },
                        ),
                        const SizedBox(height: 18),

                        
                        
                        
                        _buildDialogSectionLabel("Location"),
                        const SizedBox(height: 10),

                        _buildDialogField(
                          controller: cityController,
                          label: 'City',
                          icon: Icons.location_city_rounded,
                        ),
                        const SizedBox(height: 12),

                        _buildDialogField(
                          controller: locationController,
                          label: 'Venue / Campus',
                          icon: Icons.location_on_rounded,
                        ),
                        const SizedBox(height: 12),

                        _buildDialogField(
                          controller: addressController,
                          label: 'Address / Map Note',
                          icon: Icons.map_rounded,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 18),

                        
                        
                        
                        _buildDialogSectionLabel("Capacity & Contact"),
                        const SizedBox(height: 10),

                        _buildDialogField(
                          controller: seatsController,
                          label: 'Seats',
                          icon: Icons.event_seat_rounded,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),

                        _buildDialogField(
                          controller: phoneController,
                          label: 'Organizer Phone',
                          icon: Icons.phone_rounded,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 12),

                        _buildDialogField(
                          controller: instructionsController,
                          label: 'Description',
                          icon: Icons.info_rounded,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 18),

                        
                        
                        
                        _buildDialogSectionLabel("Blood Groups Needed"),
                        const SizedBox(height: 6),
                        const Text(
                          "Select at least one blood group",
                          style: TextStyle(fontSize: 11.5, color: kTextHint, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        _buildBloodGroupSelectorForDialog(
                          selectedGroups: _selectedGroups,
                          allSelected: allSelected,
                          onToggle: (bg, isAll) {
                            setDialogState(() {
                              if (isAll) {
                                if (allSelected) {
                                  _selectedGroups.clear();
                                } else {
                                  _selectedGroups.clear();
                                  _selectedGroups.addAll(_allBloodGroups);
                                }
                              } else {
                                if (_selectedGroups.contains(bg)) {
                                  _selectedGroups.remove(bg);
                                } else {
                                  _selectedGroups.add(bg);
                                }
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
                          onPressed: () => Navigator.pop(dialogContext),
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
                            if (startDate != null && endDate != null && endDate!.isBefore(startDate!)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('End date cannot be before start date.')),
                              );
                              return;
                            }

                            if (_selectedGroups.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Select at least one blood group.')),
                              );
                              return;
                            }

                            try {
                              final Map<String, dynamic> updateData = {
                                'name': nameController.text.trim(),
                                'location': locationController.text.trim(),
                                'city': cityController.text.trim(),
                                'address': addressController.text.trim(),
                                'coordinator': coordinatorController.text.trim(),
                                'seats': seatsController.text.trim(),
                                'organizerPhone': phoneController.text.trim(),
                                'instructions': instructionsController.text.trim(),
                                'imageUrl': imageUrlController.text.trim(),
                                
                                'bloodGroupsNeeded': _selectedGroups.toList(),
                              };

                              if (startDate != null) {
                                updateData['startDate'] = fmtDate(startDate!);
                                updateData['date'] = fmtDate(startDate!);
                                updateData['startDateTime'] = Timestamp.fromDate(startDate!);
                                updateData['dateTime'] = Timestamp.fromDate(startDate!);
                              }
                              if (endDate != null) {
                                updateData['endDate'] = fmtDate(endDate!);
                                updateData['endDateTime'] = Timestamp.fromDate(endDate!);
                              }

                              await FirebaseFirestore.instance
                                  .collection('camps')
                                  .doc(campId)
                                  .update(updateData);

                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Camp updated successfully!')),
                                );
                              }
                            } catch (e) {
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          },
                          child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
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

  
  
  
  Widget _buildBloodGroupSelectorForDialog({
    required Set<String> selectedGroups,
    required bool allSelected,
    required void Function(String bg, bool isAll) onToggle,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _bloodGroupListDisplay.map((bg) {
        final bool isAllChip = bg == 'All';
        final bool selected = isAllChip ? allSelected : selectedGroups.contains(bg);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onToggle(bg, isAllChip),
            borderRadius: BorderRadius.circular(30),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selected) ...[
                    const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                    const SizedBox(width: 5),
                  ],
                  if (isAllChip && !selected) ...[
                    const Icon(Icons.apps_rounded, size: 12, color: kTextSecondary),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    bg,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: selected ? Colors.white : kTextSecondary,
                      letterSpacing: 0.2,
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

  
  Widget _buildDialogSectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: kPrimary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: kTextHint,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  
  Widget _buildDialogDatePicker({
    required String label,
    required IconData icon,
    required DateTime? date,
    required VoidCallback onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: kTextSecondary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(kRadiusSm),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: kFieldFill,
                borderRadius: BorderRadius.circular(kRadiusSm),
                border: Border.all(color: kFieldBorder, width: 1.2),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: kTextHint),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      date == null
                          ? 'Select date'
                          : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kTextPrimary),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: kTextHint),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  
  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
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
      ),
    );
  }

  
  
  
  void _deleteCamp(BuildContext context, String campId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimaryLight.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.delete_outline_rounded, color: kPrimary, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Delete Camp',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: kTextPrimary, letterSpacing: -0.3),
            ),
            const SizedBox(height: 10),
            const Text(
              'Are you sure you want to delete this camp? This will also free up the assigned staff.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: kTextSecondary, height: 1.5),
            ),
          ],
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
                      Navigator.pop(context);
                      try {
                        DocumentSnapshot campDoc = await FirebaseFirestore.instance.collection('camps').doc(campId).get();

                        if (campDoc.exists) {
                          Map<String, dynamic> campData = campDoc.data() as Map<String, dynamic>;

                          if (campData.containsKey('assignedStaffIds') && campData['assignedStaffIds'] != null) {
                            List<dynamic> staffIds = campData['assignedStaffIds'];

                            for (String staffId in staffIds) {
                              await FirebaseFirestore.instance.collection('users').doc(staffId).update({
                                'status': 'Available',
                                'currentCampId': FieldValue.delete(),
                              });
                            }
                          }
                        }

                        await FirebaseFirestore.instance.collection('camps').doc(campId).delete();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Camp deleted and staff is now available!')),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $e')),
                          );
                        }
                      }
                    },
                    child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      extendBody: true,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.event_available_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'My Camps',
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('camps')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimary, strokeWidth: 2.5),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final campsDocs = snapshot.data!.docs;

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            itemCount: campsDocs.length,
            itemBuilder: (context, index) {
              final campDoc = campsDocs[index];
              final campData = campDoc.data() as Map<String, dynamic>;
              final campId = campDoc.id;
              return _buildCampCard(campData, campId);
            },
          );
        },
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
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NewCampScreen()),
            );
          },
          backgroundColor: kPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
          label: const Text(
            'New Camp',
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
                    break;
                  case 1:
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const StaffScreen()),
                    );
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

  
  
  
  Widget _buildCampCard(Map<String, dynamic> campData, String campId) {
    final String imageUrl = campData['imageUrl'] ?? '';
    final String campName = campData['name'] ?? 'Untitled Camp';
    final String location = campData['address'] ?? 'No location';
    final String startDate = campData['startDate'] ?? campData['date'] ?? 'No date';
    final String endDate = campData['endDate'] ?? '';
    final String coordinator = campData['organizerPhone'] ?? 'No coordinator';
    final String seats = campData['seats']?.toString() ?? '0';
    final String seatsLeft = campData['seatsLeft']?.toString() ?? '0';

    
    final List<dynamic> rawGroups = campData['bloodGroupsNeeded'] ?? [];
    final String bloodGroups = rawGroups.join(', ');

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(kRadius)),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          height: 165,
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
                        colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                        stops: const [0.5, 1.0],
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
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.people_rounded, size: 13, color: kPrimary),
                        const SizedBox(width: 5),
                        Text(
                          '$seats / $seatsLeft',
                          style: const TextStyle(
                            color: kPrimaryDark,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 14,
                  right: 14,
                  child: Text(
                    campName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      shadows: [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.person_rounded,
                    label: 'Phone No',
                    value: coordinator,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'Start Date',
                    value: startDate,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'End Date',
                    value: endDate,
                  ),
                  const SizedBox(height: 10),
                  _buildDetailRow(
                    icon: Icons.location_on_rounded,
                    label: 'Location',
                    value: location,
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
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: OutlinedButton(
                            onPressed: () => _showEditCampDialog(context, campId, campData),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kInfo,
                              side: BorderSide(color: kInfo.withOpacity(0.3), width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_rounded, size: 15, color: kInfo),
                                SizedBox(width: 6),
                                Text(
                                  'Edit',
                                  style: TextStyle(color: kInfo, fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: OutlinedButton(
                            onPressed: () => _deleteCamp(context, campId),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kPrimary,
                              side: BorderSide(color: kPrimary.withOpacity(0.3), width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.delete_outline_rounded, size: 15, color: kPrimary),
                                SizedBox(width: 6),
                                Text(
                                  'Delete',
                                  style: TextStyle(color: kPrimary, fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
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
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
              letterSpacing: -0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildImageFallback() {
    return Container(
      height: 165,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryLight.withOpacity(0.6), kPrimaryLight.withOpacity(0.2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: Icon(Icons.local_hospital_rounded, size: 52, color: kPrimary),
      ),
    );
  }

  
  
  
  Widget _buildEmptyState() {
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
              child: Icon(Icons.event_busy_rounded, size: 44, color: kPrimary.withOpacity(0.5)),
            ),
            const SizedBox(height: 18),
            const Text(
              'No camps yet',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: kTextPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Create your first camp using the button below.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: kTextHint, fontWeight: FontWeight.w500, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }
}