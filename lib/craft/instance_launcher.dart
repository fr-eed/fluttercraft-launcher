import "dart:io";
import 'package:uuid/uuid.dart';

import "./models/version_manifest_model.dart";

class CraftInstanceLauncher {
  final CraftVersionManifestModel manifesto;

  final String installDir;
  final String jarPath;

  CraftInstanceLauncher({
    required this.manifesto,
    required this.installDir,
    required this.jarPath,
  });

  static List<String> _fillArgs({
    required List<String> args,
    required Map<String, String> env,
  }) {
    // go for each arg, and evaluate ${}
    List<String> output = [];

    for (final arg in args) {
      final outputArg = arg.replaceAllMapped(RegExp(r"\$\{(.+?)\}"), (match) {
        return env[match.group(1) ?? ""] ?? "";
      });
      output.add(outputArg);
      if (outputArg == "") {
        // warining
        // TODO add logging
        print("Warning: Unknown argument: $arg");
      }
    }
    return output;
  }

  List<String> getLibPaths() {
    final currentOs = CraftOsModel.currentOs();
    final currentFeatures = CraftFeatureModel({}); // no features

    return manifesto.libraries
        .where((library) {
          return library.rules.every((e) => e.isAllowed(
                os: currentOs,
                features: currentFeatures,
              ));
        })
        .map((e) => "$installDir/libraries/${e.downloads.artifact.path}")
        .toList();
  }

  bool validateLibraries() {
    // check every path exists
    for (final path in getLibPaths()) {
      if (!File(path).existsSync()) {
        return false;
      }
    }
    return true;
  }

  bool validateJar() {
    return File(jarPath).existsSync();
  }

  bool validateInstallation() {
    return validateLibraries() && validateJar();
  }

  void launch() {
    if (!validateLibraries()) {
      throw Exception("Libraries not found");
    }
    if (!validateJar()) {
      throw Exception("Jar not found");
    }

    final currentOs = CraftOsModel.currentOs();
    final currentFeatures = CraftFeatureModel({}); // no features

    List<String> jvmArgs = [];

    for (var element in manifesto.arguments.jvm) {
      if (element.rules.every((e) => e.isAllowed(
            os: currentOs,
            features: currentFeatures,
          ))) {
        jvmArgs.addAll(element.value);
      }
    }

    List<String> gameArgs = [];
    for (var element in manifesto.arguments.game) {
      if (element.rules.every((e) => e.isAllowed(
            os: currentOs,
            features: currentFeatures,
          ))) {
        gameArgs.addAll(element.value);
      }
    }

    // Generate the classpath by concatenating each library path
    String classpath = "$jarPath:${getLibPaths().join(":")}";

    Map<String, String> env = {
      "classpath": classpath,
      "natives_directory": "$installDir/natives",
      "launcher_name": "FluttCraft Launcher",
      "launcher_version": "1.0.0",

      "assets_root": "$installDir/assets",
      "assets_index_name": manifesto
          .majorVersion, // major is index // will read from assets/index/19.2.json

      "version_name": manifesto.id,
      "version_type": manifesto.type,

      // instance
      "game_directory":
          "$installDir/gamedir/instance0", // TODO add uuid or smth

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
