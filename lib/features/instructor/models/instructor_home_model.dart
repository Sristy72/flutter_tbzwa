class InstructorHomeModel {
  final InstructorProfileSummary instructor;
  final InstructorWalletSummary wallet;
  final InstructorHomeStats stats;
  final List<InstructorHomeClass> todayClasses;
  final List<InstructorHomeGroup> assignedGroups;
  final List<InstructorHomeClass> upcomingSessions;

  const InstructorHomeModel({
    required this.instructor,
    required this.wallet,
    required this.stats,
    required this.todayClasses,
    required this.assignedGroups,
    required this.upcomingSessions,
  });

  factory InstructorHomeModel.fromJson(Map<String, dynamic> json) {
    return InstructorHomeModel(
      instructor: InstructorProfileSummary.fromJson(
        Map<String, dynamic>.from(json['instructor'] as Map? ?? const {}),
      ),
      wallet: InstructorWalletSummary.fromJson(
        Map<String, dynamic>.from(json['wallet'] as Map? ?? const {}),
      ),
      stats: InstructorHomeStats.fromJson(
        Map<String, dynamic>.from(json['stats'] as Map? ?? const {}),
      ),
      todayClasses: (json['todayClasses'] as List? ?? const [])
          .map(
            (item) => InstructorHomeClass.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      assignedGroups: (json['assignedGroups'] as List? ?? const [])
          .map(
            (item) => InstructorHomeGroup.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      upcomingSessions: (json['upcomingSessions'] as List? ?? const [])
          .map(
            (item) => InstructorHomeClass.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

class InstructorProfileSummary {
  final String id;
  final String fullName;
  final String userId;
  final String? profileImageUrl;

  const InstructorProfileSummary({
    required this.id,
    required this.fullName,
    required this.userId,
    required this.profileImageUrl,
  });

  factory InstructorProfileSummary.fromJson(Map<String, dynamic> json) {
    final profileImage = json['profileImage'] as Map<String, dynamic>?;
    return InstructorProfileSummary(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      profileImageUrl: profileImage?['url']?.toString(),
    );
  }
}

class InstructorWalletSummary {
  final double balance;
  final String currency;

  const InstructorWalletSummary({
    required this.balance,
    required this.currency,
  });

  factory InstructorWalletSummary.fromJson(Map<String, dynamic> json) {
    return InstructorWalletSummary(
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      currency: (json['currency'] ?? 'USD').toString(),
    );
  }
}

class InstructorHomeStats {
  final int totalStudents;
  final int activeGroups;
  final int todayClasses;
  final int pendingMessages;
  final int unreadNotifications;

  const InstructorHomeStats({
    required this.totalStudents,
    required this.activeGroups,
    required this.todayClasses,
    required this.pendingMessages,
    required this.unreadNotifications,
  });

  factory InstructorHomeStats.fromJson(Map<String, dynamic> json) {
    return InstructorHomeStats(
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
      activeGroups: (json['activeGroups'] as num?)?.toInt() ?? 0,
      todayClasses: (json['todayClasses'] as num?)?.toInt() ?? 0,
      pendingMessages: (json['pendingMessages'] as num?)?.toInt() ?? 0,
      unreadNotifications: (json['unreadNotifications'] as num?)?.toInt() ?? 0,
    );
  }
}

class InstructorHomeClass {
  final String id;
  final String title;
  final String groupId;
  final String groupName;
  final int studentCount;
  final DateTime? scheduledAt;
  final int duration;
  final String status;
  final String? zoomLink;

  const InstructorHomeClass({
    required this.id,
    required this.title,
    required this.groupId,
    required this.groupName,
    required this.studentCount,
    required this.scheduledAt,
    required this.duration,
    required this.status,
    required this.zoomLink,
  });

  factory InstructorHomeClass.fromJson(Map<String, dynamic> json) {
    return InstructorHomeClass(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      groupId: (json['groupId'] ?? '').toString(),
      groupName: (json['groupName'] ?? '').toString(),
      studentCount: (json['studentCount'] as num?)?.toInt() ?? 0,
      scheduledAt: DateTime.tryParse(
        (json['scheduledAt'] ?? '').toString(),
      )?.toLocal(),
      duration: (json['duration'] as num?)?.toInt() ?? 60,
      status: (json['status'] ?? '').toString(),
      zoomLink: json['zoomLink']?.toString(),
    );
  }
}

class InstructorHomeGroup {
  final String id;
  final String name;
  final String? icon;
  final String? themeColor;
  final bool isActive;
  final int totalStudents;

  const InstructorHomeGroup({
    required this.id,
    required this.name,
    required this.icon,
    required this.themeColor,
    required this.isActive,
    required this.totalStudents,
  });

  factory InstructorHomeGroup.fromJson(Map<String, dynamic> json) {
    return InstructorHomeGroup(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      icon: json['icon']?.toString(),
      themeColor: json['themeColor']?.toString(),
      isActive: json['isActive'] != false,
      totalStudents: (json['totalStudents'] as num?)?.toInt() ?? 0,
    );
  }
}
