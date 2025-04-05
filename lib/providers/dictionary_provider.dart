import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../data/dictionary.dart';
import '../utils/file_utils.dart' as file_utils;

class DictionaryProvider with ChangeNotifier {
  List<Dictionary> _dictionaries = [];
  bool _isLoading = false;
  String? _error;

  List<Dictionary> get dictionaries => List.unmodifiable(_dictionaries);
  bool get isLoading => _isLoading;
  String? get error => _error;

  DictionaryProvider() {
    loadDictionaries();
  }

  // Helper to manage loading state and errors
  Future<void> _performAction(
    AsyncCallback action, {
    String? successMessage, // Kept for simple cases like loadDictionaries
    String? errorMessagePrefix,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      // Success message printing moved inside specific actions for conditional logic
      if (kDebugMode && successMessage != null) {
        print(successMessage);
      }
    } catch (e, stackTrace) {
      final message = "${errorMessagePrefix ?? 'Error'}: $e";
      _error = message;
      if (kDebugMode) {
        print(message);
        print(stackTrace);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDictionaries() async {
    await _performAction(
      () async {
        final names = await file_utils.getDictionaryNames();
        final loaded = <Dictionary>[];
        for (final name in names) {
          try {
            final dict = await file_utils.loadDictionaryFromJson(name);
            if (dict != null) {
              loaded.add(dict);
            } else {
              if (kDebugMode) {
                print(
                  "Warning: Could not load dictionary data for '$name'. File might be corrupt or missing.",
                );
              }
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error loading individual dictionary '$name': $e");
            }
          }
        }
        loaded.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        _dictionaries = loaded;
      },
      successMessage:
          "Dictionaries loaded successfully.", // Simple case OK here
      errorMessagePrefix: "Error loading dictionaries",
    );
  }

  Future<bool> addDictionary(String name, {Color? color}) async {
    if (name.trim().isEmpty) {
      _error = "Назва словника не може бути порожньою.";
      notifyListeners();
      return false;
    }
    final trimmedName = name.trim();
    if (await dictionaryExists(trimmedName)) {
      _error = "Словник з назвою '$trimmedName' вже існує.";
      notifyListeners();
      if (kDebugMode) {
        print("Dictionary with name '$trimmedName' already exists.");
      }
      return false;
    }

    final newDictionary = Dictionary(name: trimmedName, color: color);
    bool success = false;

    await _performAction(
      () async {
        await file_utils.saveDictionaryToJson(newDictionary);
        _dictionaries.add(newDictionary);
        _dictionaries.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        success = true;
        if (kDebugMode) {
          print("Dictionary '$trimmedName' added.");
        }
      },
      // successMessage removed - handled inside action
      errorMessagePrefix: "Error adding dictionary '$trimmedName'",
    );
    return success;
  }

  Future<bool> addWordToDictionary(String dictionaryName, Word newWord) async {
    if (newWord.term.trim().isEmpty || newWord.translation.trim().isEmpty) {
      _error = "Слово та переклад не можуть бути порожніми.";
      notifyListeners();
      return false;
    }

    bool addedSuccessfully = false;
    String? wordTermForMessage; // To store term for success message

    await _performAction(
      () async {
        final index = _dictionaries.indexWhere((d) => d.name == dictionaryName);
        if (index == -1) {
          throw Exception("Dictionary '$dictionaryName' not found.");
        }

        final dictionary = _dictionaries[index];

        if (newWord.term.trim().length > 20 ||
            newWord.translation.trim().length > 20) {
          _error =
              "Довжина слова та перекладу не може перевищувати 20 символів.";
          return; // Exit early, _error is set
        }

        final trimmedTerm = newWord.term.trim();
        final trimmedTranslation = newWord.translation.trim();
        final exists = dictionary.words.any(
          (existingWord) =>
              existingWord.term.trim().toLowerCase() ==
                  trimmedTerm.toLowerCase() &&
              existingWord.translation.trim().toLowerCase() ==
                  trimmedTranslation.toLowerCase(),
        );

        if (exists) {
          _error = "Слово '$trimmedTerm' / '$trimmedTranslation' вже існує.";
          // Don't set addedSuccessfully to true
        } else {
          final wordToAdd = Word(
            term: trimmedTerm,
            translation: trimmedTranslation,
            description: newWord.description.trim(),
          );
          final updatedWords = List<Word>.from(dictionary.words)
            ..add(wordToAdd);
          final updatedDictionary = dictionary.copyWith(words: updatedWords);

          await file_utils.saveDictionaryToJson(updatedDictionary);
          _dictionaries[index] = updatedDictionary;
          addedSuccessfully = true;
          wordTermForMessage =
              wordToAdd.term; // Store for message after success
          if (kDebugMode) {
            print("Word '$wordTermForMessage' added to '$dictionaryName'.");
          }
        }
      },
      // successMessage removed - handled inside action
      errorMessagePrefix: "Error adding word to '$dictionaryName'",
    );

    // Notify if an error was set inside the action but didn't throw
    if (_error != null && !addedSuccessfully) {
      notifyListeners();
    }

    return addedSuccessfully;
  }

  /// Updates a word at a specific index within a dictionary.
  /// Returns true if successful, false otherwise.
  Future<bool> updateWordInDictionary(
    String dictionaryName,
    int wordIndex,
    Word updatedWord,
  ) async {
    if (updatedWord.term.trim().isEmpty ||
        updatedWord.translation.trim().isEmpty) {
      _error = "Слово та переклад не можуть бути порожніми.";
      notifyListeners();
      return false;
    }

    bool updatedSuccessfully = false;
    await _performAction(
      () async {
        final dictIndex = _dictionaries.indexWhere(
          (d) => d.name == dictionaryName,
        );
        if (dictIndex == -1) {
          throw Exception(
            "Dictionary '$dictionaryName' not found for word update.",
          );
        }

        final dictionary = _dictionaries[dictIndex];

        if (wordIndex < 0 || wordIndex >= dictionary.words.length) {
          throw Exception(
            "Invalid word index $wordIndex for dictionary '$dictionaryName'. Max index is ${dictionary.words.length - 1}.",
          );
        }

        if (updatedWord.term.trim().length > 20 ||
            updatedWord.translation.trim().length > 20) {
          _error =
              "Довжина слова та перекладу не може перевищувати 20 символів.";
          return; // Exit early, _error is set
        }

        final trimmedTerm = updatedWord.term.trim();
        final trimmedTranslation = updatedWord.translation.trim();
        final trimmedDescription = updatedWord.description.trim();

        // Check for duplicates *excluding* the current word being edited
        final exists = dictionary.words.asMap().entries.any(
          (entry) =>
              entry.key != wordIndex &&
              entry.value.term.trim().toLowerCase() ==
                  trimmedTerm.toLowerCase() &&
              entry.value.translation.trim().toLowerCase() ==
                  trimmedTranslation.toLowerCase(),
        );

        if (exists) {
          _error =
              "Інше слово з таким же терміном '$trimmedTerm' / '$trimmedTranslation' вже існує.";
          // Don't set updatedSuccessfully to true
        } else {
          final wordToUpdateWith = Word(
            term: trimmedTerm,
            translation: trimmedTranslation,
            description: trimmedDescription,
          );

          final List<Word> updatedWords = List<Word>.from(dictionary.words);
          updatedWords[wordIndex] = wordToUpdateWith;

          final updatedDict = dictionary.copyWith(words: updatedWords);

          await file_utils.saveDictionaryToJson(updatedDict);

          _dictionaries[dictIndex] = updatedDict;
          updatedSuccessfully = true;
          if (kDebugMode) {
            print(
              "Word at index $wordIndex in '$dictionaryName' updated to '${wordToUpdateWith.term}'.",
            );

            print("Word at index $wordIndex updated in '$dictionaryName'.");
          }
        }
      },
      // successMessage removed - handled inside action
      errorMessagePrefix:
          "Error updating word in '$dictionaryName' at index $wordIndex",
    );

    // Notify if an error was set inside the action but didn't throw
    if (_error != null && !updatedSuccessfully) {
      notifyListeners();
    }

    return updatedSuccessfully;
  }

  /// Removes a word from the dictionary by its index.
  /// Returns true if successful, false otherwise.
  Future<bool> removeWordFromDictionary(
    String dictionaryName,
    int wordIndex,
  ) async {
    bool removedSuccessfully = false;
    String? removedWordTerm; // Store for logging

    await _performAction(
      () async {
        final dictIndex = _dictionaries.indexWhere(
          (d) => d.name == dictionaryName,
        );
        if (dictIndex == -1) {
          throw Exception(
            "Dictionary '$dictionaryName' not found for word removal.",
          );
        }

        final dictionary = _dictionaries[dictIndex];

        if (wordIndex < 0 || wordIndex >= dictionary.words.length) {
          throw Exception(
            "Invalid word index $wordIndex for dictionary '$dictionaryName'. Max index is ${dictionary.words.length - 1}.",
          );
        }

        // Get the term before removing for potential success message
        removedWordTerm = dictionary.words[wordIndex].term;

        final List<Word> updatedWords = List<Word>.from(dictionary.words);
        updatedWords.removeAt(wordIndex);
        final updatedDict = dictionary.copyWith(words: updatedWords);

        await file_utils.saveDictionaryToJson(updatedDict);

        _dictionaries[dictIndex] = updatedDict;
        removedSuccessfully = true;

        if (kDebugMode) {
          print(
            "Word '$removedWordTerm' (index $wordIndex) removed from '$dictionaryName'.",
          );

          print("Word removed.");
        }
      },
      // successMessage removed - handled inside action
      errorMessagePrefix:
          "Error removing word from '$dictionaryName' at index $wordIndex",
    );
    return removedSuccessfully;
  }

  /// Updates dictionary properties (name and color).
  /// Handles renaming by moving the underlying directory/file.
  Future<bool> updateDictionaryProperties(
    String oldName,
    String newName,
    Color newColor,
  ) async {
    if (newName.trim().isEmpty) {
      _error = "Назва словника не може бути порожньою.";
      notifyListeners();
      return false;
    }
    final trimmedNewName = newName.trim();

    // Find the original dictionary index
    final index = _dictionaries.indexWhere((d) => d.name == oldName);
    if (index == -1) {
      _error = "Словник '$oldName' не знайдено для оновлення.";
      notifyListeners();
      return false;
    }

    // Check for name conflict only if the name actually changed
    if (trimmedNewName != oldName && await dictionaryExists(trimmedNewName)) {
      _error = "Словник з назвою '$trimmedNewName' вже існує.";
      notifyListeners();
      return false;
    }

    bool success = false;
    final originalDictionary = _dictionaries[index];

    await _performAction(
      () async {
        // Create the updated dictionary object *in memory* first
        final updatedDictionary = originalDictionary.copyWith(
          name: trimmedNewName,
          color: newColor,
        );

        // --- Handle file operations ---
        if (trimmedNewName == oldName) {
          // Only color changed, just save over the existing file
          await file_utils.saveDictionaryToJson(updatedDictionary);
        } else {
          // Name changed - Requires save to new, delete old
          // 1. Save the updated data to the new path
          await file_utils.saveDictionaryToJson(updatedDictionary);

          // 2. If saving to the new location was successful, delete the old directory
          final deletedOld = await file_utils.deleteDictionaryDirectory(
            oldName,
          );
          if (!deletedOld) {
            // Log critical error, but potentially proceed with in-memory update
            // The user might need to manually clean up the old file.
            final criticalMessage =
                "CRITICAL: Failed to delete old directory '$oldName' after renaming to '$trimmedNewName'. Manual cleanup might be needed.";
            if (kDebugMode) {
              print(criticalMessage);
            }
            // Decide if this should throw or just set an error message
            // Throwing might be better as the state is inconsistent.
            _error =
                "Помилка: Не вдалося видалити стару версію словника. '$oldName'";
            throw Exception(_error);
            // If not throwing: notifyListeners(); // To show the error
            // If not throwing: success = false; // Ensure success isn't set
            // return; // Stop further processing in the success path
          }
        }

        // --- Update in-memory list ---
        _dictionaries[index] = updatedDictionary;
        _dictionaries.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        success = true;
        if (kDebugMode) {
          print("Dictionary '$trimmedNewName' updated.");
        }
      },
      // successMessage removed - handled inside action
      errorMessagePrefix:
          "Error updating dictionary '$oldName' to '$trimmedNewName'",
    );

    return success;
  }

  Future<bool> deleteDictionary(String dictionaryName) async {
    bool success = false;
    await _performAction(
      () async {
        final index = _dictionaries.indexWhere((d) => d.name == dictionaryName);
        if (index == -1) {
          throw Exception(
            "Dictionary '$dictionaryName' not found for deletion.",
          );
        }

        final deletedFromFile = await file_utils.deleteDictionaryDirectory(
          dictionaryName,
        );
        if (deletedFromFile) {
          _dictionaries.removeAt(index);
          success = true;
          if (kDebugMode) {
            print("Dictionary '$dictionaryName' deleted.");
          }
        } else {
          // If file deletion failed, we might not want to remove it from the list
          throw Exception(
            "Failed to delete dictionary files for '$dictionaryName'.",
          );
        }
      },
      // successMessage removed - handled inside action
      errorMessagePrefix: "Error deleting dictionary '$dictionaryName'",
    );
    return success;
  }

  // Checks if a dictionary with the given name exists (case-insensitive)
  Future<bool> dictionaryExists(String name) async {
    // Check against the current in-memory list for immediate feedback
    final lowerCaseName = name.trim().toLowerCase();
    // Consider also checking the file system if consistency is critical,
    // but for UI feedback, the in-memory check is usually sufficient.
    return _dictionaries.any((d) => d.name.toLowerCase() == lowerCaseName);
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
