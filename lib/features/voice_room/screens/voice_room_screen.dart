import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../subcribers_flow/subscriber_choose_program_screen.dart';
import '../../subcribers_flow/subscriber_menu_drawer.dart';
import '../controllers/voice_room_controller.dart';
import '../models/voice_room_model.dart';
import '../widgets/create_voice_room_dialog.dart';
import 'voice_room_details_screen.dart';

class VoiceRoom extends StatefulWidget {
  const VoiceRoom({super.key});

  @override
  State<VoiceRoom> createState() => _VoiceRoomState();
}

class _VoiceRoomState extends State<VoiceRoom> {
  late final LearnerVoiceRoomController controller;
  late final TextEditingController _searchController;
  bool _isOpeningCreate = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LearnerVoiceRoomController>()
        ? Get.find<LearnerVoiceRoomController>()
        : Get.put(LearnerVoiceRoomController());
    _searchController = TextEditingController(
      text: controller.searchQuery.value,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(controller.ensureRoomsLoaded());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openCreateRoom() async {
    if (_isOpeningCreate) return;
    _isOpeningCreate = true;
    try {
      final eligibility = await controller.checkCreateEligibility();
      if (!mounted || eligibility == null) return;
      if (!eligibility.allowed) {
        _showSubscriptionRequired(eligibility);
        return;
      }

      final created = await Get.dialog<bool>(
        CreateVoiceRoomDialog(controller: controller),
        barrierDismissible: false,
      );
      if (created == true && mounted) {
        _searchController.clear();
      }
    } finally {
      _isOpeningCreate = false;
    }
  }

  void _showSubscriptionRequired(VoiceRoomCreateEligibility eligibility) {
    Get.defaultDialog(
      title: 'Subscription required',
      middleText: eligibility.displayReason,
      textCancel: 'Not now',
      textConfirm: 'View plans',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFF26A69A),
      onConfirm: () {
        Get.back();
        Get.to(() => const SubscriberChooseProgramScreen());
      },
    );
  }

