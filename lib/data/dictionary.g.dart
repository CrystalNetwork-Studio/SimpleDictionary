// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dictionary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Dictionary _$DictionaryFromJson(Map<String, dynamic> json) => Dictionary(
  name: json['name'] as String,
  words:
      (json['words'] as List<dynamic>?)
          ?.map((e) => Word.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  color: Dictionary._colorFromJson((json['color'] as num?)?.toInt()),
  type:
      $enumDecodeNullable(_$DictionaryTypeEnumMap, json['type']) ??
      DictionaryType.word,
);

Map<String, dynamic> _$DictionaryToJson(Dictionary instance) =>
    <String, dynamic>{
      'name': instance.name,
      'words': instance.words.map((e) => e.toJson()).toList(),
      'type': _$DictionaryTypeEnumMap[instance.type]!,
      'color': Dictionary._colorToJson(instance.color),
    };

const _$DictionaryTypeEnumMap = {
  DictionaryType.word: 'word',
  DictionaryType.phrase: 'phrase',
  DictionaryType.sentence: 'sentence',
};

Word _$WordFromJson(Map<String, dynamic> json) => Word(
  term: json['term'] as String,
  translation: json['translation'] as String,
  description: json['description'] as String?,
);

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
  'term': instance.term,
  'translation': instance.translation,
  if (instance.description case final value?) 'description': value,
};
