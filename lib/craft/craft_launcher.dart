import 'dart:async';

import 'package:fluttercraft_launcher/cubits/auth_cubit.dart';

import 'craft_exports.dart';

class CraftLauncherState {
  static CraftLauncher? launcher;
}

class CraftLauncher {
  final String installDir;

  late CraftManifestManager manifestManager;
  late CraftVersionManager versionManager;
  late JreVersionManager jreVersionManager;

  bool isRunning = false;

  Process? _runningProcess;

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
    await jreVersionManager.init();
    await manifestManager.downloadVersionManifest();
  }

  Future<Process> launch(
      {required String craftVersion, MinecraftAccount? mcAccount}) async {
    isRunning = true;
    try {
      await versionManager.ensureInstallation(craftVersion);

      final jarPath = versionManager.getJarPath(craftVersion);
      // parse the json
      final versionManifest =
          await manifestManager.loadClientManifest(craftVersion);

      final platform = JrePlatform.getSystemJreOs();

      // TODO support default java version if javaVersion not specified
      // probably find similar version or craft or inherit field
      final codeName = versionManifest.javaVersion != null
          ? JreComponent.fromString(versionManifest.javaVersion!.component)
          : JreComponent.currentUniversal;

      await jreVersionManager.ensureRuntimeInstalled(
          platform: platform, codeName: codeName);

      final javaExecutable = await jreVersionManager
          .findJreExecutableByManifest(platform: platform, codeName: codeName);

      final launcher = CraftInstanceLauncher(
          manifesto: versionManifest,
          jarPath: jarPath,
          installDir: installDir,
          javaExecutable: javaExecutable,
          mcAccount: mcAccount);

      BeaverLog.info("Launching instance with version $craftVersion");

      _runningProcess = await launcher.launch();

      // watch running process until end in background
      // TODO create mc process manager class
      unawaited(_runningProcess!.exitCode.then((value) {
        isRunning = false;
      }));

      return _runningProcess!;
    } catch (e) {
      isRunning = false;
      rethrow;
    }
  }
}
