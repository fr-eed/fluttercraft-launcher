import 'dart:ffi';
import 'dart:io';

import 'package:json_annotation/json_annotation.dart';

part 'version_manifest_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CraftJavaVersionModel {
  final int majorVersion;
  final String component;

  CraftJavaVersionModel(this.majorVersion, this.component);

  factory CraftJavaVersionModel.fromJson(Map<String, dynamic> json) =>
      _$CraftJavaVersionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CraftJavaVersionModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CraftDownloadModel {
  final String url;
  final String sha1;
  final int size;

  final String? path;

  CraftDownloadModel({
    required this.url,
    required this.sha1,
    required this.size,
    this.path,
  });

  factory CraftDownloadModel.fromJson(Map<String, dynamic> json) =>
      _$CraftDownloadModelFromJson(json);

  Map<String, dynamic> toJson() => _$CraftDownloadModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LibraryDownloadsModel {
  final CraftDownloadModel artifact;
  final String? name;

  LibraryDownloadsModel(this.artifact, this.name);

  factory LibraryDownloadsModel.fromJson(Map<String, dynamic> json) =>
      _$LibraryDownloadsModelFromJson(json);

  Map<String, dynamic> toJson() => _$LibraryDownloadsModelToJson(this);
}

enum OsArch {
  x86,
  x64,
  arm32,
  arm64,
  unknown;

  static OsArch getSystemArchitecture() {
    switch (Abi.current()) {
      case Abi.linuxX64:
      case Abi.windowsX64:
      case Abi.macosX64:
        return x64;
      case Abi.linuxIA32:
      case Abi.windowsIA32:
        return x86;
      case Abi.linuxArm64:
      case Abi.androidArm64:
        return arm64;
      case Abi.linuxArm:
      case Abi.androidArm:
        return arm32;
      default:
        return unknown;
    }
  }
}

enum OsType {
  windows,
  linux,
  osx;

  static OsType getSystemOS() {
    if (Platform.isWindows) {
      return OsType.windows;
    } else if (Platform.isLinux) {
      return OsType.linux;
    } else if (Platform.isMacOS) {
      return OsType.osx;
    } else {
      throw Exception("Unsupported OS");
    }
  }
}

@JsonSerializable(explicitToJson: true)
class CraftOsModel {
  OsType? name;
  OsArch? arch;

  CraftOsModel(this.name, this.arch);

  bool compatibleWith(CraftOsModel other) {
    return (name ?? other.name) == other.name &&
        (arch ?? other.arch) == other.arch;
  }

  static CraftOsModel currentOs() => CraftOsModel(
        OsType.getSystemOS(),
        OsArch.getSystemArchitecture(),
      );

  factory CraftOsModel.fromJson(Map<String, dynamic> json) =>
      _$CraftOsModelFromJson(json);

  Map<String, dynamic> toJson() => _$CraftOsModelToJson(this);
}

class CraftFeatureModel {
  Map<String, bool> features;

  CraftFeatureModel(this.features);

  factory CraftFeatureModel.fromJson(Map<String, dynamic> json) =>
      CraftFeatureModel(json.cast<String, bool>());

  Map<String, dynamic> toJson() => {
        ...features,
      };
}

@JsonSerializable(explicitToJson: true)
class CraftRulesModel {
  final String action;
  final CraftOsModel? os;
  final CraftFeatureModel? features;

  CraftRulesModel({
    required this.action,
    this.os,
    this.features,
  });

  bool isAllowed({
    required CraftOsModel os,
    required CraftFeatureModel features,
  }) {
    if (this.os != null) {
      if (!this.os!.compatibleWith(os)) {
        return false;
      }
    }
    if (this.features != null) {
      if (!this
          .features!
          .features
          .entries
          .every((entry) => features.features[entry.key] == entry.value)) {
        return false;
      }
    }
    return true;
  }

  factory CraftRulesModel.fromJson(Map<String, dynamic> json) =>
      _$CraftRulesModelFromJson(json);

  Map<String, dynamic> toJson() => _$CraftRulesModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CraftLibraryModel {
  final String name;

  final LibraryDownloadsModel downloads;

  final List<CraftRulesModel> rules;

  CraftLibraryModel({
    required this.name,
    required this.downloads,
    this.rules = const [],
  });

  factory CraftLibraryModel.fromJson(Map<String, dynamic> json) =>
      _$CraftLibraryModelFromJson(json);

  Map<String, dynamic> toJson() => _$CraftLibraryModelToJson(this);
}

class CraftArgumentModel {
  final List<String> value;
  final List<CraftRulesModel> rules;

  CraftArgumentModel({
    required this.value,
    this.rules = const [],
  });

  // custom from json
  // if map, then name is .value
  // if string then string is name
  factory CraftArgumentModel.fromJson(dynamic json) {
    List<CraftRulesModel> rules = [];
    List<String>? value;

    if (json is Map<String, dynamic>) {
      final rulesJson = json['rules'];
      final valueJson = json['value'];

      if (rulesJson != null) {
        rules = (json['rules'] as List)
            .map((e) => CraftRulesModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (valueJson is List) {
        value = (valueJson).cast<String>();
      } else if (valueJson is String) {
        value = [valueJson];
      } else {
        throw Exception('Invalid argument type ${json['value']}');
      }
    } else if (json is String) {
      value = [json];
    } else {
      throw Exception('Invalid argument type');
    }

    return CraftArgumentModel(value: value, rules: rules);
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'rules': rules.map((e) => e.toJson()).toList(),
      };
}

@JsonSerializable(explicitToJson: true)
class CraftArgumentsModel {
  final List<CraftArgumentModel> game;
  final List<CraftArgumentModel> jvm;

  CraftArgumentsModel({
    required this.game,
    required this.jvm,
  });

  factory CraftArgumentsModel.fromJson(Map<String, dynamic> json) =>
      _$CraftArgumentsModelFromJson(json);

  Map<String, dynamic> toJson() => _$CraftArgumentsModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CraftVersionManifestModel {
  final String id;
  final String mainClass;
  final int minimumLauncherVersion;
  final DateTime releaseTime;
  final String type; // enum in future

  final int complianceLevel;

  final CraftJavaVersionModel javaVersion;

  final Map<String, CraftDownloadModel> downloads;
  final List<CraftLibraryModel> libraries;

  final CraftArgumentsModel arguments;

  CraftVersionManifestModel({
    required this.id,
    required this.mainClass,
    required this.minimumLauncherVersion,
    required this.releaseTime,
    required this.type,
    required this.complianceLevel,
    required this.javaVersion,
    required this.downloads,
    required this.libraries,
    required this.arguments,
  });

  factory CraftVersionManifestModel.fromJson(Map<String, dynamic> json) =>
      _$CraftVersionManifestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CraftVersionManifestModelToJson(this);
}
