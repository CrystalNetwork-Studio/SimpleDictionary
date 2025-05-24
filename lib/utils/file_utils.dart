import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/dictionary.dart';

/// Read a dictionary directly from bytes.
/// This is particularly useful for Android 11+ which uses content URIs
/// where the file content is provided as bytes by the picker.
Future<Dictionary?> readDictionaryFromBytes(Uint8List bytes) async {
  if (bytes.isEmpty) {
    debugPrint("Error: Received empty byte array");
    throw const FormatException("Empty file or no data received");
  }

  try {
    // Detect and remove byte order mark (BOM) if present
    int startIndex = 0;
    if (bytes.length >= 3 &&
        bytes[0] == 0xEF &&
        bytes[1] == 0xBB &&
        bytes[2] == 0xBF) {
      startIndex = 3; // Skip UTF-8 BOM
      debugPrint("UTF-8 BOM detected and skipped");
    }

    // Try multiple decoding strategies in case of encoding issues
    String jsonString;
    try {
      jsonString = utf8.decode(bytes.sublist(startIndex));
    } catch (e) {
      debugPrint("UTF-8 decoding failed, trying Latin-1: $e");
      try {
        // Fall back to Latin-1 encoding if UTF-8 fails
        // String.fromCharCodes treats each byte as a character code, effectively Latin-1 if byte < 256
        jsonString = String.fromCharCodes(bytes.sublist(startIndex));
      } catch (charError) {
        debugPrint("Latin-1 decoding also failed: $charError");

        // Try to detect and handle file corruption
        // Filter out null bytes or other potentially corrupting bytes
        final cleanedBytes = bytes.where((b) => b > 0).toList();
        if (cleanedBytes.length < bytes.length * 0.8) {
          debugPrint(
              "File appears to be severely corrupted (${cleanedBytes.length}/${bytes.length} valid bytes)");
          throw FormatException(
              "File appears to be corrupted or not a text file");
        }
        jsonString = String.fromCharCodes(cleanedBytes);
      }
    }

    // Trim any BOM or non-printable characters that might remain
    jsonString = jsonString.trim().replaceAll(RegExp(r'[\uFEFF\u00A0]'), '');

    // Verify the string contains valid JSON before parsing
    debugPrint("File content preview: ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}");
    final trimmedJson = jsonString.trim();
    if (trimmedJson.isEmpty) {
      throw const FormatException("File is empty");
    }

    // Simple check if it looks like a JSON object
    if (!(trimmedJson.startsWith('{') && trimmedJson.endsWith('}'))) {
      debugPrint(
          "Invalid JSON format: string doesn't appear to be a JSON object");
      debugPrint(
          "Start of file content: ${trimmedJson.substring(0, trimmedJson.length > 100 ? 100 : trimmedJson.length)}..."); // Increased length for better context
      throw const FormatException(
          "File doesn't contain valid JSON data. Make sure the file is a dictionary export.");
    }

    Map<String, dynamic> jsonMap;
    try {
      jsonMap = jsonDecode(trimmedJson) as Map<String, dynamic>;
    } catch (jsonError) {
      debugPrint("JSON decode error: $jsonError");
      // Try more aggressive cleaning if standard decode fails
      // Keep only characters typically found in JSON (alphanumeric, symbols, whitespace)
      // Note: This is a fallback and might break valid JSON if it contains unusual characters
      final cleanedJson = trimmedJson.replaceAll(
          RegExp(r'[^\x09\x0A\x0D\x20-\x7E,:{}\[\]"0-9.\-+\/\\u]'), '');
      try {
        jsonMap = jsonDecode(cleanedJson) as Map<String, dynamic>;
        debugPrint("Successfully parsed JSON after cleaning (aggressive)");
      } catch (secondError) {
        debugPrint("Failed to parse even after cleaning: $secondError");
        throw FormatException("Invalid JSON format after cleaning: ${secondError.toString()}. Please check that the file is a valid dictionary export and not corrupted.");
      }
    }

    // Basic validation of dictionary structure
    if (!jsonMap.containsKey('name')) {
      debugPrint("Invalid dictionary format: missing 'name' field");
      throw const FormatException(
          "Invalid dictionary file - missing 'name' field");
    }

    // Handle missing 'type' field for backward compatibility
    if (!jsonMap.containsKey('type')) {
      debugPrint("Invalid dictionary format: missing 'type' field");
      // Try to fix old format by adding default type 'word'
      jsonMap['type'] = 'word';
      debugPrint("Added default type 'word' to dictionary");
    }

    // Additional validation for name field
    final name = jsonMap['name'];
    if (name == null || (name is String && name.trim().isEmpty)) {
      throw const FormatException("Dictionary name cannot be empty");
    }

    // Validate words array if present, default to empty list if missing or invalid
    if (jsonMap.containsKey('words')) {
      if (jsonMap['words'] is! List) {
        debugPrint(
            "Invalid 'words' field: not a list, defaulting to empty list");
        jsonMap['words'] = <dynamic>[];
      }
    } else {
      debugPrint("Missing 'words' field, defaulting to empty list");
      jsonMap['words'] = <dynamic>[];
    }

    final dictionary = Dictionary.fromJson(jsonMap);
    debugPrint(
        "Dictionary '${dictionary.name}' loaded from bytes successfully");
    return dictionary;
  } on FormatException catch (e) {
    debugPrint("Error decoding JSON from bytes: $e");
    rethrow; // Rethrow format exceptions for specific handling in the UI
  } catch (e) {
    debugPrint("Unexpected error reading dictionary from bytes: $e");
    // Wrap generic errors in a FormatException or a specific AppError if needed
    // For now, just return null as per original function signature's potential return
    // However, rethrowing might be better for UI feedback. Let's rethrow.
    rethrow;
  }
}

