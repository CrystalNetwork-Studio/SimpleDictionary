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
    this.type = DictionaryType.words,
  }) : color = color ?? Colors.blue;

  factory Dictionary.fromJson(Map<String, dynamic> json) =>
      _$DictionaryFromJson(json);

  bool get isSentencesType => type == DictionaryType.sentences;

  bool get isWordsType => type == DictionaryType.words;

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

  Map<String, dynamic> toJson() => _$DictionaryToJson(this);
  static Color _colorFromJson(int? value) {
    return value != null ? Color(value) : Colors.blue;
  }

  static int _colorToJson(Color color) {
    return color.value;
  }
}

enum DictionaryType { words, sentences }

@JsonSerializable()
class Word {
  final String term;
  final String translation;
  final String description;

  Word({
    required this.term,
    required this.translation,
    required this.description,
  });

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
  Map<String, dynamic> toJson() => _$WordToJson(this);
}
