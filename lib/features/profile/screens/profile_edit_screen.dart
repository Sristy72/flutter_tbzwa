import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../home/models/learner_api_models.dart';
import '../../home/services/learner_api_service.dart';

class ProfileEditScreen extends StatefulWidget {
  final LearnerProfile? profile;

  const ProfileEditScreen({super.key, this.profile});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final LearnerApiService _api = LearnerApiService();
  LearnerProfile? _profile;
  bool _isSaving = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
    _nameController.text = widget.profile?.fullName ?? '';
    if (widget.profile == null) _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _api.getProfile();
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _nameController.text = profile.fullName;
      });
    } catch (error) {
      if (mounted) {
        Get.snackbar(
          'Unable to load profile',
          error.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_isSaving || !_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final updated = await _api.updateProfile(
        fullName: _nameController.text.trim(),
        profileImage: _imageFile,
      );
      if (!mounted) return;
      Get.back(result: updated);
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: const Color(0xFF22A892),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      if (mounted) {
        Get.snackbar(
          'Update failed',
          error.toString().replaceFirst('Exception: ', ''),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to pick image: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF22A892),
                ),
                title: const Text('Photo Library',
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: Color(0xFF22A892),
                ),
                title: const Text('Camera',
                    style: TextStyle(color: Colors.black)),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: Text(
              _isSaving ? "Saving..." : "Save",
              style: const TextStyle(
                color: Color(0xFF22A892),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with Profile Picture
            Container(
              color: Colors.white,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 32, top: 16),
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF1F5F9),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => _showPicker(context),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: const Color(0xFFF1F5F9),
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!) as ImageProvider
                              : _profile?.profileImageUrl?.isNotEmpty == true
                              ? NetworkImage(_profile!.profileImageUrl!)
                              : const AssetImage(
                                      'assets/images/default_user_avatar.png',
                                    )
                                    as ImageProvider,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _showPicker(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22A892),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Form Fields
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel("PERSONAL INFORMATION"),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: "Full Name",
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      validator: (value) =>
                          value!.isEmpty ? "Please enter your name" : null,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Color(0xFF94A3B8),
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1E293B),
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF22A892), size: 22),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }
}
