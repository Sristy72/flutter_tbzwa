import '../../../core/api/socket_client.dart';
import '../../../core/constants/api_constants.dart';

class InstructorMessagesSocketService {
  final SocketClient _socketClient = SocketClient();

  SocketEventHandler? _connectHandler;
  SocketEventHandler? _directMessageHandler;
  SocketEventHandler? _groupMessageHandler;
  SocketEventHandler? _readHandler;
  SocketEventHandler? _statusHandler;

  bool get isConnected => _socketClient.isConnected;

  Future<void> connect({void Function()? onReconnect}) async {
    if (_connectHandler == null) {
      _connectHandler = (_) {
        emitUserOnline();
        onReconnect?.call();
      };
      _socketClient.on('connect', _connectHandler!);
    }

    await _socketClient.connect();
    if (_socketClient.isConnected) {
      emitUserOnline();
    } else {
      _socketClient.onReady.then((_) => emitUserOnline()).catchError((_) {});
    }
  }

  void listen({
    required SocketEventHandler onDirectMessage,
    required SocketEventHandler onGroupMessage,
    required SocketEventHandler onMessagesRead,
    SocketEventHandler? onUserStatus,
  }) {
    removeMessageListeners();
    _directMessageHandler = onDirectMessage;
    _groupMessageHandler = onGroupMessage;
    _readHandler = onMessagesRead;
    _statusHandler = onUserStatus;

    _socketClient.on(ApiConstants.socketEvents.messageReceive, onDirectMessage);
    _socketClient.on(ApiConstants.socketEvents.groupMessage, onGroupMessage);
    _socketClient.on(ApiConstants.socketEvents.messagesRead, onMessagesRead);
    if (onUserStatus != null) {
      _socketClient.on(ApiConstants.socketEvents.userStatus, onUserStatus);
    }
  }

  void joinDirectConversation(String conversationId) {
    if (conversationId.isEmpty) return;
    _socketClient.emit(ApiConstants.socketEvents.joinRoom, {
      'roomId': conversationId,
      'type': 'conversation',
    });
  }

  void joinGroup(String groupId) {
    if (groupId.isEmpty) return;
    _socketClient.emit(ApiConstants.socketEvents.joinRoom, {
      'roomId': groupId,
      'type': 'group',
    });
  }

  void markDirectConversationRead(String conversationId) {
    if (conversationId.isEmpty) return;
    _socketClient.emit(ApiConstants.socketEvents.messageRead, {
      'conversationId': conversationId,
    });
  }

  void emitUserOnline() {
    _socketClient.emit(ApiConstants.socketEvents.userOnline);
  }

  void removeMessageListeners() {
    if (_directMessageHandler != null) {
      _socketClient.off(
        ApiConstants.socketEvents.messageReceive,
        _directMessageHandler,
      );
      _directMessageHandler = null;
    }
    if (_groupMessageHandler != null) {
      _socketClient.off(
        ApiConstants.socketEvents.groupMessage,
        _groupMessageHandler,
      );
      _groupMessageHandler = null;
    }
    if (_readHandler != null) {
      _socketClient.off(ApiConstants.socketEvents.messagesRead, _readHandler);
      _readHandler = null;
    }
    if (_statusHandler != null) {
      _socketClient.off(ApiConstants.socketEvents.userStatus, _statusHandler);
      _statusHandler = null;
    }
  }

  void dispose() {
    removeMessageListeners();
    final connectHandler = _connectHandler;
    if (connectHandler != null) {
      _socketClient.off('connect', connectHandler);
      _connectHandler = null;
    }
  }
}
