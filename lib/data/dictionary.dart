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

  bool get isSentenceType => type == DictionaryType.sentence;
  bool get isWordType => type == DictionaryType.word;
  bool get isPhraseType => type == DictionaryType.phrase;

  int? get maxCharsPerField {
    switch (type) {
      case DictionaryType.word:
        return 14; // Max length for Word type
      case DictionaryType.phrase:
        return 23; // Max length for Phrase type
      case DictionaryType.sentence:
        return null; // No limit for Sentence type
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

  static int _colorToJson(Color? color) {
    if (color == null) {
      throw ArgumentError('Color cannot be null');
    }

    return color.toARGB32();
  }
}

enum DictionaryType { word, phrase, sentence }

@JsonSerializable()
class Word {
  final String term;
  final String translation;
  @JsonKey(includeIfNull: false)
  final String? description;

  Word({required this.term, required this.translation, this.description});

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
  Map<String, dynamic> toJson() => _$WordToJson(this);
}
