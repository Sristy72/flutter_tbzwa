import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/instructor_room_model.dart';
import '../services/instructor_rooms_service.dart';
import '../services/instructor_rooms_socket_service.dart';

class InstructorRoomsController extends GetxController {
  final InstructorRoomsService _service = InstructorRoomsService();
  final InstructorRoomsSocketService _socketService =
      InstructorRoomsSocketService();

  final scrollController = ScrollController();

  final rooms = <InstructorRoom>[].obs;
  final groups = <InstructorRoomGroup>[].obs;
  final joinedRoomIds = <String>{}.obs;
  final joiningRoomIds = <String>{}.obs;
  final leavingRoomIds = <String>{}.obs;
  final closingRoomIds = <String>{}.obs;

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final isLoadingGroups = false.obs;
  final isCreatingRoom = false.obs;
  final errorMessage = ''.obs;

  int _page = 1;
  int _totalPages = 1;
  static const int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    _socketService.listen(
      onParticipantsUpdated: _handleParticipantsUpdated,
      onRoomClosed: _handleRoomClosed,
      onRoomError: _handleRoomError,
    );
    unawaited(
      _socketService.connect(onReconnect: () => unawaited(refreshRooms())),
    );
    unawaited(loadGroups());
    unawaited(loadRooms());
  }

  @override
  void onClose() {
    for (final roomId in List<String>.from(joinedRoomIds)) {
      unawaited(_service.leaveRoom(roomId).catchError((_) {}));
    }
    _socketService.dispose();
    scrollController.dispose();
    super.onClose();
  }

  bool get hasMore => _page < _totalPages;

  List<InstructorRoomGroup> get assignedGroups => groups;

  Future<void> loadGroups() async {
    if (isLoadingGroups.value) return;
    isLoadingGroups.value = true;
    try {
      groups.assignAll(await _service.getGroups());
    } catch (error) {
      if (groups.isEmpty) {
        _showError(_cleanError(error));
      }
    } finally {
      isLoadingGroups.value = false;
    }
  }

  Future<void> loadRooms({bool refresh = false}) async {
    if (isLoading.value || isRefreshing.value || isLoadingMore.value) return;
    final requestPage = _page;
    if (refresh) {
      isRefreshing.value = true;
      _page = 1;
    } else if (rooms.isEmpty) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    errorMessage.value = '';
    try {
      final page = await _service.getRooms(
        page: _page,
        limit: _limit,
        status: 'active',
      );
      _totalPages = page.totalPages < 1 ? 1 : page.totalPages;
      if (_page == 1) {
        rooms.assignAll(page.rooms);
      } else {
        rooms.addAll(page.rooms);
      }
    } catch (error) {
      if (requestPage > 1) _page = requestPage - 1;
      errorMessage.value = _cleanError(error);
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshRooms() async {
    _page = 1;
    await loadRooms(refresh: true);
  }

  Future<void> loadNextPage() async {
    if (!hasMore ||
        isLoading.value ||
        isRefreshing.value ||
        isLoadingMore.value) {
      return;
    }
    _page += 1;
    await loadRooms();
  }

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
    if (isCreatingRoom.value) return;

    isCreatingRoom.value = true;
    try {
      final room = await _service.createRoom(
        name: name,
        groupId: groupId,
        privacy: privacy,
      );
      Get.back();
      rooms.insert(0, room);
      Get.snackbar(
        'Room created',
        'Your room is ready.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError(_cleanError(error));
    } finally {
      isCreatingRoom.value = false;
    }
  }

  Future<void> joinRoom(InstructorRoom room) async {
    if (room.id.isEmpty || joiningRoomIds.contains(room.id)) return;
    if (!await _ensureMicrophonePermission()) return;

    joiningRoomIds.add(room.id);
    try {
      final joined = await _service.joinRoom(room.id);
      joinedRoomIds.add(room.id);
      _socketService.joinRoom(room.id);
      _replaceRoom(joined);
      Get.snackbar(
        'Joined room',
        joined.name.isEmpty ? room.name : joined.name,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError(_cleanError(error));
    } finally {
      joiningRoomIds.remove(room.id);
    }
  }

  Future<void> leaveRoom(InstructorRoom room) async {
    if (room.id.isEmpty || leavingRoomIds.contains(room.id)) return;
    leavingRoomIds.add(room.id);
    try {
      await _service.leaveRoom(room.id);
      joinedRoomIds.remove(room.id);
      _socketService.leaveRoom(room.id);
      await _refreshRoom(room.id);
      Get.snackbar('Left room', room.name, snackPosition: SnackPosition.BOTTOM);
    } catch (error) {
      _showError(_cleanError(error));
    } finally {
      leavingRoomIds.remove(room.id);
    }
  }

  Future<void> closeRoom(InstructorRoom room) async {
    if (room.id.isEmpty || closingRoomIds.contains(room.id)) return;
    closingRoomIds.add(room.id);
    try {
      await _service.closeRoom(room.id);
      joinedRoomIds.remove(room.id);
      _socketService.leaveRoom(room.id);
      rooms.removeWhere((item) => item.id == room.id);
      Get.snackbar(
        'Room closed',
        room.name,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      _showError(_cleanError(error));
    } finally {
      closingRoomIds.remove(room.id);
    }
  }

  Future<void> copyRoomLink(InstructorRoom room) async {
    final value = room.shareLink.trim().isNotEmpty
        ? room.shareLink.trim()
        : room.id;
    if (value.isEmpty) {
      _showError('No room link is available.');
      return;
    }
    await Clipboard.setData(ClipboardData(text: value));
    Get.snackbar('Link copied', room.name, snackPosition: SnackPosition.BOTTOM);
  }

  void showRoomActions(InstructorRoom room) {
    final isJoined = joinedRoomIds.contains(room.id);
    Get.bottomSheet(
      SafeArea(
        child: Container(
          color: Colors.white,
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.link, color: Color(0xFF5151EF)),
                title: const Text('Copy Link'),
                onTap: () {
                  Get.back();
                  unawaited(copyRoomLink(room));
                },
              ),
              if (isJoined)
                ListTile(
                  leading: const Icon(Icons.logout, color: Color(0xFF4B5563)),
                  title: const Text('Leave Room'),
                  onTap: () {
                    Get.back();
                    unawaited(leaveRoom(room));
                  },
                ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.red),
                title: const Text('Close Room'),
                onTap: () {
                  Get.back();
                  confirmCloseRoom(room);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void confirmCloseRoom(InstructorRoom room) {
    Get.defaultDialog(
      title: 'Close Room',
      middleText: 'Close ${room.name}?',
      textCancel: 'Cancel',
      textConfirm: 'Close',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        unawaited(closeRoom(room));
      },
    );
  }

  Color iconColor(InstructorRoom room) {
    return room.isPublic ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
  }

  Color iconBgColor(InstructorRoom room) {
    return room.isPublic ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7);
  }

  String participantCountText(InstructorRoom room) {
    return room.participantCount.toString();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 160) {
      unawaited(loadNextPage());
    }
  }

  Future<void> _refreshRoom(String roomId) async {
    try {
      final room = await _service.getRoom(roomId);
      if (room.isActive) {
        _replaceRoom(room);
      } else {
        rooms.removeWhere((item) => item.id == roomId);
      }
    } catch (_) {
      await refreshRooms();
    }
  }

  void _replaceRoom(InstructorRoom room) {
    final index = rooms.indexWhere((item) => item.id == room.id);
    if (index == -1) {
      if (room.isActive) rooms.insert(0, room);
      return;
    }
    if (room.isActive) {
      rooms[index] = room;
    } else {
      rooms.removeAt(index);
    }
  }

  void _handleParticipantsUpdated(dynamic data) {
    final payload = data is Map ? Map<String, dynamic>.from(data) : null;
    if (payload == null) return;
    final roomId = (payload['roomId'] ?? '').toString();
    final index = rooms.indexWhere((room) => room.id == roomId);
    if (index == -1) return;

    final participants = (payload['participants'] as List? ?? const [])
        .map(
          (item) => InstructorRoomParticipant.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
    rooms[index] = rooms[index].copyWith(
      participantCount: participants.length,
      participants: participants,
    );
  }

  void _handleRoomClosed(dynamic data) {
    final payload = data is Map ? Map<String, dynamic>.from(data) : null;
    final roomId = (payload?['roomId'] ?? '').toString();
    if (roomId.isEmpty) return;
    joinedRoomIds.remove(roomId);
    rooms.removeWhere((room) => room.id == roomId);
  }

  void _handleRoomError(dynamic data) {
    final payload = data is Map ? Map<String, dynamic>.from(data) : null;
    if (payload?['type'] != 'voiceroom') return;
    final message = (payload?['message'] ?? 'Unable to join this voice room.')
        .toString();
    _showError(message);
  }

  Future<bool> _ensureMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;
    status = await Permission.microphone.request();
    if (status.isGranted) return true;
    _showError('Microphone permission is required to join a voice room.');
    return false;
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
