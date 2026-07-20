import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/api/socket_client.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/services/auth_storage_service.dart';
import '../../../core/services/smart_media_service.dart';
import '../../auth/controller/auth_controller.dart';
import '../../auth/screens/login_screen.dart';
import 'instructor_home_controller.dart';
import '../models/instructor_profile_model.dart';
import '../services/instructor_profile_service.dart';

class InstructorProfileController extends GetxController {
  final InstructorProfileService _service = InstructorProfileService();
  final SmartMediaService _mediaService = Get.isRegistered<SmartMediaService>()
      ? Get.find<SmartMediaService>()
      : SmartMediaService();

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  final profile = Rxn<InstructorProfile>();
  final groups = <InstructorProfileGroup>[].obs;
  final isLoading = false.obs;
  final isGroupsLoading = false.obs;
  final isSaving = false.obs;
  final isUploadingAvatar = false.obs;
  final isLoggingOut = false.obs;
  final isUpdatingNotifications = false.obs;
  final errorMessage = ''.obs;
  final groupsErrorMessage = ''.obs;

  static const int _maxAvatarBytes = 5 * 1024 * 1024;
  static const _allowedAvatarExtensions = {'jpg', 'jpeg', 'png', 'webp'};

  @override
  void onInit() {
    super.onInit();
    unawaited(loadProfile());
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.onClose();
  }

  Future<void> loadProfile({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;
    isLoading.value = true;
    errorMessage.value = '';
    groupsErrorMessage.value = '';
    try {
      final results = await Future.wait([
        _service.getProfile(),
        _loadGroupsSafely(),
      ]);
      profile.value = results[0] as InstructorProfile;
      _prefillEditFields(profile.value);
    } catch (error) {
      errorMessage.value = _cleanError(error);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProfile() => loadProfile(refresh: true);

  Future<List<InstructorProfileGroup>> _loadGroupsSafely() async {
    isGroupsLoading.value = true;
    try {
      final assignedGroups = await _service.getAssignedGroups();
      groups.assignAll(assignedGroups);
      return assignedGroups;
    } catch (error) {
      groupsErrorMessage.value = _cleanError(error);
      return const [];
    } finally {
      isGroupsLoading.value = false;
    }
  }

  void prepareEdit() {
    _prefillEditFields(profile.value);
  }

  Future<void> saveProfile() async {
    if (isSaving.value) return;
    final current = profile.value;
    if (current == null) {
      _showError('Profile is still loading.');
      return;
    }

    final validationError = _validateEditFields();
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    isSaving.value = true;
    try {
      final changedEmail =
          emailController.text.trim().toLowerCase() !=
              current.email.trim().toLowerCase()
          ? emailController.text.trim()
          : null;
      final updated = await _service.updateProfile(
        fullName: nameController.text,
        phone: phoneController.text,
        bio: bioController.text,
        changedEmail: changedEmail,
      );
      profile.value = updated;
      _prefillEditFields(updated);
      await _refreshInstructorHome();
      Get.back();
      Get.snackbar(
        'Profile updated',
        'Your profile has been saved.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError(_cleanError(error));
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> pickAvatar(ImageSource source) async {
    if (isUploadingAvatar.value) return;
    final current = profile.value;
    if (current == null) {
      _showError('Profile is still loading.');
      return;
    }

    final picked = await _mediaService.pickImage(source: source);
    if (picked == null) return;

    final file = File(picked.path);
    final validationError = await _validateAvatarFile(file);
    if (validationError != null) {
      _showError(validationError);
      return;
    }

    isUploadingAvatar.value = true;
    try {
      final updated = await _service.updateProfile(
        fullName: current.fullName,
        phone: current.phone,
        bio: current.bio,
        profileImage: file,
      );
      profile.value = updated;
      await _refreshInstructorHome();
      Get.snackbar(
        'Avatar updated',
        'Your profile photo has been saved.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError(_cleanError(error));
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  Future<void> updateNotifications(bool enabled) async {
    if (isUpdatingNotifications.value) return;
    final current = profile.value;
    if (current == null) return;
    profile.value = current.copyWith(notificationsEnabled: enabled);
    isUpdatingNotifications.value = true;
    try {
      await _service.updateNotificationPreference(enabled);
      profile.value = (await _service.getProfile()).copyWith(
        notificationsEnabled: enabled,
      );
    } catch (error) {
      profile.value = current;
      _showError(_cleanError(error));
    } finally {
      isUpdatingNotifications.value = false;
    }
  }

  Future<void> logout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    try {
      if (Get.isRegistered<AuthController>()) {
        await Get.find<AuthController>().logout();
      } else {
        SocketClient().disconnect();
        await AuthStorageService().clearAuthData();
        Get.offAll(() => const LoginScreen());
      }
    } finally {
      isLoggingOut.value = false;
    }
  }

  void showPrivacySecurityUnavailable() {
    Get.snackbar(
      'Privacy & Security',
      'Password and security controls are not available in this screen yet.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Color groupColor(InstructorProfileGroup group, int index) {
    final parsed = _parseColor(group.themeColor);
    if (parsed != null) return parsed;
    const colors = [
      Color(0xFF5151EF),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
    ];
    return colors[index % colors.length];
  }

  String groupStudentsText(InstructorProfileGroup group) {
    final count = group.displayStudentCount;
    return count == 1 ? '1 Student' : '$count Students';
  }

  ImageProvider? avatarImageProvider() {
    final url = profile.value?.profileImageUrl?.trim();
    if (url == null || url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.hasScheme) return NetworkImage(url);
    if (url.startsWith('/')) {
      return NetworkImage('${ApiConstants.baseDomain}$url');
    }
    return null;
  }

  String? _validateEditFields() {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final bio = bioController.text.trim();

    if (name.isEmpty) return 'Name is required.';
    if (email.isEmpty) return 'Email is required.';
    final emailValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!emailValid) return 'Enter a valid email address.';
    if (phone.isNotEmpty) {
      final phoneValid = RegExp(r'^[0-9+()\-\s]{6,24}$').hasMatch(phone);
      if (!phoneValid) return 'Enter a valid phone number.';
    }
    if (bio.length > 500) return 'Bio cannot exceed 500 characters.';
    return null;
  }

  Future<String?> _validateAvatarFile(File file) async {
    if (!await file.exists()) return 'Selected image could not be found.';
    final extension = file.path.split('.').last.toLowerCase();
    if (!_allowedAvatarExtensions.contains(extension)) {
      return 'Use a JPG, PNG, or WEBP image.';
    }
    final length = await file.length();
    if (length > _maxAvatarBytes) {
      return 'Profile image cannot exceed 5MB.';
    }
    return null;
  }

  void _prefillEditFields(InstructorProfile? value) {
    if (value == null) return;
    nameController.text = value.fullName;
    phoneController.text = value.phone;
    emailController.text = value.email;
    bioController.text = value.bio;
  }

  Future<void> _refreshInstructorHome() async {
    if (Get.isRegistered<InstructorHomeController>()) {
      await Get.find<InstructorHomeController>().refreshHome();
    }
  }

  Color? _parseColor(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final hex = value.replaceFirst('#', '');
    if (hex.length != 6) return null;
    final parsed = int.tryParse('FF$hex', radix: 16);
    return parsed == null ? null : Color(parsed);
  }

  void _showError(String message) {
    Get.snackbar(
      'Unable to continue',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
