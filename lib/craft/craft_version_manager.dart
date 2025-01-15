import 'package:path/path.dart' as p;

import 'craft_exports.dart';

class CraftVersionManager {
  final String installDir;
  final CraftManifestManager manifestManager;

  CraftVersionManager(
      {required this.installDir, required this.manifestManager});

  /// Get a list of valid versions with existing manifests.
  List<String> getValidVersions() {
    final versionsDir = Directory(p.join(installDir, 'versions'));

    if (!versionsDir.existsSync()) {
      return [];
    }

    return versionsDir
        .listSync()
        .whereType<Directory>() // Ensure it's a directory
        .map((entry) => p.basename(entry.path)) // Extract folder names
        .where((version) => manifestManager
            .validateClientManifest(version)) // Ensure manifest exists
        .toList();
  }

  String getJarPath(String craftVersion) {
    return p.join(installDir, 'versions', craftVersion, '$craftVersion.jar');
  }

  String pathToLib(String path) {
    return p.join(installDir, 'libraries', path);
  }

  /// Get the library paths.
  List<String> getLibPaths(CraftClientManifestModel manifesto) {
    final currentOs = CraftOsModel.currentOs();
    final currentFeatures = CraftFeatureModel(
        {}); // features are not generally needed for libraries

    return manifesto.libraries
        .where((library) => library.rules.every((e) => e.isAllowed(
              os: currentOs,
              features: currentFeatures,
            )))
        .map((e) => pathToLib(e.downloads.artifact.path!))
        .toList();
  }

  /// Check if the installation for a valid version is complete.
  Future<bool> isInstallationComplete(String version) async {
    if (!manifestManager.validateClientManifest(version)) return false;
    // check if jar exists
    if (!File(getJarPath(version)).existsSync()) {
      return false;
    }

    // ensure every lib is downloaded
    final manifesto = await manifestManager.loadClientManifest(version);

    final libPaths = getLibPaths(manifesto);

    // check every path
    for (final path in libPaths) {
      if (!File(path).existsSync()) {
        return false;
      }
    }

    return true;
  }

  /// Ensure installation by downloading missing files if necessary.
  Future<void> ensureInstallation(String version) async {
    CraftClientManifestModel manifest;

    if (!manifestManager.validateClientManifest(version)) {
      manifest = await manifestManager.downloadClientManifest(version);
    } else {
      manifest = await manifestManager.loadClientManifest(version);
    }

    // download jar from manifesto
    if (!File(getJarPath(version)).existsSync()) {
      print("Downloading jar for version $version");
      final url = manifest.downloads['client']!.url;

      await DownloadManager.downloadFile(url, getJarPath(version));
    }
    final currentOs = CraftOsModel.currentOs();
    final currentFeatures = CraftFeatureModel({});
    // check every path
    for (final lib in manifest.libraries) {
      final downloadPath = pathToLib(lib.downloads.artifact.path!);

      if (File(downloadPath).existsSync()) {
        continue;
      }

      if (!lib.rules.every((e) => e.isAllowed(
            os: currentOs,
            features: currentFeatures,
          ))) {
        print("Skipping ${lib.name} for version $version because incompatible");
        continue;
      }

      print("Downloading lib ${lib.name} for version $version");
      final url = lib.downloads.artifact.url;
      await DownloadManager.downloadFile(url, downloadPath);
    }

    if (!await isInstallationComplete(version)) {
      throw Exception("Installation incomplete for version $version");
    }

    print("Installation complete for version $version. Have fun!");
  }
}
