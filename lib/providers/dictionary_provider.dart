import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:simpledictionary/l10n/app_localizations.dart';

import '../data/dictionary.dart';
import '../utils/file_utils.dart' as file_utils;

class DictionaryProvider with ChangeNotifier {
  List<Dictionary> _dictionaries = [];
  bool _isLoading = false;
  String? _error;

  DictionaryProvider() {
    loadDictionaries();
  }
  List<Dictionary> get dictionaries => List.unmodifiable(_dictionaries);
  String? get error => _error;

  bool get isLoading => _isLoading;

  Future<bool> addDictionary(
    String name, {
    Color? color,
    BuildContext? context,
    DictionaryType dictionaryType = DictionaryType.words,
  }) async {
    String? nameNotEmptyError;
    if (context != null) {
      nameNotEmptyError = AppLocalizations.of(context)!.dictionaryNameNotEmpty;
    } else {
      nameNotEmptyError = 'Context is null';
    }
    if (name.trim().isEmpty) {
      _error = nameNotEmptyError;
      notifyListeners();
      return false;
    }
    final trimmedName = name.trim();
    String? dictionaryExistsError;
    if (context != null) {
      dictionaryExistsError =
          AppLocalizations.of(context)!.dictionaryAlreadyExists;
    } else {
      dictionaryExistsError = 'Context is null';
    }
    if (await dictionaryExists(trimmedName)) {
      _error = dictionaryExistsError;
      notifyListeners();
      if (kDebugMode) {
        debugPrint("Dictionary with name '$trimmedName' already exists.");
      }
      return false;
    }

    final newDictionary = Dictionary(
      name: trimmedName,
      color: color,
      type: dictionaryType,
    );
    bool success = false;

    await _performAction(() async {
      await file_utils.saveDictionaryToJson(newDictionary);
      _dictionaries.add(newDictionary);
      _dictionaries.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      success = true;
      if (kDebugMode) {
        debugPrint("Dictionary '$trimmedName' added.");
      }
    }, errorMessagePrefix: "Error adding dictionary '$trimmedName'");
    return success;
  }

  Future<bool> addWordToDictionary(
    String dictionaryName,
    Word newWord, {
    BuildContext? context,
  }) async {
    String? wordOrTranslationEmptyError;
    if (context != null) {
      wordOrTranslationEmptyError =
          AppLocalizations.of(context)!.wordOrTranslationCannotBeEmpty;
    } else {
      wordOrTranslationEmptyError = 'Context is null';
    }
    if (newWord.term.trim().isEmpty || newWord.translation.trim().isEmpty) {
      _error = wordOrTranslationEmptyError;
      notifyListeners();
      return false;
    }

    bool addedSuccessfully = false;
    String? wordTermForMessage;

    await _performAction(() async {
      final index = _dictionaries.indexWhere((d) => d.name == dictionaryName);
      if (index == -1) {
        throw Exception("Dictionary '$dictionaryName' not found.");
      }

      final dictionary = _dictionaries[index];

      // Only enforce length limit for 'words' type dictionaries
      if (dictionary.isWordsType &&
          (newWord.term.trim().length > 20 ||
              newWord.translation.trim().length > 20)) {
        String? wordMaxLengthError;
        if (context != null) {
          wordMaxLengthError =
              AppLocalizations.of(context)!.wordAndTranslationMaxLength20;
        } else {
          wordMaxLengthError = 'Context is null';
        }
        _error = wordMaxLengthError;
        return;
      }

      final trimmedTerm = newWord.term.trim();
      final trimmedTranslation = newWord.translation.trim();
      String? anotherWordExistsError;
      if (context != null) {
        anotherWordExistsError =
            AppLocalizations.of(context)!.anotherWordWithSameTermExists
                as String?;
      } else {
        anotherWordExistsError = 'Context is null';
      }
      final exists = dictionary.words.any(
        (existingWord) =>
            existingWord.term.trim().toLowerCase() ==
                trimmedTerm.toLowerCase() &&
            existingWord.translation.trim().toLowerCase() ==
                trimmedTranslation.toLowerCase(),
      );

      if (exists) {
        _error = anotherWordExistsError;
      } else {
        final wordToAdd = Word(
          term: trimmedTerm,
          translation: trimmedTranslation,
          description: newWord.description.trim(),
        );
        final updatedWords = List<Word>.from(dictionary.words)..add(wordToAdd);
        final updatedDictionary = dictionary.copyWith(words: updatedWords);

        await file_utils.saveDictionaryToJson(updatedDictionary);
        _dictionaries[index] = updatedDictionary;
        addedSuccessfully = true;
        wordTermForMessage = wordToAdd.term;
        if (kDebugMode) {
          debugPrint("Word '$wordTermForMessage' added to '$dictionaryName'.");
        }
      }
    }, errorMessagePrefix: "Error adding word to '$dictionaryName'");

    if (_error != null && !addedSuccessfully) {
      notifyListeners();
    }

    return addedSuccessfully;
  }

  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  Future<bool> deleteDictionary(
    String dictionaryName, {
    BuildContext? context,
  }) async {
    bool success = false;
    await _performAction(() async {
      final index = _dictionaries.indexWhere((d) => d.name == dictionaryName);
      if (index == -1) {
        throw Exception("Dictionary '$dictionaryName' not found for deletion.");
      }

      final deletedFromFile = await file_utils.deleteDictionaryDirectory(
        dictionaryName,
      );
      if (deletedFromFile) {
        _dictionaries.removeAt(index);
        success = true;
        if (kDebugMode) {
          debugPrint("Dictionary '$dictionaryName' deleted.");
        }
      } else {
        throw Exception(
          "Failed to delete dictionary files for '$dictionaryName'.",
        );
      }
    }, errorMessagePrefix: "Error deleting dictionary '$dictionaryName'");
    return success;
  }

