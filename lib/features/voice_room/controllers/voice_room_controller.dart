import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_snackbar.dart';
import '../models/voice_room_model.dart';
import '../services/voice_room_service.dart';

class LearnerVoiceRoomController extends GetxController {
  final LearnerVoiceRoomService _service = LearnerVoiceRoomService();
  final scrollController = ScrollController();

  final rooms = <LearnerVoiceRoom>[].obs;
  final searchQuery = ''.obs;
  final errorMessage = RxnString();
  final lastEligibility = Rxn<VoiceRoomCreateEligibility>();
  final joiningRoomIds = <String>{}.obs;
  final leavingRoomIds = <String>{}.obs;

  final isInitialLoading = false.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final isCheckingEligibility = false.obs;
  final isCreatingRoom = false.obs;
  final hasMore = true.obs;

  static const int _limit = 10;
  Timer? _searchDebounce;
  int _page = 1;
  int _totalPages = 1;
  int _requestSerial = 0;
  String? _inFlightKey;
  bool _hasLoadedRooms = false;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> ensureRoomsLoaded() async {
    if (_hasLoadedRooms || isInitialLoading.value) return;
    await loadRooms(reset: true);
  }

  Future<void> refreshRooms() {
    return loadRooms(reset: true, showFullScreenLoading: false);
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value || isInitialLoading.value) {
      return;
    }
    await loadRooms(reset: false);
  }

  Future<void> loadRooms({
    required bool reset,
    bool showFullScreenLoading = true,
  }) async {
    final nextPage = reset ? 1 : _page + 1;
    final requestKey = '${searchQuery.value.trim()}|$nextPage';
    if (_inFlightKey == requestKey) return;

    final serial = ++_requestSerial;
    _inFlightKey = requestKey;
    if (reset) {
      errorMessage.value = null;
      if (showFullScreenLoading && rooms.isEmpty) {
        isInitialLoading.value = true;
      } else {
        isRefreshing.value = true;
      }
    } else {
      isLoadingMore.value = true;
    }

    try {
      final page = await _service.getRooms(
        page: nextPage,
        limit: _limit,
        search: searchQuery.value,
      );
      if (serial != _requestSerial) return;

      _page = page.page;
      _totalPages = max(1, page.totalPages);
      hasMore.value = _page < _totalPages;
      _hasLoadedRooms = true;

      if (reset) {
        rooms.assignAll(_dedupe(page.rooms));
      } else {
        final existingIds = rooms.map((room) => room.id).toSet();
        rooms.addAll(
          page.rooms.where((room) => !existingIds.contains(room.id)),
        );
      }
    } catch (error) {
      if (serial != _requestSerial) return;
      final message = _cleanError(error);
      if (reset && rooms.isEmpty) {
        errorMessage.value = message;
      } else {
        AppSnackbar.error('Voice Room', message);
      }
    } finally {
      if (_inFlightKey == requestKey) _inFlightKey = null;
      if (serial == _requestSerial) {
        isInitialLoading.value = false;
        isRefreshing.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  void setSearchQuery(String query) {
    final normalized = query.trim();
    if (searchQuery.value == normalized) return;
    searchQuery.value = normalized;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(loadRooms(reset: true));
    });
  }

  Future<VoiceRoomCreateEligibility?> checkCreateEligibility() async {
    if (isCheckingEligibility.value) return lastEligibility.value;
    isCheckingEligibility.value = true;
    try {
      final eligibility = await _service.getCreateEligibility();
      lastEligibility.value = eligibility;
      return eligibility;
    } catch (error) {
      AppSnackbar.error('Voice Room', error);
      return null;
    } finally {
      isCheckingEligibility.value = false;
    }
  }

  Future<bool> createRoom({
    required String name,
    required String privacy,
    required int maxParticipants,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      AppSnackbar.warning('Voice Room', 'Room name is required.');
      return false;
    }
    if (trimmed.length > 80) {
      AppSnackbar.warning(
        'Voice Room',
        'Room name cannot exceed 80 characters.',
      );
      return false;
    }
    if (isCreatingRoom.value) return false;

    isCreatingRoom.value = true;
    try {
      final room = await _service.createRoom(
        name: trimmed,
        privacy: privacy,
        maxParticipants: maxParticipants,
      );
      searchQuery.value = '';
      _insertOrUpdateRoom(room);
      AppSnackbar.success('Voice Room', 'Your room is ready.');
      Get.back(result: true);
      await loadRooms(reset: true, showFullScreenLoading: false);
      return true;
    } catch (error) {
      AppSnackbar.error('Create Room', error);
      return false;
    } finally {
      isCreatingRoom.value = false;
    }
  }

  Future<LearnerVoiceRoom?> joinRoom(LearnerVoiceRoom room) async {
    if (room.id.isEmpty || joiningRoomIds.contains(room.id)) return null;

    joiningRoomIds.add(room.id);
    try {
      final joined = await _service.joinRoom(room.id);
      _insertOrUpdateRoom(joined);
      return joined;
    } catch (error) {
      AppSnackbar.error('Join Room', error);
      return null;
    } finally {
      joiningRoomIds.remove(room.id);
    }
  }

  Future<void> leaveRoom(String roomId) async {
    if (roomId.isEmpty || leavingRoomIds.contains(roomId)) return;
    leavingRoomIds.add(roomId);
    try {
      await _service.leaveRoom(roomId);
      await _refreshRoom(roomId);
    } catch (_) {
      await refreshRooms();
    } finally {
      leavingRoomIds.remove(roomId);
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      unawaited(loadMore());
    }
  }

  Future<void> _refreshRoom(String roomId) async {
    try {
      final room = await _service.getRoom(roomId);
      _insertOrUpdateRoom(room);
    } catch (_) {
      await refreshRooms();
    }
  }

  void _insertOrUpdateRoom(LearnerVoiceRoom room) {
    if (room.id.isEmpty) return;
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

  List<LearnerVoiceRoom> _dedupe(List<LearnerVoiceRoom> source) {
    final seen = <String>{};
    final result = <LearnerVoiceRoom>[];
    for (final room in source) {
      if (seen.add(room.id)) result.add(room);
    }
    return result;
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}
