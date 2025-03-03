// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_index_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CraftAssetObject _$CraftAssetObjectFromJson(Map<String, dynamic> json) =>
    CraftAssetObject(
      hash: json['hash'] as String,
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$CraftAssetObjectToJson(CraftAssetObject instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'size': instance.size,
    };

CraftAssetIndexModel _$CraftAssetIndexModelFromJson(
        Map<String, dynamic> json) =>
    CraftAssetIndexModel(
      objects: (json['objects'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, CraftAssetObject.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$CraftAssetIndexModelToJson(
        CraftAssetIndexModel instance) =>
    <String, dynamic>{
      'objects': instance.objects.map((k, e) => MapEntry(k, e.toJson())),
    };
