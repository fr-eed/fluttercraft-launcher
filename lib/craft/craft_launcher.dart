import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;

import './instance_launcher.dart';
import 'models/client_manifest_model.dart';

class CraftLauncher {
  CraftLauncher();

  String manifestPath(String installDir, String craftVersion) {
    return p.join(installDir, 'versions', craftVersion, '$craftVersion.json');
  }

  String jarPath(String installDir, String craftVersion) {
    return p.join(installDir, 'versions', craftVersion, '$craftVersion.jar');
  }

  Future<CraftClientManifestModel> loadManifest(String path) async {
    final file = File(path);
    final manifesto = await file.readAsString();
    final manifestoJson = json.decode(manifesto) as Map<String, dynamic>;

    // parse the json
    return CraftClientManifestModel.fromJson(manifestoJson);
  }

  Future<void> launch(
      {required String installDir, required String craftVersion}) async {
    final jarPath = this.jarPath(installDir, craftVersion);
    final manifestoPath = this.manifestPath(installDir, craftVersion);

    // read manifesto using file utils
    final file = File(manifestoPath);
    final manifesto = await file.readAsString();
    final manifestoJson = json.decode(manifesto) as Map<String, dynamic>;

    // parse the json
    final versionManifest = CraftClientManifestModel.fromJson(manifestoJson);

    final launcher = CraftInstanceLauncher(
        manifesto: versionManifest, jarPath: jarPath, installDir: installDir);
    launcher.launch();
  }
}
