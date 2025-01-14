import 'dart:convert';
import 'dart:io';

import './instance_launcher.dart';
import './models/version_manifest_model.dart';

class CraftLauncher {
  CraftLauncher();

  Future<void> launch(
      {required String installDir, required String craftVersion}) async {
    final jarPath = "$installDir/versions/$craftVersion/$craftVersion.jar";

    final manifestoPath =
        "$installDir/versions/$craftVersion/$craftVersion.json";
    // read manifesto using file utils
    final file = File(manifestoPath);
    final manifesto = await file.readAsString();
    final manifestoJson = json.decode(manifesto) as Map<String, dynamic>;

    // parse the json
    final versionManifest = CraftVersionManifestModel.fromJson(manifestoJson);

    final launcher = CraftInstanceLauncher(
        manifesto: versionManifest, jarPath: jarPath, installDir: installDir);
    launcher.launch();
  }
}
