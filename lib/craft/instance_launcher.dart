import "dart:io";

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import "models/client_manifest_model.dart";

class CraftInstanceLauncher {
  final CraftClientManifestModel manifesto;

  final String installDir;
  final String jarPath;

  CraftInstanceLauncher({
    required this.manifesto,
    required this.installDir,
    required this.jarPath,
  });

  /// Fill in the arguments with the environment variables.
  List<String> _fillArgs({
    required List<String> args,
    required Map<String, String> env,
  }) {
    return args.map((arg) {
      return arg.replaceAllMapped(RegExp(r"\$\{(.+?)\}"), (match) {
        final toInsert = env[match.group(1) ?? ""];
        if (toInsert == null) {
          print("Warning: Unknown argument: $arg");
          return "";
        }
        return toInsert;
      });
    }).toList();
  }

  /// Get the library paths.
  List<String> getLibPaths() {
    final currentOs = CraftOsModel.currentOs();
    final currentFeatures = CraftFeatureModel({}); // no features

    return manifesto.libraries
        .where((library) => library.rules.every((e) => e.isAllowed(
              os: currentOs,
              features: currentFeatures,
            )))
        .map((e) => p.join(installDir, 'libraries', e.downloads.artifact.path))
        .toList();
  }

  /// Validate the libraries.
  bool validateLibraries() {
    // check every path exists
    for (final path in getLibPaths()) {
      if (!File(path).existsSync()) {
        return false;
      }
    }
    return true;
  }

  /// Validate the jar.
  bool validateJar() {
    return File(jarPath).existsSync();
  }

  /// Validate the installation.
  bool validateInstallation() {
    return validateLibraries() && validateJar();
  }

  /// Launch the instance.
  void launch() {
    if (!validateLibraries()) {
      throw Exception("Libraries not found");
    }
    if (!validateJar()) {
      throw Exception("Jar not found");
    }

    final currentOs = CraftOsModel.currentOs();
    final currentFeatures = CraftFeatureModel({}); // no features

    List<String> jvmArgs = manifesto.arguments.jvm
        .where((element) => element.rules.every((e) => e.isAllowed(
              os: currentOs,
              features: currentFeatures,
            )))
        .expand((element) => element.value)
        .toList();

    List<String> gameArgs = manifesto.arguments.game
        .where((element) => element.rules.every((e) => e.isAllowed(
              os: currentOs,
              features: currentFeatures,
            )))
        .expand((element) => element.value)
        .toList();

    // Generate the classpath by concatenating each library path
    String classpath = "$jarPath:${getLibPaths().join(":")}";

    Map<String, String> env = {
      "classpath": classpath,
      "natives_directory": p.join(installDir, "natives"),
      "launcher_name": "FluttCraft Launcher",
      "launcher_version": "1.0.0",

      "assets_root": p.join(installDir, "assets"),

      // major is index // will read from assets/index/19.2.json
      "assets_index_name": manifesto.majorVersion,

      "version_name": manifesto.id,
      "version_type": manifesto.type.name,

      // instance
      "game_directory":
          p.join(installDir, "gamedir", "instance0"), // TODO add uuid or smth

      // usr
      "auth_player_name": "FluttCrafter",
      "auth_uuid": Uuid().v4(),
      "auth_access_token": Uuid().v4(),
      "clientid": Uuid().v4(),
      "auth_xuid": Uuid().v4(),
      "user_type": "mojang",
    };

    // jvm args -> java main class -> game args
    final javaArgs = [
      ..._fillArgs(args: jvmArgs, env: env),
      manifesto.mainClass,
      ..._fillArgs(args: gameArgs, env: env),
    ];
    // TODO select java version
    final result = Process.runSync(
      'java',
      javaArgs,
      workingDirectory: installDir,
    );
    if (result.exitCode != 0) {
      throw Exception(result.stderr);
    }
  }
}
