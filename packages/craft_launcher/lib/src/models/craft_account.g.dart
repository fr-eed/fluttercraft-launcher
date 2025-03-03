// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'craft_account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CraftProfileModel _$CraftProfileModelFromJson(Map<String, dynamic> json) =>
    CraftProfileModel(
      id: json['id'] as String,
      name: json['name'] as String,
    );

Map<String, dynamic> _$CraftProfileModelToJson(CraftProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
    };

CraftAccountModel _$CraftAccountModelFromJson(Map<String, dynamic> json) =>
    CraftAccountModel(
      accessToken: json['accessToken'] as String,
      clientId: json['clientId'] as String,
      profile:
          CraftProfileModel.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CraftAccountModelToJson(CraftAccountModel instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'clientId': instance.clientId,
      'profile': instance.profile.toJson(),
    };
