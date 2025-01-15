import 'package:path/path.dart' as p;

import 'craft_exports.dart';

class CraftManifestManager {
  final String installDir;

  bool isVersionssManifestV2Parsed = false;

  CraftVersionsManifestModel? versionsManifestV2;

  CraftManifestManager({required this.installDir}) {
    isVersionssManifestV2Parsed = validateVersionManifest();
    if (isVersionssManifestV2Parsed) {
      loadVersionManifest().then((value) {
        versionsManifestV2 = value;
      });
    }
  }

  String clientManifestPath(String craftVersion) {
    return p.join(installDir, 'versions', craftVersion, '$craftVersion.json');
  }

  bool validateClientManifest(String craftVersion) {
    return File(clientManifestPath(craftVersion)).existsSync();
  }

  bool validateVersionManifest() {
    return File(versionManifestV2Path()).existsSync();
  }

  String versionManifestV2Path() {
    return p.join(installDir, 'versions', 'version_manifest_v2.json');
  }

  Future<CraftClientManifestModel> loadClientManifest(
      String craftVersion) async {
    final file = File(clientManifestPath(craftVersion));
    final manifesto = await file.readAsString();
    final manifestoJson = json.decode(manifesto) as Map<String, dynamic>;

    // parse the json
    return CraftClientManifestModel.fromJson(manifestoJson);
  }

  Future<CraftVersionsManifestModel> loadVersionManifest() async {
    final file = File(versionManifestV2Path());
    final manifesto = await file.readAsString();
    final manifestoJson = json.decode(manifesto) as Map<String, dynamic>;

    // parse the json
    return CraftVersionsManifestModel.fromJson(manifestoJson);
  }

  // download manifest from https://piston-meta.mojang.com/mc/game/version_manifest_v2.json
  Future<CraftVersionsManifestModel> downloadVersionManifest() async {
    await DownloadManager.downloadFile(
        'https://piston-meta.mojang.com/mc/game/version_manifest_v2.json',
        versionManifestV2Path());
    return loadVersionManifest();
  }

  Future<CraftClientManifestModel> downloadClientManifest(
      String craftVersion) async {
    versionsManifestV2 ??= await downloadVersionManifest();

    // find version in manifest
    final version = versionsManifestV2!.versions
        .firstWhere((element) => element.id == craftVersion);

    await DownloadManager.downloadFile(
        version.url, clientManifestPath(craftVersion));
    return loadClientManifest(craftVersion);
  }
}
