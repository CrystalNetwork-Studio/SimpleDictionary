// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Word _$WordFromJson(Map<String, dynamic> json) => Word(
  term: json['term'] as String,
  definition: json['definition'] as String,
);

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
  'term': instance.term,
  'definition': instance.definition,
};

Dictionary _$DictionaryFromJson(Map<String, dynamic> json) => Dictionary(
  name: json['name'] as String,
  words:
      (json['words'] as List<dynamic>?)
          ?.map((e) => Word.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$DictionaryToJson(Dictionary instance) =>
    <String, dynamic>{
      'name': instance.name,
      'words': instance.words.map((e) => e.toJson()).toList(),
    };
