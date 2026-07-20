import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tbzwa/features/home/models/learner_api_models.dart';

void main() {
  test('daily voice progress uses backend completed and target values', () {
    final summary = DailyMissionSummary.fromJson({
      'overallProgress': 14,
      'completedCount': 1,
      'totalCount': 7,
      'missions': [
        {
          'key': 'voiceRecordings',
          'label': 'Voice Recordings',
          'completed': 2,
          'target': 3,
          'type': 'count',
        },
      ],
    });

    final voice = summary.missions['voiceRecordings'];
    expect(voice?.completed, 2);
    expect(voice?.target, 3);
  });

  test('daily voice progress repairs a legacy target of one', () {
    final summary = DailyMissionSummary.fromJson({
      'missions': [
        {'key': 'voiceRecordings', 'completed': 0, 'target': 1},
      ],
    });

    final voice = summary.missions['voiceRecordings'];
    expect(voice?.completed, 0);
    expect(voice?.target, 3);
  });

  test('today vocabulary parses words and progress from the backend', () {
    final todayVocabulary = TodayVocabulary.fromJson({
      'words': [
        {
          'id': 'word-1',
          'word': 'Ephemeral',
          'definition': 'Lasting for a very short time.',
          'exampleSentences': ['The morning mist was ephemeral.'],
        },
      ],
      'progress': {'completed': 1, 'target': 2},
    });

    expect(todayVocabulary.words, hasLength(1));
    expect(todayVocabulary.words.first.word, 'Ephemeral');
    expect(todayVocabulary.progress.completed, 1);
    expect(todayVocabulary.progress.target, 2);
  });

  test('today immersion parses log and boolean mission progress', () {
    final todayImmersion = TodayImmersion.fromJson({
      'log': {
        'id': 'log-1',
        'title': 'Prison Break',
        'summary': 'I watched an episode and wrote about the escape plan.',
      },
      'isComplete': true,
      'missionProgress': {'completed': 1, 'target': 3},
    });

    expect(todayImmersion.log?.title, 'Prison Break');
    expect(todayImmersion.isComplete, isTrue);
    expect(todayImmersion.progress.completed, 1);
    expect(todayImmersion.progress.target, 3);
  });
}
