import 'package:json_annotation/json_annotation.dart';

part 'dictionary.g.dart';

@JsonSerializable()
class Word {
  final String term;
  final String definition;

  Word({required this.term, required this.definition});

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
  Map<String, dynamic> toJson() => _$WordToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Dictionary {
  final String name;
  final List<Word> words;

  Dictionary({required this.name, this.words = const []});

  factory Dictionary.fromJson(Map<String, dynamic> json) =>
      _$DictionaryFromJson(json);
  Map<String, dynamic> toJson() => _$DictionaryToJson(this);
}
