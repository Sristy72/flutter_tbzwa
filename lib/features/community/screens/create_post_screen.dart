import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tbzwa/features/community/controllers/create_post_controller.dart';
import 'package:get/get.dart';

import '../models/community_post_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key, this.editingPost});

  final CommunityPost? editingPost;

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  late final String _tag;
  late final CreatePostController controller;

  @override
  void initState() {
    super.initState();
    _tag =
        widget.editingPost?.id ??
        'create-post-${DateTime.now().microsecondsSinceEpoch}';
    controller = Get.put(
      CreatePostController(editingPost: widget.editingPost),
      tag: _tag,
    );
  }

  @override
  void dispose() {
    Get.delete<CreatePostController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          controller.isEditing ? 'Edit Post' : 'Create Post',
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0, top: 10, bottom: 10),
            child: SizedBox(
              width: 75,
              child: ElevatedButton(
                onPressed: () => controller.submitPost(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22A892),
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Obx(
                  () => Text(
                    controller.isPosting.value
                        ? '...'
                        : controller.isEditing
                        ? 'Save'
                        : 'Post',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            TextField(
              controller: controller.textController,
              maxLines: null,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 30),
            Obx(() {
              return Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: controller.selectedImage.value != null
                    ? _buildMediaPreview(
                        controller.selectedImage.value!,
                        isImage: true,
                      )
                    : controller.selectedVideo.value != null
                    ? _buildMediaPreview(
                        controller.selectedVideo.value!,
                        isVideo: true,
                      )
                    : controller.selectedAudio.value != null
                    ? _buildAudioPreview(controller.selectedAudio.value!)
                    : controller.shouldShowExistingMedia
                    ? _buildExistingMediaPreview(controller.existingMedia!)
                    : _buildMediaPlaceholder(),
              );
            }),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingMediaPreview(CommunityPostMedia media) {
    if (media.uiType == 'voice') {
      return _buildExistingAudioPreview();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          child: media.uiType == 'image'
              ? Image.network(
                  media.url,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      _buildExistingMediaFallback(Icons.image_outlined),
                )
              : _buildExistingMediaFallback(Icons.videocam_rounded),
        ),
        if (media.uiType == 'video')
          const Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => controller.removeMedia(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExistingMediaFallback(IconData icon) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1A8C79), width: 2),
      ),
      child: Icon(icon, color: const Color(0xFF2FBDA3), size: 50),
    );
  }

  Widget _buildExistingAudioPreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2FBDA3).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic_rounded, color: Color(0xFF2FBDA3)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Voice Note Selected',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF123456),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF64748B)),
            onPressed: () => controller.removeMedia(),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(
    File file, {
    bool isImage = false,
    bool isVideo = false,
  }) {
    return Stack(
      children: [
        ClipRRect(
          //borderRadius: BorderRadius.circular(12),
          child: isImage
              ? Image.file(
                  file,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                )
              : Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFF1A8C79), width: 2),
                  ),

                  child: const Icon(
                    Icons.videocam_rounded,
                    color: Color(0xFF2FBDA3),
                    size: 50,
                  ),
                ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () => controller.removeMedia(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ),
        if (isVideo)
          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 60),
          ),
      ],
    );
  }

  Widget _buildAudioPreview(File file) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEBFDF5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2FBDA3).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.mic_rounded, color: Color(0xFF2FBDA3)),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Voice Note Selected',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF123456),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF64748B)),
            onPressed: () => controller.removeMedia(),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Add media to your post',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPlaceholderIcon(
              Icons.image_outlined,
              'Image',
              () => controller.pickImage(),
            ),
            const SizedBox(width: 30),
            _buildPlaceholderIcon(
              Icons.videocam_outlined,
              'Video',
              () => controller.pickVideo(),
            ),
            const SizedBox(width: 30),
            _buildPlaceholderIcon(
              Icons.mic_none_rounded,
              'Audio',
              () => controller.pickAudio(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlaceholderIcon(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFEBFDF5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF2FBDA3), size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
