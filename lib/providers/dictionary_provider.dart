import 'package:flutter/foundation.dart';
import '../data/dictionary.dart';
import '../utils/file_utils.dart' as file_utils;

class DictionaryProvider with ChangeNotifier {
  List<Dictionary> _dictionaries = [];
  bool _isLoading = false;

  List<Dictionary> get dictionaries => _dictionaries;
  bool get isLoading => _isLoading;

  DictionaryProvider() {
    loadDictionaries();
  }

  Future<void> loadDictionaries() async {
    _isLoading = true;
    notifyListeners();
    try {
      final names = await file_utils.getDictionaryNames();
      final loaded = <Dictionary>[];
      for (final name in names) {
        final dict = await file_utils.loadDictionaryFromJson(name);
        if (dict != null) {
          loaded.add(dict);
        }
      }
      _dictionaries = loaded;
    } catch (e) {
      print("Помилка в loadDictionaries provider: $e");
      _dictionaries = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDictionary(String name) async {
    if (name.isEmpty) return;
    if (_dictionaries.any((d) => d.name.toLowerCase() == name.toLowerCase())) {
      print("Словник з назвою '$name' вже існує.");
      return;
    }

    final newDictionary = Dictionary(name: name);
    _isLoading = true;
    notifyListeners();

    try {
      await file_utils.saveDictionaryToJson(newDictionary);
      _dictionaries.add(newDictionary);
      _dictionaries.sort((a, b) => a.name.compareTo(b.name));
    } catch (e) {
      print("Помилка при додаванні словника '$name': $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWordToDictionary(String dictionaryName, Word word) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final index = _dictionaries.indexWhere((d) => d.name == dictionaryName);
      if (index == -1) {
        print("Словник '$dictionaryName' не знайдено для додавання слова.");
        return;
      }
      
      // Create a new dictionary with the added word
      final dictionary = _dictionaries[index];
      final updatedWords = List<Word>.from(dictionary.words)..add(word);
      final updatedDictionary = dictionary.copyWith(words: updatedWords);
      
      // Save to storage
      await file_utils.saveDictionaryToJson(updatedDictionary);
      
      // Update in memory
      _dictionaries[index] = updatedDictionary;
      
      print("Слово '${word.term}' додано до словника '$dictionaryName'");
    } catch (e) {
      print("Помилка при додаванні слова до словника '$dictionaryName': $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update a dictionary (for example when deleting a word)
  Future<void> updateDictionary(Dictionary updatedDictionary) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final index = _dictionaries.indexWhere((d) => d.name == updatedDictionary.name);
      if (index == -1) {
        print("Словник '${updatedDictionary.name}' не знайдено для оновлення.");
        return;
      }
      
      // Save to storage
      await file_utils.saveDictionaryToJson(updatedDictionary);
      
      // Update in memory
      _dictionaries[index] = updatedDictionary;
      
      print("Словник '${updatedDictionary.name}' оновлено");
    } catch (e) {
      print("Помилка при оновленні словника '${updatedDictionary.name}': $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDictionary(Dictionary dictionary) async {
    _isLoading = true;
    notifyListeners();
    final index = _dictionaries.indexWhere((d) => d.name == dictionary.name);
    if (index == -1) {
      print("Словник '${dictionary.name}' не знайдено в списку для видалення.");
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final success = await file_utils.deleteDictionaryDirectory(
        dictionary.name,
      );
      if (success) {
        _dictionaries.removeAt(index);
      } else {
        print(
          "Не вдалося видалити файли словника для '${dictionary.name}'. Не видаляємо зі списку.",
        );
      }
    } catch (e) {
      print("Помилка при видаленні словника '${dictionary.name}': $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> dictionaryExists(String name) async {
    return _dictionaries.any((d) => d.name.toLowerCase() == name.toLowerCase());
  }
}
