import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dictionary.g.dart';

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

@JsonSerializable(explicitToJson: true)
class Dictionary {
  final String name;
  final List<Word> words;

  @JsonKey(fromJson: _colorFromJson, toJson: _colorToJson)
  final Color color;

  Dictionary({required this.name, this.words = const [], Color? color})
    : color = color ?? Colors.blue;

  Dictionary copyWith({String? name, List<Word>? words, Color? color}) {
    return Dictionary(
      name: name ?? this.name,
      words: words ?? List.from(this.words),
      color: color ?? this.color,
    );
  }

  void addWord(Word word) {
    words.add(word);
  }

  factory Dictionary.fromJson(Map<String, dynamic> json) =>
      _$DictionaryFromJson(json);
  Map<String, dynamic> toJson() => _$DictionaryToJson(this);

  static Color _colorFromJson(int? value) {
    return value != null ? Color(value) : Colors.blue;
  }

  static int _colorToJson(Color color) {
    return color.value;
  }
}
