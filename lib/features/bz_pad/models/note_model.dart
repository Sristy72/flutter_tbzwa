class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime updatedAt;
  final String? type; // e.g., 'vocabulary', 'summary', 'tips'

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.updatedAt,
    this.type,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    id: (json['id'] ?? json['_id'] ?? '').toString(),
    title: (json['title'] ?? 'Untitled').toString(),
    content: (json['content'] ?? json['preview'] ?? '').toString(),
    updatedAt:
        DateTime.tryParse((json['updatedAt'] ?? '').toString())?.toLocal() ??
        DateTime.now(),
    type: json['type']?.toString(),
  );
}

class NoteVersionModel {
  final int versionIndex;
  final String noteId;
  final String content;
  final DateTime createdAt;
  final String label; // e.g., 'Current Version', 'Auto saved', etc.

  NoteVersionModel({
    required this.versionIndex,
    required this.noteId,
    required this.content,
    required this.createdAt,
    required this.label,
  });

  factory NoteVersionModel.fromJson(Map<String, dynamic> json, String noteId) =>
      NoteVersionModel(
        versionIndex: (json['versionIndex'] as num?)?.toInt() ?? 0,
        noteId: noteId,
        content: (json['preview'] ?? '').toString(),
        createdAt:
            DateTime.tryParse((json['savedAt'] ?? '').toString())?.toLocal() ??
            DateTime.now(),
        label: (json['saveTypeLabel'] ?? '').toString(),
      );
}
