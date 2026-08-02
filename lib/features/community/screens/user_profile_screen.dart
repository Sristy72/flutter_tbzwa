import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/assest_const.dart';
import '../../../core/utils/app_snackbar.dart';
import '../controllers/community_messages_controller.dart';
import '../controllers/community_controller.dart';
import '../models/community_post_model.dart';
import 'community_chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String? userId;
  final String name;
  final String imageUrl;
  final bool showMessageAction;

  const UserProfileScreen({
    super.key,
    this.userId,
    required this.name,
    required this.imageUrl,
    this.showMessageAction = true,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ScrollController _scrollController = ScrollController();
  late final CommunityController _communityController;

  PublicUserSummary? _user;
  FriendshipStatus _friendship = const FriendshipStatus.none();
  final List<CommunityPost> _posts = [];
  bool _isInitialLoading = false;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _isMutating = false;
  bool _isOpeningMessage = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _page = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _communityController = Get.isRegistered<CommunityController>()
        ? Get.find<CommunityController>()
        : Get.put(CommunityController());
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_targetUserId.isNotEmpty) {
        _loadProfile(reset: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  String get _targetUserId => widget.userId?.trim() ?? '';

  PublicUserSummary get _displayUser =>
      _user ??
      PublicUserSummary(
        id: _targetUserId,
        displayName: widget.name,
        username: '',
        bio: '',
        role: '',
        avatarUrl: widget.imageUrl.isEmpty ? null : widget.imageUrl,
        publicPostCount: _posts.length,
      );

  Future<void> _loadProfile({required bool reset}) async {
    if (_targetUserId.isEmpty) return;
    final nextPage = reset ? 1 : _page + 1;
    if (!reset && (!_hasMore || _isLoadingMore)) return;

    setState(() {
      _errorMessage = null;
      if (reset) {
        if (_user == null && _posts.isEmpty) {
          _isInitialLoading = true;
        } else {
          _isRefreshing = true;
        }
      } else {
        _isLoadingMore = true;
      }
    });

    try {
      final result = await _communityController.getPublicProfile(
        userId: _targetUserId,
        page: nextPage,
      );
      if (!mounted) return;
      setState(() {
        _user = result.user;
        _friendship = result.friendshipStatus;
        _page = result.page;
        _totalPages = result.totalPages;
        _hasMore = _page < _totalPages;
        if (reset) {
          _posts
            ..clear()
            ..addAll(result.posts);
        } else {
          final existingIds = _posts.map((post) => post.id).toSet();
          _posts.addAll(
            result.posts.where((post) => !existingIds.contains(post.id)),
          );
        }
      });
    } catch (error) {
      if (!mounted) return;
      final message = _cleanError(error);
      if (_user == null && _posts.isEmpty) {
        setState(() => _errorMessage = message);
      } else {
        AppSnackbar.error('Profile', message);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitialLoading = false;
          _isRefreshing = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _refreshProfile() => _loadProfile(reset: true);

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      unawaited(_loadProfile(reset: false));
    }
  }

  Future<void> _sendFriendRequest() async {
    if (_targetUserId.isEmpty || _isMutating) return;
    setState(() => _isMutating = true);
    try {
      final status = await _communityController.sendFriendRequestTo(
        _targetUserId,
      );
      if (!mounted) return;
      setState(() => _friendship = status);
      _refreshRequestLists(mode: FriendRequestMode.sent);
      AppSnackbar.success('Friend Request', 'Friend request sent.');
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error('Friend Request', error);
      await _refreshProfile();
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  Future<void> _respondToRequest(String action) async {
    final requestId = _friendship.requestId;
    if (requestId == null || _isMutating) return;
    setState(() => _isMutating = true);
    try {
      final status = await _communityController.respondFriendRequestById(
        requestId: requestId,
        action: action,
      );
      if (!mounted) return;
      setState(() => _friendship = status);
      _refreshRequestLists(mode: FriendRequestMode.received);
      if (action == 'accept') {
        AppSnackbar.success('Friend Request', 'Friend request accepted.');
      } else {
        AppSnackbar.info('Friend Request', 'Friend request declined.');
      }
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error('Friend Request', error);
      await _refreshProfile();
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  Future<void> _unfriend() async {
    final friendshipId = _friendship.friendshipId;
    if (friendshipId == null || _isMutating) return;
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Remove ${_displayUser.displayName} from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isMutating = true);
    try {
      await _communityController.removeFriendship(friendshipId);
      if (!mounted) return;
      setState(() => _friendship = const FriendshipStatus.none());
      AppSnackbar.info('Friends', 'Friend removed.');
    } catch (error) {
      if (!mounted) return;
      AppSnackbar.error('Friends', error);
      await _refreshProfile();
    } finally {
      if (mounted) setState(() => _isMutating = false);
    }
  }

  void _refreshRequestLists({required FriendRequestMode mode}) {
    if (!Get.isRegistered<CommunityController>()) return;
    unawaited(
      Get.find<CommunityController>().refreshFriendRequests(mode: mode),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _displayUser;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          user.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: _isInitialLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildErrorState(_errorMessage!)
            : RefreshIndicator(
                onRefresh: _refreshProfile,
                child: ListView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                  children: [
                    _buildHeader(user),
                    const SizedBox(height: 18),
                    _buildActions(user),
                    const SizedBox(height: 26),
                    _buildPostsHeader(user),
                    const SizedBox(height: 12),
                    if (_posts.isEmpty)
                      _buildEmptyPosts()
                    else
                      ..._posts.map(_buildPostCard),
                    if (_isLoadingMore)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 18),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (_isRefreshing) const SizedBox(height: 1),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(PublicUserSummary user) {
    final username = user.username.trim();
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: const Color(0xFFE5E7EB),
              backgroundImage: _avatarProvider(user.avatarUrl),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          user.displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        if (username.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '@$username',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (user.bio.trim().isNotEmpty) ...[
          const SizedBox(height: 14),
          Text(
            user.bio.trim(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: Color(0xFF475569),
            ),
          ),
        ],
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              Text(
                '${user.publicPostCount}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Posts',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActions(PublicUserSummary user) {
    if (_targetUserId.isEmpty || _friendship.state == FriendshipUiState.self) {
      return const SizedBox.shrink();
    }

    if (_friendship.state == FriendshipUiState.requestReceived) {
      return Row(
        children: [
          Expanded(
            child: _actionButton(
              label: 'Decline',
              icon: Icons.close_rounded,
              color: const Color(0xFFD9D9D9),
              foreground: const Color(0xFF111827),
              onTap: () => _respondToRequest('decline'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _actionButton(
              label: 'Accept',
              icon: Icons.check_rounded,
              color: const Color(0xFF006B5B),
              foreground: Colors.white,
              onTap: () => _respondToRequest('accept'),
            ),
          ),
        ],
      );
    }

    final buttons = <Widget>[];
    if (_friendship.canSendRequest) {
      buttons.add(
        Expanded(
          child: _actionButton(
            label: 'Send Request',
            icon: Icons.person_add_alt_1_rounded,
            color: const Color(0xFF5456E7),
            foreground: Colors.white,
            onTap: _sendFriendRequest,
          ),
        ),
      );
    } else if (_friendship.state == FriendshipUiState.requestSent) {
      buttons.add(
        Expanded(
          child: _actionButton(
            label: 'Request Sent',
            icon: Icons.schedule_rounded,
            color: const Color(0xFFEDEEF7),
            foreground: const Color(0xFF5456E7),
            onTap: null,
          ),
        ),
      );
    } else if (_friendship.state == FriendshipUiState.friends) {
      buttons.add(
        Expanded(
          child: _actionButton(
            label: 'Friends',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFFECFDF5),
            foreground: const Color(0xFF006B5B),
            onTap: _friendship.canUnfriend ? _unfriend : null,
          ),
        ),
      );
    }

    if (widget.showMessageAction && _friendship.canMessage) {
      if (buttons.isNotEmpty) buttons.add(const SizedBox(width: 12));
      buttons.add(
        Expanded(
          child: _actionButton(
            label: 'Message',
            icon: Icons.message_rounded,
            color: const Color(0xFF5456E7),
            foreground: Colors.white,
            onTap: _isOpeningMessage ? null : () => _openMessage(user),
          ),
        ),
      );
    }

    if (buttons.isEmpty) return const SizedBox.shrink();
    return Row(children: buttons);
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color foreground,
    required VoidCallback? onTap,
  }) {
    final disabled = onTap == null || _isMutating;
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: disabled ? null : onTap,
        icon: _isMutating && onTap != null
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(foreground),
                ),
              )
            : Icon(icon, size: 19),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foreground,
          disabledBackgroundColor: color,
          disabledForegroundColor: foreground.withValues(alpha: 0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Future<void> _openMessage(PublicUserSummary user) async {
    if (_isOpeningMessage) return;
    if (user.id.isEmpty) {
      AppSnackbar.error('Messages', 'User is unavailable.');
      return;
    }

    setState(() => _isOpeningMessage = true);
    try {
      final messagesController = Get.isRegistered<CommunityMessagesController>()
          ? Get.find<CommunityMessagesController>()
          : Get.put(CommunityMessagesController());
      final conversation = await messagesController.startDirectConversation(
        user.id,
      );
      if (!mounted) return;
      Get.to(() => CommunityChatScreen(conversationId: conversation.id));
    } catch (error) {
      AppSnackbar.error('Messages', error);
    } finally {
      if (mounted) setState(() => _isOpeningMessage = false);
    }
  }

  Widget _buildPostsHeader(PublicUserSummary user) {
    return Row(
      children: [
        const Text(
          'Community Posts',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Text(
          '${user.publicPostCount}',
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(CommunityPost post) {
    final media = post.primaryMedia;
    return GestureDetector(
      onTap: () => _openPost(post),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  post.timeAgo,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.open_in_new_rounded,
                  size: 16,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
            if (post.content.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                post.content.trim(),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
            if (media != null) ...[
              const SizedBox(height: 10),
              _buildMediaPreview(media),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                _postMetric(Icons.thumb_up_alt_outlined, '${post.likesCount}'),
                const SizedBox(width: 16),
                _postMetric(
                  Icons.chat_bubble_outline_rounded,
                  '${post.commentsCount}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview(CommunityPostMedia media) {
    if (media.uiType == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            media.url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _mediaFallback(Icons.image_outlined),
          ),
        ),
      );
    }

    return _mediaFallback(
      media.uiType == 'video'
          ? Icons.play_circle_outline_rounded
          : Icons.mic_none_rounded,
    );
  }

  Widget _mediaFallback(IconData icon) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Icon(icon, color: const Color(0xFF5456E7), size: 28),
      ),
    );
  }

  Widget _postMetric(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPosts() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: Text(
          'No public posts yet.',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFEF4444),
          size: 36,
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Color(0xFF475569), fontSize: 14),
        ),
        const SizedBox(height: 18),
        Center(
          child: ElevatedButton(
            onPressed: () => _loadProfile(reset: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5456E7),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Retry'),
          ),
        ),
      ],
    );
  }

  void _openPost(CommunityPost post) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                post.timeAgo,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (post.content.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  post.content.trim(),
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
              if (post.primaryMedia != null) ...[
                const SizedBox(height: 14),
                _buildMediaPreview(post.primaryMedia!),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  _postMetric(
                    Icons.thumb_up_alt_outlined,
                    '${post.likesCount}',
                  ),
                  const SizedBox(width: 16),
                  _postMetric(
                    Icons.chat_bubble_outline_rounded,
                    '${post.commentsCount}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider<Object> _avatarProvider(String? url) {
    if (url != null && url.isNotEmpty) return NetworkImage(url);
    return AssetImage(AssetsConstants.images.profileImage);
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}
