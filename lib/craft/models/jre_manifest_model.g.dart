// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jre_manifest_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JreComponentModel _$JreComponentModelFromJson(Map<String, dynamic> json) =>
    JreComponentModel(
      json['availability'] as Map<String, dynamic>,
      json['version'] as Map<String, dynamic>,
      CraftDownloadModel.fromJson(json['manifest'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JreComponentModelToJson(JreComponentModel instance) =>
    <String, dynamic>{
      'availability': instance.availability,
      'version': instance.version,
      'manifest': instance.manifest.toJson(),
    };

JreManifestModel _$JreManifestModelFromJson(Map<String, dynamic> json) =>
    JreManifestModel(
      (json['manifest'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            $enumDecode(_$JrePlatformEnumMap, k),
            (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(
                  $enumDecode(_$JreComponentEnumMap, k),
                  (e as List<dynamic>)
                      .map((e) =>
                          JreComponentModel.fromJson(e as Map<String, dynamic>))
                      .toList()),
            )),
      ),
    );

Map<String, dynamic> _$JreManifestModelToJson(JreManifestModel instance) =>
    <String, dynamic>{
      'manifest': instance.manifest.map((k, e) => MapEntry(
          _$JrePlatformEnumMap[k]!,
          e.map((k, e) => MapEntry(
              _$JreComponentEnumMap[k]!, e.map((e) => e.toJson()).toList())))),
    };

const _$JreComponentEnumMap = {
  JreComponent.javaRuntimeAlpha: 'java-runtime-alpha',
  JreComponent.javaRuntimeBeta: 'java-runtime-beta',
  JreComponent.javaRuntimeDelta: 'java-runtime-delta',
  JreComponent.javaRuntimeGamma: 'java-runtime-gamma',
  JreComponent.javaRuntimeGammaSnapshot: 'java-runtime-gamma-snapshot',
  JreComponent.jreLegacy: 'jre-legacy',
  JreComponent.minecraftJavaExe: 'minecraft-java-exe',
  JreComponent.other: 'other',
};

const _$JrePlatformEnumMap = {
  JrePlatform.linuxX64: 'linux',
  JrePlatform.linuxX86: 'linux-i386',
  JrePlatform.windowsX64: 'windows-x64',
  JrePlatform.windowsX86: 'windows-x86',
  JrePlatform.windowsArm64: 'windows-arm64',
  JrePlatform.macosX64: 'mac-os',
  JrePlatform.macosArm64: 'mac-os-arm64',
  JrePlatform.gamecore: 'gamecore',
  JrePlatform.other: 'other',
};

JreFileDownloadsModel _$JreFileDownloadsModelFromJson(
        Map<String, dynamic> json) =>
    JreFileDownloadsModel(
      json['lzma'] == null
          ? null
          : CraftDownloadModel.fromJson(json['lzma'] as Map<String, dynamic>),
      CraftDownloadModel.fromJson(json['raw'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JreFileDownloadsModelToJson(
        JreFileDownloadsModel instance) =>
    <String, dynamic>{
      'lzma': instance.lzma?.toJson(),
      'raw': instance.raw.toJson(),
    };

JreFileModel _$JreFileModelFromJson(Map<String, dynamic> json) => JreFileModel(
      type: $enumDecode(_$JreFSItemTypeEnumMap, json['type']),
      target: json['target'] as String?,
      executable: json['executable'] as bool?,
      downloads: json['downloads'] == null
          ? null
          : JreFileDownloadsModel.fromJson(
              json['downloads'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JreFileModelToJson(JreFileModel instance) =>
    <String, dynamic>{
      'type': _$JreFSItemTypeEnumMap[instance.type]!,
      'target': instance.target,
      'executable': instance.executable,
      'downloads': instance.downloads?.toJson(),
    };

const _$JreFSItemTypeEnumMap = {
  JreFSItemType.directory: 'directory',
  JreFSItemType.file: 'file',
  JreFSItemType.link: 'link',
};

JreDownloadManifestModel _$JreDownloadManifestModelFromJson(
        Map<String, dynamic> json) =>
    JreDownloadManifestModel(
      (json['files'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(k, JreFileModel.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$JreDownloadManifestModelToJson(
        JreDownloadManifestModel instance) =>
    <String, dynamic>{
      'files': instance.files.map((k, e) => MapEntry(k, e.toJson())),
    };
