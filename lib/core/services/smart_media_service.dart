import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/app_snackbar.dart';

class LocationResult {
  final String displayName;
  final double lat;
  final double lon;

  LocationResult({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory LocationResult.fromJson(Map<String, dynamic> json) {
    return LocationResult(
      displayName: json['display_name'] ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0,
      lon: double.tryParse(json['lon']?.toString() ?? '0') ?? 0,
    );
  }
}

class SmartMediaService extends GetxService {
  final ImagePicker _imagePicker = ImagePicker();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// [Pick Single Image]
  /// Handles permissions smartly based on source (Camera/Gallery)
  Future<XFile?> pickImage({required ImageSource source}) async {
    if (source == ImageSource.gallery) {
      try {
        return await _imagePicker.pickImage(source: source, imageQuality: 70);
      } catch (e) {
        debugPrint("Error picking image: $e");
        _showErrorSnackbar("Failed to pick image");
        return null;
      }
    }

    final permission = source == ImageSource.camera
        ? Permission.camera
        : await _getGalleryPermission();

    if (await _handlePermission(
      permission,
      source == ImageSource.camera ? "Camera" : "Gallery",
    )) {
      try {
        return await _imagePicker.pickImage(source: source, imageQuality: 70);
      } catch (e) {
        debugPrint("Error picking image: $e");
        _showErrorSnackbar("Failed to pick image");
      }
    }
    return null;
  }

  /// [Pick Multiple Images]
  /// Gallery only
  Future<List<XFile>?> pickMultipleImages() async {
    try {
      return await _imagePicker.pickMultiImage(imageQuality: 70);
    } catch (e) {
      debugPrint("Error picking multiple images: $e");
      _showErrorSnackbar("Failed to pick images");
    }
    return null;
  }

  /// [Pick Single Video]
  Future<XFile?> pickVideo({required ImageSource source}) async {
    // Camera video needs microphone too
    if (source == ImageSource.camera) {
      if (!await _handlePermission(Permission.camera, "Camera") ||
          !await _handlePermission(Permission.microphone, "Microphone")) {
        return null;
      }
    } else {
      try {
        return await _imagePicker.pickVideo(source: source);
      } catch (e) {
        debugPrint("Error picking video: $e");
        _showErrorSnackbar("Failed to pick video");
      }
      return null;
    }

    try {
      return await _imagePicker.pickVideo(source: source);
    } catch (e) {
      debugPrint("Error picking video: $e");
      _showErrorSnackbar("Failed to pick video");
    }
    return null;
  }

  /// [Pick Any Files]
  Future<List<File>?> pickFiles({
    List<String>? allowedExtensions,
    bool allowMultiple = false,
    FileType type = FileType.any,
  }) async {
    final permission = await _getGalleryPermission();
    if (!await _handlePermission(permission, "Files")) return null;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : type,
        allowedExtensions: allowedExtensions,
        allowMultiple: allowMultiple,
      );

      if (result != null) {
        return result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();
      }
    } catch (e) {
      debugPrint("Error picking files: $e");
      _showErrorSnackbar("Failed to pick files");
    }
    return null;
  }

  /// [Get Current Location]
  /// Returns Position? after handling permissions
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showErrorSnackbar("Location services are disabled.");
      return null;
    }

    if (await _handlePermission(Permission.locationWhenInUse, "Location")) {
      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
          ),
        );
      } catch (e) {
        debugPrint("Error getting location: $e");
        _showErrorSnackbar("Failed to get current location");
      }
    }
    return null;
  }

  /// [Internal: Handles permission logic and UI feedback]
  Future<bool> _handlePermission(Permission permission, String label) async {
    PermissionStatus status = await permission.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      status = await permission.request();
      if (status.isGranted) return true;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog(label);
      return false;
    }

    return false;
  }

  /// Determines the correct gallery/storage permission based on Android version
  Future<Permission> _getGalleryPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 33) {
        return Permission.photos;
      }
    }
    return Permission.storage;
  }

  void _showPermissionDialog(String label) {
    Get.dialog(
      AlertDialog(
        title: Text("$label Permission Required"),
        content: Text(
          "We need $label permission to select media. Please enable it in app settings.",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              openAppSettings();
              Get.back();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    AppSnackbar.error("Error", message);
  }
}
