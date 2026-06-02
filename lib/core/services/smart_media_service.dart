// import 'dart:io';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:dio/dio.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:flutx_core/flutx_core.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:permission_handler/permission_handler.dart';


// class SmartMediaService extends GetxService {
//   final ImagePicker _imagePicker = ImagePicker();
//   final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
//   final Dio _dio = Dio(BaseOptions(
//     headers: {
//       'User-Agent': 'KarimApp/1.0',
//     },
//   ));

//   /// [Pick Single Image]
//   /// Handles permissions smartly based on source (Camera/Gallery)
//   Future<XFile?> pickImage({required ImageSource source}) async {
//     final permission = source == ImageSource.camera
//         ? Permission.camera
//         : await _getGalleryPermission();

//     if (await _handlePermission(
//       permission,
//       source == ImageSource.camera ? "Camera" : "Gallery",
//     )) {
//       try {
//         return await _imagePicker.pickImage(source: source, imageQuality: 70);
//       } catch (e) {
//         DPrint.error("Error picking image: $e");
//         _showErrorSnackbar("Failed to pick image");
//       }
//     }
//     return null;
//   }

//   /// [Pick Multiple Images]
//   /// Gallery only
//   Future<List<XFile>?> pickMultipleImages() async {
//     final permission = await _getGalleryPermission();

//     if (await _handlePermission(permission, "Gallery")) {
//       try {
//         return await _imagePicker.pickMultiImage(imageQuality: 70);
//       } catch (e) {
//         DPrint.error("Error picking multiple images: $e");
//         _showErrorSnackbar("Failed to pick images");
//       }
//     }
//     return null;
//   }

//   /// [Pick Single Video]
//   Future<XFile?> pickVideo({required ImageSource source}) async {
//     // Camera video needs microphone too
//     if (source == ImageSource.camera) {
//       if (!await _handlePermission(Permission.camera, "Camera") ||
//           !await _handlePermission(Permission.microphone, "Microphone")) {
//         return null;
//       }
//     } else {
//       final permission = await _getGalleryPermission();
//       if (!await _handlePermission(permission, "Gallery")) return null;
//     }

//     try {
//       return await _imagePicker.pickVideo(source: source);
//     } catch (e) {
//       DPrint.error("Error picking video: $e");
//       _showErrorSnackbar("Failed to pick video");
//     }
//     return null;
//   }

//   /// [Pick Any Files]
//   Future<List<File>?> pickFiles({
//     List<String>? allowedExtensions,
//     bool allowMultiple = false,
//   }) async {
//     // File picker on Android 11+ doesn't always need storage permission for some scopes,
//     // but requesting storage/photos is safer for broader access.
//     final permission = await _getGalleryPermission();
//     if (!await _handlePermission(permission, "Files")) return null;

//     try {
//       FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: allowedExtensions != null ? FileType.custom : FileType.any,
//         allowedExtensions: allowedExtensions,
//         allowMultiple: allowMultiple,
//       );

//       if (result != null) {
//         return result.paths
//             .where((path) => path != null)
//             .map((path) => File(path!))
//             .toList();
//       }
//     } catch (e) {
//       DPrint.error("Error picking files: $e");
//       _showErrorSnackbar("Failed to pick files");
//     }
//     return null;
//   }

//   /// [Get Current Location]
//   /// Returns Position? after handling permissions
//   Future<Position?> getCurrentLocation() async {
//     // 1. Check if location services are enabled
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       _showErrorSnackbar("Location services are disabled.");
//       return null;
//     }

//     // 2. Handle permissions
//     if (await _handlePermission(Permission.locationWhenInUse, "Location")) {
//       try {
//         return await Geolocator.getCurrentPosition(
//           locationSettings: const LocationSettings(
//             accuracy: LocationAccuracy.high,
//           ),
//         );
//       } catch (e) {
//         DPrint.error("Error getting location: $e");
//         _showErrorSnackbar("Failed to get current location");
//       }
//     }
//     return null;
//   }

//   /// [Search Locations using Nominatim]
//   Future<List<LocationResult>> searchLocations(String query) async {
//     if (query.isEmpty) return [];

//     try {
//       final response = await _dio.get(
//         'https://nominatim.openstreetmap.org/search',
//         queryParameters: {
//           'q': query,
//           'format': 'jsonv2',
//           'limit': 5,
//           'addressdetails': 1,
//         },
//       );

//       if (response.data is List) {
//         return (response.data as List)
//             .map((json) => LocationResult.fromJson(json))
//             .toList();
//       }
//     } catch (e) {
//       DPrint.error("Error searching locations: $e");
//     }
//     return [];
//   }

//   /// [Reverse Geocode using Nominatim]
//   Future<LocationResult?> reverseGeocode(double lat, double lng) async {
//     try {
//       final response = await _dio.get(
//         'https://nominatim.openstreetmap.org/reverse',
//         queryParameters: {
//           'lat': lat,
//           'lon': lng,
//           'format': 'jsonv2',
//           'addressdetails': 1,
//         },
//       );

//       if (response.data != null && response.data is Map) {
//         return LocationResult.fromJson(response.data as Map<String, dynamic>);
//       }
//     } catch (e) {
//       DPrint.error("Error in reverse geocoding: $e");
//     }
//     return null;
//   }

//   /// Internal: Handles permission logic and UI feedback
//   Future<bool> _handlePermission(Permission permission, String label) async {
//     PermissionStatus status = await permission.status;

//     if (status.isGranted) return true;

//     if (status.isDenied) {
//       status = await permission.request();
//       if (status.isGranted) return true;
//     }

//     if (status.isPermanentlyDenied) {
//       _showPermissionDialog(label);
//       return false;
//     }

//     return false;
//   }

//   /// Determines the correct gallery/storage permission based on Android version
//   Future<Permission> _getGalleryPermission() async {
//     if (Platform.isAndroid) {
//       final androidInfo = await _deviceInfo.androidInfo;
//       if (androidInfo.version.sdkInt >= 33) {
//         // Android 13+ uses specific permissions
//         return Permission.photos;
//       }
//     }
//     return Permission.storage;
//   }

//   void _showPermissionDialog(String label) {
//     Get.dialog(
//       AlertDialog(
//         title: Text("$label Permission Required"),
//         content: Text(
//           "We need $label permission to select media. Please enable it in app settings.",
//         ),
//         actions: [
//           TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
//           TextButton(
//             onPressed: () {
//               openAppSettings();
//               Get.back();
//             },
//             child: const Text("Open Settings"),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showErrorSnackbar(String message) {
//     Get.snackbar(
//       "Error",
//       message,
//       snackPosition: SnackPosition.BOTTOM,
//       backgroundColor: Colors.red.withValues(alpha: 0.8),
//       colorText: Colors.white,
//     );
//   }
// }
