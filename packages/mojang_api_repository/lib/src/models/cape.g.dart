// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cape.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cape _$CapeFromJson(Map<String, dynamic> json) => Cape(
      id: json['id'] as String,
      state: json['state'] as String,
      url: json['url'] as String,
      alias: json['alias'] as String,
    );

Map<String, dynamic> _$CapeToJson(Cape instance) => <String, dynamic>{
      'id': instance.id,
      'state': instance.state,
      'url': instance.url,
      'alias': instance.alias,
    };
