// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_manager.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileManager _$ProfileManagerFromJson(Map<String, dynamic> json) {
  $checkKeys(json,
      requiredKeys: const ['version', 'next_uid', 'default_profile']);
  return ProfileManager()
    ..state = _$enumDecodeNullable(_$ProfileManagerStateEnumMap, json['state'])
    ..version = json['version'] as int
    ..next_uid = json['next_uid'] as int
    ..default_profile = json['default_profile'] as int
    ..profiles = (json['profiles'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(int.parse(k),
          e == null ? null : Profile.fromJson(e as Map<String, dynamic>)),
    );
}

Map<String, dynamic> _$ProfileManagerToJson(ProfileManager instance) =>
    <String, dynamic>{
      'state': _$ProfileManagerStateEnumMap[instance.state],
      'version': instance.version,
      'next_uid': instance.next_uid,
      'default_profile': instance.default_profile,
      'profiles': instance.profiles?.map((k, e) => MapEntry(k.toString(), e)),
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

const _$ProfileManagerStateEnumMap = {
  ProfileManagerState.NeedLoad: 'NeedLoad',
  ProfileManagerState.NeedSave: 'NeedSave',
  ProfileManagerState.Synced: 'Synced',
};
