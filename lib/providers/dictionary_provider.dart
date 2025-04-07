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

  // --- Додавання словника ---
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
        debugPrint(
          "Dictionary '$trimmedName' added with type '${dictionaryType.name}'.",
        );
      }
    }, errorMessagePrefix: "Error adding dictionary '$trimmedName'");
    return success;
  }

  // --- Додавання слова до словника ---
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
    // Базова перевірка на порожні поля
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
      final trimmedTerm = newWord.term.trim();
      final trimmedTranslation = newWord.translation.trim();

      // --- Перевірка довжини відповідно до типу словника ---
      final int? maxLength = dictionary.maxCharsPerField;
      if (maxLength != null &&
          (trimmedTerm.length > maxLength ||
              trimmedTranslation.length > maxLength)) {
        String? wordMaxLengthError;
        if (context != null) {
          // Потрібно створити або адаптувати рядок локалізації
          wordMaxLengthError =
              AppLocalizations.of(
                context,
              )!.wordAndTranslationMaxLength; // Використання локалізації
        } else {
          wordMaxLengthError =
              'Term/Translation exceeds max length of $maxLength chars for ${dictionary.type.name} dictionary.';
        }
        _error = wordMaxLengthError;
        return; // Не додаємо слово, якщо довжина перевищена
      }
      // --- Кінець перевірки довжини ---

      // Перевірка на існування ідентичного слова (термін + переклад)

      String? anotherWordExistsError;
      if (context != null) {
        anotherWordExistsError = AppLocalizations.of(
          context,
        )!.anotherWordWithSameTermExists(trimmedTerm, trimmedTranslation);
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
        // Створення слова для додавання
        final wordToAdd = Word(
          term: trimmedTerm,
          translation: trimmedTranslation,
          // Додаємо опис тільки якщо це дозволено типом словника
          description:
              dictionary.isDescriptionAllowed
                  ? newWord.description
                      ?.trim() // Обрізаємо опис, якщо він є
                  : null, // Інакше встановлюємо null
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

  // --- Решта методів (load, deleteDictionary, removeWord, updateProperties, etc.) ---
  // Залишаються переважно без змін, оскільки вони оперують
  // словниками як цілими або індексами слів, а не їх вмістом/типом.
  // Потрібно переконатись, що `updateDictionaryProperties` не змінює тип словника.

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

  Future<bool> dictionaryExists(String name) async {
    final lowerCaseName = name.trim().toLowerCase();
    return _dictionaries.any((d) => d.name.toLowerCase() == lowerCaseName);
  }

  // Допоміжна функція для локалізації (якщо `context` доступний)
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
              // Важливо: При завантаженні переконайтеся, що тип словника
              // правильно десеріалізується. Якщо старі файли не мають типу,
              // можливо, знадобиться логіка для встановлення типу за замовчуванням
              // або міграції. Припускаємо, що .g.dart файл впорається.
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
              // Можливо, варто видалити пошкоджений словник або позначити його
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

  Future<bool> updateDictionaryProperties(
    String oldName,
    String newName,
    Color newColor, {
    BuildContext? context,
  }) async {
    // ... (перевірки імені залишаються) ...
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
      )!.dictionaryNotFoundForUpdate(oldName);
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
        // Важливо: Копіюємо словник, зберігаючи його оригінальний тип!
        final updatedDictionary = originalDictionary.copyWith(
          name: trimmedNewName,
          color: newColor,
          // type: НЕ ЗМІНЮЄМО ТИП ПРИ ОНОВЛЕННІ ВЛАСТИВОСТЕЙ
        );

        // ... (логіка збереження/видалення старого файлу залишається) ...
        if (trimmedNewName == oldName) {
          // Only save if name is the same, otherwise save the new one later
          await file_utils.saveDictionaryToJson(updatedDictionary);
        } else {
          // Save under the new name first
          await file_utils.saveDictionaryToJson(updatedDictionary);

          // Then delete the old directory/file
          final deletedOld = await file_utils.deleteDictionaryDirectory(
            oldName,
          );
          if (!deletedOld) {
            // This is problematic, log it and maybe inform the user
            final criticalMessage =
                "CRITICAL: Failed to delete old directory '$oldName' after renaming to '$trimmedNewName'. Manual cleanup might be needed.";
            if (kDebugMode) {
              debugPrint(criticalMessage);
            }
            // Decide how to handle this - maybe proceed but set an error?
            String? errorDeletingDictionaryDir;
            if (context != null && context.mounted) {
              errorDeletingDictionaryDir = AppLocalizations.of(
                context,
              )!.errorDeletingDictionaryDirectory(oldName, trimmedNewName);
            } else {
              errorDeletingDictionaryDir = 'Context is null or not mounted';
            }
            _error = errorDeletingDictionaryDir;
            // Optionally throw to indicate failure despite saving the new one
            throw Exception(_error);
          }
        }

        _dictionaries[index] = updatedDictionary;
        _dictionaries.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
        success = true;
        if (kDebugMode) {
          debugPrint(
            "Dictionary properties updated for '$trimmedNewName' (Type: ${updatedDictionary.type.name}).",
          );
        }
      },
      errorMessagePrefix:
          "Error updating dictionary '$oldName' to '$trimmedNewName'",
    );

    return success;
  }

  // --- Оновлення слова у словнику ---
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
    // Базова перевірка на порожні поля
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

        // --- Перевірка довжини відповідно до типу словника ---
        final int? maxLength = dictionary.maxCharsPerField;
        if (maxLength != null &&
            (trimmedTerm.length > maxLength ||
                trimmedTranslation.length > maxLength)) {
          String? wordMaxLengthError;
          if (context != null) {
            wordMaxLengthError =
                AppLocalizations.of(
                  context,
                )!.wordAndTranslationMaxLength; // Використання локалізації
          } else {
            wordMaxLengthError =
                'Term/Translation exceeds max length of $maxLength chars for ${dictionary.type.name} dictionary.';
          }
          _error = wordMaxLengthError;
          return; // Не оновлюємо слово
        }
        // --- Кінець перевірки довжини ---

        // Перевірка на існування іншого слова з таким же терміном/перекладом
        String? anotherWordExistsError;
        if (context != null) {
          anotherWordExistsError = AppLocalizations.of(
            context,
          )!.anotherWordWithSameTermExists(trimmedTerm, trimmedTranslation);
        } else {
          anotherWordExistsError = 'Context is null';
        }
        final exists = dictionary.words.asMap().entries.any(
          (entry) =>
              entry.key != wordIndex && // Не порівнювати з самим собою
              entry.value.term.trim().toLowerCase() ==
                  trimmedTerm.toLowerCase() &&
              entry.value.translation.trim().toLowerCase() ==
                  trimmedTranslation.toLowerCase(),
        );

        if (exists) {
          _error = anotherWordExistsError;
        } else {
          // Створення слова для оновлення
          final wordToUpdateWith = Word(
            term: trimmedTerm,
            translation: trimmedTranslation,
            // Додаємо опис тільки якщо це дозволено типом словника
            description:
                dictionary.isDescriptionAllowed
                    ? updatedWord.description?.trim()
                    : null,
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

  Future<void> _performAction(
    AsyncCallback action, {
    String? successMessage,
    String? errorMessagePrefix,
  }) async {
    // Ця функція залишається без змін
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
      // Перевіряємо, чи помилка вже встановлена (наприклад, валідацією)
      _error ??= message;
      if (kDebugMode) {
        debugPrint(message);
        debugPrintStack(stackTrace: stackTrace);
      }
    } finally {
      _isLoading = false;
      notifyListeners(); // Повідомити про зміни стану (включаючи помилку)
    }
  }
}
