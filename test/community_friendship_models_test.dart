import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tbzwa/features/community/models/community_post_model.dart';

void main() {
  test('public profile parses friendship state and paginated posts', () {
    final result = PublicProfileResult.fromJson(
      {
        'user': {
          'id': 'user-1',
          'displayName': 'Amina Carter',
          'username': 'BZ#AMINA',
          'bio': 'Practicing English daily.',
          'avatarUrl': '/uploads/amina.png',
          'publicPostCount': 1,
        },
        'friendshipStatus': {
          'state': 'request_received',
          'rawStatus': 'pending',
          'requestId': 'request-1',
          'canAccept': true,
          'canDecline': true,
        },
        'posts': [
          {
            'id': 'post-1',
            'userId': {
              'id': 'user-1',
              'fullName': 'Amina Carter',
              'userId': 'BZ#AMINA',
            },
            'content': 'Hello from community.',
            'likesCount': 2,
            'commentsCount': 1,
            'createdAt': '2026-07-18T09:00:00.000Z',
          },
        ],
      },
      {'page': 1, 'totalPages': 2, 'total': 3},
    );

    expect(result.user.id, 'user-1');
    expect(result.user.displayName, 'Amina Carter');
    expect(result.friendshipStatus.state, FriendshipUiState.requestReceived);
    expect(result.friendshipStatus.canAccept, isTrue);
    expect(result.posts.single.id, 'post-1');
    expect(result.page, 1);
    expect(result.totalPages, 2);
    expect(result.total, 3);
  });

  test('friend request page parses received and sent counterparts', () {
    final received = FriendRequestPage.fromJson(
      {
        'mode': 'received',
        'requests': [
          {
            'requestId': 'request-in',
            'status': 'pending',
            'requester': {
              'id': 'sender-1',
              'displayName': 'Leo Martinez',
              'username': 'BZ#LEO',
            },
          },
        ],
      },
      {'page': 1, 'totalPages': 1, 'total': 1},
      FriendRequestMode.received,
    );

    final sent = FriendRequestPage.fromJson(
      {
        'mode': 'sent',
        'requests': [
          {
            'requestId': 'request-out',
            'status': 'pending',
            'recipient': {
              'id': 'recipient-1',
              'displayName': 'Maya Singh',
              'username': 'BZ#MAYA',
            },
          },
        ],
      },
      {'page': 1, 'totalPages': 1, 'total': 1},
      FriendRequestMode.sent,
    );

    expect(received.requests.single.id, 'request-in');
    expect(received.requests.single.user.id, 'sender-1');
    expect(sent.requests.single.id, 'request-out');
    expect(sent.requests.single.user.id, 'recipient-1');
  });
}
