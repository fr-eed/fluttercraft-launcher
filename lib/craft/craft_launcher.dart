import 'craft_exports.dart';

class CraftLauncher {
  final String installDir;

  late CraftManifestManager manifestManager;
  late CraftVersionManager versionManager;
  late JreVersionManager jreVersionManager;
  CraftLauncher({
    required this.installDir,
  }) {
    manifestManager = CraftManifestManager(installDir: installDir);
    versionManager = CraftVersionManager(
        installDir: installDir, manifestManager: manifestManager);

    jreVersionManager = JreVersionManager(installDir: installDir);
  }

  Future<void> init() async {
    // Update manifest to latest
    await manifestManager.downloadVersionManifest();
  }

  Future<Process> launch({required String craftVersion}) async {
    await versionManager.ensureInstallation(craftVersion);

    final jarPath = versionManager.getJarPath(craftVersion);
    // parse the json
    final versionManifest =
        await manifestManager.loadClientManifest(craftVersion);

    final platform = JrePlatform.getSystemJreOs();

    // TODO support defult java version if javaVersion not specified
    // probably find similar version or craft or inherit field
    final codeName = versionManifest.javaVersion != null
        ? JreComponent.fromString(versionManifest.javaVersion!.component)
        : JreComponent.currentUniversal;

    await jreVersionManager.ensureRuntimeInstalled(
        platform: platform, codeName: codeName);

    final javaExecutable = jreVersionManager.findJreJavaExecutable(
        platform: platform, codeName: codeName);

    final launcher = CraftInstanceLauncher(
        manifesto: versionManifest,
        jarPath: jarPath,
        installDir: installDir,
        javaExecutable: javaExecutable);
    return await launcher.launch();
  }
}