  /// Checks if a dictionary with the given name exists (case-insensitive)
  Future<bool> dictionaryExists(String name) async {
    final lowerCaseName = name.trim().toLowerCase();
    return _dictionaries.any((d) => d.name.toLowerCase() == lowerCaseName);
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
                debugPrint(
                  "Warning: Could not load dictionary data for '$name'. File might be corrupt or missing.",
                );
              }
            }
          } catch (e) {
            if (kDebugMode) {
              debugPrint("Error loading individual dictionary '$name': $e");
            }
          }
        }
        loaded.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        _dictionaries = loaded;
      },
      successMessage: "Dictionaries loaded successfully.",
      errorMessagePrefix: "Error loading dictionaries",
    );
  }

  /// Removes a word from the dictionary by its index.
  Future<bool> removeWordFromDictionary(
    String dictionaryName,
    int wordIndex, {
    BuildContext? context,
  }) async {
    bool removedSuccessfully = false;
    String? removedWordTerm;

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

        removedWordTerm = dictionary.words[wordIndex].term;

        final List<Word> updatedWords = List<Word>.from(dictionary.words);
        updatedWords.removeAt(wordIndex);
        final updatedDict = dictionary.copyWith(words: updatedWords);

        await file_utils.saveDictionaryToJson(updatedDict);

        _dictionaries[dictIndex] = updatedDict;
        removedSuccessfully = true;

        if (kDebugMode) {
          debugPrint(
            "Word '$removedWordTerm' (index $wordIndex) removed from '$dictionaryName'.",
          );
        }
      },
      errorMessagePrefix:
          "Error removing word from '$dictionaryName' at index $wordIndex",
    );
    return removedSuccessfully;
  }

  /// Updates dictionary properties (name and color).
  Future<bool> updateDictionaryProperties(
    String oldName,
    String newName,
    Color newColor, {
    BuildContext? context,
  }) async {
    String? dictionaryNameNotEmptyError;
    if (context != null) {
      dictionaryNameNotEmptyError =
          AppLocalizations.of(context)!.dictionaryNameNotEmpty;
    } else {
      dictionaryNameNotEmptyError = 'Context is null';
    }
    if (newName.trim().isEmpty) {
      _error = dictionaryNameNotEmptyError;
      notifyListeners();
      return false;
    }
    final trimmedNewName = newName.trim();

    String? dictionaryNotFoundForUpdateError;
    if (context != null) {
      dictionaryNotFoundForUpdateError =
          AppLocalizations.of(context)!.dictionaryNotFoundForUpdate as String?;
    } else {
      dictionaryNotFoundForUpdateError = 'Context is null';
    }
    final index = _dictionaries.indexWhere((d) => d.name == oldName);
    if (index == -1) {
      _error = dictionaryNotFoundForUpdateError;
      notifyListeners();
      return false;
    }

    String? dictionaryAlreadyExistsError;
    if (context != null) {
      dictionaryAlreadyExistsError =
          AppLocalizations.of(context)!.dictionaryAlreadyExists;
    } else {
      dictionaryAlreadyExistsError = 'Context is null';
    }
    if (trimmedNewName != oldName && await dictionaryExists(trimmedNewName)) {
      _error = dictionaryAlreadyExistsError;
      notifyListeners();
      return false;
    }

    bool success = false;
    final originalDictionary = _dictionaries[index];

    await _performAction(
      () async {
        final updatedDictionary = originalDictionary.copyWith(
          name: trimmedNewName,
          color: newColor,
          // type should remain the same during property updates
        );

        if (trimmedNewName == oldName) {
          await file_utils.saveDictionaryToJson(updatedDictionary);
        } else {
          await file_utils.saveDictionaryToJson(updatedDictionary);

          final deletedOld = await file_utils.deleteDictionaryDirectory(
            oldName,
          );
          if (!deletedOld) {
            final criticalMessage =
                "CRITICAL: Failed to delete old directory '$oldName' after renaming to '$trimmedNewName'. Manual cleanup might be needed.";
            if (kDebugMode) {
              debugPrint(criticalMessage);
            }
            String? errorDeletingDictionaryDir;
            if (context != null) {
              errorDeletingDictionaryDir =
                  AppLocalizations.of(context)!.errorDeletingDictionaryDirectory
                      as String?;
            } else {
              errorDeletingDictionaryDir = 'Context is null';
            }
            _error = errorDeletingDictionaryDir;
            throw Exception(_error);
          }
        }

        _dictionaries[index] = updatedDictionary;
        _dictionaries.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        success = true;
        if (kDebugMode) {
          debugPrint("Dictionary '$trimmedNewName' updated.");
        }
      },
      errorMessagePrefix:
          "Error updating dictionary '$oldName' to '$trimmedNewName'",
    );

    return success;
  }

  /// Updates a word at a specific index within a dictionary.
  Future<bool> updateWordInDictionary(
    String dictionaryName,
    int wordIndex,
    Word updatedWord, {
    BuildContext? context,
  }) async {
    String? wordOrTranslationEmptyError;
    if (context != null) {
      wordOrTranslationEmptyError =
          AppLocalizations.of(context)!.wordOrTranslationCannotBeEmpty;
    } else {
      wordOrTranslationEmptyError = 'Context is null';
    }
    if (updatedWord.term.trim().isEmpty ||
        updatedWord.translation.trim().isEmpty) {
      _error = wordOrTranslationEmptyError;
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

        // Only enforce length limit for 'words' type dictionaries
        if (dictionary.isWordsType &&
            (updatedWord.term.trim().length > 20 ||
                updatedWord.translation.trim().length > 20)) {
          String? wordMaxLengthError;
          if (context != null) {
            wordMaxLengthError =
                AppLocalizations.of(context)!.wordAndTranslationMaxLength20;
          } else {
            wordMaxLengthError = 'Context is null';
          }
          _error = wordMaxLengthError;
          return;
        }

        final trimmedTerm = updatedWord.term.trim();
        final trimmedTranslation = updatedWord.translation.trim();
        final trimmedDescription = updatedWord.description.trim();

        String? anotherWordExistsError;
        if (context != null) {
          anotherWordExistsError =
              AppLocalizations.of(context)!.anotherWordWithSameTermExists
                  as String?;
        } else {
          anotherWordExistsError = 'Context is null';
        }

        final exists = dictionary.words.asMap().entries.any(
          (entry) =>
              entry.key != wordIndex &&
              entry.value.term.trim().toLowerCase() ==
                  trimmedTerm.toLowerCase() &&
              entry.value.translation.trim().toLowerCase() ==
                  trimmedTranslation.toLowerCase(),
        );

        if (exists) {
          _error = anotherWordExistsError;
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
            debugPrint(
              "Word at index $wordIndex in '$dictionaryName' updated to '${wordToUpdateWith.term}'.",
            );
          }
        }
      },
      errorMessagePrefix:
          "Error updating word in '$dictionaryName' at index $wordIndex",
    );

    if (_error != null && !updatedSuccessfully) {
      notifyListeners();
    }

    return updatedSuccessfully;
  }

  // Helper to manage loading state and errors
  Future<void> _performAction(
    AsyncCallback action, {
    String? successMessage,
    String? errorMessagePrefix,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      if (kDebugMode && successMessage != null) {
        debugPrint(successMessage);
      }
    } catch (e, stackTrace) {
      final message = "${errorMessagePrefix ?? 'Error'}: $e";
      _error = message;
      if (kDebugMode) {
        debugPrint(message);
        debugPrintStack(stackTrace: stackTrace);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
