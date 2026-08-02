class InstructorGroupPage {
  final List<InstructorGroup> groups;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const InstructorGroupPage({
    required this.groups,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory InstructorGroupPage.fromJson(
    Map<String, dynamic> json,
    Map<String, dynamic>? meta,
  ) {
    return InstructorGroupPage(
      groups: (json['groups'] as List? ?? const [])
          .map(
            (item) => InstructorGroup.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      page: (meta?['page'] as num?)?.toInt() ?? 1,
      limit: (meta?['limit'] as num?)?.toInt() ?? 10,
      total: (meta?['total'] as num?)?.toInt() ?? 0,
      totalPages: (meta?['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}

class InstructorGroup {
  final String id;
  final String name;
  final String description;
  final String? icon;
  final String? themeColor;
  final bool isActive;
  final int totalStudents;
  final int activeStudentCount;
  final DateTime? latestActivityAt;
  final InstructorGroupPerson? instructor;

  const InstructorGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.themeColor,
    required this.isActive,
    required this.totalStudents,
    required this.activeStudentCount,
    required this.latestActivityAt,
    required this.instructor,
  });

  factory InstructorGroup.fromJson(Map<String, dynamic> json) {
    final instructorJson = json['instructorId'];
    return InstructorGroup(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      icon: json['icon']?.toString(),
      themeColor: json['themeColor']?.toString(),
      isActive: json['isActive'] != false,
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      activeStudentCount:
          (json['activeStudentCount'] as num?)?.toInt() ??
          (json['totalStudents'] as num?)?.toInt() ??
          0,
      latestActivityAt:
          DateTime.tryParse(
            (json['latestActivityAt'] ?? '').toString(),
          )?.toLocal() ??
          DateTime.tryParse((json['updatedAt'] ?? '').toString())?.toLocal(),
      instructor: instructorJson is Map
          ? InstructorGroupPerson.fromJson(
              Map<String, dynamic>.from(instructorJson),
            )
          : null,
    );
  }

  int get displayStudentCount =>
      activeStudentCount > 0 ? activeStudentCount : totalStudents;
}

class InstructorGroupPerson {
  final String id;
  final String fullName;
  final String userId;
  final String? profileImageUrl;

  const InstructorGroupPerson({
    required this.id,
    required this.fullName,
    required this.userId,
    required this.profileImageUrl,
  });

  factory InstructorGroupPerson.fromJson(Map<String, dynamic> json) {
    final image = json['profileImage'];
    return InstructorGroupPerson(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      profileImageUrl: image is Map ? image['url']?.toString() : null,
    );
  }
}

class InstructorGroupMember {
  final String id;
  final String name;
  final String status;
  final String rsvp;

  const InstructorGroupMember({
    required this.id,
    required this.name,
    required this.status,
    required this.rsvp,
  });

  factory InstructorGroupMember.fromJson(Map<String, dynamic> json) {
    final user = json['userId'];
    final userJson = user is Map ? Map<String, dynamic>.from(user) : null;
    return InstructorGroupMember(
      id: (userJson?['id'] ?? userJson?['_id'] ?? user ?? '').toString(),
      name: (userJson?['fullName'] ?? 'Student').toString(),
      status: (json['status'] ?? 'active').toString(),
      rsvp: (json['nextClassRsvp'] ?? 'no_response').toString(),
    );
  }
}

class InstructorGroupMessage {
  final String id;
  final String senderName;
  final String content;
  final DateTime? createdAt;
  final bool isInstructor;

  const InstructorGroupMessage({
    required this.id,
    required this.senderName,
    required this.content,
    required this.createdAt,
    required this.isInstructor,
  });

  factory InstructorGroupMessage.fromJson(Map<String, dynamic> json) {
    final sender = json['senderId'];
    final senderJson = sender is Map ? Map<String, dynamic>.from(sender) : null;
    return InstructorGroupMessage(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      senderName: (senderJson?['fullName'] ?? 'Member').toString(),
      content: (json['content'] ?? '').toString(),
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? '').toString(),
      )?.toLocal(),
      isInstructor: json['isInstructor'] == true,
    );
  }
}

class InstructorGroupRoom {
  final String id;
  final String title;
  final String privacy;
  final String hostName;
  final int participantCount;
  final List<String> participantInitials;
  final bool isLocked;

  const InstructorGroupRoom({
    required this.id,
    required this.title,
    required this.privacy,
    required this.hostName,
    required this.participantCount,
    required this.participantInitials,
    required this.isLocked,
  });

  factory InstructorGroupRoom.fromJson(Map<String, dynamic> json) {
    final host = json['hostId'];
    final hostJson = host is Map ? Map<String, dynamic>.from(host) : null;
    final participants = json['participants'] as List? ?? const [];
    return InstructorGroupRoom(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['name'] ?? '').toString(),
      privacy: (json['privacy'] ?? 'public').toString(),
      hostName: (hostJson?['fullName'] ?? 'Host').toString(),
      participantCount:
          (json['participantCount'] as num?)?.toInt() ?? participants.length,
      participantInitials: participants
          .map((participant) {
            final map = participant is Map
                ? Map<String, dynamic>.from(participant)
                : const <String, dynamic>{};
            final user = map['userId'];
            final userMap = user is Map
                ? Map<String, dynamic>.from(user)
                : const <String, dynamic>{};
            final name = (userMap['fullName'] ?? '').toString().trim();
            return name.isEmpty ? 'M' : name[0].toUpperCase();
          })
          .take(4)
          .toList(),
      isLocked: json['isLocked'] == true,
    );
  }

  bool get isPublic => privacy != 'private';
}

class InstructorGroupClass {
  final String id;
  final String title;
  final DateTime? scheduledAt;
  final int duration;
  final String status;
  final String? zoomLink;
  final int goingCount;
  final int maybeCount;
  final int notGoingCount;

  const InstructorGroupClass({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.duration,
    required this.status,
    required this.zoomLink,
    required this.goingCount,
    required this.maybeCount,
    required this.notGoingCount,
  });

  factory InstructorGroupClass.fromJson(Map<String, dynamic> json) {
    return InstructorGroupClass(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      scheduledAt: DateTime.tryParse(
        (json['scheduledAt'] ?? '').toString(),
      )?.toLocal(),
      duration: (json['duration'] as num?)?.toInt() ?? 60,
      status: (json['status'] ?? '').toString(),
      zoomLink: json['zoomLink']?.toString(),
      goingCount: (json['goingCount'] as num?)?.toInt() ?? 0,
      maybeCount: (json['maybeCount'] as num?)?.toInt() ?? 0,
      notGoingCount: (json['notGoingCount'] as num?)?.toInt() ?? 0,
    );
  }
}
