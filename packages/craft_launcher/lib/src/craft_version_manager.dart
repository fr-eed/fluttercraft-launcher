import 'package:path/path.dart' as p;

import 'craft_exports.dart';

class CraftVersionManager {
  final String installDir;
  final CraftManifestManager manifestManager;

  CraftVersionManager(
      {required this.installDir, required this.manifestManager});

  /// Read version list from versions folder. Might include both downloaded, touched and externally imported versions
  List<String> getTouchedVersions() {
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
        .map((e) => pathToLib(e.downloads.artifact?.path ?? ""))
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
      if (!File(path).existsSync() &&
          !Link(path).existsSync() &&
          !Directory(path).existsSync()) {
        return false;
      }
    }

    return true;
  }

  Future<void> _downloadLibs(CraftClientManifestModel manifest) async {
    final currentOs = CraftOsModel.currentOs();
    final currentFeatures = CraftFeatureModel({});

    List<PDREntry> entriesToDownload = [];

    for (final lib in manifest.libraries) {
      // skip if no artifact
      if (lib.downloads.artifact == null) {
        continue;
      }
      final downloadPath = pathToLib(lib.downloads.artifact!.path);
      final url = lib.downloads.artifact!.url;

      if (!lib.rules.every((e) => e.isAllowed(
            os: currentOs,
            features: currentFeatures,
          ))) {
        //BeaverLog.log(
        //     "Skipping ${lib.name} for version ${manifest.id} because incompatible");
        continue;
      }

      final fileEntry = PDREntry(
        url,
        downloadPath,
        size: lib.downloads.artifact!.size,
        sha1Hash: lib.downloads.artifact!.sha1,
      );

      if (await fileEntry.validateFileSelf()) {
        continue; // already downloaded with right hash
      }

      entriesToDownload.add(fileEntry);
    }

    await PDRaDSA.batchDownload(entriesToDownload,
        name: "Libraries for version ${manifest.id}");
  }

  Future<void> _downloadJar(CraftClientManifestModel manifest) async {
    final url = manifest.downloads['client']!.url;
    final size = manifest.downloads['client']!.size;
    final sha1 = manifest.downloads['client']!.sha1;

    final fileEntry = PDREntry(
      url,
      getJarPath(manifest.id),
      size: size,
      sha1Hash: sha1,
    );

    if (await fileEntry.validateFileSelf()) {
      return; // already downloaded with right hash
    }

    await PDRaDSA.singleDownload(fileEntry,
        name: "Jar for version ${manifest.id}");
  }

  Future<void> _downloadAssets(CraftClientManifestModel manifest) async {
    // firstly we should download asset index
    final indexUrl = manifest.assetIndex.url;
    // download is done to assets/indexes/{version}.json

    final indexManifestEntry = PDREntry(
      indexUrl,
      p.join(installDir, 'assets', 'indexes', '${manifest.majorVersion}.json'),
      size: manifest.assetIndex.size,
      sha1Hash: manifest.assetIndex.sha1,
    );

    if (!await indexManifestEntry.validateFileSelf()) {
      await PDRaDSA.singleDownload(indexManifestEntry,
          immediate: true,
          name: "Asset index manifest for version ${manifest.id}");
    }

    // read that file
    final index = jsonDecode(File(p.join(
            installDir, 'assets', 'indexes', '${manifest.majorVersion}.json'))
        .readAsStringSync());

    final assetIndex =
        CraftAssetIndexModel.fromJson(index as Map<String, dynamic>);

    List<PDREntry> entriesToDownload = [];

    // download every asset
    for (final asset in assetIndex.objects.entries) {
      final hash = asset.value.hash;
      final hashId = hash.substring(0, 2);

      final downloadPath =
          p.join(installDir, 'assets', 'objects', hashId, hash);
      final url = "https://resources.download.minecraft.net/$hashId/$hash";

      final fileEntry = PDREntry(
        url,
        downloadPath,
        size: asset.value.size,
        sha1Hash: hash,
      );
      // check if exists
      if (await fileEntry.validateFileSelf()) {
        continue; // already downloaded with right hash
      }

      entriesToDownload.add(fileEntry);
    }

    await PDRaDSA.batchDownload(entriesToDownload,
        name: "Assets for version ${manifest.majorVersion}");
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

    BeaverLog.success("Installation complete for version $version. Have fun!");
  }
}
