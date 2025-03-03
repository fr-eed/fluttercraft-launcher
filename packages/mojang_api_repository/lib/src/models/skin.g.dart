// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Skin _$SkinFromJson(Map<String, dynamic> json) => Skin(
      id: json['id'] as String,
      state: json['state'] as String,
      url: json['url'] as String,
      textureKey: json['textureKey'] as String,
      variant: json['variant'] as String,
    );

Map<String, dynamic> _$SkinToJson(Skin instance) => <String, dynamic>{
      'id': instance.id,
      'state': instance.state,
      'url': instance.url,
      'textureKey': instance.textureKey,
      'variant': instance.variant,
    };