const String _baseDirName = 'Dictionary';
const String _fileName = 'words.json';

/// Deletes the directory of a specific dictionary.
///
/// Parameters:
///   - [dictionaryName]: The name of the dictionary to delete.
///
/// Returns:
///   A [Future<bool>] that resolves to true if the directory was successfully deleted, false otherwise.
Future<bool> deleteDictionaryDirectory(String dictionaryName) async {
  try {
    if (dictionaryName.isEmpty) {
      debugPrint(
        "Error: Cannot delete the main 'Dictionary' directory. Dictionary name is blank.",
      );
      return false;
    }
    final directoryPath = await getDictionaryDirectoryPath(dictionaryName);
    final dir = Directory(directoryPath);

    if (await dir.exists()) {
      await dir.delete(recursive: true);
      debugPrint(
        "Successfully deleted dictionary '$dictionaryName' at: $directoryPath",
      );
      return true;
    } else {
      debugPrint(
        "Directory for dictionary '$dictionaryName' not found at: $directoryPath",
      );
      return false;
    }
  } catch (e) {
    debugPrint("Error deleting dictionary '$dictionaryName': $e");
    return false;
  }
}

/// Retrieves the path to a specific dictionary directory.
///
/// The directory is located inside the base directory, and its name is
/// determined by the [dictionaryName] parameter.
///
/// Parameters:
///   - [dictionaryName]: The name of the dictionary. Cannot be empty.
///
/// Returns:
///   A [Future<String>] that resolves to the path of the dictionary directory.
///
/// Throws:
///   - ArgumentError: If [dictionaryName] is empty.
Future<String> getDictionaryDirectoryPath(String dictionaryName) async {
  if (dictionaryName.isEmpty) {
    throw ArgumentError(
      "Dictionary name cannot be empty when getting specific path.",
    );
  }
  final baseDirPath = await _getBaseDirectoryPath();
  return p.join(baseDirPath, dictionaryName);
}

/// Retrieves a list of all dictionary names.
///
/// It reads the names of the directories located inside the base dictionary directory.
///
/// Returns:
///   A [Future<List<String>>] that resolves to a list of dictionary names.  Returns an empty list if no dictionaries are found, or if an error occurs.
Future<List<String>> getDictionaryNames() async {
  try {
    final baseDirPath = await _getBaseDirectoryPath();
    final baseDir = Directory(baseDirPath);
    if (!await baseDir.exists()) {
      return [];
    }

    final entities = baseDir.list();
    final List<String> dirNames = [];
    await for (final entity in entities) {
      if (entity is Directory) {
        dirNames.add(p.basename(entity.path));
      }
    }
    debugPrint("Found dictionary directories: $dirNames");
    return dirNames;
  } catch (e) {
    debugPrint("Error listing dictionary directories: $e");
    return [];
  }
}

