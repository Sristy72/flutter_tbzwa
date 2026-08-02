import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/common/widgets/app_network_video.dart';
import '../../../core/utils/app_snackbar.dart';
import '../controllers/voice_room_details_controller.dart';
import '../models/voice_room_model.dart';

class VoiceRoomDetailsScreen extends StatefulWidget {
  final LearnerVoiceRoom room;

  const VoiceRoomDetailsScreen({super.key, required this.room});

  @override
  State<VoiceRoomDetailsScreen> createState() => _VoiceRoomDetailsScreenState();
}

class _VoiceRoomDetailsScreenState extends State<VoiceRoomDetailsScreen> {
  late final String _tag;
  late final VoiceRoomDetailsController controller;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _tag = 'voice-room-details-${widget.room.id}';
    controller = Get.put(
      VoiceRoomDetailsController(initialRoom: widget.room),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<VoiceRoomDetailsController>(tag: _tag)) {
      Get.delete<VoiceRoomDetailsController>(tag: _tag);
    }
    super.dispose();
  }

  Future<void> _leaveAndClose() async {
    if (_closing) return;
    _closing = true;
    await controller.leaveRoom();
    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_leaveAndClose());
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        body: SafeArea(
          child: Obx(() {
            final room = controller.room.value;
            if (controller.isEntering.value && controller.messages.isEmpty) {
              return Column(
                children: [
                  _buildHeader(room),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }

            if (controller.errorMessage.value != null &&
                controller.messages.isEmpty) {
              return Column(
                children: [
                  _buildHeader(room),
                  Expanded(child: _buildErrorState()),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(room),
                _buildRoomSummary(room),
                _buildParticipantsSection(room),
                Expanded(child: _buildChatSection(room)),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader(LearnerVoiceRoom room) {
    return SizedBox(
      height: 58,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Obx(() {
              final busy = controller.isLeaving.value;
              return IconButton(
                onPressed: busy ? null : () => unawaited(_leaveAndClose()),
                icon: busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF1E293B),
                        size: 20,
                      ),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 58),
            child: Text(
              room.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFFCBD5E1),
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              controller.errorMessage.value ?? 'Unable to enter voice room.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: controller.enterRoom,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomSummary(LearnerVoiceRoom room) {
    final topic = room.groupName.trim().isEmpty
        ? 'Speaking practice'
        : room.groupName.trim();
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
      child: Row(
        children: [
          _buildAvatar(room.hostAvatarUrl, room.hostInitial, radius: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  topic,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  room.hostName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _buildStatusChip(room),
        ],
      ),
    );
  }

  Widget _buildParticipantsSection(LearnerVoiceRoom room) {
    final participants = room.participants.take(14).toList();
    final remaining = room.participantCount - participants.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Speaking practice',
                  style: TextStyle(
                    color: Color(0xFF374151),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                room.countLabel,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (participants.isEmpty)
            _buildEmptyParticipants()
          else
            Wrap(
              spacing: 14,
              runSpacing: 15,
              children: [
                ...participants.map(_buildParticipantTile),
                if (remaining > 0) _buildMoreTile(remaining),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyParticipants() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: Text(
          'No listeners yet.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildParticipantTile(LearnerVoiceRoomParticipant participant) {
    final initial = participant.name.trim().isEmpty
        ? 'L'
        : participant.name.trim()[0].toUpperCase();
    final actionable =
        controller.canInviteParticipant(participant) ||
        controller.canRemoveParticipant(participant);
    return GestureDetector(
      onTap: actionable ? () => _showParticipantActions(participant) : null,
      onLongPress: actionable
          ? () => _showParticipantActions(participant)
          : null,
      child: SizedBox(
        width: 58,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildAvatar(participant.avatarUrl, initial, radius: 24),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _stageBadgeColor(participant),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(
                      _stageBadgeIcon(participant),
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),
                if (_countryBadge(participant.country).isNotEmpty)
                  Positioned(
                    left: -4,
                    bottom: -3,
                    child: _flagBadge(_countryBadge(participant.country)),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              participant.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF374151),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (participant.stageLabel != 'Listener') ...[
              const SizedBox(height: 2),
              Text(
                participant.stageLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMoreTile(int remaining) {
    return SizedBox(
      width: 58,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF26A69A),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$remaining+',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'More',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF374151),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatSection(LearnerVoiceRoom room) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Text(
              'General Chat',
              style: TextStyle(
                color: Color(0xFF374151),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  if (controller.roomEndedMessage.value != null)
                    _buildEndedBanner(controller.roomEndedMessage.value!),
                  _buildStageControls(room),
                  Expanded(child: _buildMessageList()),
                  _buildComposer(room),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageControls(LearnerVoiceRoom room) {
    return Obx(() {
      if (controller.isRoomEnded) return const SizedBox.shrink();
      final isSpeaker = controller.isCurrentSpeaker;
      final isHost = controller.isCurrentUserHost;
      final isInvited = controller.isCurrentInvited;
      final busy =
          controller.isStageActionBusy.value ||
          controller.isAudioStarting.value;
      final muted = controller.isCurrentMuted;
      final showControls = isSpeaker || isHost || isInvited;
      if (!showControls) return const SizedBox.shrink();

      final icon = isSpeaker
          ? muted
                ? Icons.mic_off_rounded
                : Icons.mic_rounded
          : isInvited
          ? Icons.mark_email_unread_rounded
          : Icons.admin_panel_settings_rounded;
      final title = isSpeaker
          ? muted
                ? 'Muted'
                : 'On stage'
          : isInvited
          ? 'Invited'
          : 'Stage';
      final label = isSpeaker
          ? 'Speaker'
          : isHost
          ? 'Host'
          : 'Listener';

      return Container(
        padding: const EdgeInsets.fromLTRB(14, 11, 14, 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF168A7E), size: 19),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (isSpeaker) ...[
              _roundIconButton(
                icon: muted ? Icons.mic_rounded : Icons.mic_off_rounded,
                onTap: busy ? null : () => unawaited(controller.toggleMute()),
                filled: false,
              ),
              const SizedBox(width: 8),
              _roundIconButton(
                icon: Icons.call_end_rounded,
                onTap: busy ? null : () => unawaited(controller.leaveStage()),
                filled: true,
                color: const Color(0xFFFF3752),
              ),
            ] else
              _stagePill(label),
          ],
        ),
      );
    });
  }

  Widget _buildEndedBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF7ED),
        borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFB45309),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      if (controller.isLoadingMessages.value && controller.messages.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.messages.isEmpty) {
        return const Center(
          child: Text(
            'No messages yet.',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
        );
      }

      final hasOlderLoader = controller.isLoadingOlder.value;
      return ListView.builder(
        controller: controller.chatScrollController,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
        itemCount: controller.messages.length + (hasOlderLoader ? 1 : 0),
        itemBuilder: (context, index) {
          if (hasOlderLoader && index == 0) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          }

          final messageIndex = index - (hasOlderLoader ? 1 : 0);
          final message = controller.messages[messageIndex];
          return _buildMessageBubble(message);
        },
      );
    });
  }

  Widget _buildMessageBubble(VoiceRoomMessage message) {
    final mine = message.isMine;
    final bubbleColor = mine
        ? const Color(0xFF26A69A)
        : const Color(0xFFF8FAFC);
    final textColor = mine ? Colors.white : const Color(0xFF334155);
    final metaColor = mine ? Colors.white70 : const Color(0xFF94A3B8);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: mine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!mine) ...[
            _buildAvatar(
              message.senderAvatarUrl,
              _initial(message.senderName),
              radius: 18,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.68,
              ),
              child: Column(
                crossAxisAlignment: mine
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!mine)
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 4),
                      child: Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            message.senderName,
                            style: const TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (message.roleLabel.isNotEmpty)
                            _roleChip(message.roleLabel),
                          Text(
                            _timeLabel(message.createdAt),
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(14),
                        topRight: const Radius.circular(14),
                        bottomLeft: Radius.circular(mine ? 14 : 4),
                        bottomRight: Radius.circular(mine ? 4 : 14),
                      ),
                      border: mine
                          ? null
                          : Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (message.content.trim().isNotEmpty)
                          Text(
                            message.content.trim(),
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              height: 1.25,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (message.attachment != null) ...[
                          if (message.content.trim().isNotEmpty)
                            const SizedBox(height: 8),
                          _buildAttachment(message.attachment!, mine),
                        ],
                        if (mine) ...[
                          const SizedBox(height: 4),
                          Text(
                            _timeLabel(message.createdAt),
                            style: TextStyle(
                              color: metaColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer(LearnerVoiceRoom room) {
    final disabled = controller.isRoomEnded;
    return Obx(() {
      final attachment = controller.pendingAttachment.value;
      final sending = controller.isSending.value;
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Column(
          children: [
            if (attachment != null) _buildPendingAttachment(attachment),
            Row(
              children: [
                _roundIconButton(
                  icon: Icons.add_rounded,
                  onTap: disabled || sending
                      ? null
                      : () => _showAttachmentMenu(context),
                  filled: false,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller.messageTextController,
                    enabled: !disabled && !sending,
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => unawaited(controller.sendMessage()),
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: disabled ? 'Room ended' : 'Type a message...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Color(0xFF26A69A)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _roundIconButton(
                  icon: sending
                      ? Icons.hourglass_top_rounded
                      : Icons.send_rounded,
                  onTap: disabled || sending
                      ? null
                      : () => unawaited(controller.sendMessage()),
                  filled: true,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPendingAttachment(VoiceRoomPendingAttachment attachment) {
    return Obx(() {
      final progress = controller.uploadProgress.value
          .clamp(0.0, 1.0)
          .toDouble();
      final sending = controller.isSending.value;
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _attachmentIcon(attachment.type),
                  color: const Color(0xFF26A69A),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    attachment.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: sending ? null : controller.clearAttachment,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF94A3B8),
                    size: 18,
                  ),
                ),
              ],
            ),
            if (sending && attachment.file.path.isNotEmpty) ...[
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress == 0 ? null : progress,
                minHeight: 3,
                color: const Color(0xFF26A69A),
                backgroundColor: const Color(0xFFE2E8F0),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _roundIconButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool filled,
    Color? color,
  }) {
    final fillColor = color ?? const Color(0xFF26A69A);
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: filled ? fillColor : const Color(0xFFF8FAFC),
            shape: BoxShape.circle,
            border: filled ? null : Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(
            icon,
            color: filled ? Colors.white : const Color(0xFF64748B),
            size: 19,
          ),
        ),
      ),
    );
  }

  Widget _stagePill(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  void _showParticipantActions(LearnerVoiceRoomParticipant participant) {
    final canInvite = controller.canInviteParticipant(participant);
    final canRemove = controller.canRemoveParticipant(participant);
    if (!canInvite && !canRemove) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(18),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _buildAvatar(
                      participant.avatarUrl,
                      _initial(participant.name),
                      radius: 21,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            participant.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF1E293B),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            participant.stageLabel,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (canInvite)
                  _participantAction(
                    Icons.keyboard_voice_rounded,
                    'Invite to Stage',
                    () => controller.inviteToStage(participant),
                  ),
                if (canRemove) ...[
                  _participantAction(
                    participant.isMuted
                        ? Icons.mic_rounded
                        : Icons.mic_off_rounded,
                    participant.isMuted ? 'Unmute Speaker' : 'Mute Speaker',
                    () => controller.setParticipantMute(
                      participant,
                      !participant.isMuted,
                    ),
                  ),
                  _participantAction(
                    Icons.person_remove_alt_1_outlined,
                    'Remove from Stage',
                    () => controller.removeSpeakerFromStage(participant),
                    destructive: true,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _participantAction(
    IconData icon,
    String label,
    Future<void> Function() action, {
    bool destructive = false,
  }) {
    final iconColor = destructive
        ? const Color(0xFFFF3752)
        : const Color(0xFF168A7E);
    return InkWell(
      onTap: () {
        Get.back();
        unawaited(action());
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: destructive
                    ? const Color(0xFFFFEBEE)
                    : const Color(0xFFE6F7F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: destructive
                    ? const Color(0xFFFF3752)
                    : const Color(0xFF334155),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(18),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _attachmentOption(
                  Icons.image_outlined,
                  'Image',
                  controller.pickImage,
                ),
                _attachmentOption(
                  Icons.mic_none_rounded,
                  'Audio',
                  controller.pickAudio,
                ),
                _attachmentOption(
                  Icons.videocam_outlined,
                  'Video',
                  controller.pickVideo,
                ),
                _attachmentOption(
                  Icons.description_outlined,
                  'Document',
                  controller.pickDocument,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _attachmentOption(
    IconData icon,
    String label,
    Future<void> Function() onTap,
  ) {
    return InkWell(
      onTap: () {
        Get.back();
        unawaited(onTap());
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7F4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF168A7E), size: 21),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachment(VoiceRoomMessageAttachment attachment, bool isMine) {
    if (!attachment.hasUsableUrl) {
      return _attachmentFallback(
        icon: Icons.attachment_rounded,
        label: 'Attachment unavailable',
        isMine: isMine,
      );
    }

    switch (attachment.type) {
      case 'image':
        return GestureDetector(
          onTap: () => _openImage(attachment.url),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              attachment.url,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _attachmentFallback(
                icon: Icons.broken_image_outlined,
                label: 'Image unavailable',
                isMine: isMine,
              ),
            ),
          ),
        );
      case 'video':
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: AppNetworkVideo(videoUrl: attachment.url),
          ),
        );
      case 'audio':
        return _VoiceRoomAudioAttachment(url: attachment.url, isMine: isMine);
      case 'document':
        return _tapAttachmentTile(
          icon: Icons.description_outlined,
          label: attachment.displayName,
          isMine: isMine,
          onTap: () => _openExternal(attachment.url),
        );
      default:
        return _tapAttachmentTile(
          icon: Icons.attachment_rounded,
          label: attachment.displayName,
          isMine: isMine,
          onTap: () => _openExternal(attachment.url),
        );
    }
  }

  Widget _attachmentFallback({
    required IconData icon,
    required String label,
    required bool isMine,
  }) {
    return _tapAttachmentTile(
      icon: icon,
      label: label,
      isMine: isMine,
      onTap: null,
    );
  }

  Widget _tapAttachmentTile({
    required IconData icon,
    required String label,
    required bool isMine,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: isMine ? Colors.white.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isMine ? Colors.white24 : const Color(0xFFE2E8F0),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isMine ? Colors.white : const Color(0xFF26A69A),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isMine ? Colors.white : const Color(0xFF334155),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openImage(String url) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(18),
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Center(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Padding(
                    padding: EdgeInsets.all(24),
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white70,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened) {
      AppSnackbar.error('Attachment', 'Unable to open attachment.');
    }
  }

  Widget _buildStatusChip(LearnerVoiceRoom room) {
    final color = room.isActive
        ? const Color(0xFF26A69A)
        : const Color(0xFF64748B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        room.statusLabel,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _roleChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F7F4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF168A7E),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Color _stageBadgeColor(LearnerVoiceRoomParticipant participant) {
    if (participant.isMuted) return const Color(0xFFF59E0B);
    if (participant.isSpeaker) return const Color(0xFF26A69A);
    if (participant.isInvited) return const Color(0xFF1FA0F3);
    return const Color(0xFF94A3B8);
  }

  IconData _stageBadgeIcon(LearnerVoiceRoomParticipant participant) {
    if (participant.isMuted) return Icons.mic_off_rounded;
    if (participant.isSpeaker) return Icons.mic_rounded;
    if (participant.isInvited) return Icons.mark_email_unread_rounded;
    return Icons.hearing_rounded;
  }

  IconData _attachmentIcon(String type) {
    switch (type) {
      case 'image':
        return Icons.image_outlined;
      case 'audio':
        return Icons.mic_none_rounded;
      case 'video':
        return Icons.videocam_outlined;
      case 'document':
        return Icons.description_outlined;
      default:
        return Icons.attachment_rounded;
    }
  }

  Widget _buildAvatar(
    String? url,
    String fallbackText, {
    required double radius,
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

    if (url == null || url.trim().isEmpty) return fallback;

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : fallback,
      ),
    );
  }

  Widget _flagBadge(String label) {
    return Container(
      height: 17,
      constraints: const BoxConstraints(minWidth: 17),
      padding: const EdgeInsets.symmetric(horizontal: 3),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFF26A69A), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF1E293B),
          fontSize: 9,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _initial(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'M' : trimmed.substring(0, 1).toUpperCase();
  }

  String _timeLabel(DateTime? date) {
    if (date == null) return '';
    return DateFormat('h:mm a').format(date);
  }

  String _countryBadge(String country) {
    final trimmed = country.trim();
    if (trimmed.isEmpty) return '';
    final upper = trimmed.toUpperCase();
    if (upper.length == 2 && RegExp(r'^[A-Z]{2}$').hasMatch(upper)) {
      const base = 0x1F1E6;
      final first = upper.codeUnitAt(0) - 65 + base;
      final second = upper.codeUnitAt(1) - 65 + base;
      return String.fromCharCodes([first, second]);
    }
    return trimmed.substring(0, 1).toUpperCase();
  }
}

class _VoiceRoomAudioAttachment extends StatefulWidget {
  final String url;
  final bool isMine;

  const _VoiceRoomAudioAttachment({required this.url, required this.isMine});

  @override
  State<_VoiceRoomAudioAttachment> createState() =>
      _VoiceRoomAudioAttachmentState();
}

class _VoiceRoomAudioAttachmentState extends State<_VoiceRoomAudioAttachment> {
  late final AudioPlayer _player;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<void>? _completeSub;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _positionSub = _player.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });
    _durationSub = _player.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });
    _completeSub = _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    unawaited(_positionSub?.cancel());
    unawaited(_durationSub?.cancel());
    unawaited(_completeSub?.cancel());
    _player.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (widget.url.trim().isEmpty) return;
    if (_isPlaying) {
      await _player.pause();
      if (mounted) setState(() => _isPlaying = false);
      return;
    }

    await _player.play(UrlSource(widget.url));
    if (mounted) setState(() => _isPlaying = true);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds <= 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds)
              .clamp(0.0, 1.0)
              .toDouble();
    final foreground = widget.isMine ? Colors.white : const Color(0xFF26A69A);
    final muted = widget.isMine ? Colors.white70 : const Color(0xFF94A3B8);

    return Container(
      constraints: const BoxConstraints(minWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: widget.isMine
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: widget.isMine ? Colors.white24 : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () => unawaited(_toggle()),
            child: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
              color: foreground,
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: progress == 0 ? null : progress,
              minHeight: 3,
              color: foreground,
              backgroundColor: muted.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _durationLabel(_duration),
            style: TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _durationLabel(Duration value) {
    if (value.inSeconds <= 0) return '0:00';
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
