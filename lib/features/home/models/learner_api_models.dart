import '../../../core/constants/api_constants.dart';
import 'voice_recording_model.dart';

class LearnerProfile {
  final String id;
  final String fullName;
  final String email;
  final String userId;
  final String? profileImageUrl;
  final String level;
  final String plan;
  final String subscriptionStatus;
  final DateTime? memberSince;
  final int currentStreak;
  final double walletBalance;

  const LearnerProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.userId,
    required this.profileImageUrl,
    required this.level,
    required this.plan,
    required this.subscriptionStatus,
    required this.memberSince,
    required this.currentStreak,
    required this.walletBalance,
  });

  factory LearnerProfile.fromJson(Map<String, dynamic> json) {
    final subscription = json['subscription'] as Map<String, dynamic>? ?? {};
    final profileImage = json['profileImage'] as Map<String, dynamic>?;
    final wallet = json['walletId'] is Map
        ? Map<String, dynamic>.from(json['walletId'] as Map)
        : const <String, dynamic>{};
    return LearnerProfile(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      profileImageUrl: _absoluteUrl(profileImage?['url']?.toString()),
      level: (json['level'] ?? 'none').toString(),
      plan: (subscription['plan'] ?? 'none').toString(),
      subscriptionStatus: (subscription['status'] ?? 'pending').toString(),
      memberSince: DateTime.tryParse(
        (json['memberSince'] ?? json['createdAt'] ?? '').toString(),
      )?.toLocal(),
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      walletBalance: (wallet['balance'] as num?)?.toDouble() ?? 0,
    );
  }
}

class LearnerProgressSnapshot {
  final int completedLessons;
  final int totalProgress;
  final int totalAccessibleLessons;
  final int totalXP;
  final int passedQuizzes;

  const LearnerProgressSnapshot({
    required this.completedLessons,
    required this.totalProgress,
    required this.totalAccessibleLessons,
    required this.totalXP,
    required this.passedQuizzes,
  });

  factory LearnerProgressSnapshot.fromJson(Map<String, dynamic> json) {
    final progress = json['progress'] as Map<String, dynamic>? ?? {};
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    return LearnerProgressSnapshot(
      completedLessons: (stats['completedLessons'] as num?)?.toInt() ?? 0,
      totalProgress: (progress['totalProgress'] as num?)?.toInt() ?? 0,
      totalAccessibleLessons:
          (progress['totalAccessibleLessons'] as num?)?.toInt() ?? 0,
      totalXP: (stats['totalXP'] as num?)?.toInt() ?? 0,
      passedQuizzes: (stats['passedQuizzes'] as num?)?.toInt() ?? 0,
    );
  }
}

class DailyMissionSummary {
  final int overallProgress;
  final int completedCount;
  final int totalCount;
  final Map<String, MissionProgress> missions;

  const DailyMissionSummary({
    required this.overallProgress,
    required this.completedCount,
    required this.totalCount,
    required this.missions,
  });

  factory DailyMissionSummary.fromJson(Map<String, dynamic> json) {
    final values = <String, MissionProgress>{};
    for (final item in (json['missions'] as List? ?? const [])) {
      final map = Map<String, dynamic>.from(item as Map);
      final key = map['key'].toString();
      values[key] = MissionProgress.fromJson(
        map,
        minimumTarget: key == 'voiceRecordings' || key == 'immersion'
            ? 3
            : null,
      );
    }
    return DailyMissionSummary(
      overallProgress:
          (json['dailyScore'] as num?)?.toInt() ??
          (json['overallProgress'] as num?)?.toInt() ??
          0,
      completedCount: (json['completedCount'] as num?)?.toInt() ?? 0,
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      missions: values,
    );
  }
}

class MissionProgress {
  final int completed;
  final int target;

  const MissionProgress({required this.completed, required this.target});

  factory MissionProgress.fromJson(
    Map<String, dynamic> json, {
    int? minimumTarget,
  }) {
    final doc = json['_doc'] is Map
        ? Map<String, dynamic>.from(json['_doc'] as Map)
        : const <String, dynamic>{};
    final completedValue = json['completed'] ?? doc['completed'];
    final targetValue = json['target'] ?? doc['target'];
    final parsedTarget = targetValue is bool
        ? 1
        : (targetValue as num?)?.toInt() ?? 1;
    return MissionProgress(
      completed: completedValue is bool
          ? (completedValue == true ? 1 : 0)
          : (completedValue as num?)?.toInt() ?? 0,
      target: minimumTarget != null && parsedTarget < minimumTarget
          ? minimumTarget
          : parsedTarget,
    );
  }
}

class WeeklyProgress {
  final int average;
  final List<int> scores;
  final List<WeeklyDayProgress> days;

  const WeeklyProgress({
    required this.average,
    required this.scores,
    required this.days,
  });

