import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tbzwa/features/voice_room/models/voice_room_model.dart';

void main() {
  test('parses learner voice-room page with host and participant metadata', () {
    final page = LearnerVoiceRoomPage.fromJson(
      {
        'isImmersionPlus': true,
        'rooms': [
          {
            'id': 'room-1',
            'name': 'Conversation Practice',
            'privacy': 'public',
            'isActive': true,
            'participantCount': 1,
            'maxParticipants': 20,
            'host': {
              'id': 'host-1',
              'fullName': 'Bob Nguyen',
              'userId': 'BZ#123',
              'country': 'US',
              'profileImageUrl': '/uploads/bob.png',
            },
            'participants': [
              {
                'userId': {
                  'id': 'learner-1',
                  'fullName': 'Alice Martin',
                  'country': 'FR',
                  'profileImage': {'url': '/uploads/alice.png'},
                },
                'isOnStage': false,
              },
            ],
          },
        ],
      },
      {'page': 1, 'limit': 10, 'total': 1, 'totalPages': 1},
    );

    expect(page.rooms, hasLength(1));
    expect(page.rooms.first.id, 'room-1');
    expect(page.rooms.first.hostName, 'Bob Nguyen');
    expect(page.rooms.first.hostCountryBadge, isNotEmpty);
    expect(page.rooms.first.countLabel, '1/20');
    expect(page.rooms.first.participants.first.name, 'Alice Martin');
  });

  test('parses voice-room creation eligibility payload', () {
    final eligibility = VoiceRoomCreateEligibility.fromJson({
      'eligibility': {
        'allowed': false,
        'reason': 'Your subscription has expired.',
        'upgradeRequired': true,
        'requiredPlan': 'immersion_plus_plus',
        'plan': 'immersion_plus_plus',
        'subscriptionStatus': 'active',
        'endDate': '2026-01-01T00:00:00.000Z',
        'isLifetime': false,
      },
    });

    expect(eligibility.allowed, isFalse);
    expect(eligibility.displayReason, 'Your subscription has expired.');
    expect(eligibility.requiredPlan, 'immersion_plus_plus');
    expect(eligibility.endDate, isNotNull);
  });

  test('parses voice-room messages with sender labels and attachments', () {
    final page = VoiceRoomMessagePage.fromJson(
      {
        'messages': [
          {
            'id': 'message-1',
            'roomId': 'room-1',
            'clientMessageId': 'client-1',
            'content': 'Good morning!',
            'type': 'text',
            'roleLabel': 'Host',
            'isHost': true,
            'createdAt': '2026-07-20T09:00:00.000Z',
            'sender': {
              'id': 'host-1',
              'fullName': 'Kathy Onana',
              'role': 'instructor',
              'country': 'US',
              'profileImageUrl': '/uploads/kathy.png',
            },
          },
          {
            'id': 'message-2',
            'roomId': 'room-1',
            'content': '',
            'type': 'document',
            'createdAt': '2026-07-20T09:01:00.000Z',
            'sender': {'id': 'learner-1', 'fullName': 'Alice Martin'},
            'mediaFile': {
              'url': '/uploads/rooms/notes.pdf',
              'type': 'document',
              'filename': 'notes.pdf',
              'mimeType': 'application/pdf',
              'size': 1234,
            },
          },
        ],
      },
      {'page': 1, 'limit': 30, 'total': 2, 'totalPages': 1},
      'learner-1',
    );

    expect(page.messages, hasLength(2));
    expect(page.messages.first.roleLabel, 'Host');
    expect(page.messages.first.isMine, isFalse);
    expect(page.messages.last.isMine, isTrue);
    expect(page.messages.last.attachment?.type, 'document');
    expect(page.messages.last.attachment?.displayName, 'notes.pdf');
    expect(page.messages.last.preview, 'Document');
  });
}
