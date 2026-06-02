import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutx_core/core/debug_print.dart';

class MediaCacheService {
  // Singleton instance
  static final MediaCacheService _instance = MediaCacheService._internal();
  factory MediaCacheService() => _instance;
  MediaCacheService._internal();

  /// Specifically configured CacheManager for Images
  /// Keeps up to 200 images, extending cache duration to 7 days.
  static final CacheManager imageCacheManager = CacheManager(
    Config(
      'app_image_cache',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 200,
      fileSystem: IOFileSystem('app_image_cache'),
    ),
  );

  /// Specifically configured CacheManager for Videos
  /// Videos are large, so we keep fewer of them (e.g., 15) and for a shorter time (e.g., 3 days).
  static final CacheManager videoCacheManager = CacheManager(
    Config(
      'app_video_cache',
      stalePeriod: const Duration(days: 3),
      maxNrOfCacheObjects: 15,
    ),
  );

  /// Helper to completely clear all media caches
  Future<void> clearAllMediaCache() async {
    try {
      await imageCacheManager.emptyCache();
      await videoCacheManager.emptyCache();
      DPrint.info("Cleared all media caches (Images & Videos)");
    } catch (e) {
      DPrint.error("Failed to clear media cache: $e");
    }
  }

  /// Prefetch a single video into the cache in the background
  Future<void> preCacheVideo(String url) async {
    try {
      if (url.isEmpty) return;
      // downloadFile starts the download in the background if not already cached
      videoCacheManager.downloadFile(url);
    } catch (e) {
      DPrint.error("Failed to pre-cache video: $url -> $e");
    }
  }

  /// Batch pre-fetch videos
  void preCacheVideos(List<String> urls) {
    for (final url in urls) {
      preCacheVideo(url);
    }
  }
}