/// Loads a [Dictionary] object from a JSON file.
///
/// The file is loaded from the directory corresponding to the [dictionaryName] parameter.
///
/// Parameters:
///   - [dictionaryName]: The name of the dictionary to load.
///
/// Returns:
///   A [Future<Dictionary?>] that resolves to the loaded Dictionary object, or null if the file doesn't exist or an error occurs.
Future<Dictionary?> loadDictionaryFromJson(String dictionaryName) async {
  try {
    final directoryPath = await getDictionaryDirectoryPath(dictionaryName);
    final filePath = p.join(directoryPath, _fileName);
    final file = File(filePath);

    if (await file.exists()) {
      // Use readAsBytes and readDictionaryFromBytes for consistent decoding
      final bytes = await file.readAsBytes();
      return await readDictionaryFromBytes(bytes);
    } else {
      debugPrint(
        "Dictionary file not found for '$dictionaryName' at: $filePath",
      );
      return null;
    }
  } catch (e) {
    debugPrint("Error loading dictionary '$dictionaryName': $e");
    return null;
  }
}

/// Saves a [Dictionary] object to a JSON file.
///
/// The file is saved in the directory corresponding to the dictionary's name.
/// If the directory doesn't exist, it is created.
///
/// Parameters:
///   - [dictionary]: The Dictionary object to save.
///
/// Throws:
///   - Any exception that occurs during the saving process.
Future<void> saveDictionaryToJson(Dictionary dictionary) async {
  try {
    final directoryPath = await getDictionaryDirectoryPath(dictionary.name);
    final dir = Directory(directoryPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      debugPrint(
        "Directory for dictionary '${dictionary.name}' created at: $directoryPath",
      );
    }
    final filePath = p.join(directoryPath, _fileName);
    final file = File(filePath);
    // Generate properly formatted JSON with pretty printing for better readability
    final jsonMap = dictionary.toJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonMap);
    await file.writeAsString(jsonString, flush: true);
    debugPrint("Dictionary '${dictionary.name}' saved to: $filePath");
  } catch (e) {
    debugPrint("Error saving dictionary '${dictionary.name}': $e");
    rethrow; // Rethrow to allow caller to handle
  }
}

/// Exports a [Dictionary] object to a specified JSON file path or content URI.
///
/// Parameters:
///   - [dictionary]: The Dictionary object to export.
///   - [exportPath]: The full file path or content URI where the JSON file should be saved.
///
/// Returns:
///   - A [Future<String>] with the actual path where the file was saved.
///
/// Throws:
///   - Any exception that occurs during the saving process, including errors writing to the specified path.
///
/// Note: Writing to Content URIs on Android 12+ typically requires a Uri and
/// platform-specific methods (e.g., using `ContentResolver`). Using `dart:io.File`
/// directly with a `content://` URI will fail. This function assumes `exportPath`
/// is compatible with `dart:io.File` or that the platform handles the URI correctly
/// if `dart:io` is bypassed (e.g., via plugins/platform channels not shown here).
/// The directory creation logic has been removed as it's often unnecessary or incorrect
/// when writing to paths obtained from a file picker.
Future<String> exportDictionaryToJsonFile(
  Dictionary dictionary,
  String exportPath,
) async {
  try {
    debugPrint("Attempting to export to path: $exportPath");

    // Generate properly formatted JSON with pretty printing for better readability
    final jsonMap = dictionary.toJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonMap);

    // Create a File object and write the string.
    // This works for standard file system paths accessible to the app.
    // It WILL NOT work for content:// URIs on platforms like Android 12+
    // unless the underlying platform handles the URI conversion/access
    // transparently for dart:io (which is not the standard behavior).
    // A robust solution for content URIs requires platform-specific code
    // or a package that handles these scenarios.
    final file = File(exportPath);
    await file.writeAsString(jsonString, flush: true);

    debugPrint(
        "Dictionary '${dictionary.name}' exported successfully to: $exportPath");
    return exportPath;
  } catch (e) {
    debugPrint(
        "Error exporting dictionary '${dictionary.name}' to '$exportPath': $e");
    rethrow; // Rethrow to allow caller to handle
  }
}

