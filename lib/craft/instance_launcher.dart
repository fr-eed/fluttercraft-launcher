import "dart:io";

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

  List<String> getLibPaths() {
    final currentOs = CraftOsModel.currentOs();
    return manifesto.libraries
        .where((library) {
          for (final rule in library.rules) {
            if (rule.os != null) {
              if (!rule.os!.compatibleWith(currentOs)) {
                return false;
              }
            }
          }
          return true;
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
    // Define the path to the JSON file

    if (!validateLibraries()) {
      throw Exception("Libraries not found");
    }
    if (!validateJar()) {
      throw Exception("Jar not found");
    }

    List<String> jvmArgs = [];
    for (var element in manifesto.arguments.jvm) {
      jvmArgs.add(element.value);
    }
    List<String> gameArgs = [];
    for (var element in manifesto.arguments.game) {
      gameArgs.add(element.value);
    }

    // TODO insert and fill variables into gameArgs and jvmArgs

    // Generate the classpath by concatenating each library path
    String classpath = "$jarPath:${getLibPaths().join(":")}";

    // Generate the Java command with the updated classpath
    final javaCommand = [
      "java",
      "-XstartOnFirstThread",
      "-Djava.library.path=$installDir/libraries",
      "-Dminecraft.launcher.brand=launcher",
      "-Dminecraft.launcher.version=1.0",
      "-cp",
      classpath,
      "net.minecraft.client.main.Main",
      "--accessToken",
      "",
      "--version",
      manifesto.id,
      "--username",
      "username"
    ];

    final result = Process.runSync(
      javaCommand[0],
      javaCommand.sublist(1),
      workingDirectory: installDir,
    );

    if (result.exitCode != 0) {
      throw Exception(result.stderr);
    }
  }
}
