import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/instructor_group_model.dart';
import '../services/instructor_groups_service.dart';

class InstructorGroupsController extends GetxController {
  final InstructorGroupsService _service = InstructorGroupsService();

  final searchController = TextEditingController();
  final memberSearchController = TextEditingController();
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  final groups = <InstructorGroup>[].obs;
  final selectedGroup = Rxn<InstructorGroup>();
  final members = <InstructorGroupMember>[].obs;
  final messages = <InstructorGroupMessage>[].obs;
  final rooms = <InstructorGroupRoom>[].obs;
  final classes = <InstructorGroupClass>[].obs;

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final isDetailLoading = false.obs;
  final isSendingMessage = false.obs;
  final isCreatingRoom = false.obs;
  final errorMessage = ''.obs;
  final detailErrorMessage = ''.obs;
  final selectedStatus = 'all'.obs;
  final memberSearchQuery = ''.obs;
  final startingClassIds = <String>{}.obs;
  final joiningRoomIds = <String>{}.obs;

  Timer? _searchDebounce;
  int _page = 1;
  int _totalPages = 1;
  static const int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    scrollController.addListener(_onScroll);
    loadGroups();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    searchController.dispose();
    memberSearchController.dispose();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  bool get hasMore => _page < _totalPages;

  List<InstructorGroupMember> get filteredMembers {
    final query = memberSearchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return members;
    return members
        .where((member) => member.name.toLowerCase().contains(query))
        .toList();
  }

  InstructorGroupClass? get nextClass => classes.isEmpty ? null : classes.first;

  void setStatus(String value) {
    if (selectedStatus.value == value) return;
    selectedStatus.value = value;
    loadGroups(refresh: true);
  }

