import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../data/dictionary.dart';

/// Helper class for Android storage operations, specifically addressing
/// Android 11+ scoped storage restrictions.
class AndroidStorageHelper {
  /// Determines if the device is likely running Android 11 or higher
  /// based on the SDK version.
  static bool get isRunningAndroid11Plus {
    try {
      // Get platform version if available
      final String platform = defaultTargetPlatform.toString();
      if (platform.toLowerCase().contains('android')) {
        // Android-specific detection logic could go here if we had access to the SDK version
        // For now, we'll assume modern Android API levels
        return true;
      }
    } catch (e) {
      debugPrint('Error detecting Android version: $e');
    }
    return false;
  }

  /// Gets the app's documents directory (accessible in scoped storage)
  static Future<Directory> getAccessibleDocsDir() async {
    final appDocsDir = await getApplicationDocumentsDirectory();
    return appDocsDir;
  }

  /// Gets a temporary directory that's accessible in scoped storage
  static Future<Directory> getAccessibleTempDir() async {
    final tempDir = await getTemporaryDirectory();
    return tempDir;
  }

  /// Returns guidance for users about Android 11+ storage restrictions
  static List<String> getAndroidStorageGuidance() {
    return [
      'On Android 11+, storage access is restricted for security reasons.',
      'Use the system file picker to select where to save or load files.',
      'You can choose any folder accessible by the picker, including Downloads, Documents, or external storage.',
      'Using the device\'s default file manager app within the picker might improve access.',
    ];
  }

  /// Checks if a path appears to be a content URI (Android SAF)
  static bool isContentUri(String path) {
    return path.startsWith('content://');
  }

  /// Picks a file for importing, allowing selection from any folder.
  /// Uses Storage Access Framework for Android 11+ compatibility.
  ///
  /// Returns a [FilePickerResult] containing the selected file information.
  static Future<FilePickerResult?> pickDictionaryFile({
    required String dialogTitle,
  }) async {
    FilePickerResult? result;

    try {
      // Use FilePicker to access Storage Access Framework.
      // FileType.any allows selecting any file type from any folder accessible by the system picker.
      result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Changed from FileType.custom/fallback
        // Removed allowedExtensions to allow any file type
        dialogTitle: dialogTitle,
        withData: true, // Critical for Android 11+ to get file bytes
        // Removed allowCompression as it's deprecated and has no effect
        lockParentWindow: true,
      );
    } catch (e) {
      debugPrint('File picker failed: $e');
      rethrow; // Rethrow the error if picking fails
    }

