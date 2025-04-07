import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dictionary.g.dart';

@JsonSerializable(explicitToJson: true)
class Dictionary {
  final String name;
  final List<Word> words;
  final DictionaryType type;

  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson, includeIfNull: false)
  final Color color;

  Dictionary({
    required this.name,
    this.words = const [],
    Color? color,
    this.type = DictionaryType.word,
  }) : color = color ?? Colors.blue;

  factory Dictionary.fromJson(Map<String, dynamic> json) =>
      _$DictionaryFromJson(json);

  Map<String, dynamic> toJson() => _$DictionaryToJson(this);

  // Гетери для перевірки типу словника
  bool get isSentenceType => type == DictionaryType.sentence;
  bool get isWordType => type == DictionaryType.word;
  bool get isPhraseType => type == DictionaryType.phrase;

  // Допоміжний метод для отримання максимальної довжини символів
  int? get maxCharsPerField {
    switch (type) {
      case DictionaryType.word:
        return 14;
      case DictionaryType.phrase:
        return 23;
      case DictionaryType.sentence:
        return null; // Без обмежень
    }
  }

  bool get isDescriptionAllowed {
    return type == DictionaryType.word;
  }

  void addWord(Word word) {
    words.add(word);
  }

  Dictionary copyWith({
    String? name,
    List<Word>? words,
    Color? color,
    DictionaryType? type,
  }) {
    return Dictionary(
      name: name ?? this.name,
      words: words ?? List.from(this.words),
      color: color ?? this.color,
      type: type ?? this.type,
    );
  }

  static Color _colorFromJson(int? value) {
    return value != null ? Color(value) : Colors.blue;
  }

  static int _colorToJson(Color color) {
    return color.value;
  }
}

// Оновлений enum з новими типами
enum DictionaryType {
  word, // Змінено з words
  phrase, // Новий тип
  sentence, // Змінено з sentences
}

@JsonSerializable()
class Word {
  final String term;
  final String translation;
  // Опис тепер необов'язковий
  @JsonKey(includeIfNull: false) // Не включати в JSON, якщо null
  final String? description;

  Word({
    required this.term,
    required this.translation,
    this.description, // Зроблено необов'язковим
  });

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
  Map<String, dynamic> toJson() => _$WordToJson(this);
}
