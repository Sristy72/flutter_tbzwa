import '../../../core/constants/api_constants.dart';

class LibraryCategory {
  final String name;
  final int count;

  const LibraryCategory({required this.name, required this.count});

  factory LibraryCategory.fromJson(Map<String, dynamic> json) {
    return LibraryCategory(
      name: (json['name'] ?? '').toString(),
      count: (json['count'] as num?)?.toInt() ?? 0,
    );
  }
}

class LibraryFolder {
  final String folder;
  final String label;
  final bool isUnlocked;
  final bool comingSoon;
  final List<LibraryCategory> categories;
  final int totalItems;

  const LibraryFolder({
    required this.folder,
    required this.label,
    required this.isUnlocked,
    required this.comingSoon,
    required this.categories,
    required this.totalItems,
  });

  factory LibraryFolder.fromJson(Map<String, dynamic> json) {
    return LibraryFolder(
      folder: (json['folder'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      isUnlocked: json['isUnlocked'] == true,
      comingSoon: json['comingSoon'] == true,
      categories: (json['categories'] as List? ?? const [])
          .map(
            (item) => LibraryCategory.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
    );
  }
}

class LibraryItem {
  final String id;
  final String category;
  final String folder;
  final String type;
  final String word;
  final String phonetic;
  final String translation;
  final String definition;
  final String example;
  final String exampleTranslation;
  final String audioUrl;

  const LibraryItem({
    required this.id,
    required this.category,
    required this.folder,
    required this.type,
    required this.word,
    required this.phonetic,
    required this.translation,
    required this.definition,
    required this.example,
    required this.exampleTranslation,
    required this.audioUrl,
  });

  factory LibraryItem.fromJson(Map<String, dynamic> json) {
    final audioFile = json['audioFile'];
    var audioUrl = audioFile is Map
        ? (audioFile['url'] ?? '').toString()
        : (audioFile ?? '').toString();
    if (audioUrl.startsWith('/')) {
      audioUrl = '${ApiConstants.baseDomain}$audioUrl';
    }

    return LibraryItem(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      folder: (json['folder'] ?? '').toString(),
      type: (json['type'] ?? 'vocabulary').toString(),
      word: (json['word'] ?? '').toString(),
      phonetic: (json['phonetic'] ?? '').toString(),
      translation: (json['translation'] ?? '').toString(),
      definition: (json['definition'] ?? '').toString(),
      example: (json['example'] ?? '').toString(),
      exampleTranslation: (json['exampleTranslation'] ?? '').toString(),
      audioUrl: audioUrl,
    );
  }

  String get tag => type
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}
