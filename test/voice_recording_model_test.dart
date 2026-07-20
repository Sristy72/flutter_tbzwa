import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tbzwa/core/constants/api_constants.dart';
import 'package:flutter_tbzwa/features/home/models/learner_api_models.dart';
import 'package:flutter_tbzwa/features/home/models/voice_recording_model.dart';

void main() {
  test('parses backend voice recording and local audio URL', () {
    final recording = VoiceRecordingModel.fromJson({
      'id': 'recording-1',
      'label': 'My speaking practice',
      'duration': 65,
      'recordedAt': '2026-07-13T08:30:00.000Z',
      'timeSlot': 'afternoon',
      'file': {'url': '/uploads/recordings/voice/test.m4a'},
    });

    expect(recording.id, 'recording-1');
    expect(recording.slotTitle, 'Afternoon Fluency');
    expect(recording.durationLabel, '01:05');
    expect(
      recording.audioUrl,
      '${ApiConstants.baseDomain}/uploads/recordings/voice/test.m4a',
    );
  });

  test('uses local recording hour when older API data has no time slot', () {
    expect(VoiceRecordingModel.slotForHour(8), 'morning');
    expect(VoiceRecordingModel.slotForHour(14), 'afternoon');
    expect(VoiceRecordingModel.slotForHour(20), 'evening');
  });

  test('parses boolean mission targets used by immersion missions', () {
    final mission = MissionProgress.fromJson({
      'completed': false,
      'target': false,
    });

    expect(mission.completed, 0);
    expect(mission.target, 1);
  });

  test('parses weekly consistency values from the progress API', () {
    final weekly = WeeklyProgress.fromJson({
      'weeklyAverage': 35,
      'consistency': [
        {'date': '2026-07-12', 'score': 20, 'hasActivity': true},
        {'date': '2026-07-13', 'score': 50, 'hasActivity': true},
      ],
    });

    expect(weekly.average, 35);
    expect(weekly.scores, [20, 50]);
    expect(weekly.days.last.hasActivity, isTrue);
  });
}
