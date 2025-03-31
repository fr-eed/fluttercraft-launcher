import 'package:json_annotation/json_annotation.dart';
import 'profile.dart';

part 'account.g.dart';

enum AuthStatus { initial, authenticating, authenticated, failed }

@JsonSerializable()
class MinecraftAccount {
  final String uuid;
  final AuthStatus authStatus;
  final String? accessToken;
  final DateTime? tokenExpiry;
  final MinecraftProfile? profile;
  final AuthException? authException;

  MinecraftAccount({
    required this.uuid,
    required this.authStatus,
    this.accessToken,
    this.tokenExpiry,
    this.profile,
    this.authException,
  });

  bool get isTokenValid =>
      tokenExpiry != null && DateTime.now().isBefore(tokenExpiry!);

  MinecraftAccount copyWith({
    String? uuid,
    AuthStatus? authStatus,
    String? accessToken,
    DateTime? tokenExpiry,
    MinecraftProfile? profile,
    AuthException? authException,
  }) {
    return MinecraftAccount(
      uuid: uuid ?? this.uuid,
      authStatus: authStatus ?? this.authStatus,
      accessToken: accessToken ?? this.accessToken,
      tokenExpiry: tokenExpiry ?? this.tokenExpiry,
      profile: profile ?? this.profile,
      authException: authException ?? this.authException,
    );
  }

  factory MinecraftAccount.fromJson(Map<String, dynamic> json) =>
      _$MinecraftAccountFromJson(json);

  Map<String, dynamic> toJson() => _$MinecraftAccountToJson(this);
}

@JsonSerializable()
class AccountException implements Exception {
  final String message;

  AccountException(this.message);

  @override
  String toString() => 'AccountException: $message';

  factory AccountException.fromJson(Map<String, dynamic> json) =>
      _$AccountExceptionFromJson(json);

  Map<String, dynamic> toJson() => _$AccountExceptionToJson(this);
}

@JsonSerializable()
class AuthException extends AccountException {
  AuthException(super.message);

  factory AuthException.fromJson(Map<String, dynamic> json) =>
      _$AuthExceptionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AuthExceptionToJson(this);
}

@JsonSerializable()
class LaunchException extends AccountException {
  LaunchException(super.message);

  factory LaunchException.fromJson(Map<String, dynamic> json) =>
      _$LaunchExceptionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LaunchExceptionToJson(this);
}

@JsonSerializable()
class AccountNotFoundException extends AccountException {
  AccountNotFoundException(super.message);

  factory AccountNotFoundException.fromJson(Map<String, dynamic> json) =>
      _$AccountNotFoundExceptionFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AccountNotFoundExceptionToJson(this);
}
