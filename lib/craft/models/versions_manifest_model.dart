import 'package:json_annotation/json_annotation.dart';

import 'enums.dart';

part 'versions_manifest_model.g.dart';

@JsonSerializable(explicitToJson: true)
class CraftVersionsManifestModel {
  final LatestVersionModel latest;
  final List<CraftVersionModel> versions;

  CraftVersionsManifestModel({
    required this.latest,
    required this.versions,
  });

  factory CraftVersionsManifestModel.fromJson(Map<String, dynamic> json) =>
      _$CraftVersionsManifestModelFromJson(json);

  Map<String, dynamic> toJson() => _$CraftVersionsManifestModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class LatestVersionModel {
  final String release;
  final String snapshot;

  LatestVersionModel({
    required this.release,
    required this.snapshot,
  });

  factory LatestVersionModel.fromJson(Map<String, dynamic> json) =>
      _$LatestVersionModelFromJson(json);

  Map<String, dynamic> toJson() => _$LatestVersionModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CraftVersionModel {
  final String id;
  final CraftVersionType type; // release/snapshot
  final String url;
  final DateTime time;
  final DateTime releaseTime;

  String get majorVersion {
    // if contains ., then split and take first 2
    if (id.contains('.')) {
      return ('${id.split('.')[0]}.${id.split('.')[1]}'); // 19.1 from 19.1.2
    } else {
      return id; // snapshot or something, idk
    }
  }

  //he SHA1 hash of the version and therefore the JSON file ID. (manifest v2)
  final String? sha1;

  //  If 0, the launcher warns the user about this version not being recent enough to support the latest player safety features. Its value is 1 otherwise.
  final int? complianceLevel;

  // v2:
  // https://piston-meta.mojang.com/mc/game/version_manifest_v2.json
  // v1:
  // https://launchermeta.mojang.com/mc/game/version_manifest.json

  CraftVersionModel({
    required this.id,
    required this.type,
    required this.url,
    required this.time,
    required this.releaseTime,
    this.sha1,
    this.complianceLevel,
  });

  factory CraftVersionModel.fromJson(Map<String, dynamic> json) =>
      _$CraftVersionModelFromJson(json);

  Map<String, dynamic> toJson() => _$CraftVersionModelToJson(this);
}
