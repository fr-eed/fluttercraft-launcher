// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_manifest_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CraftJavaVersionModel _$CraftJavaVersionModelFromJson(
        Map<String, dynamic> json) =>
    CraftJavaVersionModel(
      (json['majorVersion'] as num).toInt(),
      json['component'] as String,
    );

Map<String, dynamic> _$CraftJavaVersionModelToJson(
        CraftJavaVersionModel instance) =>
    <String, dynamic>{
      'majorVersion': instance.majorVersion,
      'component': instance.component,
    };

CraftDownloadModel _$CraftDownloadModelFromJson(Map<String, dynamic> json) =>
    CraftDownloadModel(
      url: json['url'] as String,
      sha1: json['sha1'] as String,
      size: (json['size'] as num).toInt(),
    );

Map<String, dynamic> _$CraftDownloadModelToJson(CraftDownloadModel instance) =>
    <String, dynamic>{
      'url': instance.url,
      'sha1': instance.sha1,
      'size': instance.size,
    };

CraftLibDownloadModel _$CraftLibDownloadModelFromJson(
        Map<String, dynamic> json) =>
    CraftLibDownloadModel(
      url: json['url'] as String,
      sha1: json['sha1'] as String,
      size: (json['size'] as num).toInt(),
      path: json['path'] as String,
    );

Map<String, dynamic> _$CraftLibDownloadModelToJson(
        CraftLibDownloadModel instance) =>
    <String, dynamic>{
      'url': instance.url,
      'sha1': instance.sha1,
      'size': instance.size,
      'path': instance.path,
    };