    return result;
  }

  /// Attempts to read a dictionary from raw bytes.
  /// This is the most reliable method on Android 11+ with content URIs.
  static Future<Dictionary?> readDictionaryFromBytes(Uint8List bytes) async {
    if (bytes.isEmpty) {
      throw const FormatException('Empty file or no data received');
    }

    try {
      // Handle BOM (Byte Order Mark) if present
      int startIndex = 0;
      if (bytes.length >= 3 &&
          bytes[0] == 0xEF &&
          bytes[1] == 0xBB &&
          bytes[2] == 0xBF) {
        startIndex = 3; // Skip UTF-8 BOM
        debugPrint('UTF-8 BOM detected and skipped');
      }

      // Try multiple decoding strategies
      String jsonString;
      try {
        jsonString = utf8.decode(bytes.sublist(startIndex));
      } catch (e) {
        debugPrint('UTF-8 decoding failed, trying Latin-1: $e');
        try {
          jsonString = String.fromCharCodes(bytes.sublist(startIndex));
        } catch (charError) {
          debugPrint('Latin-1 decoding also failed: $charError');
          final cleanedBytes = bytes.where((b) => b > 0).toList();
          if (cleanedBytes.length < bytes.length * 0.8) {
            throw FormatException(
                'File appears to be corrupted (${cleanedBytes.length}/${bytes.length} valid bytes)');
          }
          jsonString = String.fromCharCodes(cleanedBytes);
        }
      }

      // Clean and validate JSON
      final trimmedJson = jsonString.trim();
      if (trimmedJson.isEmpty) {
        throw const FormatException('File is empty');
      }

      if (!(trimmedJson.startsWith('{') && trimmedJson.endsWith('}'))) {
        throw const FormatException(
            'File doesn\'t contain valid JSON data. Make sure it\'s a dictionary export file');
      }

      // Parse JSON data
      Map<String, dynamic> jsonMap;
      try {
        jsonMap = jsonDecode(trimmedJson) as Map<String, dynamic>;
      } catch (jsonError) {
        debugPrint('JSON decode error: $jsonError');
        final cleanedJson =
            trimmedJson.replaceAll(RegExp(r'[^\x20-\x7E,:{}\[\]"0-9.\-+]'), '');
        try {
          jsonMap = jsonDecode(cleanedJson) as Map<String, dynamic>;
        } catch (e) {
          throw FormatException('Invalid JSON format: ${e.toString()}');
        }
      }

      // Validate dictionary structure
      if (!jsonMap.containsKey('name')) {
        throw const FormatException(
            'Invalid dictionary file - missing "name" field');
      }

      // Handle older dictionary formats
      if (!jsonMap.containsKey('type')) {
        jsonMap['type'] = 'word'; // Default type
      }

      // Validate name
      final name = jsonMap['name'];
      if (name == null || (name is String && name.trim().isEmpty)) {
        throw const FormatException('Dictionary name cannot be empty');
      }

      // Ensure words array exists
      if (!jsonMap.containsKey('words')) {
        jsonMap['words'] = <dynamic>[];
      } else if (jsonMap['words'] is! List) {
        jsonMap['words'] = <dynamic>[];
      }

      // Create dictionary object
      final dictionary = Dictionary.fromJson(jsonMap);
      return dictionary;
    } on FormatException catch (e) {
      debugPrint('Format error reading dictionary: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error reading dictionary from bytes: $e');
      return null;
    }
  }

  /// Saves a dictionary to a JSON file, handling both regular paths and content URIs.
  /// Uses Storage Access Framework for Android 11+ compatibility, allowing
  /// selection of any folder accessible by the system file picker.
  ///
  /// Returns the path where the file was saved (may be a content URI).
  static Future<String> saveDictionaryToExternalFile({
    required Dictionary dictionary,
    required String suggestedFilename,
    required String dialogTitle,
  }) async {
    try {
      // Sanitize filename
      final sanitizedName =
          suggestedFilename.replaceAll(RegExp(r'[\/\\:*?"<>|]'), '_');

      // Create JSON data
      final jsonMap = dictionary.toJson();
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonMap);
      final Uint8List fileBytes = utf8.encode(jsonString);

      // Use FilePicker.saveFile to access Storage Access Framework on Android
      // This allows the user to choose any directory they have access to.
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: dialogTitle,
        fileName: sanitizedName,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: fileBytes, // Provide bytes for direct writing via SAF
        lockParentWindow: true,
      );

      if (outputFile == null) {
        // User cancelled the picker
        throw Exception('File selection cancelled');
      }

      // On Android 11+, FilePicker.saveFile with the `bytes` parameter handles
      // writing the data directly to the selected URI. The returned `outputFile`
      // is typically a content URI.
      // For non-content URIs (like older Android versions or other platforms),
      // the plugin might return a direct file path, and the direct write below
      // serves as a backup or standard behavior.
      if (!outputFile.startsWith('content://')) {
        try {
          final file = File(outputFile);
          // Only write if the file doesn't already exist or if bytes wasn't used,
          // but with bytes parameter, the plugin should handle it.
          // This block might be redundant if bytes param is always used.
          // Keeping it as a safeguard for unexpected behavior.
          if (!await file.exists() || fileBytes.isEmpty) {
            // Basic check
            await file.writeAsBytes(fileBytes, flush: true);
          } else {
            // Assuming bytes were written by the plugin if outputFile is not content://
            debugPrint('Note: FilePicker plugin likely wrote bytes directly.');
          }
        } catch (e) {
          debugPrint(
              'Note: Direct file write error after FilePicker.saveFile: $e');
          // This might happen if saveFile returns a path but failed to write bytes
          // or if the path is inaccessible for direct writes.
        }
      }

      return outputFile;
    } catch (e) {
      debugPrint('Error exporting dictionary: $e');
      rethrow;
    }
  }
}
