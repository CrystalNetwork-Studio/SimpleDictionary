import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Utility class for cross-platform storage access
/// with special handling for Android Storage Access Framework (SAF)
class PlatformStorageAccess {
  static const MethodChannel _channel =
      MethodChannel('dev.crystalnetwork.mobile.simpledictionary/storage');

  /// Determines if the current platform is Android
  static bool get isAndroid => Platform.isAndroid;

  /// Determines if the platform is likely Android 11 or newer
  static Future<bool> get isAndroid11Plus async {
    if (!isAndroid) return false;

    try {
      final int sdkInt = await _getSdkVersion();
      return sdkInt >= 30; // Android 11 is API 30
    } catch (e) {
      debugPrint('Error checking Android SDK version: $e');
      // Assume modern Android as a fallback
      return true;
    }
  }

  /// Opens a document picker for reading a file
  /// Allows choosing files from any location accessible via SAF document providers.
  static Future<String?> openDocumentForRead({
    List<String> mimeTypes = const ['application/json'],
  }) async {
    if (!isAndroid) return null;

    try {
      final result =
          await _channel.invokeMethod<String>('openDocumentForRead', {
        'mimeTypes': mimeTypes,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error opening document for reading: ${e.message}');
      return null;
    }
  }

  /// Creates a new document for writing
  /// Allows choosing a location to save the file via SAF document providers.
  /// This inherently allows selecting any accessible folder via the system picker.
  static Future<String?> createDocumentForWrite({
    required String fileName,
    String mimeType = 'application/json',
  }) async {
    if (!isAndroid) return null;

    try {
      final result =
          await _channel.invokeMethod<String>('createDocumentForWrite', {
        'fileName': fileName,
        'mimeType': mimeType,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error creating document for writing: ${e.message}');
      return null;
    }
  }

  /// Reads content from a content URI
  static Future<String?> readFromUri(String uri) async {
    if (!isAndroid) return null;

    try {
      final result = await _channel.invokeMethod<String>('readFromUri', {
        'uri': uri,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('Error reading from URI: ${e.message}');
      return null;
    }
  }

  /// Writes content to a content URI
  static Future<bool> writeToUri(String uri, String content) async {
    if (!isAndroid) return false;

    try {
      final result = await _channel.invokeMethod<bool>('writeToUri', {
        'uri': uri,
        'content': content,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error writing to URI: ${e.message}');
      return false;
    }
  }

  /// Checks if the app has storage permission
  static Future<bool> checkStoragePermission() async {
    // SAF operations typically don't require storage permissions (READ_EXTERNAL_STORAGE, WRITE_EXTERNAL_STORAGE)
    // as they work through the system's document provider permissions granted via URIs.
    // However, native implementation might still check/request depending on underlying implementation details
    // or if non-SAF methods are also used. Keep existing check for robustness.
    if (!isAndroid) return true;

    try {
      final result = await _channel.invokeMethod<bool>('checkPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error checking storage permission: ${e.message}');
      return false;
    }
  }

  /// Requests storage permission if needed
  static Future<bool> requestStoragePermission() async {
    // See comment in checkStoragePermission regarding SAF and permissions.
    if (!isAndroid) return true;

    try {
      final result = await _channel.invokeMethod<bool>('requestPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Error requesting storage permission: ${e.message}');
      return false;
    }
  }

  /// Gets the Android SDK version
  static Future<int> _getSdkVersion() async {
    try {
      final result = await _channel.invokeMethod<int>('getSdkVersion');
      return result ?? 0;
    } on PlatformException catch (e) {
      debugPrint('Error getting SDK version: ${e.message}');
      return 0;
    }
  }

  /// Helper method to check if a path is a content URI
  static bool isContentUri(String? path) {
    return path != null && path.startsWith('content://');
  }
}
