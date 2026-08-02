import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_tbzwa/core/utils/app_snackbar.dart';
import 'package:get/get.dart';

import '../models/community_post_model.dart';
import '../services/community_api_service.dart';

class CommunityController extends GetxController {
  final CommunityApiService _api = CommunityApiService();

  final RxString selectedFilter = 'Recent'.obs;
  final RxString searchQuery = ''.obs;
  final RxList<CommunityPost> posts = <CommunityPost>[].obs;
  final RxnString errorMessage = RxnString();
  final RxBool isInitialLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  final RxBool isLocked = false.obs;
  final RxSet<String> likingPostIds = <String>{}.obs;
  final RxSet<String> deletingPostIds = <String>{}.obs;
  final RxList<FriendRequestItem> friendRequests = <FriendRequestItem>[].obs;
  final RxList<FriendRequestItem> sentRequests = <FriendRequestItem>[].obs;
  final RxBool isReceivedRequestsLoading = false.obs;
  final RxBool isSentRequestsLoading = false.obs;
  final RxBool isReceivedRequestsLoadingMore = false.obs;
  final RxBool isSentRequestsLoadingMore = false.obs;
  final RxBool hasMoreReceivedRequests = true.obs;
  final RxBool hasMoreSentRequests = true.obs;
  final RxnString receivedRequestsError = RxnString();
  final RxnString sentRequestsError = RxnString();
  final RxSet<String> handlingFriendRequestIds = <String>{}.obs;

  Timer? _searchDebounce;
  int _page = 1;
  int _totalPages = 1;
  int _receivedRequestsPage = 1;
  int _sentRequestsPage = 1;
  int _requestSerial = 0;
  String? _inFlightKey;
  bool _hasLoadedFeed = false;
  bool _hasLoadedReceivedRequests = false;
  bool _hasLoadedSentRequests = false;

  Future<void> ensureFeedLoaded() async {
    if (_hasLoadedFeed || isInitialLoading.value) return;
    await loadPosts(reset: true);
  }

  Future<void> refreshFeed() async {
    await loadPosts(reset: true, showFullScreenLoading: false);
  }

  Future<void> loadMore() async {
    if (!hasMore.value || isLoadingMore.value || isInitialLoading.value) return;
    await loadPosts(reset: false);
  }

  Future<void> loadPosts({
    required bool reset,
    bool showFullScreenLoading = true,
  }) async {
    final nextPage = reset ? 1 : _page + 1;
    final requestKey =
        '${_apiFilter(selectedFilter.value)}|'
        '${searchQuery.value.trim()}|$nextPage';
    if (_inFlightKey == requestKey) return;

    final serial = ++_requestSerial;
    _inFlightKey = requestKey;
    if (reset) {
      errorMessage.value = null;
      if (showFullScreenLoading && posts.isEmpty) {
        isInitialLoading.value = true;
      } else {
        isRefreshing.value = true;
      }
    } else {
      isLoadingMore.value = true;
    }

    try {
      final result = await _api.getCommunityFeed(
        filter: _apiFilter(selectedFilter.value),
        search: searchQuery.value,
        page: nextPage,
      );
      if (serial != _requestSerial) return;

      isLocked.value = result.isLocked;
      _page = result.page;
      _totalPages = max(1, result.totalPages);
      hasMore.value = _page < _totalPages;
      _hasLoadedFeed = true;

      if (reset) {
        posts.assignAll(_dedupe(result.posts));
      } else {
        final existingIds = posts.map((post) => post.id).toSet();
        posts.addAll(
          result.posts.where((post) => !existingIds.contains(post.id)),
        );
      }
    } catch (error) {
      if (serial != _requestSerial) return;
      final message = _cleanError(error);
      if (reset && posts.isEmpty) {
        errorMessage.value = message;
      } else {
        AppSnackbar.error('Community', message);
      }
    } finally {
      if (_inFlightKey == requestKey) _inFlightKey = null;
      if (serial == _requestSerial) {
        isInitialLoading.value = false;
        isRefreshing.value = false;
        isLoadingMore.value = false;
      }
    }
  }

  void setFilter(String filter) {
    if (selectedFilter.value == filter) return;
    selectedFilter.value = filter;
    loadPosts(reset: true);
  }

