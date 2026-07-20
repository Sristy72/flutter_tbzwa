import '../../../core/constants/api_constants.dart';

class VoiceRecordingModel {
  final String id;
  final String label;
  final String audioUrl;
  final int duration;
  final DateTime recordedAt;
  final String timeSlot;

  const VoiceRecordingModel({
    required this.id,
    required this.label,
    required this.audioUrl,
    required this.duration,
    required this.recordedAt,
    required this.timeSlot,
  });

  factory VoiceRecordingModel.fromJson(Map<String, dynamic> json) {
    final file = json['file'] as Map?;
    var audioUrl = (file?['url'] ?? '').toString();
    if (audioUrl.startsWith('/')) {
      audioUrl = '${ApiConstants.baseDomain}$audioUrl';
    }

    final recordedAt =
        DateTime.tryParse(
          (json['recordedAt'] ?? json['createdAt'] ?? '').toString(),
        )?.toLocal() ??
        DateTime.now();
    final apiSlot = (json['timeSlot'] ?? '').toString();

    return VoiceRecordingModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      audioUrl: audioUrl,
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      recordedAt: recordedAt,
      timeSlot: apiSlot.isEmpty ? slotForHour(recordedAt.hour) : apiSlot,
    );
  }

  static String slotForHour(int hour) {
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  String get fileUrl => audioUrl;

  String get slotTitle {
    switch (timeSlot) {
      case 'morning':
        return 'Morning Drill';
      case 'afternoon':
        return 'Afternoon Fluency';
      default:
        return 'Evening Reflection';
    }
  }

  String get durationLabel {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
