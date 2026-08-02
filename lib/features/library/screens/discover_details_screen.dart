import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DiscoverDetailsScreen extends StatelessWidget {
  final String title;
  final Color color;
  final bool isLocked;

  const DiscoverDetailsScreen({
    super.key,
    required this.title,
    required this.color,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildFoldersHeader(),
            const SizedBox(height: 40),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.lock_outline, color: color, size: 32),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Coming Soon",
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFoldersHeader() {
    final folders = [
      {'title': 'Discover I', 'color': const Color(0xFFDCDCFC)},
      {'title': 'Discover II', 'color': const Color(0xFFDCFCE7)},
      {'title': 'Discover III', 'color': const Color(0xFFFCE7F3)},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: folders.map((folder) {
        bool isActive = folder['title'] == title;
        return Container(
          width: (Get.width - 80) / 3,
          height: 80,
          decoration: BoxDecoration(
            color: folder['color'] as Color,
            borderRadius: BorderRadius.circular(16),
            border: isActive ? Border.all(color: (folder['color'] as Color).withOpacity(0.8), width: 2) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.description_outlined, color: (folder['color'] as Color).withOpacity(0.8), size: 20),
              const SizedBox(height: 4),
              Text(
                folder['title'] as String,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
