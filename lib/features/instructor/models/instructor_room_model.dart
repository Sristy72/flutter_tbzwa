class InstructorRoomPage {
  final List<InstructorRoom> rooms;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const InstructorRoomPage({
    required this.rooms,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory InstructorRoomPage.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic>? meta,
  ) {
    return InstructorRoomPage(
      rooms: (json['rooms'] as List? ?? const [])
          .whereType<Object?>()
          .map((item) {
            try {
              return InstructorRoom.fromJson(
                Map<String, dynamic>.from(item as Map),
              );
            } catch (_) {
              return null;
            }
          })
          .whereType<InstructorRoom>()
          .toList(),
      page: (meta?['page'] as num?)?.toInt() ?? 1,
      limit: (meta?['limit'] as num?)?.toInt() ?? 20,
      total: (meta?['total'] as num?)?.toInt() ?? 0,
      totalPages: (meta?['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class InstructorRoom {
  final String id;
  final String name;
  final String privacy;
  final String status;
  final bool isActive;
  final int participantCount;
  final int maxParticipants;
  final String hostName;
  final String? hostId;
  final String groupName;
  final String? groupId;
  final String shareLink;
  final List<InstructorRoomParticipant> participants;
  final DateTime? createdAt;

  const InstructorRoom({
    required this.id,
    required this.name,
    required this.privacy,
    required this.status,
    required this.isActive,
    required this.participantCount,
    required this.maxParticipants,
    required this.hostName,
    required this.hostId,
    required this.groupName,
    required this.groupId,
    required this.shareLink,
    required this.participants,
    required this.createdAt,
  });

  factory InstructorRoom.fromJson(Map<String, dynamic> json) {
    final host = json['host'] ?? json['hostId'];
    final hostJson = host is Map ? Map<String, dynamic>.from(host) : null;
    final group = json['group'] ?? json['groupId'];
    final groupJson = group is Map ? Map<String, dynamic>.from(group) : null;
    final participants = (json['participants'] as List? ?? const [])
        .whereType<Object?>()
        .map((item) {
          try {
            return InstructorRoomParticipant.fromJson(
              Map<String, dynamic>.from(item as Map),
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<InstructorRoomParticipant>()
        .toList();
    final isActive = json['isActive'] != false;

    return InstructorRoom(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      privacy: (json['privacy'] ?? 'public').toString(),
      status: (json['status'] ?? (isActive ? 'active' : 'ended')).toString(),
      isActive: isActive,
      participantCount:
          (json['participantCount'] as num?)?.toInt() ?? participants.length,
      maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 20,
      hostName: (hostJson?['fullName'] ?? 'Host').toString(),
      hostId: (hostJson?['id'] ?? hostJson?['_id'] ?? host)?.toString(),
      groupName: (groupJson?['name'] ?? '').toString(),
      groupId: (groupJson?['id'] ?? groupJson?['_id'] ?? group)?.toString(),
      shareLink: (json['shareLink'] ?? '').toString(),
      participants: participants,
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? '').toString(),
      )?.toLocal(),
    );
  }

  bool get isPublic => privacy != 'private';

  InstructorRoom copyWith({
    bool? isActive,
    String? status,
    int? participantCount,
    List<InstructorRoomParticipant>? participants,
  }) {
    return InstructorRoom(
      id: id,
      name: name,
      privacy: privacy,
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      participantCount: participantCount ?? this.participantCount,
      maxParticipants: maxParticipants,
      hostName: hostName,
      hostId: hostId,
      groupName: groupName,
      groupId: groupId,
      shareLink: shareLink,
      participants: participants ?? this.participants,
      createdAt: createdAt,
    );
  }
}

class InstructorRoomParticipant {
  final String userId;
  final String name;
  final String? avatarUrl;
  final bool isOnStage;

  const InstructorRoomParticipant({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    required this.isOnStage,
  });

  factory InstructorRoomParticipant.fromJson(Map<String, dynamic> json) {
    final user = json['userId'];
    final userJson = user is Map ? Map<String, dynamic>.from(user) : null;
    final image = userJson?['profileImage'];
    return InstructorRoomParticipant(
      userId: (userJson?['id'] ?? userJson?['_id'] ?? user ?? '').toString(),
      name: (userJson?['fullName'] ?? 'Participant').toString(),
      avatarUrl: image is Map ? image['url']?.toString() : null,
      isOnStage: json['isOnStage'] == true,
    );
  }
}

class InstructorRoomGroup {
  final String id;
  final String name;

  const InstructorRoomGroup({required this.id, required this.name});

  factory InstructorRoomGroup.fromJson(Map<String, dynamic> json) {
    return InstructorRoomGroup(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
    );
  }
}
