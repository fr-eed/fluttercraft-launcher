import 'package:json_annotation/json_annotation.dart';

part 'craft_account.g.dart';

@JsonSerializable(explicitToJson: true)
class CraftProfileModel {
  final String id;
  final String name;

  CraftProfileModel({required this.id, required this.name});

  factory CraftProfileModel.fromJson(Map<String, dynamic> json) =>
      _$CraftProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$CraftProfileModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CraftAccountModel {
  final String accessToken;

  final String clientId;

  final CraftProfileModel profile;

  CraftAccountModel({
    required this.accessToken,
    required this.clientId,
    required this.profile,
  });

  factory CraftAccountModel.fromJson(Map<String, dynamic> json) =>
      _$CraftAccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$CraftAccountModelToJson(this);
}
