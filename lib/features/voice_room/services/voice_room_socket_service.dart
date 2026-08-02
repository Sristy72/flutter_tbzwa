import '../../../core/api/socket_client.dart';
import '../../../core/constants/api_constants.dart';

class LearnerVoiceRoomSocketService {
  final SocketClient _socketClient = SocketClient();
  final Set<String> _joinedRoomIds = {};

  SocketEventHandler? _connectHandler;
  SocketEventHandler? _participantsUpdatedHandler;
  SocketEventHandler? _roomClosedHandler;
  SocketEventHandler? _roomErrorHandler;
  SocketEventHandler? _messageHandler;
  SocketEventHandler? _stageInviteHandler;
  SocketEventHandler? _stageEventHandler;
  SocketEventHandler? _rtcSignalHandler;

  bool get isConnected => _socketClient.isConnected;

  Future<void> connect({void Function()? onReconnect}) async {
    if (_connectHandler == null) {
      _connectHandler = (_) {
        _rejoinTrackedRooms();
        onReconnect?.call();
      };
      _socketClient.on('connect', _connectHandler!);
    }

    await _socketClient.connect();
    if (_socketClient.isConnected) {
      _rejoinTrackedRooms();
    } else {
      _socketClient.onReady
          .then((_) => _rejoinTrackedRooms())
          .catchError((_) {});
    }
  }

  void listen({
    required SocketEventHandler onParticipantsUpdated,
    required SocketEventHandler onRoomClosed,
    required SocketEventHandler onRoomMessage,
    required SocketEventHandler onStageInvite,
    required SocketEventHandler onStageEvent,
    required SocketEventHandler onRtcSignal,
    SocketEventHandler? onRoomError,
  }) {
    removeRoomListeners();
    _participantsUpdatedHandler = onParticipantsUpdated;
    _roomClosedHandler = onRoomClosed;
    _roomErrorHandler = onRoomError;
    _messageHandler = onRoomMessage;
    _stageInviteHandler = onStageInvite;
    _stageEventHandler = onStageEvent;
    _rtcSignalHandler = onRtcSignal;

    _socketClient.on(
      ApiConstants.socketEvents.voiceRoomParticipantsUpdated,
      onParticipantsUpdated,
    );
    _socketClient.on(ApiConstants.socketEvents.roomClosed, onRoomClosed);
    _socketClient.on(ApiConstants.socketEvents.voiceRoomMessage, onRoomMessage);
    _socketClient.on(
      ApiConstants.socketEvents.voiceRoomStageInvite,
      onStageInvite,
    );
    _socketClient.on(ApiConstants.socketEvents.voiceRoomRtcSignal, onRtcSignal);
    for (final event in _stageEvents) {
      _socketClient.on(event, onStageEvent);
    }
    if (onRoomError != null) {
      _socketClient.on(ApiConstants.socketEvents.roomError, onRoomError);
    }
  }

  void joinRoom(String roomId) {
    if (roomId.isEmpty) return;
    _joinedRoomIds.add(roomId);
    _emitJoin(roomId);
  }

  void leaveRoom(String roomId) {
    if (roomId.isEmpty) return;
    _joinedRoomIds.remove(roomId);
    _socketClient.emit(ApiConstants.socketEvents.voiceRoomLeave, {
      'roomId': roomId,
    });
  }

  void emitRtcSignal({
    required String roomId,
    required String targetUserId,
    required Map<String, dynamic> signal,
  }) {
    if (roomId.isEmpty || targetUserId.isEmpty || !_socketClient.isConnected) {
      return;
    }
    _socketClient.emit(ApiConstants.socketEvents.voiceRoomRtcSignal, {
      'roomId': roomId,
      'targetUserId': targetUserId,
      'signal': signal,
    });
  }

  void removeRoomListeners() {
    if (_participantsUpdatedHandler != null) {
      _socketClient.off(
        ApiConstants.socketEvents.voiceRoomParticipantsUpdated,
        _participantsUpdatedHandler,
      );
      _participantsUpdatedHandler = null;
    }
    if (_roomClosedHandler != null) {
      _socketClient.off(
        ApiConstants.socketEvents.roomClosed,
        _roomClosedHandler,
      );
      _roomClosedHandler = null;
    }
    if (_messageHandler != null) {
      _socketClient.off(
        ApiConstants.socketEvents.voiceRoomMessage,
        _messageHandler,
      );
      _messageHandler = null;
    }
    if (_stageInviteHandler != null) {
      _socketClient.off(
        ApiConstants.socketEvents.voiceRoomStageInvite,
        _stageInviteHandler,
      );
      _stageInviteHandler = null;
    }
    if (_stageEventHandler != null) {
      for (final event in _stageEvents) {
        _socketClient.off(event, _stageEventHandler);
      }
      _stageEventHandler = null;
    }
    if (_rtcSignalHandler != null) {
      _socketClient.off(
        ApiConstants.socketEvents.voiceRoomRtcSignal,
        _rtcSignalHandler,
      );
      _rtcSignalHandler = null;
    }
    if (_roomErrorHandler != null) {
      _socketClient.off(ApiConstants.socketEvents.roomError, _roomErrorHandler);
      _roomErrorHandler = null;
    }
  }

  void dispose() {
    for (final roomId in List<String>.from(_joinedRoomIds)) {
      leaveRoom(roomId);
    }
    removeRoomListeners();
    final connectHandler = _connectHandler;
    if (connectHandler != null) {
      _socketClient.off('connect', connectHandler);
      _connectHandler = null;
    }
  }

  void _rejoinTrackedRooms() {
    for (final roomId in _joinedRoomIds) {
      _emitJoin(roomId);
    }
  }

  void _emitJoin(String roomId) {
    if (!_socketClient.isConnected) return;
    _socketClient.emit(ApiConstants.socketEvents.voiceRoomJoin, {
      'roomId': roomId,
    });
  }

  List<String> get _stageEvents => [
    ApiConstants.socketEvents.voiceRoomStageInvitationCreated,
    ApiConstants.socketEvents.voiceRoomStageInvitationAccepted,
    ApiConstants.socketEvents.voiceRoomStageInvitationDeclined,
    ApiConstants.socketEvents.voiceRoomStageInvitationCancelled,
    ApiConstants.socketEvents.voiceRoomStageChanged,
    ApiConstants.socketEvents.voiceRoomStageDeclined,
    ApiConstants.socketEvents.voiceRoomStageRemoved,
    ApiConstants.socketEvents.voiceRoomStageLeft,
    ApiConstants.socketEvents.voiceRoomStageMuted,
  ];
}
