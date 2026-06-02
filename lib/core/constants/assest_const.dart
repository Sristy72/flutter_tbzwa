class AssetsConstants {
  static Images get images => Images();
  static Icons get icons => Icons();
}

class Images {
  static const String _base = 'assets/images';
  final String logo = '$_base/logo.png';
  final String onboardOne = '$_base/onboard_one.png';
  final String onboardTwo = '$_base/onboard_two.png';
  final String onboardThree = '$_base/onboard_three.png';

  // Profile image update
  final String profileImage = '$_base/image-avater.png';

  // Event image
  final String eventImage = '$_base/events_bg.jpg';
}

class Icons {
  static const String _base = 'assets/icons';

  /// bottom navigation icons [Start]
  final String home = '$_base/home.svg';
  final String userCircle = '$_base/user-circle.svg';
  final String playSquare = '$_base/play-square.svg';
  final String bell = '$_base/bell.svg';
  final String message = '$_base/message.svg';
  final String menu = '$_base/menu.svg';
  final String building = '$_base/building.svg';

  /// bottom navigation icons [End]

  /// Menu screen icons [Start]
  final String darkMode = '$_base/dark-mode.svg';
  final String search = '$_base/search.svg';
  final String settings = '$_base/settings.svg';
  final String adsManager = '$_base/ads_manager.svg';
  final String birthday = '$_base/birthday.svg';
  final String blog = '$_base/blog.svg';
  final String event = '$_base/event.svg';
  final String groups = '$_base/Groups.svg';
  final String jobSearch = '$_base/job_search.svg';
  final String marketplace = '$_base/marketplace.svg';
  final String memories = '$_base/memories.svg';
  final String offers = '$_base/offers.svg';
  final String page = '$_base/page.svg';
  final String pokes = '$_base/pokes.svg';
  final String reels = '$_base/reels.svg';
  final String save = '$_base/save.svg';
  final String spaces = '$_base/spaces.svg';
  final String helpAndCentre = '$_base/help-centre.svg';
  final String settingsPrivate = '$_base/settings-private.svg';
  final String termsPolicies = '$_base/terms-policies.svg';
  final String delete = '$_base/trash.svg';
  final String logOut = '$_base/log-out.svg';

  /// Menu Screen Icons [End]

  /// Home Screen Icons [Start]
  final String plusSquare = '$_base/plus-square.svg';
  final String searchSm = '$_base/search-sm.svg';
  final String postinMsgLogo = '$_base/postin-msg-logo.svg';

  final String smileIcon = '$_base/smile-icon.svg';
  final String gelaryIcon = '$_base/gelary-icon.svg';

  /// Home Screen Icons [End]
  ///

  /// Create Post [Start]
  final String postGelary = '$_base/post-gelary.svg';
  final String postCamera = '$_base/post-camera.svg';
  final String postSteam = '$_base/post-steam.svg';
  final String postEmoji = '$_base/post-emoji.svg';
  final String postWhatsapp = '$_base/post-whatsapp.svg';

  /// Create Post [End]

  /// Group Screen Icons [Start]
  final String groupUserIcon = '$_base/user.svg';
  late final String groupSearch = searchSm;
  late final String groupPlusSquare = plusSquare;

  /// Group Screen Icons [End]
  ///

  /// Message Screen Icons [Start]
  final String cameraMsg = '$_base/camera-msg.svg';
  final String imageMsg = '$_base/image-msg.svg';
  final String microphoneMsg = '$_base/microphone-msg.svg';
  final String thumbsUpMsg = '$_base/thumbs-up-msg.svg';

  /// Message Screen Icons [End]

  /// Conversation Info Screen Icons [Start]
  final String phoneCall = '$_base/phone-call.svg';
  final String videoCall = '$_base/video-call.svg';
  String get profile => userCircle;
  String get mute => bell;

  final String themeIcon = '$_base/theme-icon.svg';
  final String nicknameIcon = '$_base/nickname-icon.svg';

  String get groupIcon => groups;
  final String mediaIcon = '$_base/media-icon.svg';
  String get searchIcon => searchSm;
  String get notification => bell;
  final String blockIcon = '$_base/block-icon.svg';
  final String report = '$_base/report-icon.svg';
  String get deleteIcon => delete;

  /// Conversation Info Screen Icons [End]
}
