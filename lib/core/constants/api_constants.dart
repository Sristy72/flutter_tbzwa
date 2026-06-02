class ApiConstants {
  /// [Base Configuration]
  static const String baseDomain = 'http://10.10.5.48:5006'; // Noyon Office
  // static const String baseDomain = 'http://192.168.10.243:5006'; // Noyon Office Wifi
  // static const String baseDomain = 'http://192.168.0.218:5006'; // Noyon Home

  // static const String baseDomain = 'http://187.77.187.56:5006'; // Office VPS

  static const String baseUrl = '$baseDomain/api/v1';
  static const String graphqlEndpoint = '$baseDomain/graphql';

  /// Dynamically generated WebSocket URL based on baseDomain
  static String get webSocketUrl {
    if (baseDomain.startsWith('https://')) {
      return baseDomain.replaceFirst('https://', 'wss://');
    } else if (baseDomain.startsWith('http://')) {
      return baseDomain.replaceFirst('http://', 'ws://');
    }
    // Fallback for unexpected cases (e.g., no scheme)
    return 'ws://$baseDomain';
  }

  /// [Headers]
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
    // Content-Type will be set automatically for multipart
  };

  /// [Socket Events]
  static SocketEndpoint get socketEvents => SocketEndpoint();

  /// [Endpoint Groups
  static AuthEndpoints get auth => AuthEndpoints();
  static UserEndpoints get user => UserEndpoints();
  static GroupEndpoints get group => GroupEndpoints();
  static CommentEndpoints get comment => CommentEndpoints();
  static PostEndpoints get post => PostEndpoints();
  static FriendEndpoints get friend => FriendEndpoints();
  static NotificationEndpoints get notification => NotificationEndpoints();
  static StoryEndpoints get story => StoryEndpoints();
  static ChatEndpoints get chat => ChatEndpoints();
  static SearchEndpoints get search => SearchEndpoints();
  static PageEndpoints get page => PageEndpoints();
  static EventEndpoints get event => EventEndpoints();
  static MarketplaceEndpoints get marketplace => MarketplaceEndpoints();
  static CollectionEndpoints get collections => CollectionEndpoints();

  /// [Map Configurations]
  static MapConstants get map => MapConstants();
}

class SocketEndpoint {
  final String joinChatRoom = "joinChatRoom";
  final String registerUser = "registerUser";
  final String heartbeat = "heartbeat";

  final String joinPost = "joinPost";
  final String leavePost = "leavePost";

  final String joinConversation = "joinConversation";
  final String joinGroup = "joinGroup";
  final String leaveGroup = "leaveGroup";
  final String joinAlerts = "joinAlerts";

  final String watchPresence = "watchPresence";
  final String unwatchPresence = "unwatchPresence";

  final String notificationNew = "notification:new";
  final String messageNew = "message:new";
  final String conversationUpdated = "conversation:updated";
  final String conversationSeen = "conversation:seen";
  final String conversationTyping = "conversation:typing";
  final String messageDeleted = "message:deleted";
  final String messageUpdated = "message:updated";
  final String messagePinned = "message:pinned";
  final String messageReaction = "message:reaction";
  final String postReaction = "post:reaction";
  final String postComment = "post:comment";
  final String commentReaction = "comment:reaction";
  final String userPresence = "userPresence";

  final String searchUsers = "search_query";
  final String searchUsersResults = "search_results";

  final String searchPageCategories = "search_page_categories";
  final String searchPageCategoriesResults = "search_page_categories_results";

  // Call Signaling
  final String callInitiate = "call:initiate";
  final String callReceive = "call:receive";
  final String callRespond = "call:respond";
  final String callResponse = "call:response";
  final String callJoin = "call:join";
  final String callSignal = "call:signal";
  final String callInvite = "call:invite";
  final String callLeave = "call:leave";
  final String callToggleMedia = "call:toggle-media";
  final String callPeerJoined = "call:peer-joined";
  final String callPeerLeft = "call:peer-left";
  final String callMediaUpdate = "call:media-update";
}

class CommentEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/comments';
  final String comments = _base;

  String postComments(String postId) => '$_base/post/$postId';
  String createComment(String postId) => '$_base/$postId';
  String reactComment(String commentId) => '$_base/react/$commentId';
  String commentReplies(String commentId) => '$_base/$commentId/replies';
  String commentByID(String commentId) => '$_base/$commentId';
}

/// [Authentication Endpoints]
class AuthEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/auth';

  final String login = '$_base/login';
  final String register = '$_base/register';

  // final String forgetPassSendOtp = '$_base/forget';
  // final String verifyOtp = '$_base/verify-otp';
  // final String resetPass = '$_base/reset-password';

  final String changePassword = '$_base/change-password';

  final String refreshToken = '$_base/refresh-token';

  // final String logout = '$_base/logout';
}

class UserEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/users';
  final String users = _base;

  String getProfileByIdOrEmail(String identifier) => '$_base/$identifier';

  // final String updatePersonalInfo = '$_base/update-profile';

  final String profile = '$_base/profile';
  final String deleteAccount = '$_base/delete-account';

  String followUser(String id) => '$_base/follow/$id';
  String unfollowUser(String id) => '$_base/follow/$id';

  /// [Search]
  final String searchUsers = '$_base/search/list';
}

class GroupEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/groups';
  final String root = _base;

  String manageGroup(String groupId) => '$root/$groupId/manage';

  final String discover = _base;

  final String adminMe = '$_base/admin/me';

  String groupByID(String id) => '$_base/$id';

  String joinGroup(String id) => '$_base/$id/join';
  String inviteFriendToGroup(String groupId, String friendId) =>
      '$_base/$groupId/invite/$friendId';
  String cancelGroupInvite(String groupId, String userId) =>
      '$_base/$groupId/invite/$userId/cancel';
  String leaveGroup(String id) => '$_base/$id/leave';
  String approveMember(String groupId, String userId) =>
      '$_base/$groupId/approve/$userId';
  String rejectMember(String groupId, String userId) =>
      '$_base/$groupId/reject/$userId';

  String groupPosts(String groupId) => '$_base/$groupId/posts';

  String groupMediaPhotos(String groupId) => '$_base/$groupId/media/photos';
  String groupMediaVideos(String groupId) => '$_base/$groupId/media/videos';
  String groupAlbumByID(String groupId, String albumId) =>
      '$_base/$groupId/media/albums/$albumId';
  String createGroupAlbum(String groupId) => '$_base/$groupId/media/albums';

  String getGroupMembers(String groupId) => '$_base/$groupId/members';
  String getGroupMembersNotInGroup(String groupId) =>
      '$_base/$groupId/friends-not-in-group';

  String removeMember(String groupId, String memberId) =>
      '$_base/$groupId/members/$memberId';
  String addAdmin(String groupId, String memberId) =>
      '$_base/$groupId/admin/$memberId';

  String togglePinGroupPost(String groupId, String postId) =>
      '$_base/$groupId/posts/$postId/pin';
  String getPinGroupPost(String groupId) => '$_base/$groupId/posts/pinned';
}

class PostEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/posts';
  final String posts = _base;

  String postByID(String id) => '$_base/$id';

  final String feed = '$_base/feed';

  String createPost(String groupId) => '$_base/$groupId';
  String deletePost(String postId) => '$_base/$postId';

  String reactPost(String postId) => '$_base/$postId/react';
  String save(String postId) => '$_base/$postId/save';

  final String allJoinedGroupPost = '$_base/groups/joined';

  String userTimeline(String userId) => '$_base/timeline/$userId';
}

class FriendEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/friends';
  final String root = _base;

  final String getNotFriends = '$_base/non-friends';
  final String getFriendRequests = '$_base/requests';
  String getFriendRequestsWithMode(String mode) => '$_base/requests?mode=$mode';
  final String getFriendSuggestions = '$_base/suggestions';
  final String sendFriendRequest = '$_base/request';
  String respondFriendRequest(String requestId) => '$_base/request/$requestId';
  String cancelFriendRequest(String requestId) =>
      '$_base/request/$requestId/cancel';
  String unfriend(String friendId) => '$_base/$friendId';
}

class NotificationEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/notifications';
  final String root = _base;

  final String readAll = '$_base/read-all';
  String markRead(String id) => '$_base/$id/read';
  String delete(String id) => '$_base/$id';
}

class StoryEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/stories';
  final String root = _base;

  final String getStories = _base;
  final String createStory = _base;
  final String getMyStories = '$_base/me/list';

  String storyByID(String id) => '$_base/$id';
  String viewStory(String id) => '$_base/$id/view';
  String reactStory(String id) => '$_base/$id/react';
  String deleteStory(String id) => '$_base/$id';
}

class ChatEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/messages';
  final String root = _base;
  String conversations = '$_base/conversations';

  String get getMyConversations => conversations;

  String get createDirectConversation => '$conversations/direct';

  String getConversationByID(String conversationId) =>
      '$conversations/$conversationId';

  String sendDirectMessage(String conversationId) =>
      '$conversations/$conversationId/messages';

  String getChatMessages(String conversationId) =>
      '$conversations/$conversationId/messages';

  String reactToMessage(String conversationId, String messageId) =>
      '$conversations/$conversationId/messages/$messageId/react';

  String editMessage(String messageId) => '$_base/$messageId';

  String pinMessage(String conversationId, String messageId) =>
      '$conversations/$conversationId/messages/$messageId/pin';

  String markConversationSeen(String conversationId) =>
      '$conversations/$conversationId/seen';

  String deleteMessage(String messageId) => '$_base/$messageId';

  final String createGroupConversation = '$_base/conversations/group';
}

class SearchEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/search';
  final String globalSearch = _base;

  final String searchUsers = '$_base/users';
}

class PageEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/pages';
  final String root = _base;

  final String myPages = '$_base/my-pages';
  final String liked = '$_base/liked';
  final String discover = '$_base/discover';

  String pageDetails(String id) => '$_base/$id';
  String updatePage(String id) => '$_base/$id';
  String followPage(String id) => '$_base/$id/follow';
  String unfollowPage(String id) => '$_base/$id/follow';
  String pagePosts(String id) => '$_base/$id/posts';
  String createPagePost(String id) => '$_base/$id/posts';
}

class EventEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/events';
  final String root = _base;

  String eventByID(String id) => '$_base/$id';
  String rsvp(String id) => '$_base/$id/rsvp';
  String invite(String id) => '$_base/$id/invite';
}

class MarketplaceEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/marketplace';
  final String root = _base;

  final String meta = '$_base/meta';
  final String listings = '$_base/listings';
  final String myListings = '$_base/my/listings';
  final String savedListings = '$_base/saved/me';
  final String myOffers = '$_base/offers/me';

  String listingDetails(String id) => '$_base/listings/$id';
  String listingStatus(String id) => '$_base/listings/$id/status';
  String saveListing(String id) => '$_base/listings/$id/save';
  String hideListing(String id) => '$_base/listings/$id/hide';
  String reportListing(String id) => '$_base/listings/$id/report';
  String messageSeller(String id) => '$_base/listings/$id/message';
  String listingOffers(String id) => '$_base/listings/$id/offers';
  String respondOffer(String id) => '$_base/offers/$id/respond';
  String cancelOffer(String id) => '$_base/offers/$id/cancel';
  String sellerRatings(String id) => '$_base/ratings/$id';
}

class CollectionEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/collections';
  final String root = _base;
  final String me = '$_base/me';
  String userCollections(String userId) => '$_base/user/$userId';
  String items(String id) => '$_base/$id/items';
  String update(String id) => '$_base/$id';
  String delete(String id) => '$_base/$id';
}

class MapConstants {
  final String osmUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  final String osmAttribution = '© OpenStreetMap contributors';
  final String userAgentPackageName = 'com.karim.app';
}
