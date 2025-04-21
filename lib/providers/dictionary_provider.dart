import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    DictionaryType dictionaryType = DictionaryType.word,
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

    await _performAction(() async {
      final index = _dictionaries.indexWhere((d) => d.name == dictionaryName);
      if (index == -1) {
        throw Exception("Dictionary '$dictionaryName' not found.");
      }

      final dictionary = _dictionaries[index];
      final trimmedTerm = newWord.term.trim();
      final trimmedTranslation = newWord.translation.trim();

      // Check length according to dictionary type
      final int? maxLength = dictionary.maxCharsPerField;
      if (maxLength != null &&
          (trimmedTerm.length > maxLength ||
              trimmedTranslation.length > maxLength)) {
        String? wordMaxLengthError;
        if (context != null) {
          wordMaxLengthError =
              AppLocalizations.of(context)!.wordAndTranslationMaxLength;
        } else {
          wordMaxLengthError =
              'Term/Translation exceeds max length of $maxLength chars for ${dictionary.type.name} dictionary.';
        }
        _error = wordMaxLengthError;
        return; // Do not add if length is exceeded
      }

      // Check for existing identical word (term + translation)
      String? anotherWordExistsError;
      if (context != null) {
        anotherWordExistsError = AppLocalizations.of(
          context,
        )!
            .anotherWordWithSameTermExists(trimmedTerm, trimmedTranslation);
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
          // Add description only if allowed by dictionary type
          description: dictionary.isDescriptionAllowed
              ? newWord.description?.trim()
              : null,
        );
        final updatedWords = List<Word>.from(dictionary.words)..add(wordToAdd);
        final updatedDictionary = dictionary.copyWith(words: updatedWords);

        await file_utils.saveDictionaryToJson(updatedDictionary);
        _dictionaries[index] = updatedDictionary;
        addedSuccessfully = true;
      }
    }, errorMessagePrefix: "Error adding word to '$dictionaryName'");

    if (_error != null && !addedSuccessfully) {
      notifyListeners();
    }

    return addedSuccessfully;
  }

  // Need to ensure that updateDictionaryProperties does not change the dictionary type.

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
      } else {
        throw Exception(
          "Failed to delete dictionary files for '$dictionaryName'.",
        );
      }
    }, errorMessagePrefix: "Error deleting dictionary '$dictionaryName'");
    return success;
  }

  Future<bool> dictionaryExists(String name) async {
    final lowerCaseName = name.trim().toLowerCase();
    return _dictionaries.any((d) => d.name.toLowerCase() == lowerCaseName);
  }

  AppLocalizations l10n(BuildContext context) => AppLocalizations.of(context)!;

  Future<void> loadDictionaries() async {
    await _performAction(
      () async {
        final names = await file_utils.getDictionaryNames();
        final loaded = <Dictionary>[];
        for (final name in names) {
          try {
            final dict = await file_utils.loadDictionaryFromJson(name);
            if (dict != null) {
              // IMPORTANT: Ensure dictionary type is correctly deserialized on load.
              // Old files without a type might need default type logic or migration.
              // Assuming the .g.dart file handles this.
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
              // Consider deleting or marking the corrupt dictionary
              // await file_utils.deleteDictionaryDirectory(name);
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

  Future<bool> exportDictionary(
    String dictionaryName,
    String exportPath,
  ) async {
    bool success = false;
    await _performAction(
      () async {
        final dictionary = _dictionaries.firstWhere(
          (d) => d.name == dictionaryName,
          orElse: () => throw Exception(
            "Dictionary '$dictionaryName' not found for export.",
          ),
        );
        await file_utils.exportDictionaryToJsonFile(dictionary, exportPath);
        success = true;
      },
      errorMessagePrefix:
          "Error exporting dictionary '$dictionaryName' to '$exportPath'",
    );
    return success;
  }

  /// Loads dictionary data from a file for import preview, without adding it to the state.
  Future<Dictionary?> loadDictionaryForImport(String importPath) async {
    Dictionary? dictionary;
    await _performAction(
      () async {
        dictionary = await file_utils.importDictionaryFromJsonFile(importPath);
        if (dictionary == null) {
          // file_utils handles internal errors, but set a provider error for UI
          _error = "Failed to load dictionary from file or file not found.";
        } else if (dictionary!.name.trim().isEmpty) {
          _error = "Imported dictionary has an empty name.";
          dictionary = null; // Invalidate dictionary with empty name
        }
      },
      errorMessagePrefix:
          "Error loading dictionary for import from '$importPath'",
    );
    // Notify listeners if an error occurred during the action (e.g., empty name)
    if (_error != null) {
      notifyListeners();
    }
    return dictionary;
  }

  /// Completes the import process by adding/overwriting the dictionary in the state and saving it.
  Future<bool> importDictionary(Dictionary dictionaryToImport) async {
    bool success = false;
    final String importName = dictionaryToImport.name;

    // Ensure name is not empty after potential rename during import preview
    if (importName.trim().isEmpty) {
      _error = "Dictionary name cannot be empty for import.";
      notifyListeners();
      return false;
    }

    await _performAction(
      () async {
        final existingIndex = _dictionaries.indexWhere(
          (d) => d.name.toLowerCase() == importName.toLowerCase(),
        );

        if (existingIndex != -1) {
          // Overwrite existing dictionary
          await file_utils.saveDictionaryToJson(
              dictionaryToImport); // Save replaces file content
          _dictionaries[existingIndex] =
              dictionaryToImport; // Update in provider list
        } else {
          // Add as a new dictionary
          await file_utils.saveDictionaryToJson(dictionaryToImport);
          _dictionaries.add(dictionaryToImport);
          _dictionaries.sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );
        }
        success = true;
      },
      errorMessagePrefix:
          "Error importing dictionary '${dictionaryToImport.name}'",
    );
    return success;
  }

  Future<bool> removeWordFromDictionary(
    String dictionaryName,
    int wordIndex, {
    BuildContext? context,
  }) async {
    bool removedSuccessfully = false;

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

        final List<Word> updatedWords = List<Word>.from(dictionary.words);
        updatedWords.removeAt(wordIndex);
        final updatedDict = dictionary.copyWith(words: updatedWords);

        await file_utils.saveDictionaryToJson(updatedDict);

        _dictionaries[dictIndex] = updatedDict;
        removedSuccessfully = true;
      },
      errorMessagePrefix:
          "Error removing word from '$dictionaryName' at index $wordIndex",
    );
    return removedSuccessfully;
  }

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
      dictionaryNotFoundForUpdateError = AppLocalizations.of(
        context,
      )!
          .dictionaryNotFoundForUpdate(oldName);
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
        // IMPORTANT: Copy the dictionary, preserving its original type!
        final updatedDictionary = originalDictionary.copyWith(
          name: trimmedNewName,
          color: newColor,
          // type: DO NOT CHANGE TYPE WHEN UPDATING PROPERTIES
        );

        if (trimmedNewName == oldName) {
          // Only save if name is the same, file structure doesn't change
          await file_utils.saveDictionaryToJson(updatedDictionary);
        } else {
          // Save under the new name first
          await file_utils.saveDictionaryToJson(updatedDictionary);

          // Then delete the old directory/file
          final deletedOld = await file_utils.deleteDictionaryDirectory(
            oldName,
          );
          if (!deletedOld) {
            // This is problematic, log it and set an error for the UI
            final criticalMessage =
                "CRITICAL: Failed to delete old directory '$oldName' after renaming to '$trimmedNewName'. Manual cleanup might be needed.";
            if (kDebugMode) debugPrint(criticalMessage);

            String? errorDeletingDictionaryDir;
            if (context != null && context.mounted) {
              errorDeletingDictionaryDir = AppLocalizations.of(
                context,
              )!
                  .errorDeletingDictionaryDirectory(oldName, trimmedNewName);
            } else {
              errorDeletingDictionaryDir = 'Context is null or not mounted';
            }
            _error = errorDeletingDictionaryDir;
            // Optionally throw to indicate overall failure despite saving the new one
            // throw Exception(_error);
          }
        }

        _dictionaries[index] = updatedDictionary;
        _dictionaries.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        success = true;
      },
      errorMessagePrefix:
          "Error updating dictionary '$oldName' to '$trimmedNewName'",
    );

    return success;
  }

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

        final trimmedTerm = updatedWord.term.trim();
        final trimmedTranslation = updatedWord.translation.trim();

        // Check length according to dictionary type
        final int? maxLength = dictionary.maxCharsPerField;
        if (maxLength != null &&
            (trimmedTerm.length > maxLength ||
                trimmedTranslation.length > maxLength)) {
          String? wordMaxLengthError;
          if (context != null) {
            wordMaxLengthError =
                AppLocalizations.of(context)!.wordAndTranslationMaxLength;
          } else {
            wordMaxLengthError =
                'Term/Translation exceeds max length of $maxLength chars for ${dictionary.type.name} dictionary.';
          }
          _error = wordMaxLengthError;
          return; // Do not update word
        }

        // Check for existence of another word with the same term/translation
        String? anotherWordExistsError;
        if (context != null) {
          anotherWordExistsError = AppLocalizations.of(
            context,
          )!
              .anotherWordWithSameTermExists(trimmedTerm, trimmedTranslation);
        } else {
          anotherWordExistsError = 'Context is null';
        }
        final exists = dictionary.words.asMap().entries.any(
              (entry) =>
                  entry.key !=
                      wordIndex && // Don't compare the word with itself
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
            // Add description only if allowed by dictionary type
            description: dictionary.isDescriptionAllowed
                ? updatedWord.description?.trim()
                : null,
          );

          final List<Word> updatedWords = List<Word>.from(dictionary.words);
          updatedWords[wordIndex] = wordToUpdateWith;

          final updatedDict = dictionary.copyWith(words: updatedWords);

          await file_utils.saveDictionaryToJson(updatedDict);

          _dictionaries[dictIndex] = updatedDict;
          updatedSuccessfully = true;
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

  /// Helper function to handle loading state and errors for async operations.
  Future<void> _performAction(
    AsyncCallback action, {
    String? successMessage,
    String? errorMessagePrefix,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Notify start of loading
    try {
      await action();
      if (kDebugMode && successMessage != null) {
        debugPrint(successMessage);
      }
    } catch (e, stackTrace) {
      final message = "${errorMessagePrefix ?? 'Error'}: $e";
      // Assign error only if one hasn't been set by validation logic inside the action
      _error ??= message;
      if (kDebugMode) {
        debugPrint(message);
        debugPrintStack(stackTrace: stackTrace);
      }
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify end of loading and potential error
    }
  }
}
