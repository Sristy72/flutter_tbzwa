import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'subscriber_choose_program_screen.dart';
import '../community/models/community_post_model.dart';
import 'models/subscriber_community_models.dart';
import 'services/subscriber_community_api_service.dart';

class SubscriberCommunityScreen extends StatefulWidget {
  const SubscriberCommunityScreen({super.key});

  @override
  State<SubscriberCommunityScreen> createState() =>
      _SubscriberCommunityScreenState();
}

class _SubscriberCommunityScreenState extends State<SubscriberCommunityScreen> {
  final SubscriberCommunityApiService _api = SubscriberCommunityApiService();
  int _selectedTab = 0; // 0 = Friends, 1 = Voice, 2 = Video room
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _tabs = ['Friends', 'Voice', 'Live'];

  List<SubscriberFriendRequest> _friendRequests = const [];
  List<SubscriberOnlineFriend> _onlineUsers = const [];
  List<SubscriberVoiceRoom> _voiceRooms = const [];
  List<CommunityPost> _livePosts = const [];

  @override
  void initState() {
    super.initState();
    _loadCommunityData();
  }

  Future<void> _loadCommunityData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final results = await Future.wait<dynamic>([
        _api.getFriendRequests(),
        _api.getOnlineFriends(),
        _api.getVoiceRooms(),
        _api.getVideoPosts(),
      ]);
      if (!mounted) return;
      setState(() {
        _friendRequests = results[0] as List<SubscriberFriendRequest>;
        _onlineUsers = results[1] as List<SubscriberOnlineFriend>;
        _voiceRooms = results[2] as List<SubscriberVoiceRoom>;
        _livePosts = results[3] as List<CommunityPost>;
      });
    } catch (error) {
      if (!mounted) return;
      setState(
        () => _errorMessage = error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _respondToFriendRequest(
    SubscriberFriendRequest request,
    String action,
  ) async {
    try {
      await _api.respondToFriendRequest(request.id, action);
      await _loadCommunityData();
    } catch (error) {
      Get.snackbar(
        'Friend Request',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _createVoiceRoom() async {
    try {
      await _api.createVoiceRoom();
      await _loadCommunityData();
    } catch (error) {
      Get.snackbar(
        'Voice Room',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _joinVoiceRoom(SubscriberVoiceRoom room) async {
    try {
      await _api.joinVoiceRoom(room.id);
      await _loadCommunityData();
    } catch (error) {
      Get.snackbar(
        'Voice Room',
        error.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildNetworkAvatar(double radius, String? url) {
    final size = radius * 2;
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFE8EAF0),
      child: ClipOval(
        child: url == null || url.isEmpty
            ? SizedBox(width: size, height: size)
            : Image.network(
                url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => SizedBox(width: size, height: size),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: SafeArea(
        child: Stack(
          children: [
            // ─── Main Content ──────────────────────────────────────────
            Column(
              children: [
                _buildHeader(),
                _buildTabBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _errorMessage != null
                      ? Center(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Color(0xFF64748B)),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _selectedTab == 0
                      ? RefreshIndicator(
                          onRefresh: _loadCommunityData,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                _buildFriendRequestsSection(),
                                const SizedBox(height: 28),
                                _buildOnlineNowSection(),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        )
                      : _selectedTab == 1
                      ? _buildVoiceTab()
                      : _buildLiveTab(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Builder(
          //   builder: (context) => GestureDetector(
          //     onTap: () => Scaffold.of(context).openDrawer(),
          //     child: const Icon(Icons.menu, color: Color(0xFF1E293B), size: 24),
          //   ),
          // ),
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
          const SizedBox(width: 24), // balance spacer
        ],
      ),
    );
  }

  // ─── Voice Tab ───────────────────────────────────────────────────────────────

  Widget _buildVoiceTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildPremiumBanner(),
          const SizedBox(height: 8),
          ..._voiceRooms.map(
            (room) => _buildVoiceRoomCard(
              title: room.title,
              hostName: room.hostName,
              hostSubtitle: room.hostSubtitle,
              language: room.language,
              count: room.countLabel,
              isPro: room.isPro,
              hostAvatarUrl: room.hostImageUrl,
              participants: room.participants,
              onJoin: () => _joinVoiceRoom(room),
            ),
          ),

          //const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: ElevatedButton(
              onPressed: _createVoiceRoom,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00A63E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Change radius here
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_add_alt, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Create Voice Rooms',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF655EFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'IMMERSION++ Exclusive',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Update to access premium voice rooms and unlimited hosting',
            style: TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () =>
                Get.to(() => const SubscriberChooseProgramScreen()),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white70),
              foregroundColor: Color(0xFF655EFF),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'Upgrade Now',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceRoomCard({
    required String title,
    required String hostName,
    required String hostSubtitle,
    required String language,
    required String count,
    required bool isPro,
    required String? hostAvatarUrl,
    required List<SubscriberVoiceRoomParticipant> participants,
    required VoidCallback onJoin,
  }) {
    final visibleParticipants = participants.take(3).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room title + PRO badge
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isPro)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFAE00), Color(0xFFDB9600)],
                      begin: AlignmentGeometry.topCenter,
                      end: AlignmentGeometry.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/crown.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'PRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          // Host info
          Row(
            children: [
              _buildNetworkAvatar(22, hostAvatarUrl),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hostName,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    hostSubtitle,
                    style: const TextStyle(
                      color: Color(0xFF8493AC),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Participants avatars
          Row(
            children: [
              // Stacked avatars with mic indicators
              SizedBox(
                height: 62,
                width: visibleParticipants.isEmpty
                    ? 62
                    : 52.0 * visibleParticipants.length + 50,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: List.generate(visibleParticipants.length, (i) {
                    final participant = visibleParticipants[i];
                    return Positioned(
                      left: i * 60.0,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _buildNetworkAvatar(24, participant.imageUrl),
                          Positioned(
                            right: -4,
                            bottom: -4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: participant.isMuted
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF22C55E),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                participant.isMuted ? Icons.mic_off : Icons.mic,
                                size: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 10),
              // +9 overflow
              // Container(
              //   width: 48,
              //   height: 48,
              //   decoration: BoxDecoration(
              //     shape: BoxShape.circle,
              //     border: Border.all(
              //         color: const Color(0xFF4F5CD1), width: 1.5),
              //   ),
              //   alignment: Alignment.center,
              //   child: const Text('+9',
              //       style: TextStyle(
              //           color: Color(0xFF4F5CD1),
              //           fontWeight: FontWeight.bold,
              //           fontSize: 13)),
              // ),
            ],
          ),
          const SizedBox(height: 14),
          // Bottom row: count + language + join
          Row(
            children: [
              const Icon(
                Icons.people_outline,
                size: 16,
                color: Color(0xFF000000),
              ),
              const SizedBox(width: 4),
              Text(
                count,
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xD7252424)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  language,
                  style: const TextStyle(
                    color: Color(0xFF2C3247),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onJoin,
                icon: const Icon(Icons.mic, size: 16, color: Colors.white),
                label: const Text(
                  'Join',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E293B),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFEBEBEB),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE8EAF0)),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color: isSelected
                        ? const Color(0xFF4A82E7)
                        : const Color(0xFF000000),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFriendRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Friend Requests",
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              "${_friendRequests.length}",
              style: const TextStyle(
                color: Color(0xFF516080),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(_friendRequests.length, (index) {
          final request = _friendRequests[index];
          final user = request.requester;
          return _buildFriendRequestCard(
            name: user.fullName,
            lang: user.languageLabel,
            mutual: user.userId,
            avatarUrl: user.profileImageUrl,
            onAccept: () => _respondToFriendRequest(request, 'accept'),
            onDecline: () => _respondToFriendRequest(request, 'reject'),
          );
        }),
      ],
    );
  }

  Widget _buildFriendRequestCard({
    required String name,
    required String lang,
    required String mutual,
    required String? avatarUrl,
    required VoidCallback onAccept,
    required VoidCallback onDecline,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNetworkAvatar(28, avatarUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lang,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
                Text(
                  mutual,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Accept
              SizedBox(
                height: 34,
                width: 96,
                child: ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.check, size: 14, color: Colors.white),
                  label: const Text(
                    "Accept",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Decline
              SizedBox(
                height: 34,
                width: 96,
                child: OutlinedButton.icon(
                  onPressed: onDecline,
                  icon: const Icon(
                    Icons.close,
                    size: 14,
                    color: Color(0xFFEF4444),
                  ),
                  label: const Text(
                    "Decline",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineNowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              "Online Now",
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${_onlineUsers.length} online",
                style: const TextStyle(
                  color: Color(0xFF16A34A),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(_onlineUsers.length, (index) {
          final user = _onlineUsers[index].user;
          return _buildOnlineUserCard(
            name: user.fullName,
            langs: user.shortLanguages,
            location: user.locationLabel,
            avatarUrl: user.profileImageUrl,
          );
        }),
      ],
    );
  }

  Widget _buildOnlineUserCard({
    required String name,
    required String langs,
    required String location,
    required String? avatarUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            children: [
              _buildNetworkAvatar(28, avatarUrl),
              Positioned(
                right: 0,
                bottom: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  langs,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 11,
                  ),
                ),
                Row(
                  children: [
                    const Text(
                      "●Active now",
                      style: TextStyle(
                        color: Color(0xFF22C55E),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      location,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF4F5CD1),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.waving_hand_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Live Tab ────────────────────────────────────────────────────────────────

  Widget _buildLiveTab() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _livePosts.length,
      separatorBuilder: (_, _) => const SizedBox(height: 20),
      itemBuilder: (context, index) {
        final post = _livePosts[index];
        final media = post.primaryMedia;
        return _buildLiveCard(
          title: post.content.isEmpty ? 'Community Live' : post.content,
          hostName: post.authorName,
          thumbnailUrl: media?.url ?? '',
          avatarUrl: post.authorImageUrl,
        );
      },
    );
  }

  Widget _buildLiveCard({
    required String title,
    required String hostName,
    required String thumbnailUrl,
    required String? avatarUrl,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          AspectRatio(
            aspectRatio: 16 / 9,
            child: thumbnailUrl.isEmpty
                ? Container(color: const Color(0xFFE8EAF0))
                : Image.network(
                    thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        Container(color: const Color(0xFFE8EAF0)),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: const Color(0xFFE8EAF0),
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      );
                    },
                  ),
          ),

          // Title row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 4, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.more_vert,
                    color: Color(0xFF1E293B),
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          // Host row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                _buildNetworkAvatar(20, avatarUrl),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hostName,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                // Gift button
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.card_giftcard_outlined,
                    size: 16,
                    color: Color(0xFF1E293B),
                  ),
                  label: const Text(
                    'Gift',
                    style: TextStyle(
                      color: Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