  void setSearchQuery(String query) {
    final normalized = query.trim();
    if (searchQuery.value == normalized) return;
    searchQuery.value = normalized;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      loadPosts(reset: true);
    });
  }

  void insertOrUpdatePost(CommunityPost post) {
    final index = posts.indexWhere((item) => item.id == post.id);
    if (index == -1) {
      posts.insert(0, post);
    } else {
      posts[index] = post;
    }
  }

  Future<void> toggleLike(CommunityPost post) async {
    if (likingPostIds.contains(post.id)) return;
    final index = posts.indexWhere((item) => item.id == post.id);
    if (index == -1) return;

    likingPostIds.add(post.id);
    final original = posts[index];
    final nextLiked = !original.isLiked;
    posts[index] = original.copyWith(
      isLiked: nextLiked,
      likesCount: max(0, original.likesCount + (nextLiked ? 1 : -1)),
    );

    try {
      final result = await _api.toggleLike(post.id);
      final currentIndex = posts.indexWhere((item) => item.id == post.id);
      if (currentIndex != -1) {
        posts[currentIndex] = posts[currentIndex].copyWith(
          isLiked: result.liked,
          likesCount: max(0, result.likesCount),
        );
      }
    } catch (error) {
      final currentIndex = posts.indexWhere((item) => item.id == post.id);
      if (currentIndex != -1) posts[currentIndex] = original;
      AppSnackbar.error('Like', error);
    } finally {
      likingPostIds.remove(post.id);
    }
  }

  Future<void> deletePost(CommunityPost post) async {
    if (!post.isOwner || deletingPostIds.contains(post.id)) return;
    deletingPostIds.add(post.id);
    try {
      await _api.deletePost(post.id);
      posts.removeWhere((item) => item.id == post.id);
      AppSnackbar.success('Community', 'Post deleted.');
    } catch (error) {
      AppSnackbar.error('Delete Post', error);
    } finally {
      deletingPostIds.remove(post.id);
    }
  }

  Future<CommunityCommentPage> loadComments({
    required String postId,
    int page = 1,
  }) {
    return _api.getComments(postId: postId, page: page);
  }

  Future<CommunityComment> addComment({
    required String postId,
    required String content,
  }) async {
    final comment = await _api.addComment(postId: postId, content: content);
    final index = posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      posts[index] = posts[index].copyWith(
        commentsCount: posts[index].commentsCount + 1,
      );
    }
    return comment;
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    await _api.deleteComment(postId: postId, commentId: commentId);
    final index = posts.indexWhere((post) => post.id == postId);
    if (index != -1) {
      posts[index] = posts[index].copyWith(
        commentsCount: max(0, posts[index].commentsCount - 1),
      );
    }
  }

  Future<void> sharePost(CommunityPost post) async {
    await Clipboard.setData(ClipboardData(text: _api.shareText(post)));
    AppSnackbar.info('Share', 'Post link copied.');
  }

  Future<PublicProfileResult> getPublicProfile({
    required String userId,
    int page = 1,
    int limit = 10,
  }) {
    return _api.getPublicProfile(userId: userId, page: page, limit: limit);
  }

  Future<FriendshipStatus> sendFriendRequestTo(String userId) {
    return _api.sendFriendRequest(userId);
  }

  Future<FriendshipStatus> respondFriendRequestById({
    required String requestId,
    required String action,
  }) {
    return _api.respondFriendRequest(requestId: requestId, action: action);
  }

  Future<void> removeFriendship(String friendshipId) {
    return _api.removeFriend(friendshipId);
  }

  String _apiFilter(String filter) {
    switch (filter) {
      case 'Image':
        return 'image';
      case 'Voice':
        return 'voice';
      case 'Video':
        return 'video';
      default:
        return 'recent';
    }
  }

  List<CommunityPost> _dedupe(List<CommunityPost> incoming) {
    final seen = <String>{};
    return incoming.where((post) => seen.add(post.id)).toList();
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  Future<void> ensureFriendRequestsLoaded({bool includeSent = false}) async {
    final loads = <Future<void>>[];
    if (!_hasLoadedReceivedRequests && !isReceivedRequestsLoading.value) {
      loads.add(
        loadFriendRequests(mode: FriendRequestMode.received, reset: true),
      );
    }
    if (includeSent &&
        !_hasLoadedSentRequests &&
        !isSentRequestsLoading.value) {
      loads.add(loadFriendRequests(mode: FriendRequestMode.sent, reset: true));
    }
    if (loads.isEmpty) return;
    await Future.wait(loads);
  }

  Future<void> refreshFriendRequests({FriendRequestMode? mode}) async {
    if (mode == null) {
      await Future.wait([
        loadFriendRequests(mode: FriendRequestMode.received, reset: true),
        loadFriendRequests(mode: FriendRequestMode.sent, reset: true),
      ]);
      return;
    }
    await loadFriendRequests(mode: mode, reset: true);
  }

  Future<void> loadMoreFriendRequests(FriendRequestMode mode) async {
    if (mode == FriendRequestMode.sent) {
      if (!hasMoreSentRequests.value || isSentRequestsLoadingMore.value) return;
    } else {
      if (!hasMoreReceivedRequests.value ||
          isReceivedRequestsLoadingMore.value) {
        return;
      }
    }
    await loadFriendRequests(mode: mode, reset: false);
  }

  Future<void> loadFriendRequests({
    required FriendRequestMode mode,
    required bool reset,
  }) async {
    final list = _requestList(mode);
    final loading = _requestLoading(mode);
    final loadingMore = _requestLoadingMore(mode);
    final error = _requestError(mode);
    final nextPage = reset ? 1 : _requestPage(mode) + 1;

    if (reset) {
      error.value = null;
      if (list.isEmpty) loading.value = true;
    } else {
      loadingMore.value = true;
    }

    try {
      final result = await _api.getFriendRequests(mode: mode, page: nextPage);
      _setRequestPage(mode, result.page);
      _requestHasMore(mode).value = result.page < result.totalPages;
      _setHasLoadedRequests(mode, true);

      if (reset) {
        list.assignAll(_dedupeRequests(result.requests));
      } else {
        final existingIds = list.map((request) => request.id).toSet();
        list.addAll(
          result.requests.where((request) => !existingIds.contains(request.id)),
        );
      }
    } catch (err) {
      final message = _cleanError(err);
      if (reset && list.isEmpty) {
        error.value = message;
      } else {
        AppSnackbar.error('Friend Requests', message);
      }
    } finally {
      loading.value = false;
      loadingMore.value = false;
    }
  }

  Future<void> acceptRequest(FriendRequestItem request) async {
    await _handleReceivedRequest(request, 'accept');
  }

  Future<void> declineRequest(FriendRequestItem request) async {
    await _handleReceivedRequest(request, 'decline');
  }

  Future<void> _handleReceivedRequest(
    FriendRequestItem request,
    String action,
  ) async {
    if (handlingFriendRequestIds.contains(request.id)) return;
    final index = friendRequests.indexWhere((item) => item.id == request.id);
    if (index == -1) return;

    handlingFriendRequestIds.add(request.id);
    final removed = friendRequests.removeAt(index);
    try {
      await _api.respondFriendRequest(requestId: request.id, action: action);
      if (action == 'accept') {
        AppSnackbar.success('Friend Requests', 'Friend request accepted.');
      } else {
        AppSnackbar.info('Friend Requests', 'Friend request declined.');
      }
    } catch (err) {
      if (!friendRequests.any((item) => item.id == removed.id)) {
        final restoreIndex = index > friendRequests.length
            ? friendRequests.length
            : index;
        friendRequests.insert(restoreIndex, removed);
      }
      AppSnackbar.error('Friend Requests', err);
    } finally {
      handlingFriendRequestIds.remove(request.id);
    }
  }

  RxList<FriendRequestItem> _requestList(FriendRequestMode mode) =>
      mode == FriendRequestMode.sent ? sentRequests : friendRequests;

  RxBool _requestLoading(FriendRequestMode mode) =>
      mode == FriendRequestMode.sent
      ? isSentRequestsLoading
      : isReceivedRequestsLoading;

  RxBool _requestLoadingMore(FriendRequestMode mode) =>
      mode == FriendRequestMode.sent
      ? isSentRequestsLoadingMore
      : isReceivedRequestsLoadingMore;

  RxBool _requestHasMore(FriendRequestMode mode) =>
      mode == FriendRequestMode.sent
      ? hasMoreSentRequests
      : hasMoreReceivedRequests;

  RxnString _requestError(FriendRequestMode mode) =>
      mode == FriendRequestMode.sent
      ? sentRequestsError
      : receivedRequestsError;

  int _requestPage(FriendRequestMode mode) => mode == FriendRequestMode.sent
      ? _sentRequestsPage
      : _receivedRequestsPage;

  void _setRequestPage(FriendRequestMode mode, int page) {
    if (mode == FriendRequestMode.sent) {
      _sentRequestsPage = page;
    } else {
      _receivedRequestsPage = page;
    }
  }

  void _setHasLoadedRequests(FriendRequestMode mode, bool value) {
    if (mode == FriendRequestMode.sent) {
      _hasLoadedSentRequests = value;
    } else {
      _hasLoadedReceivedRequests = value;
    }
  }

  List<FriendRequestItem> _dedupeRequests(List<FriendRequestItem> incoming) {
    final seen = <String>{};
    return incoming.where((request) => seen.add(request.id)).toList();
  }
}