/// Validates whether we have permission to write to the given path.
///
/// Note: This check is heuristic and may not be accurate for all platforms or file systems,
/// especially for content URIs where the concept of 'writing to a path' is different.
/// For content URIs obtained from a picker configured for writing, assume permission is granted.
/// For file system paths, attempt to write a temporary file.
Future<bool> canWriteToPath(String path) async {
  try {
    if (path.startsWith('content://')) {
      debugPrint("Checking write permission for Content URI: $path");
      // Content URIs require different permission checks, usually granted by the picker.
      // Assume permission is granted if the URI was obtained from a picker configured for writing.
      // A more robust check would involve platform channels.
      debugPrint(
          "Assuming write permission for Content URI obtained from picker.");
      return true;
    }

    // For standard file paths, attempt a write test
    debugPrint("Checking write permission for file path: $path");
    final directory = File(path).parent;
    final testFileName =
        'test_write_permission_${DateTime.now().microsecondsSinceEpoch}.tmp';
    final testFile = File(p.join(directory.path, testFileName));

    try {
      // Attempt to create the directory if it doesn't exist and write a test file
      if (!await directory.exists()) {
        await directory.create(recursive: true);
        debugPrint("Created directory for permission test: ${directory.path}");
      }
      await testFile.writeAsString('test');
      await testFile.delete();
      debugPrint("Write permission test successful.");
      return true;
    } catch (e) {
      debugPrint("Failed write permission test for path '$path': $e");
      // Clean up the directory if we created it but failed later
      if (!await directory.exists()) {
        // Check if it was created
        try {
          await directory.delete();
        } catch (_) {} // Attempt cleanup silently
      }
      return false;
    }
  } catch (e) {
    debugPrint("Error checking write permission: $e");
    return false;
  }
}

/// Imports a [Dictionary] object from a specified JSON file path or bytes.
///
/// This function is designed to handle importing from standard file paths or
/// from bytes provided by a file picker (useful for Content URIs).
///
/// Parameters:
///   - [importPath]: The full file path or content URI of the JSON file to import.
///   - [bytes]: Optional byte data of the file. If provided, the file is read from bytes
///              instead of the path. This is required for content URIs on Android 12+.
///
/// Returns:
///   A [Future<Dictionary?>] that resolves to the imported Dictionary object,
///   or null if the file doesn't exist (when reading from path), is invalid,
///   or an error occurs.
///
/// Throws:
///   - FormatException: If the file contains invalid JSON or the dictionary format is invalid.
///   - Any other exception that occurs during file reading or byte processing.
Future<Dictionary?> importDictionaryFromJsonFile(String importPath,
    {Uint8List? bytes}) async {
  try {
    debugPrint(
        "Attempting to import from path: $importPath${bytes != null ? ' (bytes provided)' : ''}");

    if (bytes != null) {
      // Bytes were explicitly provided (e.g., from a file picker handling a content URI)
      debugPrint("Using provided bytes for import.");
      return await readDictionaryFromBytes(bytes);
    } else {
      // No bytes provided, attempt to read from the path directly.
      // This works for standard file paths but WILL NOT work for content URIs
      // unless the platform allows direct file access from the URI (unlikely on Android 12+).
      debugPrint("Attempting to read from path directly.");
      final file = File(importPath);

      if (!await file.exists()) {
        debugPrint("Import file not found at path: $importPath");
        return null;
      }

      // Read file as bytes first, then use the dedicated byte reading function
      final fileBytes = await file.readAsBytes();
      return await readDictionaryFromBytes(fileBytes);
    }
  } on FormatException catch (e) {
    debugPrint("Error decoding JSON or invalid format: $e");
    rethrow; // Rethrow specific format exception for UI
  } catch (e) {
    debugPrint("Error importing dictionary from path/bytes: $e");
    // Log the specific exception type for debugging
    debugPrint("Exception type: ${e.runtimeType}");
    rethrow; // Rethrow unexpected errors for UI
  }
}

/// Retrieves the path to the base directory where all dictionaries are stored.
///
/// If the directory doesn't exist, it creates it. The base directory is located
/// inside the application documents directory, under the name 'Dictionary'.
///
/// Returns:
///   A [Future<String>] that resolves to the path of the base directory.
Future<String> _getBaseDirectoryPath() async {
  final directory = await getApplicationDocumentsDirectory();
  final baseDirPath = p.join(directory.path, _baseDirName);
  final baseDir = Directory(baseDirPath);
  if (!await baseDir.exists()) {
    await baseDir.create(recursive: true);
    debugPrint("Base 'Dictionary' directory created at: $baseDirPath");
  }
  return baseDirPath;
}
