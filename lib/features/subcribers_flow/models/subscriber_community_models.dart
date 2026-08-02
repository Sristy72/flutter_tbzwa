import '../../../core/constants/api_constants.dart';

class SubscriberCommunityUser {
  final String id;
  final String fullName;
  final String userId;
  final String language;
  final String country;
  final String address;
  final String? profileImageUrl;

  const SubscriberCommunityUser({
    required this.id,
    required this.fullName,
    required this.userId,
    required this.language,
    required this.country,
    required this.address,
    required this.profileImageUrl,
  });

  factory SubscriberCommunityUser.fromJson(Map<String, dynamic> json) {
    final profileImage = json['profileImage'] as Map?;
    return SubscriberCommunityUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? 'TalkBZ User').toString(),
      userId: (json['userId'] ?? '').toString(),
      language: (json['language'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      profileImageUrl: _absoluteUrl(profileImage?['url']?.toString()),
    );
  }

  String get languageLabel {
    if (language.isEmpty) return userId.isEmpty ? 'TalkBZ learner' : userId;
    return '$language - Learning English';
  }

  String get shortLanguages =>
      language.isEmpty ? 'Eng' : '${language.toUpperCase()} - Eng';

  String get locationLabel {
    final parts = [
      address,
      country,
    ].map((item) => item.trim()).where((item) => item.isNotEmpty).toList();
    return parts.isEmpty ? userId : parts.join(', ');
  }
}

class SubscriberFriendRequest {
  final String id;
  final SubscriberCommunityUser requester;

  const SubscriberFriendRequest({required this.id, required this.requester});

  factory SubscriberFriendRequest.fromJson(Map<String, dynamic> json) {
    return SubscriberFriendRequest(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      requester: SubscriberCommunityUser.fromJson(
        Map<String, dynamic>.from(json['requester'] as Map? ?? const {}),
      ),
    );
  }
}

class SubscriberOnlineFriend {
  final SubscriberCommunityUser user;

  const SubscriberOnlineFriend({required this.user});

  factory SubscriberOnlineFriend.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] is Map ? json['user'] : json;
    return SubscriberOnlineFriend(
      user: SubscriberCommunityUser.fromJson(
        Map<String, dynamic>.from(userJson as Map? ?? const {}),
      ),
    );
  }
}

class SubscriberVoiceRoom {
  final String id;
  final String title;
  final String hostName;
  final String hostSubtitle;
  final String language;
  final int participantCount;
  final int maxParticipants;
  final bool isPro;
  final String? hostImageUrl;
  final List<SubscriberVoiceRoomParticipant> participants;

  const SubscriberVoiceRoom({
    required this.id,
    required this.title,
    required this.hostName,
    required this.hostSubtitle,
    required this.language,
    required this.participantCount,
    required this.maxParticipants,
    required this.isPro,
    required this.hostImageUrl,
    required this.participants,
  });

  factory SubscriberVoiceRoom.fromJson(Map<String, dynamic> json) {
    final host = json['host'] as Map? ?? const {};
    final group = json['group'] as Map? ?? const {};
    final privacy = (json['privacy'] ?? 'public').toString();
    return SubscriberVoiceRoom(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['name'] ?? 'Voice Room').toString(),
      hostName: (host['fullName'] ?? 'Host').toString(),
      hostSubtitle: (group['name'] ?? 'Daily Conversation Practice').toString(),
      language: privacy == 'private' ? 'Private' : 'English',
      participantCount:
          (json['participantCount'] as num?)?.toInt() ??
          (json['participants'] as List? ?? const []).length,
      maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 20,
      isPro: json['isLocked'] == true || privacy == 'private',
      hostImageUrl: _absoluteUrl(host['profileImageUrl']?.toString()),
      participants: (json['participants'] as List? ?? const [])
          .map(
            (item) => SubscriberVoiceRoomParticipant.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  String get countLabel => '$participantCount/$maxParticipants';
}

class SubscriberVoiceRoomParticipant {
  final String? imageUrl;
  final bool isMuted;

  const SubscriberVoiceRoomParticipant({
    required this.imageUrl,
    required this.isMuted,
  });

  factory SubscriberVoiceRoomParticipant.fromJson(Map<String, dynamic> json) {
    final user = json['userId'] as Map? ?? const {};
    final profileImage = user['profileImage'] as Map?;
    return SubscriberVoiceRoomParticipant(
      imageUrl: _absoluteUrl(profileImage?['url']?.toString()),
      isMuted: json['isOnStage'] != true,
    );
  }
}

String? _absoluteUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (url.startsWith('/')) return '${ApiConstants.baseDomain}$url';
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme) return url;
  if (_isLocalBackendHost(uri.host) && uri.path.isNotEmpty) {
    final base = Uri.parse(ApiConstants.baseDomain);
    return base
        .replace(path: uri.path, query: uri.query.isEmpty ? null : uri.query)
        .toString();
  }
  return url;
}

bool _isLocalBackendHost(String host) {
  if (host == 'localhost' || host == '127.0.0.1') return true;
  if (host.startsWith('10.')) return true;
  if (host.startsWith('192.168.')) return true;
  final parts = host.split('.');
  if (parts.length == 4 && parts.first == '172') {
    final second = int.tryParse(parts[1]);
    return second != null && second >= 16 && second <= 31;
  }
  return false;
}
