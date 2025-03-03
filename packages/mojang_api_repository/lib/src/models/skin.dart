import 'package:json_annotation/json_annotation.dart';

part 'skin.g.dart';

@JsonSerializable()
class Skin {
  final String id;
  final String state;
  final String url;
  final String textureKey;
  final String variant;

  Skin({
    required this.id,
    required this.state,
    required this.url,
    required this.textureKey,
    required this.variant,
  });

  factory Skin.fromJson(Map<String, dynamic> json) => _$SkinFromJson(json);

  Map<String, dynamic> toJson() => _$SkinToJson(this);
}
