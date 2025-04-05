import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../data/dictionary.dart';

const String _baseDirName = 'Dictionary';
const String _fileName = 'words.json';

/// Deletes the directory of a specific dictionary.
///
/// Parameters:
///   - [dictionaryName]: The name of the dictionary to delete.
///
/// Returns:
///   A Future<bool> that resolves to true if the directory was successfully deleted, false otherwise.
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
///   A Future<String> that resolves to the path of the dictionary directory.
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
///   A Future<List<String>> that resolves to a list of dictionary names.  Returns an empty list if no dictionaries are found, or if an error occurs.
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
///   A Future<Dictionary?> that resolves to the loaded Dictionary object, or null if the file doesn't exist or an error occurs.
Future<Dictionary?> loadDictionaryFromJson(String dictionaryName) async {
  try {
    final directoryPath = await getDictionaryDirectoryPath(dictionaryName);
    final filePath = p.join(directoryPath, _fileName);
    final file = File(filePath);

    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return Dictionary.fromJson(jsonMap);
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
    final jsonString = jsonEncode(dictionary.toJson());
    await file.writeAsString(jsonString);
    debugPrint("Dictionary '${dictionary.name}' saved to: $filePath");
  } catch (e) {
    debugPrint("Error saving dictionary '${dictionary.name}': $e");
    rethrow; // Rethrow to allow caller to handle
  }
}

/// Retrieves the path to the base directory where all dictionaries are stored.
///
/// If the directory doesn't exist, it creates it. The base directory is located
/// inside the application documents directory, under the name 'Dictionary'.
///
/// Returns:
///   A Future<String> that resolves to the path of the base directory.
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
