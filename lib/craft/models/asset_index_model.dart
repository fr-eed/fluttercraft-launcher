import 'package:json_annotation/json_annotation.dart';

part 'asset_index_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CraftAssetObject {
  final String hash;
  final int size;

  CraftAssetObject({required this.hash, required this.size});

  factory CraftAssetObject.fromJson(Map<String, dynamic> json) =>
      _$CraftAssetObjectFromJson(json);

  Map<String, dynamic> toJson() => _$CraftAssetObjectToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CraftAssetIndexModel {
  final Map<String, CraftAssetObject> objects;

  CraftAssetIndexModel({required this.objects});

  factory CraftAssetIndexModel.fromJson(Map<String, dynamic> json) =>
      _$CraftAssetIndexModelFromJson(json);

  Map<String, dynamic> toJson() => _$CraftAssetIndexModelToJson(this);
}