  Future<void> _joinRoom(LearnerVoiceRoom room) async {
    final joined = await controller.joinRoom(room);
    if (!mounted || joined == null) return;
    Get.to(() => VoiceRoomDetailsScreen(room: joined));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      drawer: const SubscriberMenuDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Builder(
                      builder: (context) => GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 18.0),
                          child: Icon(
                            Icons.menu,
                            color: Color(0xFF1E293B),
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildHeader(),
                ],
              ),
            ),
            const Divider(color: Color(0xFFD1D1D1)),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: _buildSearchBar()),
                  const SizedBox(width: 12),
                  Obx(() {
                    final busy = controller.isCheckingEligibility.value;
                    return GestureDetector(
                      onTap: busy ? null : _openCreateRoom,
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF26A69A),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF26A69A,
                              ).withValues(alpha: 0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: busy
                            ? const Padding(
                                padding: EdgeInsets.all(15),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.add, color: Colors.white),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(child: _buildRoomList()),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomList() {
    return Obx(() {
      if (controller.isInitialLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  color: Color(0xFFCBD5E1),
                  size: 44,
                ),
                const SizedBox(height: 12),
                Text(
                  controller.errorMessage.value!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => controller.loadRooms(reset: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.rooms.isEmpty) {
        return RefreshIndicator(
          onRefresh: controller.refreshRooms,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            children: [
              const SizedBox(height: 130),
              Icon(Icons.mic_none_rounded, size: 58, color: Colors.grey[300]),
              const SizedBox(height: 14),
              const Center(
                child: Text(
                  'No voice rooms found.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                ),
              ),
            ],
          ),
        );
      }

      final busyRoomIds = controller.joiningRoomIds.toSet();
      return RefreshIndicator(
        onRefresh: controller.refreshRooms,
        child: ListView.builder(
          controller: controller.scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount:
              controller.rooms.length +
              (controller.isLoadingMore.value ? 1 : 0) +
              1,
          itemBuilder: (context, index) {
            if (index == controller.rooms.length) {
              if (!controller.isLoadingMore.value) {
                return const SizedBox(height: 18);
              }
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (index > controller.rooms.length) {
              return const SizedBox(height: 18);
            }

            final room = controller.rooms[index];
            return KeyedSubtree(
              key: ValueKey('learner-voice-room-${room.id}'),
              child: _buildVoiceRoomCard(
                room: room,
                hasBorder: index == 0,
                isJoining: busyRoomIds.contains(room.id),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEDF1)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: controller.setSearchQuery,
        style: const TextStyle(color: Color(0xFF536F7A), fontSize: 14),
        decoration: const InputDecoration(
          hintText: 'Search voice rooms...',
          hintStyle: TextStyle(color: Color(0xFF90A4AE), fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Color(0xFF90A4AE)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildVoiceRoomCard({
    required LearnerVoiceRoom room,
    required bool hasBorder,
    required bool isJoining,
  }) {
    return GestureDetector(
      onTap: isJoining ? null : () => _joinRoom(room),
      child: Opacity(
        opacity: isJoining ? 0.72 : 1,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasBorder
                  ? const Color(0xFF26A69A)
                  : const Color(0xFFEAEDF1),
              width: hasBorder ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      room.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _buildStatusChip(room),
                ],
              ),
              if (room.groupName.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  room.groupName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildHostAvatar(room),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      room.hostName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF374151),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildParticipantAvatars(room),
                  if (isJoining) ...[
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    color: Color(0xFF94A3B8),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    room.countLabel,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    room.isPublic
                        ? Icons.public_rounded
                        : Icons.lock_outline_rounded,
                    color: const Color(0xFF94A3B8),
                    size: 15,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    room.privacyLabel,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.keyboard_arrow_right_rounded,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: 0.5,
              ),
              children: [
                TextSpan(text: "TALK/"),
                TextSpan(text: "'BZ/"),
              ],
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildStatusChip(LearnerVoiceRoom room) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: room.isActive
            ? const Color(0xFFE6F7F4)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        room.statusLabel,
        style: TextStyle(
          color: room.isActive
              ? const Color(0xFF168A7E)
              : const Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildHostAvatar(LearnerVoiceRoom room) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildAvatar(
          room.hostAvatarUrl,
          radius: 22,
          fallbackText: room.hostInitial,
        ),
        if (room.hostCountryBadge.isNotEmpty)
          Positioned(
            left: -3,
            bottom: -4,
            child: Container(
              height: 18,
              constraints: const BoxConstraints(minWidth: 18),
              padding: const EdgeInsets.symmetric(horizontal: 3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: const Color(0xFF26A69A), width: 1),
              ),
              child: Text(
                room.hostCountryBadge,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildParticipantAvatars(LearnerVoiceRoom room) {
    final participants = room.participants.take(4).toList();
    if (participants.isEmpty) {
      return Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text(
          '0',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    final width = 30.0 + ((participants.length - 1) * 22.0);
    final overflow = room.participantCount - participants.length;
    return SizedBox(
      height: 32,
      width: width + (overflow > 0 ? 24 : 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...List.generate(participants.length, (index) {
            final participant = participants[index];
            return Positioned(
              left: index * 22.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: _buildAvatar(
                  participant.avatarUrl,
                  radius: 15,
                  fallbackText: participant.name.trim().isEmpty
                      ? 'L'
                      : participant.name.trim()[0].toUpperCase(),
                ),
              ),
            );
          }),
          if (overflow > 0)
            Positioned(
              left: width - 2,
              top: 2,
              child: Container(
                height: 28,
                width: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF26A69A),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '+$overflow',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(
    String? url, {
    required double radius,
    required String fallbackText,
  }) {
    final size = radius * 2;
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFE8EAF0),
        shape: BoxShape.circle,
      ),
      child: Text(
        fallbackText,
        style: TextStyle(
          color: const Color(0xFF64748B),
          fontSize: radius * 0.72,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    if (url == null || url.trim().isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: const AssetImage(
          'assets/images/default_user_avatar.png',
        ),
      );
    }

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return fallback;
        },
      ),
    );
  }
}
