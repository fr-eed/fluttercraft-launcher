import 'package:json_annotation/json_annotation.dart';

import 'client_manifest_model.dart';
import 'enums.dart';

part 'jre_manifest_model.g.dart';

@JsonSerializable(explicitToJson: true)
class JreComponentModel {
  Map<String, dynamic> availability;
  Map<String, dynamic> version;

  // same as client manifest
  CraftDownloadModel manifest;

  JreComponentModel(this.availability, this.version, this.manifest);

  factory JreComponentModel.fromJson(Map<String, dynamic> json) =>
      _$JreComponentModelFromJson(json);

  Map<String, dynamic> toJson() => _$JreComponentModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JreManifestModel {
  Map<JrePlatform, Map<JreComponent, List<JreComponentModel>>> manifest;

  JreManifestModel(this.manifest);

  /// Null if doesn't exist
  JreComponentModel? getComponent(
      JrePlatform platform, JreComponent component) {
    return manifest[platform]?[component]?.firstOrNull;
  }

  factory JreManifestModel.fromJson(Map<String, dynamic> json) =>
      _$JreManifestModelFromJson(json);

  Map<String, dynamic> toJson() => _$JreManifestModelToJson(this);
}

enum JreFSItemType {
  directory,
  file,
  link;
}

@JsonSerializable(explicitToJson: true)
class JreFileDownloadsModel {
  CraftDownloadModel? lzma;
  CraftDownloadModel raw;

  JreFileDownloadsModel(this.lzma, this.raw);

  factory JreFileDownloadsModel.fromJson(Map<String, dynamic> json) =>
      _$JreFileDownloadsModelFromJson(json);

  Map<String, dynamic> toJson() => _$JreFileDownloadsModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JreFileModel {
  JreFSItemType type;

  /// for JreFSItemType.link
  String? target;

  /// for JreFSItemType.file
  bool? executable;

  /// for JreFSItemType.file
  JreFileDownloadsModel? downloads;

  JreFileModel(
      {required this.type, this.target, this.executable, this.downloads});

  factory JreFileModel.fromJson(Map<String, dynamic> json) =>
      _$JreFileModelFromJson(json);

  Map<String, dynamic> toJson() => _$JreFileModelToJson(this);
}

@JsonSerializable(explicitToJson: true)
class JreDownloadManifestModel {
  /// key is path
  Map<String, JreFileModel> files;

  JreDownloadManifestModel(this.files);

  factory JreDownloadManifestModel.fromJson(Map<String, dynamic> json) =>
      _$JreDownloadManifestModelFromJson(json);

  Map<String, dynamic> toJson() => _$JreDownloadManifestModelToJson(this);
}
