import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFEAEDF1)),
        ),
        child: Row(
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF263238),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF90A4AE),
                    ),
                  ),
                ],
              ),
            ),

            Column(
              children: [
                Text(
                  _formatTime(note.updatedAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF90A4AE),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [

                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, color: Color(0xFF90A4AE), size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') onDelete();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    Color bgColor;
    IconData iconData;
    Color iconColor;

    switch (note.type) {
      case 'vocabulary':
        bgColor = const Color(0xFFE2E3F7);
        iconData = Icons.description_outlined;
        iconColor = const Color(0xFF5151EF);
        break;
      case 'summary':
        bgColor = const Color(0xFFDFF2F4);
        iconData = Icons.article_outlined;
        iconColor = const Color(0xFF006B5B);
        break;
      case 'tips':
        bgColor = const Color(0xFFF3EBF3);
        iconData = Icons.lightbulb_outline;
        iconColor = const Color(0xFF7F3858);
        break;
      default:
        bgColor = const Color(0xFFF0F2F5);
        iconData = Icons.note_outlined;
        iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inHours < 24) {
      if (difference.inHours == 0) return "${difference.inMinutes}m";
      return "${difference.inHours}h";
    } else if (difference.inDays == 1) {
      return "Yesterday";
    } else if (difference.inDays < 7) {
      return DateFormat('E').format(date); // e.g., "Mon"
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
