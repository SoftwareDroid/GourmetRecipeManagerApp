// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return Profile(
    json['uid'] as int,
  )
    ..vegMode = _$enumDecodeNullable(_$VegModeEnumMap, json['vegMode'])
    ..name = json['name'] as String
    ..maxTime = json['maxTime'] == null
        ? null
        : Duration(microseconds: json['maxTime'] as int)
    ..meatMode = json['meatMode'] as String
    ..dish_types = (json['dish_types'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as bool),
    )
    ..blacklist_tags = (json['blacklist_tags'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as bool),
    )
    ..whitelist_tags = (json['whitelist_tags'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as bool),
    )
    ..whitelist_cuisines =
        (json['whitelist_cuisines'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, e as bool),
    );
}

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'uid': instance.uid,
      'vegMode': _$VegModeEnumMap[instance.vegMode],
      'name': instance.name,
      'maxTime': instance.maxTime?.inMicroseconds,
      'meatMode': instance.meatMode,
      'dish_types': instance.dish_types,
      'blacklist_tags': instance.blacklist_tags,
      'whitelist_tags': instance.whitelist_tags,
      'whitelist_cuisines': instance.whitelist_cuisines,
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$VegModeEnumMap = {
  VegMode.Vegan: 'Vegan',
  VegMode.Vegetarian: 'Vegetarian',
  VegMode.All: 'All',
};
