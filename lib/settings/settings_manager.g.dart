// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_manager.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsManager _$SettingsManagerFromJson(Map<String, dynamic> json) {
  $checkKeys(json, requiredKeys: const [
    'version',
    'ownerMail',
    'veganTag',
    'vegetarianTag',
    'favoriteTag',
    'todoTag',
    'agreedAlphaReleaseNote',
    'showHelp',
    'suggestionAlgo'
  ]);
  return SettingsManager()
    ..state = _$enumDecodeNullable(_$SettingsManagerStateEnumMap, json['state'])
    ..version = json['version'] as int
    ..ownerMail = json['ownerMail'] as String
    ..veganTag = json['veganTag'] as String
    ..vegetarianTag = json['vegetarianTag'] as String
    ..favoriteTag = json['favoriteTag'] as String
    ..todoTag = json['todoTag'] as String
    ..agreedAlphaReleaseNote = json['agreedAlphaReleaseNote'] as bool
    ..showHelp = json['showHelp'] as bool
    ..suggestionAlgo = json['suggestionAlgo'] as String;
}

Map<String, dynamic> _$SettingsManagerToJson(SettingsManager instance) =>
    <String, dynamic>{
      'state': _$SettingsManagerStateEnumMap[instance.state],
      'version': instance.version,
      'ownerMail': instance.ownerMail,
      'veganTag': instance.veganTag,
      'vegetarianTag': instance.vegetarianTag,
      'favoriteTag': instance.favoriteTag,
      'todoTag': instance.todoTag,
      'agreedAlphaReleaseNote': instance.agreedAlphaReleaseNote,
      'showHelp': instance.showHelp,
      'suggestionAlgo': instance.suggestionAlgo,
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

const _$SettingsManagerStateEnumMap = {
  SettingsManagerState.NeedLoad: 'NeedLoad',
  SettingsManagerState.NeedSave: 'NeedSave',
  SettingsManagerState.Synced: 'Synced',
};
