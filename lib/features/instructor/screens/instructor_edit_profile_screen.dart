import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/instructor_profile_controller.dart';

class InstructorEditProfileScreen extends StatefulWidget {
  const InstructorEditProfileScreen({super.key});

  @override
  State<InstructorEditProfileScreen> createState() =>
      _InstructorEditProfileScreenState();
}

class _InstructorEditProfileScreenState
    extends State<InstructorEditProfileScreen> {
  late final InstructorProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<InstructorProfileController>()
        ? Get.find<InstructorProfileController>()
        : Get.put(InstructorProfileController());
    _controller.prepareEdit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Account",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          Obx(
            () => TextButton(
              onPressed: _controller.isSaving.value
                  ? null
                  : _controller.saveProfile,
              child: const Text(
                "Done",
                style: TextStyle(
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () => _showAvatarSourceSheet(context),
                child: Obx(() {
                  final avatar = _controller.avatarImageProvider();
                  final profile = _controller.profile.value;
                  return Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFE5E7EB),
                        backgroundImage: avatar,
                        child: avatar == null
                            ? Text(
                                profile?.initials ?? 'I',
                                style: const TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                      if (_controller.isUploadingAvatar.value)
                        const Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0x66000000),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1F2937),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              label: "Name",
              hint: "Name",
              controller: _controller.nameController,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: "Phone Number",
              hint: "Phone Number",
              controller: _controller.phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: "Email",
              hint: "Email",
              controller: _controller.emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: "Bio",
              hint: "Bio",
              controller: _controller.bioController,
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: Color(0xFF1F2937),
                ),
                title: const Text(
                  "Camera",
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _controller.pickAvatar(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF1F2937),
                ),
                title: const Text(
                  "Gallery",
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _controller.pickAvatar(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Color(0xFF4B5563)),
                title: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4B5563),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: const BorderSide(color: Color(0xFF5151EF)),
            ),
          ),
        ),
      ],
    );
  }
}
