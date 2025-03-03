import 'package:json_annotation/json_annotation.dart';
import 'profile.dart';

part 'account.g.dart';

@JsonSerializable()
class MinecraftAccount {
  final String accessToken;
  final DateTime tokenExpiry;
  final MinecraftProfile profile;

  MinecraftAccount({
    required this.accessToken,
    required this.tokenExpiry,
    required this.profile,
  });

  factory MinecraftAccount.fromJson(Map<String, dynamic> json) =>
      _$MinecraftAccountFromJson(json);

  Map<String, dynamic> toJson() => _$MinecraftAccountToJson(this);

  bool get isTokenValid => DateTime.now().isBefore(tokenExpiry);
}
