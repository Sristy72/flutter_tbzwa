import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/auth_storage_service.dart';
import '../../../core/services/smart_media_service.dart';
import '../../../core/utils/app_snackbar.dart';
import '../models/voice_room_model.dart';
import '../services/voice_room_audio_service.dart';
import '../services/voice_room_service.dart';
import '../services/voice_room_socket_service.dart';
import 'voice_room_controller.dart';

class VoiceRoomPendingAttachment {
  final File file;
  final String type;
  final String displayName;

  const VoiceRoomPendingAttachment({
    required this.file,
    required this.type,
    required this.displayName,
  });
}

class VoiceRoomDetailsController extends GetxController
    with WidgetsBindingObserver {
  VoiceRoomDetailsController({required LearnerVoiceRoom initialRoom})
    : room = initialRoom.obs;

  static const int _messageLimit = 30;
  static const int _maxAttachmentBytes = 200 * 1024 * 1024;
  static const Set<String> _imageExtensions = {'jpg', 'jpeg', 'png', 'webp'};
  static const Set<String> _videoExtensions = {'mp4', 'mov', 'webm', 'mpeg'};
  static const Set<String> _audioExtensions = {
    'mp3',
    'mpeg',
    'wav',
    'webm',
    'm4a',
    'ogg',
    'aac',
  };
  static const Set<String> _documentExtensions = {'pdf'};

  final LearnerVoiceRoomService _service = LearnerVoiceRoomService();
  final LearnerVoiceRoomSocketService _socketService =
      LearnerVoiceRoomSocketService();
  final VoiceRoomAudioService _audioService = VoiceRoomAudioService();
  final AuthStorageService _authStorage = AuthStorageService();
  final SmartMediaService _mediaService = Get.isRegistered<SmartMediaService>()
      ? Get.find<SmartMediaService>()
      : Get.put(SmartMediaService());

  final Rx<LearnerVoiceRoom> room;
  final messages = <VoiceRoomMessage>[].obs;
  final errorMessage = RxnString();
  final roomEndedMessage = RxnString();
  final pendingAttachment = Rxn<VoiceRoomPendingAttachment>();
  final pendingStageInvitation = Rxn<VoiceRoomStageInvitation>();

  final isEntering = false.obs;
  final isLoadingMessages = false.obs;
  final isLoadingOlder = false.obs;
  final isSending = false.obs;
  final isLeaving = false.obs;
  final isStageActionBusy = false.obs;
  final isAudioStarting = false.obs;
  final hasMoreMessages = true.obs;
  final uploadProgress = 0.0.obs;

  final messageTextController = TextEditingController();
  final chatScrollController = ScrollController();

  String _currentUserId = '';
  int _messagePage = 1;
  int _messageTotalPages = 1;
  bool _hasEntered = false;
  bool _hasLeft = false;
  bool _isClosing = false;
  bool _stageDialogVisible = false;
  CancelToken? _sendCancelToken;

  bool get isRoomEnded => room.value.isActive == false;

  String get currentUserId => _currentUserId;

  LearnerVoiceRoomParticipant? get currentParticipant {
    if (_currentUserId.isEmpty) return null;
    for (final participant in room.value.participants) {
      if (participant.userId == _currentUserId) return participant;
    }
    return null;
  }

  bool get isCurrentUserHost {
    final hostId = room.value.hostId;
    return _currentUserId.isNotEmpty &&
        hostId != null &&
        hostId == _currentUserId;
  }

  bool get isCurrentSpeaker => currentParticipant?.isSpeaker == true;

  bool get isCurrentMuted =>
      currentParticipant?.isMuted == true || _audioService.isMuted;

  bool get isCurrentInvited =>
      currentParticipant?.isInvited == true ||
      pendingStageInvitation.value != null;

  bool canInviteParticipant(LearnerVoiceRoomParticipant participant) {
    if (!isCurrentUserHost || isRoomEnded || isStageActionBusy.value) {
      return false;
    }
    if (participant.userId.isEmpty || participant.userId == _currentUserId) {
      return false;
    }
    if (participant.userId == room.value.hostId) return false;
    return !participant.isSpeaker && !participant.isInvited;
  }

  bool canRemoveParticipant(LearnerVoiceRoomParticipant participant) {
    if (!isCurrentUserHost || isRoomEnded || isStageActionBusy.value) {
      return false;
    }
    if (participant.userId.isEmpty || participant.userId == _currentUserId) {
      return false;
    }
    if (participant.userId == room.value.hostId) return false;
    return participant.isSpeaker;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    chatScrollController.addListener(_onChatScroll);
    unawaited(enterRoom());
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _sendCancelToken?.cancel('Voice room closed.');
    if (!_hasLeft) {
      unawaited(leaveRoom(silent: true));
    } else {
      _socketService.dispose();
      unawaited(_audioService.dispose());
    }
    _dismissStageDialog();
    chatScrollController.dispose();
    messageTextController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_audioService.pauseLocalAudio());
      return;
    }

    if (state == AppLifecycleState.resumed) {
      unawaited(_audioService.resumeLocalAudioIfNeeded());
      unawaited(_syncAudioState());
    }
  }

  Future<void> enterRoom() async {
    if (_hasEntered || isEntering.value) return;
    _hasEntered = true;
    isEntering.value = true;
    errorMessage.value = null;

    try {
      _currentUserId = await _authStorage.getUserId() ?? '';
      await _audioService.initialize(
        roomId: room.value.id,
        currentUserId: _currentUserId,
        sendSignal: ({required signal, required targetUserId}) {
          _socketService.emitRtcSignal(
            roomId: room.value.id,
            targetUserId: targetUserId,
            signal: signal,
          );
        },
      );
      _socketService.listen(
        onParticipantsUpdated: _handleParticipantsUpdated,
        onRoomClosed: _handleRoomClosed,
        onRoomMessage: _handleRoomMessage,
        onStageInvite: _handleStageInvite,
        onStageEvent: _handleStageEvent,
        onRtcSignal: _handleRtcSignal,
        onRoomError: _handleRoomError,
      );
      await _socketService.connect(
        onReconnect: () {
          if (_hasLeft || isRoomEnded) return;
          _socketService.joinRoom(room.value.id);
          unawaited(refreshRoomDetails(silent: true));
          unawaited(loadMessages(reset: true, showLoading: false));
          unawaited(_syncAudioState());
        },
      );

      final joined = await _service.joinRoom(room.value.id);
      room.value = joined;
      _socketService.joinRoom(joined.id);
      unawaited(_syncAudioState());
      await loadMessages(reset: true);
    } catch (error) {
      _hasEntered = false;
      errorMessage.value = _cleanError(error);
    } finally {
      isEntering.value = false;
    }
  }

  Future<void> refreshRoomDetails({bool silent = false}) async {
    try {
      final latest = await _service.getRoom(room.value.id);
      room.value = latest;
      unawaited(_syncAudioState());
      if (!latest.isActive) {
        _markRoomEnded('This voice room has ended.');
      }
    } catch (error) {
      if (!silent) AppSnackbar.error('Voice Room', error);
    }
  }

  Future<void> refreshAll() async {
    await refreshRoomDetails(silent: true);
    await loadMessages(reset: true);
  }

  Future<void> loadMessages({
    required bool reset,
    bool showLoading = true,
  }) async {
    if (reset) {
      if (isLoadingMessages.value) return;
    } else {
      if (isLoadingOlder.value || !hasMoreMessages.value) return;
    }

    final nextPage = reset ? 1 : _messagePage + 1;
    if (reset && showLoading) {
      isLoadingMessages.value = true;
    } else if (!reset) {
      isLoadingOlder.value = true;
    }

    try {
      final page = await _service.getMessages(
        roomId: room.value.id,
        page: nextPage,
        limit: _messageLimit,
        currentUserId: _currentUserId,
      );
      _messagePage = page.page;
      _messageTotalPages = page.totalPages < 1 ? 1 : page.totalPages;
      hasMoreMessages.value = _messagePage < _messageTotalPages;

      if (reset) {
        _mergeMessages(page.messages);
        _scrollToBottomSoon();
      } else {
        _prependOlderMessages(page.messages);
      }
    } catch (error) {
      if (reset && messages.isEmpty) {
        errorMessage.value = _cleanError(error);
      } else {
        AppSnackbar.error('Voice Room Chat', error);
      }
    } finally {
      isLoadingMessages.value = false;
      isLoadingOlder.value = false;
    }
  }

  Future<void> pickImage() async {
    final image = await _mediaService.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    await _setAttachment(File(image.path), _imageExtensions, 'image');
  }

  Future<void> pickVideo() async {
    final video = await _mediaService.pickVideo(source: ImageSource.gallery);
    if (video == null) return;
    await _setAttachment(File(video.path), _videoExtensions, 'video');
  }

  Future<void> pickAudio() async {
    final files = await _mediaService.pickFiles(type: FileType.audio);
    if (files == null || files.isEmpty) return;
    await _setAttachment(files.first, _audioExtensions, 'audio');
  }

  Future<void> pickDocument() async {
    final files = await _mediaService.pickFiles(
      allowedExtensions: _documentExtensions.toList(),
    );
    if (files == null || files.isEmpty) return;
    await _setAttachment(files.first, _documentExtensions, 'document');
  }

  void clearAttachment() {
    pendingAttachment.value = null;
    uploadProgress.value = 0;
  }

  Future<void> sendMessage() async {
    if (isSending.value || isRoomEnded) return;

    final content = messageTextController.text.trim();
    final attachment = pendingAttachment.value;
    if (content.isEmpty && attachment == null) {
      AppSnackbar.warning('Voice Room Chat', 'Type a message first.');
      return;
    }

    isSending.value = true;
    uploadProgress.value = attachment == null ? 1 : 0;
    final clientMessageId =
        'vr-${room.value.id}-${DateTime.now().microsecondsSinceEpoch}';
    final cancelToken = CancelToken();
    _sendCancelToken = cancelToken;

    try {
      final sent = await _service.sendMessage(
        roomId: room.value.id,
        content: content,
        clientMessageId: clientMessageId,
        currentUserId: _currentUserId,
        attachment: attachment?.file,
        type: attachment?.type ?? 'text',
        cancelToken: cancelToken,
        onSendProgress: (sentBytes, totalBytes) {
          if (totalBytes <= 0) return;
          uploadProgress.value = sentBytes / totalBytes;
        },
      );
      messageTextController.clear();
      clearAttachment();
      _upsertMessage(sent);
      _scrollToBottomSoon();
    } catch (error) {
      if (!_isClosing && !cancelToken.isCancelled) {
        AppSnackbar.error('Voice Room Chat', error);
      }
    } finally {
      if (_sendCancelToken == cancelToken) _sendCancelToken = null;
      isSending.value = false;
      uploadProgress.value = 0;
    }
  }

  Future<void> leaveRoom({bool silent = false}) async {
    if (_hasLeft || isLeaving.value) return;
    _hasLeft = true;
    _isClosing = true;
    isLeaving.value = true;
    _sendCancelToken?.cancel('Left voice room.');
    pendingStageInvitation.value = null;
    _dismissStageDialog();
    await _audioService.dispose();
    _socketService.leaveRoom(room.value.id);

    try {
      if (!isRoomEnded) {
        await _service.leaveRoom(room.value.id);
      }
    } catch (error) {
      if (!silent && !isRoomEnded) AppSnackbar.error('Leave Room', error);
    } finally {
      _socketService.dispose();
      _isClosing = false;
      isLeaving.value = false;
      if (Get.isRegistered<LearnerVoiceRoomController>()) {
        unawaited(Get.find<LearnerVoiceRoomController>().refreshRooms());
      }
    }
  }

  Future<void> inviteToStage(LearnerVoiceRoomParticipant participant) async {
    if (!canInviteParticipant(participant)) return;
    isStageActionBusy.value = true;
    try {
      await _service.inviteToStage(
        roomId: room.value.id,
        targetUserId: participant.userId,
      );
      await refreshRoomDetails(silent: true);
      AppSnackbar.success('Voice Room', 'Stage invite sent.');
    } catch (error) {
      AppSnackbar.error('Voice Room', error);
    } finally {
      isStageActionBusy.value = false;
    }
  }

  Future<void> acceptStageInvitation(
    VoiceRoomStageInvitation invitation,
  ) async {
    if (isRoomEnded || isStageActionBusy.value) return;
    if (invitation.id.isEmpty) {
      AppSnackbar.error('Voice Room', 'Stage invitation is missing.');
      return;
    }
    final hasPermission = await _ensureMicrophonePermission();
    if (!hasPermission) return;

    isStageActionBusy.value = true;
    isAudioStarting.value = true;
    var acceptedOnServer = false;
    try {
      final updated = await _service.acceptStageInvite(
        roomId: room.value.id,
        invitationId: invitation.id,
      );
      acceptedOnServer = true;
      room.value = updated;
      pendingStageInvitation.value = null;
      _dismissStageDialog();
      await _audioService.startPublishing(muted: false);
      await _syncAudioState();
      AppSnackbar.success('Voice Room', 'You are on stage.');
    } catch (error) {
      await _audioService.stopPublishing();
      if (acceptedOnServer) {
        await _leaveStageSilently();
      }
      AppSnackbar.error('Voice Room', error);
    } finally {
      isAudioStarting.value = false;
      isStageActionBusy.value = false;
    }
  }

  Future<void> declineStageInvitation(
    VoiceRoomStageInvitation invitation,
  ) async {
    if (isRoomEnded || isStageActionBusy.value) return;
    if (invitation.id.isEmpty) {
      pendingStageInvitation.value = null;
      _dismissStageDialog();
      return;
    }

    isStageActionBusy.value = true;
    try {
      final updated = await _service.declineStageInvite(
        roomId: room.value.id,
        invitationId: invitation.id,
      );
      room.value = updated;
      pendingStageInvitation.value = null;
      _dismissStageDialog();
    } catch (error) {
      AppSnackbar.error('Voice Room', error);
    } finally {
      isStageActionBusy.value = false;
    }
  }

  Future<void> removeSpeakerFromStage(
    LearnerVoiceRoomParticipant participant,
  ) async {
    if (!canRemoveParticipant(participant)) return;
    isStageActionBusy.value = true;
    try {
      final updated = await _service.removeSpeakerFromStage(
        roomId: room.value.id,
        targetUserId: participant.userId,
      );
      room.value = updated;
      AppSnackbar.success('Voice Room', 'Speaker removed.');
      unawaited(_syncAudioState());
    } catch (error) {
      AppSnackbar.error('Voice Room', error);
    } finally {
      isStageActionBusy.value = false;
    }
  }

  Future<void> setParticipantMute(
    LearnerVoiceRoomParticipant participant,
    bool isMuted,
  ) async {
    if (!canRemoveParticipant(participant)) return;
    isStageActionBusy.value = true;
    try {
      final updated = await _service.setStageMute(
        roomId: room.value.id,
        targetUserId: participant.userId,
        isMuted: isMuted,
      );
      room.value = updated;
    } catch (error) {
      AppSnackbar.error('Voice Room', error);
    } finally {
      isStageActionBusy.value = false;
    }
  }

  Future<void> leaveStage() async {
    if (!isCurrentSpeaker || isRoomEnded || isStageActionBusy.value) return;
    isStageActionBusy.value = true;
    try {
      final updated = await _service.leaveStage(room.value.id);
      room.value = updated;
      await _audioService.stopPublishing();
      await _syncAudioState();
    } catch (error) {
      AppSnackbar.error('Voice Room', error);
    } finally {
      isStageActionBusy.value = false;
    }
  }

  Future<void> toggleMute() async {
    if (!isCurrentSpeaker || isRoomEnded || isStageActionBusy.value) return;
    final nextMuted = !isCurrentMuted;
    isStageActionBusy.value = true;
    try {
      final updated = await _service.setStageMute(
        roomId: room.value.id,
        isMuted: nextMuted,
      );
      room.value = updated;
      await _audioService.setMuted(nextMuted);
    } catch (error) {
      AppSnackbar.error('Voice Room', error);
    } finally {
      isStageActionBusy.value = false;
    }
  }

  void _handleParticipantsUpdated(dynamic data) {
    final payload = _mapOf(data);
    if (!_matchesRoom(payload['roomId'])) return;
    _applyParticipantsPayload(payload);
    _closeInviteIfNoLongerPending();
    unawaited(_syncAudioState());
  }

  void _applyParticipantsPayload(Map<String, dynamic> payload) {
    final participants = (payload['participants'] as List? ?? const [])
        .whereType<Object?>()
        .map((item) {
          try {
            return LearnerVoiceRoomParticipant.fromJson(
              Map<String, dynamic>.from(item as Map),
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<LearnerVoiceRoomParticipant>()
        .toList();

    room.value = room.value.copyWith(
      participants: participants,
      participantCount: participants.length,
    );
  }

  void _handleStageInvite(dynamic data) {
    final payload = _mapOf(data);
    if (!_matchesRoom(payload['roomId'])) return;
    final invitation = _stageInvitationFromPayload(payload);
    if (invitation == null || invitation.inviteeId != _currentUserId) return;
    pendingStageInvitation.value = invitation;
    _showStageInviteDialog(invitation);
  }

  void _handleStageEvent(dynamic data) {
    final payload = _mapOf(data);
    if (!_matchesRoom(payload['roomId'])) return;
    final hasParticipantsPayload = payload['participants'] is List;
    if (hasParticipantsPayload) {
      _applyParticipantsPayload(payload);
    }

    final invitation = _stageInvitationFromPayload(payload);
    if (invitation != null && invitation.inviteeId == _currentUserId) {
      if (invitation.status == 'pending') {
        pendingStageInvitation.value = invitation;
      } else {
        pendingStageInvitation.value = null;
        _dismissStageDialog();
      }
    }

    final affectedUserId = (payload['userId'] ?? '').toString();
    if (affectedUserId == _currentUserId) {
      final isMuted = payload['isMuted'];
      if (isMuted is bool) unawaited(_audioService.setMuted(isMuted));
      final stageStatus = (payload['stageStatus'] ?? '').toString();
      if (stageStatus == 'listener' ||
          payload.containsKey('removedBy') ||
          payload['isOnStage'] == false) {
        unawaited(_audioService.stopPublishing());
      }
      if (!hasParticipantsPayload) {
        unawaited(refreshRoomDetails(silent: true));
        return;
      }
    }

    _closeInviteIfNoLongerPending();
    unawaited(_syncAudioState());
  }

  void _handleRtcSignal(dynamic data) {
    final payload = _mapOf(data);
    if (!_matchesRoom(payload['roomId'])) return;
    final fromUserId = (payload['fromUserId'] ?? '').toString();
    final rawSignal = payload['signal'];
    if (fromUserId.isEmpty || rawSignal is! Map) return;
    unawaited(
      _audioService.handleSignal(
        fromUserId: fromUserId,
        signal: Map<String, dynamic>.from(rawSignal),
      ),
    );
  }

  void _handleRoomMessage(dynamic data) {
    final payload = _mapOf(data);
    if (!_matchesRoom(payload['roomId'])) return;
    final rawMessage = payload['message'];
    if (rawMessage is! Map) return;

    try {
      final message = VoiceRoomMessage.fromJson(
        Map<String, dynamic>.from(rawMessage),
        _currentUserId,
      );
      _upsertMessage(message);
      _scrollToBottomSoon();
    } catch (_) {
      return;
    }
  }

  void _handleRoomClosed(dynamic data) {
    final payload = _mapOf(data);
    if (!_matchesRoom(payload['roomId'])) return;
    _markRoomEnded(
      (payload['message'] ?? 'This voice room has ended.').toString(),
    );
  }

  void _handleRoomError(dynamic data) {
    final payload = _mapOf(data);
    if (!_matchesRoom(payload['roomId'])) return;
    AppSnackbar.error(
      'Voice Room',
      (payload['message'] ?? 'Voice room unavailable.').toString(),
    );
  }

  Future<bool> _ensureMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;
    status = await Permission.microphone.request();
    if (status.isGranted) return true;
    AppSnackbar.warning(
      'Microphone Required',
      'Microphone permission is required to speak on stage.',
    );
    return false;
  }

  Future<void> _syncAudioState() async {
    if (_hasLeft || _isClosing || room.value.id.isEmpty) return;
    final participant = currentParticipant;
    final localIsSpeaker = participant?.isSpeaker == true;

    try {
      if (!localIsSpeaker) {
        if (_audioService.isPublishing) await _audioService.stopPublishing();
      } else if (_audioService.isPublishing) {
        await _audioService.setMuted(participant?.isMuted == true);
      } else if (await Permission.microphone.status.isGranted) {
        await _audioService.startPublishing(
          muted: participant?.isMuted == true,
        );
      }

      await _audioService.syncParticipants(
        participants: room.value.participants,
        localIsSpeaker: localIsSpeaker,
      );
    } catch (error) {
      if (localIsSpeaker && !_isClosing) {
        await _leaveStageSilently();
        AppSnackbar.error('Voice Room Audio', error);
      }
    }
  }

  Future<void> _leaveStageSilently() async {
    try {
      final updated = await _service.leaveStage(room.value.id);
      room.value = updated;
    } catch (_) {
      return;
    } finally {
      await _audioService.stopPublishing();
    }
  }

  VoiceRoomStageInvitation? _stageInvitationFromPayload(
    Map<String, dynamic> payload,
  ) {
    final raw = payload['invitation'];
    if (raw is! Map) return null;
    try {
      return VoiceRoomStageInvitation.fromJson(Map<String, dynamic>.from(raw));
    } catch (_) {
      return null;
    }
  }

  void _closeInviteIfNoLongerPending() {
    final invitation = pendingStageInvitation.value;
    if (invitation == null) return;
    final participant = currentParticipant;
    if (participant?.isInvited == true &&
        participant?.stageInvitationId == invitation.id) {
      return;
    }
    pendingStageInvitation.value = null;
    _dismissStageDialog();
  }

  void _showStageInviteDialog(VoiceRoomStageInvitation invitation) {
    if (_stageDialogVisible || _isClosing || isRoomEnded) return;
    _stageDialogVisible = true;
    Get.dialog<void>(
      Obx(() {
        final currentInvitation = pendingStageInvitation.value ?? invitation;
        final busy = isStageActionBusy.value;
        final starting = isAudioStarting.value;
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE6F7F4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Color(0xFF168A7E),
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "You're invited on stage",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentInvitation.roomName.trim().isEmpty
                        ? room.value.name
                        : currentInvitation.roomName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: busy || starting
                              ? null
                              : () => unawaited(
                                  declineStageInvitation(currentInvitation),
                                ),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF64748B),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Decline',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: busy || starting
                              ? null
                              : () => unawaited(
                                  acceptStageInvitation(currentInvitation),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF26A69A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: starting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.keyboard_voice_rounded),
                          label: Text(starting ? 'Starting' : 'On Stage'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      barrierDismissible: false,
    ).whenComplete(() => _stageDialogVisible = false);
  }

  void _dismissStageDialog() {
    if (!_stageDialogVisible) return;
    _stageDialogVisible = false;
    if (Get.isDialogOpen == true) Get.back<void>();
  }

  Future<void> _setAttachment(
    File file,
    Set<String> allowedExtensions,
    String type,
  ) async {
    if (!await _validateAttachment(file, allowedExtensions, type)) return;
    pendingAttachment.value = VoiceRoomPendingAttachment(
      file: file,
      type: type,
      displayName: file.uri.pathSegments.isEmpty
          ? type
          : file.uri.pathSegments.last,
    );
  }

  Future<bool> _validateAttachment(
    File file,
    Set<String> allowedExtensions,
    String label,
  ) async {
    final extension = file.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      AppSnackbar.warning(
        'Unsupported $label',
        'Please choose a supported $label file.',
      );
      return false;
    }

    final size = await file.length();
    if (size > _maxAttachmentBytes) {
      AppSnackbar.warning(
        'File too large',
        'Please choose a file under 200 MB.',
      );
      return false;
    }
    return true;
  }

  void _onChatScroll() {
    if (!chatScrollController.hasClients) return;
    if (chatScrollController.position.pixels <= 120) {
      unawaited(loadMessages(reset: false));
    }
  }

  void _mergeMessages(List<VoiceRoomMessage> incoming) {
    final byId = {for (final message in messages) message.id: message};
    for (final message in incoming) {
      byId[message.id] = message;
    }
    final merged = byId.values.toList()..sort(_compareMessages);
    messages.assignAll(merged);
  }

  void _prependOlderMessages(List<VoiceRoomMessage> older) {
    final existingIds = messages.map((message) => message.id).toSet();
    final fresh = older
        .where((message) => !existingIds.contains(message.id))
        .toList();
    if (fresh.isEmpty) return;
    messages.insertAll(0, fresh);
    messages.sort(_compareMessages);
    messages.refresh();
  }

  void _upsertMessage(VoiceRoomMessage message) {
    if (message.id.isEmpty || !_matchesRoom(message.roomId)) return;
    final index = messages.indexWhere((item) => item.id == message.id);
    if (index == -1) {
      messages.add(message);
    } else {
      messages[index] = message;
    }
    messages.sort(_compareMessages);
    messages.refresh();
  }

  int _compareMessages(VoiceRoomMessage a, VoiceRoomMessage b) {
    final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final result = aTime.compareTo(bTime);
    if (result != 0) return result;
    return a.id.compareTo(b.id);
  }

  void _markRoomEnded(String message) {
    if (roomEndedMessage.value != null) return;
    roomEndedMessage.value = message;
    room.value = room.value.copyWith(status: 'ended', isActive: false);
    _socketService.leaveRoom(room.value.id);
    AppSnackbar.warning('Voice Room Ended', message);
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!chatScrollController.hasClients) return;
      chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  bool _matchesRoom(dynamic roomId) => roomId?.toString() == room.value.id;

  Map<String, dynamic> _mapOf(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '').trim();
  }
}
