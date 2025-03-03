// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_JreComponentEnumWrapper _$JreComponentEnumWrapperFromJson(
        Map<String, dynamic> json) =>
    _JreComponentEnumWrapper(
      $enumDecode(_$JreComponentEnumMap, json['name']),
    );

Map<String, dynamic> _$JreComponentEnumWrapperToJson(
        _JreComponentEnumWrapper instance) =>
    <String, dynamic>{
      'name': _$JreComponentEnumMap[instance.name]!,
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

_JrePlatformEnumWrapper _$JrePlatformEnumWrapperFromJson(
        Map<String, dynamic> json) =>
    _JrePlatformEnumWrapper(
      $enumDecode(_$JrePlatformEnumMap, json['name']),
    );

Map<String, dynamic> _$JrePlatformEnumWrapperToJson(
        _JrePlatformEnumWrapper instance) =>
    <String, dynamic>{
      'name': _$JrePlatformEnumMap[instance.name]!,
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
