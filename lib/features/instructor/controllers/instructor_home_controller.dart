import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/instructor_home_model.dart';
import '../screens/instructor_groups_screen.dart';
import '../screens/instructor_schedule_screen.dart';
import '../screens/instructor_messages_screen.dart';
import '../services/instructor_home_service.dart';

class InstructorHomeController extends GetxController {
  final InstructorHomeService _service = InstructorHomeService();

  final home = Rxn<InstructorHomeModel>();
  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final errorMessage = ''.obs;
  final startingClassIds = <String>{}.obs;
  bool _isOpeningSchedule = false;
  bool _isOpeningGroups = false;

  @override
  void onInit() {
    super.onInit();
    loadHome();
  }

  InstructorHomeModel? get data => home.value;

  String get instructorName =>
      data?.instructor.fullName.trim().isNotEmpty == true
      ? data!.instructor.fullName.trim()
      : '...';

  String get instructorFirstName {
    final name = data?.instructor.fullName.trim();
    if (name == null || name.isEmpty) return '...';
    return name.split(RegExp(r'\s+')).first;
  }

  String get instructorId {
    final value = data?.instructor.userId.trim();
    return value == null || value.isEmpty ? '...' : value;
  }

  String get balanceText {
    final wallet = data?.wallet;
    if (wallet == null) return '...';
    if (wallet.currency == 'USD') {
      return '\$${wallet.balance.toStringAsFixed(2)}';
    }
    return '${wallet.currency} ${wallet.balance.toStringAsFixed(2)}';
  }

  String get totalStudentsText => data?.stats.totalStudents.toString() ?? '...';

  String get activeGroupsText => data?.stats.activeGroups.toString() ?? '...';

  String get todayClassesText => data?.stats.todayClasses.toString() ?? '...';

  String get pendingMessagesText =>
      data?.stats.pendingMessages.toString() ?? '...';

  List<InstructorHomeClass> get todayClasses => data?.todayClasses ?? const [];

  List<InstructorHomeClass> get upcomingSessions =>
      data?.upcomingSessions ?? const [];

  List<InstructorHomeGroup> get assignedGroups =>
      data?.assignedGroups ?? const [];

  bool isStartingClass(String classId) => startingClassIds.contains(classId);

  Future<void> loadHome({bool refresh = false}) async {
    if (refresh) {
      isRefreshing.value = true;
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      home.value = await _service.getHome();
    } catch (error) {
      errorMessage.value = _cleanError(error);
      if (!refresh) home.value ??= null;
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> refreshHome() => loadHome(refresh: true);

  Future<void> createRoom({
    required String name,
    required String groupId,
    required String privacy,
  }) async {
    if (name.trim().isEmpty) {
      _showError('Room name is required.');
      return;
    }
    if (groupId.trim().isEmpty) {
      _showError('Please select a group.');
      return;
    }

    try {
      await _service.createRoom(name: name, groupId: groupId, privacy: privacy);
      Get.back();
      await refreshHome();
      Get.snackbar(
        'Room created',
        'Your room is ready.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError(_cleanError(error));
    }
  }

  Future<void> startNextClass() async {
    InstructorHomeClass? nextClass;
    for (final item in todayClasses) {
      if (item.status == 'scheduled' || item.status == 'live') {
        nextClass = item;
        break;
      }
    }
    if (nextClass == null) {
      _showError('No scheduled class is available today.');
      return;
    }
    await startClass(nextClass);
  }

  Future<void> startClass(InstructorHomeClass liveClass) async {
    if (liveClass.id.isEmpty || isStartingClass(liveClass.id)) return;
    if (liveClass.status == 'live') {
      await _openClassLink(liveClass.zoomLink);
      return;
    }
    startingClassIds.add(liveClass.id);
    try {
      final zoomLink = await _service.startClass(liveClass.id);
      await refreshHome();
      await _openClassLink(zoomLink);
    } catch (error) {
      _showError(_cleanError(error));
    } finally {
      startingClassIds.remove(liveClass.id);
    }
  }

  void openSchedule() {
    if (_isOpeningSchedule) return;
    _isOpeningSchedule = true;
    Get.to(() => const InstructorScheduleScreen())?.whenComplete(() {
      _isOpeningSchedule = false;
    });
  }

  void openGroups() {
    if (_isOpeningGroups) return;
    _isOpeningGroups = true;
    Get.to(
      () => const InstructorGroupsScreen(showBackButton: true),
    )?.whenComplete(() {
      _isOpeningGroups = false;
    });
  }

  void openNotifications() {
    final unread = data?.stats.unreadNotifications ?? 0;
    Get.snackbar(
      'Notifications',
      unread == 0
          ? 'No unread notifications.'
          : '$unread unread notifications.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void openMessages() {
    Get.to(() => const InstructorMessagesScreen());
  }

  String classSubtitle(InstructorHomeClass liveClass) {
    final groupName = liveClass.groupName.trim().isEmpty
        ? 'Group'
        : liveClass.groupName.trim();
    final students = liveClass.studentCount == 1
        ? '1 student'
        : '${liveClass.studentCount} students';
    return '$groupName • $students';
  }

  String classTimeRange(InstructorHomeClass liveClass) {
    final start = liveClass.scheduledAt;
    if (start == null) return 'Time unavailable';
    final end = start.add(Duration(minutes: liveClass.duration));
    final formatter = DateFormat('hh:mm a');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  String sessionDateLabel(InstructorHomeClass liveClass) {
    final scheduledAt = liveClass.scheduledAt;
    if (scheduledAt == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(scheduledAt.year, scheduledAt.month, scheduledAt.day);
    final difference = date.difference(today).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';
    if (difference > 1 && difference < 7) return DateFormat('EEE').format(date);
    return DateFormat('MMM d').format(date);
  }

  String groupStudentsText(InstructorHomeGroup group) {
    if (group.totalStudents == 1) return '1 student';
    return '${group.totalStudents} students';
  }

  String groupLetter(InstructorHomeGroup group) {
    final name = group.name.trim();
    if (name.isEmpty) return 'G';
    return name.characters.first.toUpperCase();
  }

  Color groupColor(InstructorHomeGroup group, int index) {
    final parsed = _parseColor(group.themeColor);
    if (parsed != null) return parsed;
    const fallbacks = [
      Color(0xFF5151EF),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
    ];
    return fallbacks[index % fallbacks.length];
  }

  Color? _parseColor(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final hex = value.replaceFirst('#', '');
    if (hex.length != 6) return null;
    final parsed = int.tryParse('FF$hex', radix: 16);
    return parsed == null ? null : Color(parsed);
  }

  Future<void> _openClassLink(String? zoomLink) async {
    if (zoomLink == null || zoomLink.trim().isEmpty) {
      Get.snackbar(
        'Class started',
        'No class link is available yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final uri = Uri.tryParse(zoomLink.trim());
    final opened =
        uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      Get.snackbar(
        'Class started',
        zoomLink,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
