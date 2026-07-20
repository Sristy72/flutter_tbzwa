import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tbzwa/core/constants/api_constants.dart';
import 'package:flutter_tbzwa/features/library/models/library_models.dart';

void main() {
  test('parses discovery folders and their API category counts', () {
    final folder = LibraryFolder.fromJson({
      'folder': 'discover_2',
      'label': 'Discover II',
      'isUnlocked': true,
      'comingSoon': false,
      'totalItems': 3,
      'categories': [
        {'name': 'Kitchen', 'count': 3},
      ],
    });

    expect(folder.folder, 'discover_2');
    expect(folder.isUnlocked, isTrue);
    expect(folder.totalItems, 3);
    expect(folder.categories.single.name, 'Kitchen');
  });

  test('parses pronunciation audio from the API response', () {
    final item = LibraryItem.fromJson({
      'id': 'word-1',
      'category': 'Kitchen',
      'folder': 'discover_1',
      'type': 'phrasal_verb',
      'word': 'put away',
      'phonetic': '/pʊt əˈweɪ/',
      'audioFile': {'url': '/uploads/put-away.mp3'},
    });

    expect(item.audioUrl, '${ApiConstants.baseDomain}/uploads/put-away.mp3');
    expect(item.phonetic, '/pʊt əˈweɪ/');
    expect(item.tag, 'Phrasal Verb');
  });
}
