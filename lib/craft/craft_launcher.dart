import 'craft_exports.dart';

class CraftLauncher {
  final String installDir;

  late CraftManifestManager manifestManager;
  late CraftVersionManager versionManager;

  CraftLauncher({
    required this.installDir,
  }) {
    manifestManager = CraftManifestManager(installDir: installDir);
    versionManager = CraftVersionManager(
        installDir: installDir, manifestManager: manifestManager);
    init();
  }

  Future<void> init() async {
    // downlaod manifest if not downloaded
    if (!manifestManager.isVersionssManifestV2Parsed) {
      await manifestManager.downloadVersionManifest();
      print("Downloaded manifest");
    }
  }

  Future<void> launch({required String craftVersion}) async {
    await versionManager.ensureInstallation(craftVersion);

    final jarPath = versionManager.getJarPath(craftVersion);
    // parse the json
    final versionManifest =
        await manifestManager.loadClientManifest(craftVersion);

    final launcher = CraftInstanceLauncher(
        manifesto: versionManifest, jarPath: jarPath, installDir: installDir);
    launcher.launch();
  }
}
