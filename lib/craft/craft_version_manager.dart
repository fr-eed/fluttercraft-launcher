import 'package:http/http.dart';
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

  Future<void> _downloadLibs(CraftClientManifestModel manifest) async {
    final currentOs = CraftOsModel.currentOs();
    final currentFeatures = CraftFeatureModel({});
    // check every path
    List<Future> futures = [];
    const chunkSize = 30;
    for (final lib in manifest.libraries) {
      final downloadPath = pathToLib(lib.downloads.artifact.path!);

      if (File(downloadPath).existsSync()) {
        continue;
      }

      if (!lib.rules.every((e) => e.isAllowed(
            os: currentOs,
            features: currentFeatures,
          ))) {
        print(
            "Skipping ${lib.name} for version ${manifest.id} because incompatible");
        continue;
      }

      print("Downloading lib ${lib.name} for version ${manifest.id}");
      final url = lib.downloads.artifact.url;
      futures.add(DownloadManager.downloadFile(url, downloadPath));

      if (futures.length > chunkSize) {
        await Future.wait(futures.take(chunkSize));
        futures = futures.skip(chunkSize).toList();
      }
    }

    await Future.wait(futures);
  }

  Future<void> _downloadJar(CraftClientManifestModel manifest) async {
    // download jar from manifesto
    if (!File(getJarPath(manifest.id)).existsSync()) {
      print("Downloading jar for version ${manifest.id}");
      final url = manifest.downloads['client']!.url;

      await DownloadManager.downloadFile(url, getJarPath(manifest.id));
    }
  }

  Future<void> _downloadAssets(CraftClientManifestModel manifest) async {
    // firstly we should download asset index
    final indexUrl = manifest.assetIndex.url;
    // download is done to assets/indexes/{version}.json

    await DownloadManager.downloadFile(
        indexUrl,
        p.join(
            installDir, 'assets', 'indexes', '${manifest.majorVersion}.json'));

    // read that file
    final index = jsonDecode(File(p.join(
            installDir, 'assets', 'indexes', '${manifest.majorVersion}.json'))
        .readAsStringSync());

    final assetIndex =
        CraftAssetIndexModel.fromJson(index as Map<String, dynamic>);

    List<Future> futures = [];
    const chunkSize = 200;

    final actualSize = assetIndex.objects.values.fold(0, (a, b) => a + b.size);
    int sizeDownloaded = 0;
    // download every asset
    for (final asset in assetIndex.objects.entries) {
      final hash = asset.value.hash;
      final hashId = hash.substring(0, 2);

      final path = p.join(installDir, 'assets', 'objects', hashId, hash);
      final url = "https://resources.download.minecraft.net/$hashId/$hash";
      // check if exists
      if (File(path).existsSync()) {
        continue;
      }

      //print(
      //    "Downloading asset ${asset.key} for version ${manifest.majorVersion}");

      futures.add(DownloadManager.downloadFile(url, path));

      sizeDownloaded += asset.value.size;

      // if futures > chunkSize
      while (futures.length > chunkSize) {
        await Future.wait(futures.take(1));
        futures = futures.skip(1).toList();
        // calculate how much left and draw a progressbar
        final left = actualSize - sizeDownloaded;
        final percent = (sizeDownloaded / actualSize) * 100;
        // TODO move to query download manager
        print("Downloading assets... ${percent.toStringAsFixed(2)}% done");
        print(
            "Left: ${(left / 1024 / 1024).toStringAsFixed(2)} MB (${(left / 1024 / 1024 / 1024).toStringAsFixed(2)} GB)");
      }
    }

    await Future.wait(futures);
  }

  /// Ensure installation by downloading missing files if necessary.
  Future<void> ensureInstallation(String version) async {
    CraftClientManifestModel manifest;

    if (!manifestManager.validateClientManifest(version)) {
      manifest = await manifestManager.downloadClientManifest(version);
    } else {
      manifest = await manifestManager.loadClientManifest(version);
    }

    await _downloadJar(manifest);

    await _downloadLibs(manifest);

    await _downloadAssets(manifest);

    if (!await isInstallationComplete(version)) {
      throw Exception("Installation incomplete for version $version");
    }

    print("Installation complete for version $version. Have fun!");
  }
}
