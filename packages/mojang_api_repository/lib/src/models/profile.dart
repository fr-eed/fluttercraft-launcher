import 'package:json_annotation/json_annotation.dart';
import 'cape.dart';
import 'skin.dart';

part 'profile.g.dart';

@JsonSerializable()
class MinecraftProfile {
  final String id;
  final String name;
  final List<Skin> skins;
  final List<Cape> capes;
  final Map<String, dynamic> profileActions;

  MinecraftProfile({
    required this.id,
    required this.name,
    required this.skins,
    required this.capes,
    required this.profileActions,
  });

  factory MinecraftProfile.fromJson(Map<String, dynamic> json) =>
      _$MinecraftProfileFromJson(json);

  Map<String, dynamic> toJson() => _$MinecraftProfileToJson(this);
}
