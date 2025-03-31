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
      _dictionaries = []; // Reset on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDictionary(String name) async {
    if (name.isEmpty) return;
    // Check if dictionary with the same name already exists (case-insensitive)
    if (_dictionaries.any((d) => d.name.toLowerCase() == name.toLowerCase())) {
      print("Словник з назвою '$name' вже існує.");
      // Optionally: throw error or return a status
      return;
    }

    final newDictionary = Dictionary(name: name);
    _isLoading = true; // Indicate loading while saving
    notifyListeners();

    try {
      await file_utils.saveDictionaryToJson(newDictionary);
      _dictionaries.add(newDictionary);
      _dictionaries.sort((a, b) => a.name.compareTo(b.name)); // Keep sorted
    } catch (e) {
      print("Помилка при додаванні словника '$name': $e");
      // Optionally: show error message to user
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDictionary(Dictionary dictionary) async {
    _isLoading = true; // Indicate loading while deleting
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
        // Optionally: show error message to user
      }
    } catch (e) {
      print("Помилка при видаленні словника '${dictionary.name}': $e");
      // Optionally: show error message to user
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> dictionaryExists(String name) async {
    return _dictionaries.any((d) => d.name.toLowerCase() == name.toLowerCase());
  }

  // TODO: Add methods for adding/removing words within a dictionary if needed
}
