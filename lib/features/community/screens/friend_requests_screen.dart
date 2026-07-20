import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/assest_const.dart';
import '../controllers/community_controller.dart';
import '../models/community_post_model.dart';
import 'user_profile_screen.dart';

class FriendRequestsScreen extends StatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  State<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends State<FriendRequestsScreen> {
  late final CommunityController controller;
  final ScrollController _requestedScrollController = ScrollController();
  final ScrollController _sentScrollController = ScrollController();
  int _selectedTab = 0;

  FriendRequestMode get _selectedMode =>
      _selectedTab == 0 ? FriendRequestMode.received : FriendRequestMode.sent;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CommunityController>()
        ? Get.find<CommunityController>()
        : Get.put(CommunityController());
    _requestedScrollController.addListener(
      () => _handleScroll(FriendRequestMode.received),
    );
    _sentScrollController.addListener(
      () => _handleScroll(FriendRequestMode.sent),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.ensureFriendRequestsLoaded(includeSent: true);
    });
  }

  @override
  void dispose() {
    _requestedScrollController.dispose();
    _sentScrollController.dispose();
    super.dispose();
  }

  void _handleScroll(FriendRequestMode mode) {
    final scrollController = mode == FriendRequestMode.sent
        ? _sentScrollController
        : _requestedScrollController;
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 260) {
      controller.loadMoreFriendRequests(mode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xFF1E293B),
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Friend Requests',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildTabs(),
            Expanded(child: _buildRequestList(_selectedMode)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildTab(label: 'Requested', index: 0),
            _buildTab(label: 'Sent', index: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTab({required String label, required int index}) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF5456E7)
                  : const Color(0xFF6B7280),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequestList(FriendRequestMode mode) {
    return Obx(() {
      final requests = mode == FriendRequestMode.sent
          ? controller.sentRequests
          : controller.friendRequests;
      final isLoading = mode == FriendRequestMode.sent
          ? controller.isSentRequestsLoading.value
          : controller.isReceivedRequestsLoading.value;
      final isLoadingMore = mode == FriendRequestMode.sent
          ? controller.isSentRequestsLoadingMore.value
          : controller.isReceivedRequestsLoadingMore.value;
      final error = mode == FriendRequestMode.sent
          ? controller.sentRequestsError.value
          : controller.receivedRequestsError.value;

      if (isLoading && requests.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (error != null && requests.isEmpty) {
        return _buildErrorState(error, mode);
      }

      return RefreshIndicator(
        onRefresh: () => controller.refreshFriendRequests(mode: mode),
        child: requests.isEmpty
            ? _buildEmptyState(mode)
            : ListView.builder(
                controller: mode == FriendRequestMode.sent
                    ? _sentScrollController
                    : _requestedScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                itemCount: requests.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == requests.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return _buildRequestCard(requests[index], mode);
                },
              ),
      );
    });
  }

  Widget _buildRequestCard(FriendRequestItem request, FriendRequestMode mode) {
    final user = request.user;
    final isRequested = mode == FriendRequestMode.received;
    final isBusy = controller.handlingFriendRequestIds.contains(request.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFEAEDF1)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _openProfile(user),
            child: CircleAvatar(
              radius: 28,
              backgroundImage: _avatarProvider(user.avatarUrl),
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () => _openProfile(user),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isRequested
                        ? _usernameLabel(user.username)
                        : 'Request Sent',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (isRequested) ...[
            _roundActionButton(
              icon: Icons.close_rounded,
              color: const Color(0xFFD9D9D9),
              foreground: Colors.black,
              isBusy: isBusy,
              onTap: () => controller.declineRequest(request),
            ),
            const SizedBox(width: 10),
            _roundActionButton(
              icon: Icons.check_rounded,
              color: const Color(0xFF006B5B),
              foreground: Colors.white,
              isBusy: isBusy,
              onTap: () => controller.acceptRequest(request),
            ),
          ] else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Already Sent',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _roundActionButton({
    required IconData icon,
    required Color color,
    required Color foreground,
    required bool isBusy,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Center(
          child: isBusy
              ? SizedBox(
                  width: 17,
                  height: 17,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(foreground),
                  ),
                )
              : Icon(icon, size: 19, color: foreground),
        ),
      ),
    );
  }

  Widget _buildEmptyState(FriendRequestMode mode) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 120, 20, 20),
      children: [
        const Icon(
          Icons.people_outline_rounded,
          color: Color(0xFFCBD5E1),
          size: 44,
        ),
        const SizedBox(height: 12),
        Text(
          mode == FriendRequestMode.sent
              ? 'No sent requests.'
              : 'No friend requests.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, FriendRequestMode mode) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 110, 24, 20),
      children: [
        const Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFEF4444),
          size: 38,
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
            onPressed: () =>
                controller.loadFriendRequests(mode: mode, reset: true),
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

  void _openProfile(PublicUserSummary user) {
    Get.to(
      () => UserProfileScreen(
        userId: user.id,
        name: user.displayName,
        imageUrl: user.avatarUrl ?? '',
      ),
    );
  }

  ImageProvider<Object> _avatarProvider(String? url) {
    if (url != null && url.isNotEmpty) return NetworkImage(url);
    return AssetImage(AssetsConstants.images.profileImage);
  }

  String _usernameLabel(String username) {
    final value = username.trim();
    if (value.isEmpty) return '';
    return value.startsWith('@') ? value : '@$value';
  }
}