  factory WeeklyProgress.fromJson(Map<String, dynamic> json) {
    final days = (json['consistency'] as List? ?? const [])
        .map(
          (item) => WeeklyDayProgress.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
    return WeeklyProgress(
      average: (json['weeklyAverage'] as num?)?.toInt() ?? 0,
      scores: days.map((day) => day.score).toList(),
      days: days,
    );
  }

  List<WeeklyDayProgress> currentWeekDays({DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final daysByDate = {for (final day in days) _dateKey(day.date): day};

    return List.generate(7, (index) {
      final date = weekStart.add(Duration(days: index));
      return daysByDate[_dateKey(date)] ??
          WeeklyDayProgress(date: date, score: 0, hasActivity: false);
    });
  }
}

class WeeklyDayProgress {
  final DateTime date;
  final int score;
  final bool hasActivity;

  const WeeklyDayProgress({
    required this.date,
    required this.score,
    required this.hasActivity,
  });

  factory WeeklyDayProgress.fromJson(Map<String, dynamic> json) {
    final rawDate = (json['date'] ?? '').toString();
    return WeeklyDayProgress(
      date: _parseLocalDate(rawDate) ?? DateTime.now(),
      score: ((json['score'] as num?)?.toInt() ?? 0).clamp(0, 100),
      hasActivity: json['hasActivity'] == true,
    );
  }

  String get dayLabel {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return labels[date.weekday - 1];
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

DateTime? _parseLocalDate(String value) {
  final dateOnlyMatch = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
  if (dateOnlyMatch != null) {
    return DateTime(
      int.parse(dateOnlyMatch.group(1)!),
      int.parse(dateOnlyMatch.group(2)!),
      int.parse(dateOnlyMatch.group(3)!),
    );
  }

  return DateTime.tryParse(value)?.toLocal();
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String _dateKey(DateTime date) {
  final localDate = _dateOnly(date);
  return '${localDate.year}-${localDate.month}-${localDate.day}';
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

class VocabularyWord {
  final String id;
  final String word;
  final String definition;
  final List<String> exampleSentences;
  final DateTime? missionDate;
  final DateTime? createdAt;

  const VocabularyWord({
    required this.id,
    required this.word,
    required this.definition,
    required this.exampleSentences,
    required this.missionDate,
    required this.createdAt,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      word: (json['word'] ?? '').toString(),
      definition: (json['definition'] ?? '').toString(),
      exampleSentences: (json['exampleSentences'] as List? ?? const [])
          .map((item) => item.toString())
          .toList(),
      missionDate: DateTime.tryParse(
        (json['missionDate'] ?? '').toString(),
      )?.toLocal(),
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? '').toString(),
      )?.toLocal(),
    );
  }
}

class TodayVocabulary {
  final List<VocabularyWord> words;
  final MissionProgress progress;

  const TodayVocabulary({required this.words, required this.progress});

  factory TodayVocabulary.fromJson(Map<String, dynamic> json) {
    return TodayVocabulary(
      words: (json['words'] as List? ?? const [])
          .map(
            (item) =>
                VocabularyWord.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
      progress: MissionProgress.fromJson(
        Map<String, dynamic>.from(json['progress'] as Map? ?? const {}),
        minimumTarget: 2,
      ),
    );
  }
}

class ImmersionLogEntry {
  final String id;
  final String title;
  final String summary;
  final DateTime? missionDate;
  final DateTime? createdAt;

  const ImmersionLogEntry({
    required this.id,
    required this.title,
    required this.summary,
    required this.missionDate,
    required this.createdAt,
  });

  factory ImmersionLogEntry.fromJson(Map<String, dynamic> json) {
    return ImmersionLogEntry(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      missionDate: DateTime.tryParse(
        (json['missionDate'] ?? '').toString(),
      )?.toLocal(),
      createdAt: DateTime.tryParse(
        (json['createdAt'] ?? '').toString(),
      )?.toLocal(),
    );
  }
}

class TodayImmersion {
  final ImmersionLogEntry? log;
  final List<ImmersionLogEntry> logs;
  final MissionProgress progress;
  final bool isComplete;

  const TodayImmersion({
    required this.log,
    required this.logs,
    required this.progress,
    required this.isComplete,
  });

  factory TodayImmersion.fromJson(Map<String, dynamic> json) {
    final rawLog = json['log'];
    final logs = (json['logs'] as List? ?? const [])
        .map(
          (item) => ImmersionLogEntry.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
    return TodayImmersion(
      log: rawLog is Map
          ? ImmersionLogEntry.fromJson(Map<String, dynamic>.from(rawLog))
          : null,
      logs: logs,
      progress: MissionProgress.fromJson(
        Map<String, dynamic>.from(json['missionProgress'] as Map? ?? const {}),
        minimumTarget: 3,
      ),
      isComplete: json['isComplete'] == true,
    );
  }
}

class TodaySummaryTask {
  final String title;
  final String lessonTitle;
  final String summaryText;
  final String courseLabel;
  final String instructorName;
  final DateTime? scheduledAt;
  final MissionProgress progress;

  const TodaySummaryTask({
    required this.title,
    required this.lessonTitle,
    required this.summaryText,
    required this.courseLabel,
    required this.instructorName,
    required this.scheduledAt,
    required this.progress,
  });

  factory TodaySummaryTask.fromJson(Map<String, dynamic> json) {
    final task = json['task'] as Map<String, dynamic>? ?? {};
    final summaryTask = task['summaryTask'] as Map<String, dynamic>? ?? {};
    final lesson = task['lesson'] as Map<String, dynamic>? ?? {};
    final instructor = lesson['instructorId'] as Map<String, dynamic>? ?? {};
    final lessonGroup = lesson['groupId'] as Map<String, dynamic>? ?? {};

    return TodaySummaryTask(
      title: (summaryTask['title'] ?? 'This is the summary of the last lesson')
          .toString(),
      lessonTitle:
          (summaryTask['lessonTitle'] ?? lesson['title'] ?? 'Daily Summary')
              .toString(),
      summaryText: (summaryTask['summaryText'] ?? task['savedText'] ?? '')
          .toString(),
      courseLabel: (summaryTask['courseLabel'] ?? lessonGroup['name'] ?? '')
          .toString(),
      instructorName:
          (summaryTask['instructorName'] ?? instructor['fullName'] ?? '')
              .toString(),
      scheduledAt: DateTime.tryParse(
        (summaryTask['scheduledAt'] ?? lesson['scheduledAt'] ?? '').toString(),
      )?.toLocal(),
      progress: MissionProgress.fromJson(
        Map<String, dynamic>.from(json['missionProgress'] as Map? ?? const {}),
        minimumTarget: 2,
      ),
    );
  }
}

class SummaryHistoryEntry {
  final DateTime? date;
  final int recordingsCount;
  final String status;
  final List<VoiceRecordingModel> recordings;

  const SummaryHistoryEntry({
    required this.date,
    required this.recordingsCount,
    required this.status,
    required this.recordings,
  });

  factory SummaryHistoryEntry.fromJson(Map<String, dynamic> json) {
    return SummaryHistoryEntry(
      date: DateTime.tryParse((json['date'] ?? '').toString())?.toLocal(),
      recordingsCount: (json['recordingsCount'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? '').toString(),
      recordings: (json['recordings'] as List? ?? const [])
          .map(
            (item) => VoiceRecordingModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }

  String get title {
    final value = date;
    if (value == null) return 'Summary';
    final today = DateTime.now();
    final yesterday = DateTime(today.year, today.month, today.day - 1);
    if (value.year == today.year &&
        value.month == today.month &&
        value.day == today.day) {
      return 'Today';
    }
    if (value.year == yesterday.year &&
        value.month == yesterday.month &&
        value.day == yesterday.day) {
      return 'Yesterday';
    }
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[value.weekday - 1];
  }

  String get completionLabel => '$recordingsCount/2 $status';
}

class LiveClassInfo {
  final String id;
  final String title;
  final DateTime scheduledAt;
  final int duration;
  final String status;
  final String description;
  final List<String> objectives;
  final String myRsvp;
  final String instructorName;
  final String? instructorImageUrl;
  final String groupName;

  const LiveClassInfo({
    required this.id,
    required this.title,
    required this.scheduledAt,
    required this.duration,
    required this.status,
    required this.description,
    required this.objectives,
    required this.myRsvp,
    required this.instructorName,
    required this.instructorImageUrl,
    required this.groupName,
  });

  factory LiveClassInfo.fromJson(Map<String, dynamic> json) {
    final instructor = json['instructorId'] as Map<String, dynamic>? ?? {};
    final image = instructor['profileImage'] as Map<String, dynamic>?;
    final group = json['groupId'] as Map<String, dynamic>? ?? {};
    return LiveClassInfo(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      scheduledAt:
          DateTime.tryParse(
            (json['scheduledAt'] ?? '').toString(),
          )?.toLocal() ??
          DateTime.now(),
      duration: (json['duration'] as num?)?.toInt() ?? 60,
      status: (json['status'] ?? 'scheduled').toString(),
      description: (json['description'] ?? '').toString(),
      objectives: (json['objectives'] as List? ?? const [])
          .map((e) => e.toString())
          .toList(),
      myRsvp: (json['myRsvp'] ?? 'no_response').toString(),
      instructorName: (instructor['fullName'] ?? '').toString(),
      instructorImageUrl: image?['url']?.toString(),
      groupName: (group['name'] ?? '').toString(),
    );
  }
}

class LearnerLiveClasses {
  final List<LiveClassInfo> today;
  final List<LiveClassInfo> upcoming;
  final List<LiveClassInfo> past;

  const LearnerLiveClasses({
    required this.today,
    required this.upcoming,
    required this.past,
  });

  factory LearnerLiveClasses.fromJson(Map<String, dynamic> json) {
    List<LiveClassInfo> parse(String key) => (json[key] as List? ?? const [])
        .map(
          (item) =>
              LiveClassInfo.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
    return LearnerLiveClasses(
      today: parse('today'),
      upcoming: parse('upcoming'),
      past: parse('past'),
    );
  }
}