  Future<void> loadGroups({bool refresh = false}) async {
    if (isLoading.value || isRefreshing.value || isLoadingMore.value) return;
    if (refresh) {
      isRefreshing.value = true;
      _page = 1;
    } else if (groups.isEmpty) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    errorMessage.value = '';
    try {
      final page = await _service.getGroups(
        page: _page,
        limit: _limit,
        search: searchController.text,
        status: selectedStatus.value,
      );
      _totalPages = page.totalPages < 1 ? 1 : page.totalPages;
      if (_page == 1) {
        groups.assignAll(page.groups);
      } else {
        groups.addAll(page.groups);
      }
    } catch (error) {
      errorMessage.value = _cleanError(error);
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadNextPage() async {
    if (!hasMore ||
        isLoading.value ||
        isRefreshing.value ||
        isLoadingMore.value) {
      return;
    }
    _page += 1;
    await loadGroups();
  }

  Future<void> refreshGroups() async {
    _page = 1;
    await loadGroups(refresh: true);
  }

  Future<void> loadGroupDetails(String groupId) async {
    if (groupId.isEmpty) return;
    isDetailLoading.value = true;
    detailErrorMessage.value = '';
    memberSearchQuery.value = '';
    memberSearchController.clear();

    InstructorGroup? cached;
    for (final group in groups) {
      if (group.id == groupId) {
        cached = group;
        break;
      }
    }
    if (cached != null) selectedGroup.value = cached;

    try {
      final detail = await _service.getGroup(groupId);
      selectedGroup.value = detail;
      final results = await Future.wait([
        _service.getMembers(groupId),
        _service.getDiscussion(groupId),
        _service.getRooms(groupId),
        _service.getUpcomingClasses(groupId),
      ]);
      members.assignAll(results[0] as List<InstructorGroupMember>);
      messages.assignAll(results[1] as List<InstructorGroupMessage>);
      rooms.assignAll(results[2] as List<InstructorGroupRoom>);
      classes.assignAll(results[3] as List<InstructorGroupClass>);
    } catch (error) {
      detailErrorMessage.value = _cleanError(error);
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> sendMessage(String groupId) async {
    final content = messageController.text.trim();
    if (content.isEmpty || isSendingMessage.value) return;
    isSendingMessage.value = true;
    try {
      final message = await _service.sendMessage(
        groupId: groupId,
        content: content,
      );
      messages.add(message);
      messageController.clear();
    } catch (error) {
      _showError(_cleanError(error));
    } finally {
      isSendingMessage.value = false;
    }
  }

  Future<void> createRoom({
    required String groupId,
    required String name,
    required String privacy,
  }) async {
    if (name.trim().isEmpty || isCreatingRoom.value) return;
    isCreatingRoom.value = true;
    try {
      await _service.createRoom(groupId: groupId, name: name, privacy: privacy);
      Get.back();
      await loadGroupDetails(groupId);
      Get.snackbar('Room created', 'Your room is ready.');
    } catch (error) {
      _showError(_cleanError(error));
    } finally {
      isCreatingRoom.value = false;
    }
  }

  Future<void> joinRoom(InstructorGroupRoom room) async {
    if (room.id.isEmpty || joiningRoomIds.contains(room.id)) return;
    joiningRoomIds.add(room.id);
    try {
      await _service.joinRoom(room.id);
      Get.snackbar('Joined room', room.title);
    } catch (error) {
      _showError(_cleanError(error));
    } finally {
      joiningRoomIds.remove(room.id);
    }
  }

  Future<void> startNextClass() async {
    final liveClass = nextClass;
    if (liveClass == null) {
      _showError('No upcoming class is available for this group.');
      return;
    }
    await startClass(liveClass);
  }

  Future<void> startClass(InstructorGroupClass liveClass) async {
    if (liveClass.id.isEmpty || startingClassIds.contains(liveClass.id)) {
      return;
    }
    if (liveClass.status == 'live') {
      await _openClassLink(liveClass.zoomLink);
      return;
    }
    startingClassIds.add(liveClass.id);
    try {
      final zoomLink = await _service.startClass(liveClass.id);
      await loadGroupDetails(selectedGroup.value?.id ?? '');
      await _openClassLink(zoomLink);
    } catch (error) {
      _showError(_cleanError(error));
    } finally {
      startingClassIds.remove(liveClass.id);
    }
  }

  void showEditDetailsUnavailable() {
    Get.snackbar(
      'Edit details',
      'This group has no editable class form in the current screen.',
    );
  }

  String groupLetter(InstructorGroup group) {
    final name = group.name.trim();
    if (name.isEmpty) return 'G';
    return name.characters.first.toUpperCase();
  }

  String groupStudentsText(InstructorGroup group) {
    final count = group.displayStudentCount;
    return count == 1 ? '1 Student' : '$count Students';
  }

  String latestActivityText(InstructorGroup group) {
    final date = group.latestActivityAt;
    if (date == null) return 'No activity';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    final months = (diff.inDays / 30).floor();
    return months <= 1 ? '1 month ago' : '$months months ago';
  }

  Color groupColor(InstructorGroup group, int index) {
    final parsed = _parseColor(group.themeColor);
    if (parsed != null) return parsed;
    const fallbacks = [
      Color(0xFF5151EF),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF8B5CF6),
      Color(0xFF64748B),
    ];
    return fallbacks[index % fallbacks.length];
  }

  Color memberStatusColor(String status) {
    return status == 'active'
        ? const Color(0xFF10B981)
        : const Color(0xFF9CA3AF);
  }

  String memberStatusLabel(String status) {
    if (status == 'active') return 'Active';
    if (status == 'expired') return 'Expired';
    return 'Removed';
  }

  String rsvpLabel(String value) {
    if (value == 'going') return 'Going';
    if (value == 'maybe') return 'Maybe';
    if (value == 'not_going') return 'Not Going';
    return 'No RSVP';
  }

  Color rsvpColor(String value) {
    if (value == 'going') return const Color(0xFFDCFCE7);
    if (value == 'maybe') return const Color(0xFFFEF3C7);
    if (value == 'not_going') return const Color(0xFFFEE2E2);
    return const Color(0xFFF1F5F9);
  }

  Color rsvpTextColor(String value) {
    if (value == 'going') return const Color(0xFF15803D);
    if (value == 'maybe') return const Color(0xFFB45309);
    if (value == 'not_going') return const Color(0xFFB91C1C);
    return const Color(0xFF64748B);
  }

  String messageTime(InstructorGroupMessage message) {
    final createdAt = message.createdAt;
    if (createdAt == null) return '';
    return DateFormat('hh:mm a').format(createdAt);
  }

  String classTimeStart(InstructorGroupClass? liveClass) {
    final start = liveClass?.scheduledAt;
    if (start == null) return 'Time';
    return DateFormat('hh:mm a').format(start);
  }

  String classTimeEnd(InstructorGroupClass? liveClass) {
    final start = liveClass?.scheduledAt;
    if (start == null) return 'Unavailable';
    return DateFormat(
      'hh:mm a',
    ).format(start.add(Duration(minutes: liveClass?.duration ?? 60)));
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      refreshGroups();
    });
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 160) {
      loadNextPage();
    }
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
      Get.snackbar('Class started', 'No class link is available yet.');
      return;
    }
    final uri = Uri.tryParse(zoomLink.trim());
    final opened =
        uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      Get.snackbar('Class started', zoomLink);
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