LibraryDownloadsModel _$LibraryDownloadsModelFromJson(
        Map<String, dynamic> json) =>
    LibraryDownloadsModel(
      artifact: json['artifact'] == null
          ? null
          : CraftLibDownloadModel.fromJson(
              json['artifact'] as Map<String, dynamic>),
      classifiers: (json['classifiers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k, CraftLibDownloadModel.fromJson(e as Map<String, dynamic>)),
      ),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$LibraryDownloadsModelToJson(
        LibraryDownloadsModel instance) =>
    <String, dynamic>{
      'artifact': instance.artifact?.toJson(),
      'classifiers':
          instance.classifiers?.map((k, e) => MapEntry(k, e.toJson())),
      'name': instance.name,
    };

CraftOsModel _$CraftOsModelFromJson(Map<String, dynamic> json) => CraftOsModel(
      $enumDecodeNullable(_$OsTypeEnumMap, json['name']),
      $enumDecodeNullable(_$OsArchEnumMap, json['arch']),
    );

Map<String, dynamic> _$CraftOsModelToJson(CraftOsModel instance) =>
    <String, dynamic>{
      'name': _$OsTypeEnumMap[instance.name],
      'arch': _$OsArchEnumMap[instance.arch],
    };

const _$OsTypeEnumMap = {
  OsType.windows: 'windows',
  OsType.linux: 'linux',
  OsType.osx: 'osx',
};

const _$OsArchEnumMap = {
  OsArch.x64: 'x64',
  OsArch.x86: 'x86',
  OsArch.arm64: 'arm64',
  OsArch.unknown: 'unknown',
};

CraftRulesModel _$CraftRulesModelFromJson(Map<String, dynamic> json) =>
    CraftRulesModel(
      action: $enumDecode(_$RuleActionEnumMap, json['action']),
      os: json['os'] == null
          ? null
          : CraftOsModel.fromJson(json['os'] as Map<String, dynamic>),
      features: json['features'] == null
          ? null
          : CraftFeatureModel.fromJson(
              json['features'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CraftRulesModelToJson(CraftRulesModel instance) =>
    <String, dynamic>{
      'action': _$RuleActionEnumMap[instance.action]!,
      'os': instance.os?.toJson(),
      'features': instance.features?.toJson(),
    };

const _$RuleActionEnumMap = {
  RuleAction.allow: 'allow',
  RuleAction.disallow: 'disallow',
};

CraftLibraryModel _$CraftLibraryModelFromJson(Map<String, dynamic> json) =>
    CraftLibraryModel(
      name: json['name'] as String,
      downloads: LibraryDownloadsModel.fromJson(
          json['downloads'] as Map<String, dynamic>),
      rules: (json['rules'] as List<dynamic>?)
              ?.map((e) => CraftRulesModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$CraftLibraryModelToJson(CraftLibraryModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'downloads': instance.downloads.toJson(),
      'rules': instance.rules.map((e) => e.toJson()).toList(),
    };

CraftArgumentsModel _$CraftArgumentsModelFromJson(Map<String, dynamic> json) =>
    CraftArgumentsModel(
      game: (json['game'] as List<dynamic>)
          .map(CraftArgumentModel.fromJson)
          .toList(),
      jvm: (json['jvm'] as List<dynamic>)
          .map(CraftArgumentModel.fromJson)
          .toList(),
    );

Map<String, dynamic> _$CraftArgumentsModelToJson(
        CraftArgumentsModel instance) =>
    <String, dynamic>{
      'game': instance.game.map((e) => e.toJson()).toList(),
      'jvm': instance.jvm.map((e) => e.toJson()).toList(),
    };

CraftAssetIndex _$CraftAssetIndexFromJson(Map<String, dynamic> json) =>
    CraftAssetIndex(
      id: json['id'] as String,
      sha1: json['sha1'] as String,
      size: (json['size'] as num).toInt(),
      totalSize: (json['totalSize'] as num).toInt(),
      url: json['url'] as String,
    );

Map<String, dynamic> _$CraftAssetIndexToJson(CraftAssetIndex instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sha1': instance.sha1,
      'size': instance.size,
      'totalSize': instance.totalSize,
      'url': instance.url,
    };

CraftClientManifestModel _$CraftClientManifestModelFromJson(
        Map<String, dynamic> json) =>
    CraftClientManifestModel(
      id: json['id'] as String,
      mainClass: json['mainClass'] as String,
      minimumLauncherVersion: (json['minimumLauncherVersion'] as num).toInt(),
      releaseTime: DateTime.parse(json['releaseTime'] as String),
      type: $enumDecode(_$CraftVersionTypeEnumMap, json['type']),
      complianceLevel: (json['complianceLevel'] as num?)?.toInt(),
      javaVersion: json['javaVersion'] == null
          ? null
          : CraftJavaVersionModel.fromJson(
              json['javaVersion'] as Map<String, dynamic>),
      downloads: (json['downloads'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, CraftDownloadModel.fromJson(e as Map<String, dynamic>)),
      ),
      libraries: (json['libraries'] as List<dynamic>)
          .map((e) => CraftLibraryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      assetIndex:
          CraftAssetIndex.fromJson(json['assetIndex'] as Map<String, dynamic>),
      arguments: json['arguments'] == null
          ? null
          : CraftArgumentsModel.fromJson(
              json['arguments'] as Map<String, dynamic>),
      minecraftArguments: json['minecraftArguments'] as String?,
    );

Map<String, dynamic> _$CraftClientManifestModelToJson(
        CraftClientManifestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mainClass': instance.mainClass,
      'minimumLauncherVersion': instance.minimumLauncherVersion,
      'releaseTime': instance.releaseTime.toIso8601String(),
      'type': _$CraftVersionTypeEnumMap[instance.type]!,
      'complianceLevel': instance.complianceLevel,
      'javaVersion': instance.javaVersion?.toJson(),
      'downloads': instance.downloads.map((k, e) => MapEntry(k, e.toJson())),
      'libraries': instance.libraries.map((e) => e.toJson()).toList(),
      'arguments': instance.arguments?.toJson(),
      'minecraftArguments': instance.minecraftArguments,
      'assetIndex': instance.assetIndex.toJson(),
    };

const _$CraftVersionTypeEnumMap = {
  CraftVersionType.snapshot: 'snapshot',
  CraftVersionType.release: 'release',
  CraftVersionType.old_beta: 'old_beta',
  CraftVersionType.old_alpha: 'old_alpha',
};
