import '../../../core/constants/api_constants.dart';

class CommunityFeedResult {
  final bool isLocked;
  final String? message;
  final List<CommunityPost> posts;
  final int page;
  final int totalPages;
  final int total;

  const CommunityFeedResult({
    required this.isLocked,
    required this.message,
    required this.posts,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  factory CommunityFeedResult.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic>? meta,
  ) {
    return CommunityFeedResult(
      isLocked: json['isLocked'] == true,
      message: json['message']?.toString(),
      posts: (json['posts'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => CommunityPost.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((post) => post.id.isNotEmpty)
          .toList(),
      page: (meta?['page'] as num?)?.toInt() ?? 1,
      totalPages: (meta?['totalPages'] as num?)?.toInt() ?? 1,
      total: (meta?['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class CommunityCommentPage {
  final List<CommunityComment> comments;
  final int page;
  final int totalPages;
  final int total;

  const CommunityCommentPage({
    required this.comments,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  factory CommunityCommentPage.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic>? meta,
  ) {
    return CommunityCommentPage(
      comments: (json['comments'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                CommunityComment.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((comment) => comment.id.isNotEmpty)
          .toList(),
      page: (meta?['page'] as num?)?.toInt() ?? 1,
      totalPages: (meta?['totalPages'] as num?)?.toInt() ?? 1,
      total: (meta?['total'] as num?)?.toInt() ?? 0,
    );
  }
}

enum FriendRequestMode {
  received,
  sent;

  String get apiValue => this == FriendRequestMode.sent ? 'sent' : 'received';
}

enum FriendshipUiState {
  none,
  requestSent,
  requestReceived,
  friends,
  rejected,
  blocked,
  self,
  unknown,
}

class FriendshipStatus {
  final FriendshipUiState state;
  final String rawState;
  final String rawStatus;
  final String? friendshipId;
  final String? requestId;
  final bool canSendRequest;
  final bool canAccept;
  final bool canDecline;
  final bool canMessage;
  final bool canUnfriend;

  const FriendshipStatus({
    required this.state,
    required this.rawState,
    required this.rawStatus,
    required this.friendshipId,
    required this.requestId,
    required this.canSendRequest,
    required this.canAccept,
    required this.canDecline,
    required this.canMessage,
    required this.canUnfriend,
  });

  const FriendshipStatus.none()
    : state = FriendshipUiState.none,
      rawState = 'none',
      rawStatus = 'none',
      friendshipId = null,
      requestId = null,
      canSendRequest = true,
      canAccept = false,
      canDecline = false,
      canMessage = false,
      canUnfriend = false;

  factory FriendshipStatus.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const FriendshipStatus.none();
    final rawState = (json['state'] ?? 'none').toString();
    return FriendshipStatus(
      state: _friendshipState(rawState),
      rawState: rawState,
      rawStatus: (json['rawStatus'] ?? rawState).toString(),
      friendshipId: _nullableString(json['friendshipId']),
      requestId: _nullableString(json['requestId']),
      canSendRequest: json['canSendRequest'] == true,
      canAccept: json['canAccept'] == true,
      canDecline: json['canDecline'] == true,
      canMessage: json['canMessage'] == true,
      canUnfriend: json['canUnfriend'] == true,
    );
  }

  bool get isPending =>
      state == FriendshipUiState.requestSent ||
      state == FriendshipUiState.requestReceived;
}

class PublicUserSummary {
  final String id;
  final String displayName;
  final String username;
  final String bio;
  final String role;
  final String? avatarUrl;
  final int publicPostCount;

  const PublicUserSummary({
    required this.id,
    required this.displayName,
    required this.username,
    required this.bio,
    required this.role,
    required this.avatarUrl,
    required this.publicPostCount,
  });

  factory PublicUserSummary.fromJson(Map<String, dynamic> json) {
    final profileImage = _asMap(json['profileImage']);
    final avatar = (json['avatarUrl'] ?? profileImage?['url'])?.toString();
    return PublicUserSummary(
      id: _idFrom(json) ?? '',
      displayName: (json['displayName'] ?? json['fullName'] ?? 'TalkBZ User')
          .toString(),
      username: (json['username'] ?? json['userId'] ?? '').toString(),
      bio: (json['bio'] ?? '').toString(),
      role: (json['role'] ?? '').toString(),
      avatarUrl: _absoluteUrl(avatar),
      publicPostCount: _nonNegativeInt(json['publicPostCount']),
    );
  }
}

class PublicProfileResult {
  final PublicUserSummary user;
  final List<CommunityPost> posts;
  final FriendshipStatus friendshipStatus;
  final int page;
  final int totalPages;
  final int total;

  const PublicProfileResult({
    required this.user,
    required this.posts,
    required this.friendshipStatus,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  factory PublicProfileResult.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic>? meta,
  ) {
    final userMap = _asMap(json['user']) ?? const <String, dynamic>{};
    return PublicProfileResult(
      user: PublicUserSummary.fromJson(userMap),
      posts: (json['posts'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => CommunityPost.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((post) => post.id.isNotEmpty)
          .toList(),
      friendshipStatus: FriendshipStatus.fromJson(
        _asMap(json['friendshipStatus']),
      ),
      page: (meta?['page'] as num?)?.toInt() ?? 1,
      totalPages: (meta?['totalPages'] as num?)?.toInt() ?? 1,
      total:
          (meta?['total'] as num?)?.toInt() ??
          _nonNegativeInt(userMap['publicPostCount']),
    );
  }
}

class FriendRequestPage {
  final FriendRequestMode mode;
  final List<FriendRequestItem> requests;
  final int page;
  final int totalPages;
  final int total;

  const FriendRequestPage({
    required this.mode,
    required this.requests,
    required this.page,
    required this.totalPages,
    required this.total,
  });

  factory FriendRequestPage.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic>? meta,
    FriendRequestMode mode,
  ) {
    return FriendRequestPage(
      mode: mode,
      requests: (json['requests'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) => FriendRequestItem.fromJson(
              Map<String, dynamic>.from(item),
              mode,
            ),
          )
          .where(
            (request) => request.id.isNotEmpty && request.user.id.isNotEmpty,
          )
          .toList(),
      page: (meta?['page'] as num?)?.toInt() ?? 1,
      totalPages: (meta?['totalPages'] as num?)?.toInt() ?? 1,
      total: (meta?['total'] as num?)?.toInt() ?? 0,
    );
  }
}

class FriendRequestItem {
  final String id;
  final String status;
  final FriendRequestMode direction;
  final PublicUserSummary user;
  final FriendshipStatus friendshipStatus;
  final DateTime? createdAt;

  const FriendRequestItem({
    required this.id,
    required this.status,
    required this.direction,
    required this.user,
    required this.friendshipStatus,
    required this.createdAt,
  });

  factory FriendRequestItem.fromJson(
    Map<String, dynamic> json,
    FriendRequestMode mode,
  ) {
    final userMap =
        _asMap(json['user']) ??
        _asMap(
          mode == FriendRequestMode.sent
              ? json['recipient']
              : json['requester'],
        ) ??
        const <String, dynamic>{};
    return FriendRequestItem(
      id: (json['requestId'] ?? json['id'] ?? json['_id'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      direction: mode,
      user: PublicUserSummary.fromJson(userMap),
      friendshipStatus: FriendshipStatus.fromJson(
        _asMap(json['friendshipStatus']),
      ),
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? '').toString(),
      )?.toLocal(),
    );
  }
}

class CommunityPost {
  final String id;
  final String authorId;
  final String authorName;
  final String authorUserId;
  final String? authorImageUrl;
  final String content;
  final List<CommunityPostMedia> mediaFiles;
  final DateTime createdAt;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool isLiked;
  final bool isOwner;

  const CommunityPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorUserId,
    required this.authorImageUrl,
    required this.content,
    required this.mediaFiles,
    required this.createdAt,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.isLiked,
    required this.isOwner,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['userId']);
    final profileImage = _asMap(user?['profileImage']);
    final authorId =
        _idFrom(user) ??
        (json['userId'] is String ? json['userId'] as String : '');

    return CommunityPost(
      id: _idFrom(json) ?? '',
      authorId: authorId,
      authorName: (user?['fullName'] ?? 'TalkBZ User').toString(),
      authorUserId: (user?['userId'] ?? '').toString(),
      authorImageUrl: _absoluteUrl(profileImage?['url']?.toString()),
      content: (json['content'] ?? '').toString(),
      mediaFiles: (json['mediaFiles'] as List? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                CommunityPostMedia.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((media) => media.url.isNotEmpty && media.uiType.isNotEmpty)
          .toList(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString())?.toLocal() ??
          DateTime.now(),
      likesCount: _nonNegativeInt(json['likesCount']),
      commentsCount: _nonNegativeInt(json['commentsCount']),
      sharesCount: _nonNegativeInt(json['sharesCount'] ?? json['shareCount']),
      isLiked: json['isLiked'] == true,
      isOwner: json['isOwner'] == true,
    );
  }

  CommunityPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorUserId,
    String? authorImageUrl,
    String? content,
    List<CommunityPostMedia>? mediaFiles,
    DateTime? createdAt,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    bool? isLiked,
    bool? isOwner,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorUserId: authorUserId ?? this.authorUserId,
      authorImageUrl: authorImageUrl ?? this.authorImageUrl,
      content: content ?? this.content,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      isLiked: isLiked ?? this.isLiked,
      isOwner: isOwner ?? this.isOwner,
    );
  }

  CommunityPostMedia? get primaryMedia =>
      mediaFiles.isEmpty ? null : mediaFiles.first;

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
    if (difference.inHours < 24) return '${difference.inHours} hours ago';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}

class CommunityPostMedia {
  final String url;
  final String type;
  final String publicId;
  final Duration? duration;

  const CommunityPostMedia({
    required this.url,
    required this.type,
    required this.publicId,
    this.duration,
  });

  factory CommunityPostMedia.fromJson(Map<String, dynamic> json) {
    return CommunityPostMedia(
      url: _absoluteUrl((json['url'] ?? '').toString()) ?? '',
      type: (json['type'] ?? '').toString(),
      publicId: (json['public_id'] ?? json['publicId'] ?? '').toString(),
      duration:
          _durationFromJson(json['duration']) ??
          _durationFromJson(json['durationSeconds']) ??
          _durationFromJson(json['durationMs']) ??
          _durationFromJson(
            json['metadata'] is Map
                ? (json['metadata'] as Map)['duration']
                : null,
          ),
    );
  }

  String get uiType => type == 'audio' ? 'voice' : type;
}

class CommunityComment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorUserId;
  final String? authorImageUrl;
  final String content;
  final DateTime createdAt;
  final bool isOwner;

  const CommunityComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorUserId,
    required this.authorImageUrl,
    required this.content,
    required this.createdAt,
    required this.isOwner,
  });

  factory CommunityComment.fromJson(Map<String, dynamic> json) {
    final user = _asMap(json['userId']);
    final profileImage = _asMap(user?['profileImage']);
    final authorId =
        _idFrom(user) ??
        (json['userId'] is String ? json['userId'] as String : '');

    return CommunityComment(
      id: _idFrom(json) ?? '',
      postId: (json['postId'] ?? '').toString(),
      authorId: authorId,
      authorName: (user?['fullName'] ?? 'TalkBZ User').toString(),
      authorUserId: (user?['userId'] ?? '').toString(),
      authorImageUrl: _absoluteUrl(profileImage?['url']?.toString()),
      content: (json['content'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString())?.toLocal() ??
          DateTime.now(),
      isOwner: json['isOwner'] == true,
    );
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}

FriendshipUiState _friendshipState(String value) {
  switch (value) {
    case 'none':
      return FriendshipUiState.none;
    case 'request_sent':
      return FriendshipUiState.requestSent;
    case 'request_received':
      return FriendshipUiState.requestReceived;
    case 'friends':
      return FriendshipUiState.friends;
    case 'rejected':
      return FriendshipUiState.rejected;
    case 'blocked':
      return FriendshipUiState.blocked;
    case 'self':
      return FriendshipUiState.self;
    default:
      return FriendshipUiState.unknown;
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String? _idFrom(dynamic value) {
  final map = _asMap(value);
  if (map == null) return null;
  return (map['id'] ?? map['_id'])?.toString();
}

int _nonNegativeInt(dynamic value) {
  final parsed = value is num
      ? value.toInt()
      : int.tryParse(value?.toString() ?? '');
  if (parsed == null || parsed < 0) return 0;
  return parsed;
}

String? _nullableString(dynamic value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}

Duration? _durationFromJson(dynamic value) {
  if (value == null) return null;

  if (value is Duration) return value > Duration.zero ? value : null;

  if (value is num) {
    if (value <= 0) return null;
    final milliseconds = value > 1000 ? value.round() : (value * 1000).round();
    return Duration(milliseconds: milliseconds);
  }

  final raw = value.toString().trim();
  if (raw.isEmpty) return null;

  final numeric = num.tryParse(raw);
  if (numeric != null) return _durationFromJson(numeric);

  final parts = raw.split(':').map((part) => int.tryParse(part)).toList();
  if (parts.any((part) => part == null)) return null;

  if (parts.length == 2) {
    final minutes = parts[0]!;
    final seconds = parts[1]!;
    final duration = Duration(minutes: minutes, seconds: seconds);
    return duration > Duration.zero ? duration : null;
  }

  if (parts.length == 3) {
    final hours = parts[0]!;
    final minutes = parts[1]!;
    final seconds = parts[2]!;
    final duration = Duration(hours: hours, minutes: minutes, seconds: seconds);
    return duration > Duration.zero ? duration : null;
  }

  return null;
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
