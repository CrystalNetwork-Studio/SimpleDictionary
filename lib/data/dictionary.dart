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

  Dictionary({required this.name, this.words = const []});

  Dictionary copyWith({
    String? name,
    List<Word>? words,
  }) {
    return Dictionary(
      name: name ?? this.name,
      words: words ?? List.from(this.words),
    );
  }

  void addWord(Word word) {
    words.add(word);
  }

  factory Dictionary.fromJson(Map<String, dynamic> json) =>
      _$DictionaryFromJson(json);
  Map<String, dynamic> toJson() => _$DictionaryToJson(this);
}