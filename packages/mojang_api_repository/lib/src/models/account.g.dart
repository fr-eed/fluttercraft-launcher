// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MinecraftAccount _$MinecraftAccountFromJson(Map<String, dynamic> json) =>
    MinecraftAccount(
      accessToken: json['accessToken'] as String,
      tokenExpiry: DateTime.parse(json['tokenExpiry'] as String),
      profile:
          MinecraftProfile.fromJson(json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MinecraftAccountToJson(MinecraftAccount instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'tokenExpiry': instance.tokenExpiry.toIso8601String(),
      'profile': instance.profile,
    };
