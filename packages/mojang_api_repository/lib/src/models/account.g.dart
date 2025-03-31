// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MinecraftAccount _$MinecraftAccountFromJson(Map<String, dynamic> json) =>
    MinecraftAccount(
      uuid: json['uuid'] as String,
      authStatus: $enumDecode(_$AuthStatusEnumMap, json['authStatus']),
      accessToken: json['accessToken'] as String?,
      tokenExpiry: json['tokenExpiry'] == null
          ? null
          : DateTime.parse(json['tokenExpiry'] as String),
      profile: json['profile'] == null
          ? null
          : MinecraftProfile.fromJson(json['profile'] as Map<String, dynamic>),
      authException: json['authException'] == null
          ? null
          : AuthException.fromJson(
              json['authException'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$MinecraftAccountToJson(MinecraftAccount instance) =>
    <String, dynamic>{
      'uuid': instance.uuid,
      'authStatus': _$AuthStatusEnumMap[instance.authStatus]!,
      'accessToken': instance.accessToken,
      'tokenExpiry': instance.tokenExpiry?.toIso8601String(),
      'profile': instance.profile,
      'authException': instance.authException,
    };

const _$AuthStatusEnumMap = {
  AuthStatus.initial: 'initial',
  AuthStatus.authenticating: 'authenticating',
  AuthStatus.authenticated: 'authenticated',
  AuthStatus.failed: 'failed',
};

AccountException _$AccountExceptionFromJson(Map<String, dynamic> json) =>
    AccountException(
      json['message'] as String,
    );

Map<String, dynamic> _$AccountExceptionToJson(AccountException instance) =>
    <String, dynamic>{
      'message': instance.message,
    };

AuthException _$AuthExceptionFromJson(Map<String, dynamic> json) =>
    AuthException(
      json['message'] as String,
    );

Map<String, dynamic> _$AuthExceptionToJson(AuthException instance) =>
    <String, dynamic>{
      'message': instance.message,
    };

LaunchException _$LaunchExceptionFromJson(Map<String, dynamic> json) =>
    LaunchException(
      json['message'] as String,
    );

Map<String, dynamic> _$LaunchExceptionToJson(LaunchException instance) =>
    <String, dynamic>{
      'message': instance.message,
    };

AccountNotFoundException _$AccountNotFoundExceptionFromJson(
        Map<String, dynamic> json) =>
    AccountNotFoundException(
      json['message'] as String,
    );

Map<String, dynamic> _$AccountNotFoundExceptionToJson(
        AccountNotFoundException instance) =>
    <String, dynamic>{
      'message': instance.message,
    };
