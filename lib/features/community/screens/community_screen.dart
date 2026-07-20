import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutx_core/core/debug_print.dart';
import 'package:flutter_tbzwa/core/constants/assest_const.dart';
import 'package:flutter_tbzwa/core/services/media_cache_service.dart';
import 'package:flutter_tbzwa/core/utils/app_snackbar.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../subcribers_flow/subscriber_menu_drawer.dart';
import '../controllers/community_controller.dart';
import '../models/community_post_model.dart';
import 'community_messages_screen.dart';
import 'create_post_screen.dart';
import 'user_profile_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with WidgetsBindingObserver {
  late final CommunityController controller;
  late final TextEditingController _searchController;
  final ScrollController _scrollController = ScrollController();
  bool _isOpeningMessages = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.isRegistered<CommunityController>()
        ? Get.find<CommunityController>()
        : Get.put(CommunityController());
    _searchController = TextEditingController(
      text: controller.searchQuery.value,
    );
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.ensureFeedLoaded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pauseActiveMedia();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _pauseActiveMedia();
    }
  }

  void _pauseActiveMedia() {
    unawaited(_CommunityMediaCoordinator.instance.pauseActive());
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      drawer: const SubscriberMenuDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Builder(
                      builder: (context) => GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: const Padding(
                          padding: EdgeInsets.only(left: 18.0),
                          child: Icon(
                            Icons.menu,
                            color: Color(0xFF1E293B),
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _buildHeaders(),
                ],
              ),
            ),
            const Divider(color: Color(0xFFD1D1D1)),
            _buildHeader(),
            _buildFilters(),
            Expanded(child: _buildPostList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14),
                onChanged: (query) {
                  _pauseActiveMedia();
                  controller.setSearchQuery(query);
                },
                decoration: const InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _openCreatePost,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFFFFFF),
              ),
              child: const Icon(Icons.edit_outlined, color: Color(0xFF1E293B)),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _openMessages,
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFFFFFFF),
              ),
              child: const Icon(Icons.chat, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaders() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
                letterSpacing: 0.5,
              ),
              children: [
                TextSpan(text: "TALK/"),
                TextSpan(text: "'BZ/"),
              ],
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['Recent', 'Image', 'Voice', 'Video'];
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 20),
      child: Obx(() {
        final selected = controller.selectedFilter.value;
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          scrollDirection: Axis.horizontal,
          itemCount: filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = selected == filter;
            return GestureDetector(
              onTap: () {
                _pauseActiveMedia();
                controller.setFilter(filter);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF22A892)
                      : const Color(0xFFE3E7EE),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildPostList() {
    return Obx(() {
      if (controller.isInitialLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.errorMessage.value!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    _pauseActiveMedia();
                    controller.loadPosts(reset: true);
                  },
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.posts.isEmpty) {
        return RefreshIndicator(
          onRefresh: () {
            _pauseActiveMedia();
            return controller.refreshFeed();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 160),
              Center(
                child: Text(
                  'No posts found.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ),
            ],
          ),
        );
      }

      final busyLikeIds = controller.likingPostIds.toSet();
      return RefreshIndicator(
        onRefresh: () {
          _pauseActiveMedia();
          return controller.refreshFeed();
        },
        child: ListView.builder(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount:
              controller.posts.length +
              (controller.isLoadingMore.value ? 1 : 0) +
              1,
          itemBuilder: (context, index) {
            if (index == controller.posts.length) {
              if (!controller.isLoadingMore.value) {
                return const SizedBox(height: 20);
              }
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 18),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (index > controller.posts.length) {
              return const SizedBox(height: 20);
            }
            final post = controller.posts[index];
            return KeyedSubtree(
              key: ValueKey('community-post-${post.id}'),
              child: _buildPostCard(
                post,
                isLikeBusy: busyLikeIds.contains(post.id),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildPostCard(CommunityPost post, {required bool isLikeBusy}) {
    final media = post.primaryMedia;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _openAuthorProfile(post),
                child: _buildAvatar(post.authorImageUrl, 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openAuthorProfile(post),
                  child: Text(
                    post.authorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (post.isOwner)
                    _buildOwnPostMenu(post)
                  else
                    const SizedBox(height: 24),
                  Text(
                    post.timeAgo,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (post.content.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              post.content,
              style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
            ),
          ],
          if (media != null) ...[
            const SizedBox(height: 12),
            _buildMedia(post, media),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInteraction(
                post.isLiked ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                _countLabel('Like', post.likesCount),
                onTap: () => controller.toggleLike(post),
                active: post.isLiked,
                isBusy: isLikeBusy,
              ),
              _buildInteraction(
                Icons.chat_bubble_outline_rounded,
                _countLabel('Comment', post.commentsCount),
                onTap: () => _showComments(post),
              ),
              _buildInteraction(
                Icons.share_outlined,
                _countLabel('Share', post.sharesCount),
                onTap: () => controller.sharePost(post),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOwnPostMenu(CommunityPost post) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_horiz, color: Color(0xFF94A3B8)),
      onSelected: (value) {
        if (value == 'edit') _openEditPost(post);
        if (value == 'delete') _confirmDelete(post);
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'edit', child: Text('Edit')),
        PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
    );
  }

  Widget _buildMedia(CommunityPost post, CommunityPostMedia media) {
    if (media.uiType == 'voice') {
      return _CommunityAudioPlayer(
        key: ValueKey(
          'community-audio-${post.id}-${media.publicId}-${media.url.hashCode}',
        ),
        playbackKey: 'community-audio-${post.id}',
        url: media.url,
        initialDuration: media.duration,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: double.infinity,
        height: 200,
        child: media.uiType == 'video'
            ? _CommunityVideoPlayer(
                key: ValueKey(
                  'community-video-${post.id}-${media.publicId}-${media.url.hashCode}',
                ),
                playbackKey: 'community-video-${post.id}',
                url: media.url,
              )
            : _isValidNetworkMediaUrl(media.url)
            ? Image.network(
                media.url,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    _buildMediaFallback(Icons.image_outlined),
              )
            : _buildMediaFallback(Icons.image_outlined),
      ),
    );
  }

  Widget _buildAvatar(String? avatarUrl, double radius) {
    return _buildCommunityAvatar(avatarUrl, radius);
  }

  Widget _buildMediaFallback(IconData icon) {
    return Container(
      width: double.infinity,
      height: 200,
      color: const Color(0xFFCFFEF5),
      child: Icon(icon, color: const Color(0xFF2FBDA3), size: 50),
    );
  }

  String _countLabel(String label, int count) {
    if (count <= 0) return label;
    return '$label $count';
  }

  Future<void> _openCreatePost() async {
    _pauseActiveMedia();
    final result = await Get.to<CommunityPost>(() => const CreatePostScreen());
    if (result != null) controller.insertOrUpdatePost(result);
  }

  Future<void> _openMessages() async {
    if (_isOpeningMessages) return;
    _isOpeningMessages = true;
    _pauseActiveMedia();
    try {
      await Get.to(() => const CommunityMessagesScreen());
    } catch (error) {
      AppSnackbar.error('Messages', error);
    } finally {
      _isOpeningMessages = false;
    }
  }

  Future<void> _openEditPost(CommunityPost post) async {
    _pauseActiveMedia();
    final result = await Get.to<CommunityPost>(
      () => CreatePostScreen(editingPost: post),
    );
    if (result != null) controller.insertOrUpdatePost(result);
  }

  void _confirmDelete(CommunityPost post) {
    _pauseActiveMedia();
    Get.dialog(
      AlertDialog(
        title: const Text('Delete post?'),
        content: const Text('This post will be removed from Community.'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deletePost(post);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildInteraction(
    IconData icon,
    String label, {
    required VoidCallback onTap,
    bool active = false,
    bool isBusy = false,
  }) {
    final color = active ? const Color(0xFF22A892) : const Color(0xFF94A3B8);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: isBusy ? null : onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComments(CommunityPost post) {
    _pauseActiveMedia();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CommunityCommentsSheet(post: post),
    );
  }

  void _openAuthorProfile(CommunityPost post) {
    if (post.authorId.isEmpty) return;
    _pauseActiveMedia();
    Get.to(
      () => UserProfileScreen(
        userId: post.authorId,
        name: post.authorName,
        imageUrl: post.authorImageUrl ?? '',
      ),
    );
  }
}

class _CommunityCommentsSheet extends StatefulWidget {
  const _CommunityCommentsSheet({required this.post});

  final CommunityPost post;

  @override
  State<_CommunityCommentsSheet> createState() =>
      _CommunityCommentsSheetState();
}

class _CommunityCommentsSheetState extends State<_CommunityCommentsSheet> {
  final CommunityController controller = Get.find<CommunityController>();
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<CommunityComment> _comments = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isSending = false;
  String? _errorMessage;
  int _page = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
    _loadComments(reset: true);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients ||
        _isLoadingMore ||
        _page >= _totalPages) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 160) {
      _loadComments(reset: false);
    }
  }

  Future<void> _loadComments({required bool reset}) async {
    setState(() {
      if (reset) {
        _isLoading = true;
        _errorMessage = null;
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final result = await controller.loadComments(
        postId: widget.post.id,
        page: reset ? 1 : _page + 1,
      );
      if (!mounted) return;
      setState(() {
        _page = result.page;
        _totalPages = result.totalPages < 1 ? 1 : result.totalPages;
        if (reset) {
          _comments
            ..clear()
            ..addAll(result.comments);
        } else {
          final existing = _comments.map((comment) => comment.id).toSet();
          _comments.addAll(
            result.comments.where((comment) => !existing.contains(comment.id)),
          );
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _sendComment() async {
    if (_isSending) return;
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSending = true);
    try {
      final comment = await controller.addComment(
        postId: widget.post.id,
        content: content,
      );
      if (!mounted) return;
      setState(() {
        _comments.insert(0, comment);
        _commentController.clear();
      });
    } catch (error) {
      AppSnackbar.error('Comment', error);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const Text(
              'Comments',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: _buildCommentList()),
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            ),
            TextButton(
              onPressed: () => _loadComments(reset: true),
              child: const Text('Try again'),
            ),
          ],
        ),
      );
    }
    if (_comments.isEmpty) {
      return const Center(
        child: Text(
          'No comments yet.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      itemCount: _comments.length + (_isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _comments.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final comment = _comments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _openCommentAuthor(comment),
                child: _commentAvatar(comment.authorImageUrl),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _openCommentAuthor(comment),
                      child: Text(
                        comment.authorName,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.content,
                      style: const TextStyle(
                        color: Color(0xFF1E293B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                comment.timeAgo,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                minLines: 1,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: TextStyle(color: const Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),

                  filled: true,
                  fillColor: const Color(0xFFF7F8FC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _isSending ? null : _sendComment,
              child: Container(
                height: 42,
                width: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF22A892),
                  shape: BoxShape.circle,
                ),
                child: _isSending
                    ? const Padding(
                        padding: EdgeInsets.all(11),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _commentAvatar(String? avatarUrl) {
    return _buildCommunityAvatar(avatarUrl, 17);
  }

  void _openCommentAuthor(CommunityComment comment) {
    if (comment.authorId.isEmpty) return;
    unawaited(_CommunityMediaCoordinator.instance.pauseActive());
    Get.to(
      () => UserProfileScreen(
        userId: comment.authorId,
        name: comment.authorName,
        imageUrl: comment.authorImageUrl ?? '',
      ),
    );
  }
}

typedef _PauseCommunityMedia = Future<void> Function();

class _CommunityMediaCoordinator {
  _CommunityMediaCoordinator._();

  static final _CommunityMediaCoordinator instance =
      _CommunityMediaCoordinator._();

  String? _activeKey;
  _PauseCommunityMedia? _pauseActiveCallback;

  Future<void> requestPlay(
    String key,
    _PauseCommunityMedia pauseCurrent,
  ) async {
    if (_activeKey != key) {
      final previousPause = _pauseActiveCallback;
      _activeKey = null;
      _pauseActiveCallback = null;
      await previousPause?.call();
    }

    _activeKey = key;
    _pauseActiveCallback = pauseCurrent;
  }

  Future<void> clear(String key) async {
    if (_activeKey != key) return;
    _activeKey = null;
    _pauseActiveCallback = null;
  }

  Future<void> pauseActive() async {
    final previousPause = _pauseActiveCallback;
    _activeKey = null;
    _pauseActiveCallback = null;
    await previousPause?.call();
  }
}

Widget _buildCommunityAvatar(String? avatarUrl, double radius) {
  final size = radius * 2;
  final url = avatarUrl?.trim() ?? '';
  return SizedBox(
    width: size,
    height: size,
    child: ClipOval(
      child: _isValidNetworkMediaUrl(url)
          ? Image.network(
              url,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _buildAvatarFallback(size, radius),
            )
          : _buildAvatarFallback(size, radius),
    ),
  );
}

Widget _buildAvatarFallback(double size, double radius) {
  return Image.asset(
    AssetsConstants.images.profileImage,
    width: size,
    height: size,
    fit: BoxFit.cover,
    errorBuilder: (_, _, _) => Container(
      width: size,
      height: size,
      color: const Color(0xFFE3E7EE),
      child: Icon(
        Icons.person_outline_rounded,
        size: radius,
        color: const Color(0xFF94A3B8),
      ),
    ),
  );
}

bool _isValidNetworkMediaUrl(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return false;
  return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
}

String _formatCommunityMediaDuration(Duration duration) {
  final totalSeconds = duration.inMilliseconds <= 0
      ? 0
      : duration.inSeconds.clamp(1, 1 << 31);
  final hours = totalSeconds ~/ 3600;
  final minutesValue = (totalSeconds % 3600) ~/ 60;
  final secondsValue = totalSeconds % 60;
  final minutes = hours > 0
      ? minutesValue.toString().padLeft(2, '0')
      : minutesValue.toString();
  final seconds = secondsValue.toString().padLeft(2, '0');
  if (hours > 0) return '$hours:$minutes:$seconds';
  return '$minutes:$seconds';
}

class _CommunityAudioPlayer extends StatefulWidget {
  const _CommunityAudioPlayer({
    super.key,
    required this.playbackKey,
    required this.url,
    this.initialDuration,
  });

  final String playbackKey;
  final String url;
  final Duration? initialDuration;

  @override
  State<_CommunityAudioPlayer> createState() => _CommunityAudioPlayerState();
}

class _CommunityAudioPlayerState extends State<_CommunityAudioPlayer>
    with WidgetsBindingObserver {
  late final AudioPlayer _player;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<void>? _completionSubscription;
  StreamSubscription<PlayerState>? _stateSubscription;
  Future<bool>? _prepareFuture;

  bool _isPlaying = false;
  bool _isPreparing = false;
  bool _hasError = false;
  bool _sourceReady = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  int _sourceVersion = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _duration = widget.initialDuration ?? Duration.zero;
    _player = AudioPlayer();

    _durationSubscription = _player.onDurationChanged.listen((duration) {
      if (!mounted || duration <= Duration.zero) return;
      setState(() => _duration = duration);
    });
    _positionSubscription = _player.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() => _position = position);
    });
    _completionSubscription = _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
      unawaited(_CommunityMediaCoordinator.instance.clear(widget.playbackKey));
    });
    _stateSubscription = _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void didUpdateWidget(covariant _CommunityAudioPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playbackKey != widget.playbackKey) {
      unawaited(
        _CommunityMediaCoordinator.instance.clear(oldWidget.playbackKey),
      );
    }
    if (oldWidget.url != widget.url) {
      _resetSource();
    } else if (oldWidget.initialDuration != widget.initialDuration) {
      setState(() {
        _duration = widget.initialDuration ?? _duration;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(_pauseFromUser());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sourceVersion++;
    unawaited(_CommunityMediaCoordinator.instance.clear(widget.playbackKey));
    unawaited(_durationSubscription?.cancel());
    unawaited(_positionSubscription?.cancel());
    unawaited(_completionSubscription?.cancel());
    unawaited(_stateSubscription?.cancel());
    unawaited(_player.dispose());
    super.dispose();
  }

  void _resetSource() {
    _sourceVersion++;
    _prepareFuture = null;
    _sourceReady = false;
    _isPlaying = false;
    _isPreparing = false;
    _hasError = false;
    _position = Duration.zero;
    _duration = widget.initialDuration ?? Duration.zero;
    unawaited(_player.stop());
  }

  Future<bool> _prepareSource() {
    if (_sourceReady) return Future.value(true);
    if (_prepareFuture != null) return _prepareFuture!;
    _prepareFuture = _loadSource();
    return _prepareFuture!;
  }

  Future<bool> _loadSource() async {
    final url = widget.url.trim();
    if (!_isValidNetworkMediaUrl(url)) {
      if (mounted) {
        setState(() {
          _sourceReady = false;
          _isPreparing = false;
          _hasError = true;
        });
      }
      _prepareFuture = null;
      return false;
    }

    final version = ++_sourceVersion;
    if (mounted) {
      setState(() {
        _isPreparing = true;
        _hasError = false;
      });
    }

    try {
      await _runGuardedAudioAction(
        () => _player.setReleaseMode(ReleaseMode.stop),
      );
      final File file = await MediaCacheService.audioCacheManager.getSingleFile(
        url,
      );
      if (!mounted || version != _sourceVersion) return false;

      await _runGuardedAudioAction(
        () => _player.setSource(DeviceFileSource(file.path)),
      );
      final duration = await _runGuardedAudioAction(_player.getDuration);
      if (!mounted || version != _sourceVersion) return false;
      setState(() {
        _sourceReady = true;
        _isPreparing = false;
        if (duration != null && duration > Duration.zero) {
          _duration = duration;
        }
      });
      return true;
    } catch (error) {
      DPrint.error(
        'Community audio failed to load (${widget.playbackKey}): $error',
      );
      if (mounted && version == _sourceVersion) {
        setState(() {
          _sourceReady = false;
          _isPreparing = false;
          _hasError = true;
        });
      }
      return false;
    } finally {
      if (version == _sourceVersion) {
        _prepareFuture = null;
      }
    }
  }

  Future<T> _runGuardedAudioAction<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    runZonedGuarded(
      () {
        unawaited(() async {
          try {
            final result = await action();
            if (!completer.isCompleted) completer.complete(result);
          } catch (error, stackTrace) {
            if (!completer.isCompleted) {
              completer.completeError(error, stackTrace);
            }
          }
        }());
      },
      (error, stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        } else {
          DPrint.error(
            'Community audio ignored late platform error (${widget.playbackKey}): ${error.runtimeType}',
          );
        }
      },
    );
    return completer.future;
  }

  Future<void> _toggle() async {
    if (_isPreparing) return;
    if (_isPlaying) {
      await _pauseFromUser();
      return;
    }

    await _CommunityMediaCoordinator.instance.requestPlay(
      widget.playbackKey,
      _pauseFromCoordinator,
    );

    final ready = await _prepareSource();
    if (!ready) {
      await _CommunityMediaCoordinator.instance.clear(widget.playbackKey);
      return;
    }

    try {
      if (_duration > Duration.zero && _position >= _duration) {
        await _runGuardedAudioAction(() => _player.seek(Duration.zero));
      }
      await _runGuardedAudioAction(_player.resume);
      if (mounted) {
        setState(() {
          _hasError = false;
          _isPlaying = true;
        });
      }
    } catch (error) {
      DPrint.error(
        'Community audio failed to play (${widget.playbackKey}): $error',
      );
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _hasError = true;
        });
      }
      await _CommunityMediaCoordinator.instance.clear(widget.playbackKey);
    }
  }

  Future<void> _pauseFromUser() async {
    await _pauseFromCoordinator();
    await _CommunityMediaCoordinator.instance.clear(widget.playbackKey);
  }

  Future<void> _pauseFromCoordinator() async {
    try {
      await _player.pause();
    } catch (_) {
      return;
    }
    if (mounted) setState(() => _isPlaying = false);
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds <= 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

    return VisibilityDetector(
      key: ValueKey('community-audio-visibility-${widget.playbackKey}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction < 0.1) {
          unawaited(_pauseFromUser());
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFCFFEF5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _isPreparing ? null : _toggle,
              child: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFF2FBDA3),
                  shape: BoxShape.circle,
                ),
                child: _isPreparing
                    ? const Padding(
                        padding: EdgeInsets.all(9),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        _hasError
                            ? Icons.error_outline_rounded
                            : _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: Colors.white.withValues(alpha: 0.8),
                  valueColor: const AlwaysStoppedAnimation(Color(0xFF2FBDA3)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _formatCommunityMediaDuration(
                _duration == Duration.zero ? _position : _duration,
              ),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityVideoPlayer extends StatefulWidget {
  const _CommunityVideoPlayer({
    super.key,
    required this.playbackKey,
    required this.url,
  });

  final String playbackKey;
  final String url;

  @override
  State<_CommunityVideoPlayer> createState() => _CommunityVideoPlayerState();
}

class _CommunityVideoPlayerState extends State<_CommunityVideoPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  Future<bool>? _initializeFuture;
  bool _isInitializing = false;
  bool _hasError = false;
  bool _isCompleted = false;
  bool _hasPlayIntent = false;
  int _sourceVersion = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(covariant _CommunityVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playbackKey != widget.playbackKey) {
      unawaited(
        _CommunityMediaCoordinator.instance.clear(oldWidget.playbackKey),
      );
    }
    if (oldWidget.url != widget.url) {
      _resetController();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(_pauseFromUser());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sourceVersion++;
    _initializeFuture = null;
    unawaited(_CommunityMediaCoordinator.instance.clear(widget.playbackKey));
    _disposeController();
    super.dispose();
  }

  void _resetController() {
    _sourceVersion++;
    _initializeFuture = null;
    _isInitializing = false;
    _hasError = false;
    _isCompleted = false;
    _hasPlayIntent = false;
    _disposeController();
  }

  void _disposeController() {
    final controller = _controller;
    _controller = null;
    if (controller == null) return;
    controller.removeListener(_handleControllerChanged);
    unawaited(controller.dispose());
  }

  Future<bool> _ensureInitialized() {
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      return Future.value(true);
    }
    if (_initializeFuture != null) return _initializeFuture!;
    _initializeFuture = _initializeController();
    return _initializeFuture!;
  }

  Future<bool> _initializeController() async {
    final url = widget.url.trim();
    if (!_isValidNetworkMediaUrl(url)) {
      if (mounted) setState(() => _hasError = true);
      _initializeFuture = null;
      return false;
    }

    final version = ++_sourceVersion;
    if (mounted) {
      setState(() {
        _isInitializing = true;
        _hasError = false;
        _isCompleted = false;
      });
    }

    VideoPlayerController? controller;
    try {
      final File file = await MediaCacheService.videoCacheManager.getSingleFile(
        url,
      );
      if (!mounted || version != _sourceVersion) return false;

      controller = VideoPlayerController.file(file);
      _controller = controller;
      controller.addListener(_handleControllerChanged);
      await controller.initialize();
      await controller.setLooping(false);

      if (!mounted || version != _sourceVersion) {
        if (_controller == controller) {
          _controller = null;
          controller.removeListener(_handleControllerChanged);
          await controller.dispose();
        }
        return false;
      }

      setState(() => _isInitializing = false);
      return true;
    } catch (error) {
      DPrint.error(
        'Community video failed to initialize (${widget.playbackKey}): $error',
      );
      if (controller != null) {
        if (_controller == controller) {
          _controller = null;
          controller.removeListener(_handleControllerChanged);
          await controller.dispose();
        }
      }
      if (mounted && version == _sourceVersion) {
        setState(() {
          _controller = null;
          _isInitializing = false;
          _hasError = true;
        });
      }
      return false;
    } finally {
      if (version == _sourceVersion) {
        _initializeFuture = null;
      }
    }
  }

  void _handleControllerChanged() {
    final controller = _controller;
    if (!mounted || controller == null) return;
    final value = controller.value;
    final completed = _isVideoCompleted(controller.value);
    if (completed && !_isCompleted) {
      unawaited(_CommunityMediaCoordinator.instance.clear(widget.playbackKey));
    }
    setState(() {
      _isCompleted = completed;
      if (completed) {
        _hasPlayIntent = false;
      } else if (value.isPlaying) {
        _hasPlayIntent = true;
      }
    });
  }

  bool _isVideoCompleted(VideoPlayerValue value) {
    if (!value.isInitialized || value.duration <= Duration.zero) return false;
    final threshold = value.duration - const Duration(milliseconds: 250);
    final completedAt = threshold.isNegative ? Duration.zero : threshold;
    return !value.isPlaying && value.position >= completedAt;
  }

  Future<void> _toggle() async {
    if (_isInitializing) return;

    final controller = _controller;
    if (controller != null &&
        controller.value.isInitialized &&
        controller.value.isPlaying) {
      await _pauseFromUser();
      return;
    }

    await _CommunityMediaCoordinator.instance.requestPlay(
      widget.playbackKey,
      _pauseFromCoordinator,
    );

    if (mounted) {
      setState(() {
        _hasError = false;
        _hasPlayIntent = true;
        _isCompleted = false;
      });
    }

    final ready = await _ensureInitialized();
    final initializedController = _controller;
    if (!ready ||
        initializedController == null ||
        !initializedController.value.isInitialized) {
      if (mounted) setState(() => _hasPlayIntent = false);
      await _CommunityMediaCoordinator.instance.clear(widget.playbackKey);
      return;
    }

    try {
      if (_isCompleted || _isVideoCompleted(initializedController.value)) {
        await initializedController.seekTo(Duration.zero);
      }
      if (mounted) {
        setState(() {
          _hasPlayIntent = true;
          _isCompleted = false;
        });
      }
      await initializedController.play();
      if (mounted) {
        setState(() {
          _hasError = false;
          _hasPlayIntent = true;
          _isCompleted = false;
        });
      }
    } catch (error) {
      DPrint.error(
        'Community video failed to play (${widget.playbackKey}): $error',
      );
      if (mounted) {
        setState(() {
          _hasError = true;
          _hasPlayIntent = false;
        });
      }
      await _CommunityMediaCoordinator.instance.clear(widget.playbackKey);
    }
  }

  Future<void> _pauseFromUser() async {
    await _pauseFromCoordinator();
    await _CommunityMediaCoordinator.instance.clear(widget.playbackKey);
  }

  Future<void> _pauseFromCoordinator() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    try {
      await controller.pause();
    } catch (_) {
      return;
    }
    if (mounted) setState(() => _hasPlayIntent = false);
  }

  @override
  Widget build(BuildContext context) {
    final value = _controller?.value;
    final isInitialized = value?.isInitialized == true;
    final isBuffering = isInitialized && (value?.isBuffering ?? false);
    final isPlaying = isInitialized && (value?.isPlaying ?? false);
    final hasActivePlayback = isPlaying || (_hasPlayIntent && !_isCompleted);
    final showLoading = _isInitializing || isBuffering;
    final showPlay =
        !_hasError &&
        !showLoading &&
        (!isInitialized || !hasActivePlayback || _isCompleted);

    return VisibilityDetector(
      key: ValueKey('community-video-visibility-${widget.playbackKey}'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction < 0.1) {
          unawaited(_pauseFromUser());
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _isInitializing ? null : _toggle,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(child: _buildVideoContent()),
            if (showLoading)
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Color(0xFF2FBDA3),
                ),
              ),
            if (showPlay)
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFF2FBDA3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            if (isInitialized)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: VideoProgressIndicator(
                  _controller!,
                  allowScrubbing: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    final controller = _controller;
    if (_hasError) {
      return Container(
        color: Colors.black12,
        child: const Center(
          child: Icon(Icons.error_outline, color: Colors.red),
        ),
      );
    }

    if (controller == null || !controller.value.isInitialized) {
      return Container(color: Colors.black12);
    }

    final size = controller.value.size;
    final width = size.width <= 0 ? 16.0 : size.width;
    final height = size.height <= 0 ? 9.0 : size.height;
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: width,
        height: height,
        child: VideoPlayer(controller),
      ),
    );
  }
}
