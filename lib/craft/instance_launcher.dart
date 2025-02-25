import 'package:fluttercraft_launcher/cubits/auth_cubit.dart';
import 'package:path/path.dart' as p;

import 'craft_exports.dart';

class CraftInstanceLauncher {
  final CraftClientManifestModel manifesto;

  final String installDir;
  final String jarPath;

  final String javaExecutable;

  MinecraftAccount? mcAccount;

  CraftInstanceLauncher(
      {required this.manifesto,
      required this.installDir,
      required this.jarPath,
      required this.javaExecutable,
      this.mcAccount});

  /// Fill in the arguments with the environment variables.
  List<String> _fillArgs({
    required List<String> args,
    required Map<String, String> env,
  }) {
    return args.map((arg) {
      return _FillArg(arg: arg, env: env);
    }).toList();
  }

  static String _FillArg({
    required String arg,
    required Map<String, String> env,
  }) {
    return arg.replaceAllMapped(RegExp(r"\$\{(.+?)\}"), (match) {
      final toInsert = env[match.group(1) ?? ""];
      if (toInsert == null) {
        BeaverLog.warning("Warning: Unknown argument: $arg");
        return "";
      }
      return toInsert;
    });
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
        .map((e) =>
            p.join(installDir, 'libraries', e.downloads.artifact?.path ?? ""))
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
  Future<Process> launch() async {
    if (!validateLibraries()) {
      throw Exception("Libraries not found");
    }
    if (!validateJar()) {
      throw Exception("Jar not found");
    }

    final currentOs = CraftOsModel.currentOs();
    final currentFeatures = CraftFeatureModel({}); // no features

    // Generate the classpath by concatenating each library path
    String classpath = "$jarPath:${getLibPaths().join(":")}";

    Map<String, String> env = {
      "classpath": classpath,
      "natives_directory":
          p.join(installDir, "natives", manifesto.majorVersion),
      "launcher_name": "FlutterCraft",
      "launcher_version": "1.0.0",

      "assets_root": p.join(installDir, "assets"),
      // legacy
      "game_assets": p.join(installDir, "assets"),

      // major is index // will read from assets/index/19.2.json
      "assets_index_name": manifesto.majorVersion,

      "version_name": manifesto.id,
      "version_type": manifesto.type.name,

      // instance
      "game_directory":
          p.join(installDir, "gamedir", "instance0"), // TODO add uuid or smth

      // usr
      "auth_player_name": mcAccount?.username ?? "FlutterCrafter",
      "auth_uuid": mcAccount?.uuid ?? Uuid().v4(),
      "auth_access_token": mcAccount?.accessToken ?? Uuid().v4(),
      "clientid": Uuid().v4(),
      "auth_xuid": mcAccount?.uuid ?? Uuid().v4(),
      "user_type": "microsoft",
    };

    List<String> javaArgs = [];

    if (manifesto.arguments != null) {
      List<String> jvmArgs = manifesto.arguments!.jvm
          .where((element) => element.rules.every((e) => e.isAllowed(
                os: currentOs,
                features: currentFeatures,
              )))
          .expand((element) => element.value)
          .toList();

      List<String> gameArgs = manifesto.arguments!.game
          .where((element) => element.rules.every((e) => e.isAllowed(
                os: currentOs,
                features: currentFeatures,
              )))
          .expand((element) => element.value)
          .toList();

      // jvm args -> java main class -> game args
      javaArgs = [
        ..._fillArgs(args: jvmArgs, env: env),
        manifesto.mainClass,
        ..._fillArgs(args: gameArgs, env: env),
      ];
    } else if (manifesto.minecraftArguments != null) {
      javaArgs = [
        "-cp",
        classpath,
        manifesto.mainClass,
        _FillArg(arg: manifesto.minecraftArguments!, env: env)
      ];
    } else {
      throw Exception("No arguments found");
    }
    // TODO select java version
    final process = await Process.start(javaExecutable, javaArgs,
        workingDirectory: installDir, runInShell: true);

    return process;
  }
}
