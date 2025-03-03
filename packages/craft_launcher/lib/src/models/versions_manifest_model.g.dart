// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'versions_manifest_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CraftVersionsManifestModel _$CraftVersionsManifestModelFromJson(
        Map<String, dynamic> json) =>
    CraftVersionsManifestModel(
      latest:
          LatestVersionModel.fromJson(json['latest'] as Map<String, dynamic>),
      versions: (json['versions'] as List<dynamic>)
          .map((e) => CraftVersionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CraftVersionsManifestModelToJson(
        CraftVersionsManifestModel instance) =>
    <String, dynamic>{
      'latest': instance.latest.toJson(),
      'versions': instance.versions.map((e) => e.toJson()).toList(),
    };

LatestVersionModel _$LatestVersionModelFromJson(Map<String, dynamic> json) =>
    LatestVersionModel(
      release: json['release'] as String,
      snapshot: json['snapshot'] as String,
    );

Map<String, dynamic> _$LatestVersionModelToJson(LatestVersionModel instance) =>
    <String, dynamic>{
      'release': instance.release,
      'snapshot': instance.snapshot,
    };

CraftVersionModel _$CraftVersionModelFromJson(Map<String, dynamic> json) =>
    CraftVersionModel(
      id: json['id'] as String,
      type: $enumDecode(_$CraftVersionTypeEnumMap, json['type']),
      url: json['url'] as String,
      time: DateTime.parse(json['time'] as String),
      releaseTime: DateTime.parse(json['releaseTime'] as String),
      sha1: json['sha1'] as String?,
      complianceLevel: (json['complianceLevel'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CraftVersionModelToJson(CraftVersionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$CraftVersionTypeEnumMap[instance.type]!,
      'url': instance.url,
      'time': instance.time.toIso8601String(),
      'releaseTime': instance.releaseTime.toIso8601String(),
      'sha1': instance.sha1,
      'complianceLevel': instance.complianceLevel,
    };

const _$CraftVersionTypeEnumMap = {
  CraftVersionType.snapshot: 'snapshot',
  CraftVersionType.release: 'release',
  CraftVersionType.old_beta: 'old_beta',
  CraftVersionType.old_alpha: 'old_alpha',
};
