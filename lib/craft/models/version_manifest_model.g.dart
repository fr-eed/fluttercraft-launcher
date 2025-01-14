// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_manifest_model.dart';

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
      path: json['path'] as String?,
    );

Map<String, dynamic> _$CraftDownloadModelToJson(CraftDownloadModel instance) =>
    <String, dynamic>{
      'url': instance.url,
      'sha1': instance.sha1,
      'size': instance.size,
      'path': instance.path,
    };

LibraryDownloadsModel _$LibraryDownloadsModelFromJson(
        Map<String, dynamic> json) =>
    LibraryDownloadsModel(
      CraftDownloadModel.fromJson(json['artifact'] as Map<String, dynamic>),
      json['name'] as String?,
    );

Map<String, dynamic> _$LibraryDownloadsModelToJson(
        LibraryDownloadsModel instance) =>
    <String, dynamic>{
      'artifact': instance.artifact.toJson(),
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
  OsArch.x86: 'x86',
  OsArch.x64: 'x64',
  OsArch.arm32: 'arm32',
  OsArch.arm64: 'arm64',
  OsArch.unknown: 'unknown',
};

CraftRulesModel _$CraftRulesModelFromJson(Map<String, dynamic> json) =>
    CraftRulesModel(
      json['action'] as String,
      json['os'] == null
          ? null
          : CraftOsModel.fromJson(json['os'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CraftRulesModelToJson(CraftRulesModel instance) =>
    <String, dynamic>{
      'action': instance.action,
      'os': instance.os?.toJson(),
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

CraftVersionManifestModel _$CraftVersionManifestModelFromJson(
        Map<String, dynamic> json) =>
    CraftVersionManifestModel(
      id: json['id'] as String,
      mainClass: json['mainClass'] as String,
      minimumLauncherVersion: (json['minimumLauncherVersion'] as num).toInt(),
      releaseTime: DateTime.parse(json['releaseTime'] as String),
      type: json['type'] as String,
      complianceLevel: (json['complianceLevel'] as num).toInt(),
      javaVersion: CraftJavaVersionModel.fromJson(
          json['javaVersion'] as Map<String, dynamic>),
      downloads: (json['downloads'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, CraftDownloadModel.fromJson(e as Map<String, dynamic>)),
      ),
      libraries: (json['libraries'] as List<dynamic>)
          .map((e) => CraftLibraryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      arguments: CraftArgumentsModel.fromJson(
          json['arguments'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CraftVersionManifestModelToJson(
        CraftVersionManifestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mainClass': instance.mainClass,
      'minimumLauncherVersion': instance.minimumLauncherVersion,
      'releaseTime': instance.releaseTime.toIso8601String(),
      'type': instance.type,
      'complianceLevel': instance.complianceLevel,
      'javaVersion': instance.javaVersion.toJson(),
      'downloads': instance.downloads.map((k, e) => MapEntry(k, e.toJson())),
      'libraries': instance.libraries.map((e) => e.toJson()).toList(),
      'arguments': instance.arguments.toJson(),
    };
