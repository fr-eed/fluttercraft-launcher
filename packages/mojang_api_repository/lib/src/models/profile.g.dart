// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MinecraftProfile _$MinecraftProfileFromJson(Map<String, dynamic> json) =>
    MinecraftProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      skins: (json['skins'] as List<dynamic>)
          .map((e) => Skin.fromJson(e as Map<String, dynamic>))
          .toList(),
      capes: (json['capes'] as List<dynamic>)
          .map((e) => Cape.fromJson(e as Map<String, dynamic>))
          .toList(),
      profileActions: json['profileActions'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$MinecraftProfileToJson(MinecraftProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'skins': instance.skins,
      'capes': instance.capes,
      'profileActions': instance.profileActions,
    };
