import 'dart:async';

import 'package:flutx_core/core/debug_print.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;

import '../models/voice_room_model.dart';

typedef VoiceRoomSignalSender =
    void Function({
      required String targetUserId,
      required Map<String, dynamic> signal,
    });

class VoiceRoomAudioService {
  final Map<String, webrtc.RTCPeerConnection> _peers = {};
  final Map<String, webrtc.MediaStream> _remoteStreams = {};
  final Map<String, Set<String>> _localTrackIdsByPeer = {};

  webrtc.MediaStream? _localStream;
  String _roomId = '';
  String _currentUserId = '';
  VoiceRoomSignalSender? _sendSignal;
  bool _isPublishing = false;
  bool _isMuted = false;

  final Map<String, dynamic> _iceServers = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
    ],
  };

  final Map<String, dynamic> _config = {'sdpSemantics': 'unified-plan'};

  bool get isPublishing => _isPublishing;

  bool get isMuted => _isMuted;

  Future<void> initialize({
    required String roomId,
    required String currentUserId,
    required VoiceRoomSignalSender sendSignal,
  }) async {
    _roomId = roomId;
    _currentUserId = currentUserId;
    _sendSignal = sendSignal;
    await _configureAudioSession();
  }

  Future<void> startPublishing({bool muted = false}) async {
    if (_isPublishing && _localStream != null) {
      await setMuted(muted);
      return;
    }

    _localStream = await webrtc.navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });
    _isPublishing = true;
    await setMuted(muted);

    for (final entry in _peers.entries) {
      final addedTracks = await _addLocalTracks(entry.key, entry.value);
      if (addedTracks) {
        await _createAndSendOffer(entry.key, entry.value);
      }
    }
  }

  Future<void> stopPublishing() async {
    _isPublishing = false;
    _isMuted = false;
    final stream = _localStream;
    _localStream = null;
    _localTrackIdsByPeer.clear();
    if (stream == null) return;
    for (final track in stream.getTracks()) {
      track.enabled = false;
      await track.stop();
    }
    await stream.dispose();
  }

  Future<void> setMuted(bool muted) async {
    _isMuted = muted;
    final enabled = !muted;
    for (final track in _localStream?.getAudioTracks() ?? const []) {
      track.enabled = enabled;
    }
  }

  Future<void> pauseLocalAudio() async {
    for (final track in _localStream?.getAudioTracks() ?? const []) {
      track.enabled = false;
    }
  }

  Future<void> resumeLocalAudioIfNeeded() async {
    if (!_isPublishing) return;
    for (final track in _localStream?.getAudioTracks() ?? const []) {
      track.enabled = !_isMuted;
    }
  }

  Future<void> syncParticipants({
    required List<LearnerVoiceRoomParticipant> participants,
    required bool localIsSpeaker,
  }) async {
    if (_roomId.isEmpty || _currentUserId.isEmpty) return;

    final speakers = participants
        .where((participant) => participant.userId != _currentUserId)
        .where((participant) => participant.isSpeaker)
        .map((participant) => participant.userId)
        .where((userId) => userId.isNotEmpty)
        .toSet();

    final targets = localIsSpeaker
        ? participants
              .map((participant) => participant.userId)
              .where((userId) => userId.isNotEmpty && userId != _currentUserId)
              .toSet()
        : speakers;

    for (final userId in _peers.keys.toList()) {
      if (!targets.contains(userId)) {
        await _closePeer(userId);
      }
    }

    for (final targetUserId in targets) {
      final shouldOffer = _currentUserId.compareTo(targetUserId) < 0;
      await _ensurePeer(targetUserId, createOffer: shouldOffer);
    }
  }

  Future<void> handleSignal({
    required String fromUserId,
    required Map<String, dynamic> signal,
  }) async {
    if (fromUserId.isEmpty || fromUserId == _currentUserId) return;
    final type = (signal['type'] ?? '').toString();
    final peer = await _ensurePeer(fromUserId, createOffer: false);

    try {
      if (type == 'offer') {
        final sdp = signal['sdp']?.toString();
        if (sdp == null || sdp.isEmpty) return;
        await peer.setRemoteDescription(
          webrtc.RTCSessionDescription(sdp, 'offer'),
        );
        await _addLocalTracks(fromUserId, peer);
        final answer = await peer.createAnswer({'offerToReceiveAudio': true});
        await peer.setLocalDescription(answer);
        _emitSignal(fromUserId, {'type': 'answer', 'sdp': answer.sdp});
      } else if (type == 'answer') {
        final sdp = signal['sdp']?.toString();
        if (sdp == null || sdp.isEmpty) return;
        await peer.setRemoteDescription(
          webrtc.RTCSessionDescription(sdp, 'answer'),
        );
      } else if (type == 'candidate') {
        final candidate = signal['candidate']?.toString();
        final sdpMid = signal['sdpMid']?.toString();
        final sdpMLineIndex = (signal['sdpMLineIndex'] as num?)?.toInt();
        if (candidate == null || sdpMid == null || sdpMLineIndex == null) {
          return;
        }
        await peer.addCandidate(
          webrtc.RTCIceCandidate(candidate, sdpMid, sdpMLineIndex),
        );
      }
    } catch (error) {
      DPrint.error('Voice room WebRTC signal failed: ${error.runtimeType}');
    }
  }

  Future<void> dispose() async {
    await stopPublishing();
    for (final userId in _peers.keys.toList()) {
      await _closePeer(userId);
    }
    _sendSignal = null;
    _roomId = '';
    _currentUserId = '';
  }

  Future<webrtc.RTCPeerConnection> _ensurePeer(
    String targetUserId, {
    required bool createOffer,
  }) async {
    final existing = _peers[targetUserId];
    if (existing != null) return existing;

    final peer = await webrtc.createPeerConnection(_iceServers, _config);
    _peers[targetUserId] = peer;
    await _addLocalTracks(targetUserId, peer);

    peer.onIceCandidate = (candidate) {
      if (candidate.candidate == null) return;
      _emitSignal(targetUserId, {
        'type': 'candidate',
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    peer.onTrack = (event) {
      if (event.streams.isNotEmpty) {
        _remoteStreams[targetUserId] = event.streams.first;
      }
    };

    if (createOffer) {
      await _createAndSendOffer(targetUserId, peer);
    }

    return peer;
  }

  Future<bool> _addLocalTracks(
    String targetUserId,
    webrtc.RTCPeerConnection peer,
  ) async {
    final stream = _localStream;
    if (stream == null) return false;
    final attachedTrackIds = _localTrackIdsByPeer.putIfAbsent(
      targetUserId,
      () => <String>{},
    );
    var added = false;
    for (final track in stream.getAudioTracks()) {
      final trackId = track.id ?? '${track.kind}-${identityHashCode(track)}';
      if (attachedTrackIds.contains(trackId)) continue;
      try {
        await peer.addTrack(track, stream);
        attachedTrackIds.add(trackId);
        added = true;
      } catch (_) {
        // Some WebRTC builds throw when a track is already attached.
      }
    }
    return added;
  }

  Future<void> _createAndSendOffer(
    String targetUserId,
    webrtc.RTCPeerConnection peer,
  ) async {
    try {
      final offer = await peer.createOffer({'offerToReceiveAudio': true});
      await peer.setLocalDescription(offer);
      _emitSignal(targetUserId, {'type': 'offer', 'sdp': offer.sdp});
    } catch (error) {
      DPrint.error('Voice room WebRTC offer failed: ${error.runtimeType}');
    }
  }

  void _emitSignal(String targetUserId, Map<String, dynamic> signal) {
    final sender = _sendSignal;
    if (sender == null || targetUserId.isEmpty || _roomId.isEmpty) return;
    sender(targetUserId: targetUserId, signal: signal);
  }

  Future<void> _closePeer(String userId) async {
    final peer = _peers.remove(userId);
    final remoteStream = _remoteStreams.remove(userId);
    _localTrackIdsByPeer.remove(userId);
    await remoteStream?.dispose();
    await peer?.close();
  }

  Future<void> _configureAudioSession() async {
    try {
      await webrtc.Helper.setSpeakerphoneOn(true);
    } catch (_) {
      // Some platforms no-op here; WebRTC still owns the audio session.
    }
  }
}
