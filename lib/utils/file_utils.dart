import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../data/dictionary.dart';

const String _baseDirName = 'Dictionary';
const String _fileName = 'words.json';

// Gets the path to the main "Dictionary" directory in app documents.
Future<String> _getBaseDirectoryPath() async {
  final directory = await getApplicationDocumentsDirectory();
  final baseDirPath = p.join(directory.path, _baseDirName);
  final baseDir = Directory(baseDirPath);
  if (!await baseDir.exists()) {
    await baseDir.create(recursive: true);
    print("Base 'Dictionary' directory created at: $baseDirPath");
  }
  return baseDirPath;
}

// Gets the path to a specific dictionary's directory.
Future<String> getDictionaryDirectoryPath(String dictionaryName) async {
  if (dictionaryName.isEmpty) {
    throw ArgumentError(
      "Dictionary name cannot be empty when getting specific path.",
    );
  }
  final baseDirPath = await _getBaseDirectoryPath();
  return p.join(baseDirPath, dictionaryName);
}

// Saves a Dictionary object to its specific directory as words.json.
Future<void> saveDictionaryToJson(Dictionary dictionary) async {
  try {
    final directoryPath = await getDictionaryDirectoryPath(dictionary.name);
    final dir = Directory(directoryPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      print(
        "Directory for dictionary '${dictionary.name}' created at: $directoryPath",
      );
    }
    final filePath = p.join(directoryPath, _fileName);
    final file = File(filePath);
    final jsonString = jsonEncode(dictionary.toJson());
    await file.writeAsString(jsonString);
    print("Dictionary '${dictionary.name}' saved to: $filePath");
  } catch (e) {
    print("Error saving dictionary '${dictionary.name}': $e");
    rethrow; // Rethrow to allow caller to handle
  }
}

// Loads a Dictionary object from words.json in its specific directory.
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
      print("Dictionary file not found for '$dictionaryName' at: $filePath");
      return null;
    }
  } catch (e) {
    print("Error loading dictionary '$dictionaryName': $e");
    return null;
  }
}

// Gets the names of all dictionary directories.
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
        dirNames.add(p.basename(entity.path)); // Get only the directory name
      }
    }
    print("Found dictionary directories: $dirNames");
    return dirNames;
  } catch (e) {
    print("Error listing dictionary directories: $e");
    return [];
  }
}

// Deletes the directory for a specific dictionary.
Future<bool> deleteDictionaryDirectory(String dictionaryName) async {
  try {
    if (dictionaryName.isEmpty) {
      print(
        "Error: Cannot delete the main 'Dictionary' directory. Dictionary name is blank.",
      );
      return false;
    }
    final directoryPath = await getDictionaryDirectoryPath(dictionaryName);
    final dir = Directory(directoryPath);

    if (await dir.exists()) {
      await dir.delete(recursive: true);
      print(
        "Successfully deleted dictionary '$dictionaryName' at: $directoryPath",
      );
      return true;
    } else {
      print(
        "Directory for dictionary '$dictionaryName' not found at: $directoryPath",
      );
      return false; // Directory didn't exist
    }
  } catch (e) {
    print("Error deleting dictionary '$dictionaryName': $e");
    return false;
  }
}
