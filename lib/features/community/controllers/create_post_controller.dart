import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tbzwa/core/utils/app_snackbar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/smart_media_service.dart';
import '../models/community_post_model.dart';
import '../services/community_api_service.dart';

class CreatePostController extends GetxController {
  CreatePostController({this.editingPost});

  static const int _maxMediaBytes = 200 * 1024 * 1024;
  static const Set<String> _imageExtensions = {'jpg', 'jpeg', 'png', 'webp'};
  static const Set<String> _videoExtensions = {'mp4', 'mov', 'webm', 'mpeg'};
  static const Set<String> _audioExtensions = {
    'mp3',
    'mpeg',
    'wav',
    'webm',
    'm4a',
    'ogg',
    'aac',
  };

  final CommunityPost? editingPost;
  final SmartMediaService _mediaService = Get.find<SmartMediaService>();
  final CommunityApiService _communityApiService = CommunityApiService();
  final TextEditingController textController = TextEditingController();

  final Rxn<File> selectedImage = Rxn<File>();
  final Rxn<File> selectedVideo = Rxn<File>();
  final Rxn<File> selectedAudio = Rxn<File>();
  final RxBool existingMediaRemoved = false.obs;
  final isPosting = false.obs;

  bool get isEditing => editingPost != null;

  CommunityPostMedia? get existingMedia => editingPost?.primaryMedia;

  bool get shouldShowExistingMedia {
    return existingMedia != null &&
        !existingMediaRemoved.value &&
        selectedImage.value == null &&
        selectedVideo.value == null &&
        selectedAudio.value == null;
  }

  @override
  void onInit() {
    super.onInit();
    textController.text = editingPost?.content ?? '';
  }

  Future<void> pickImage() async {
    final image = await _mediaService.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final file = File(image.path);
    if (!await _validateMedia(file, _imageExtensions, 'image')) return;
    selectedImage.value = file;
    selectedVideo.value = null;
    selectedAudio.value = null;
    existingMediaRemoved.value = false;
  }

  Future<void> pickVideo() async {
    final video = await _mediaService.pickVideo(source: ImageSource.gallery);
    if (video == null) return;
    final file = File(video.path);
    if (!await _validateMedia(file, _videoExtensions, 'video')) return;
    selectedVideo.value = file;
    selectedImage.value = null;
    selectedAudio.value = null;
    existingMediaRemoved.value = false;
  }

  Future<void> pickAudio() async {
    final files = await _mediaService.pickFiles(type: FileType.audio);
    if (files == null || files.isEmpty) return;
    final file = files.first;
    if (!await _validateMedia(file, _audioExtensions, 'audio')) return;
    selectedAudio.value = file;
    selectedImage.value = null;
    selectedVideo.value = null;
    existingMediaRemoved.value = false;
  }

  void removeMedia() {
    if (selectedImage.value != null ||
        selectedVideo.value != null ||
        selectedAudio.value != null) {
      selectedImage.value = null;
      selectedVideo.value = null;
      selectedAudio.value = null;
      return;
    }
    existingMediaRemoved.value = true;
  }

  Future<void> submitPost() async {
    if (isPosting.value) return;

    final content = textController.text.trim();
    final mediaFile =
        selectedImage.value ?? selectedVideo.value ?? selectedAudio.value;
    final hasExistingMedia = shouldShowExistingMedia;
    if (content.isEmpty && mediaFile == null && !hasExistingMedia) {
      AppSnackbar.warning(
        'Community',
        'Write something or add media before posting.',
      );
      return;
    }

    isPosting.value = true;
    try {
      final post = isEditing
          ? await _communityApiService.updatePost(
              postId: editingPost!.id,
              content: content,
              mediaFile: mediaFile,
              removeMedia: existingMediaRemoved.value && mediaFile == null,
            )
          : await _communityApiService.createPost(
              content: content,
              mediaFile: mediaFile,
            );
      Get.back(result: post);
      AppSnackbar.success(
        'Success',
        isEditing ? 'Post updated successfully!' : 'Post created successfully!',
      );
    } catch (error) {
      AppSnackbar.error(
        isEditing ? 'Unable to update post' : 'Unable to create post',
        error,
      );
    } finally {
      isPosting.value = false;
    }
  }

  Future<bool> _validateMedia(
    File file,
    Set<String> allowedExtensions,
    String label,
  ) async {
    final extension = file.path.split('.').last.toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      AppSnackbar.warning(
        'Unsupported $label',
        'Please choose a supported $label file.',
      );
      return false;
    }

    final size = await file.length();
    if (size > _maxMediaBytes) {
      AppSnackbar.warning(
        'File too large',
        'Please choose a file under 200 MB.',
      );
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
