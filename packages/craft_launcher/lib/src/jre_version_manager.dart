import 'dart:async';

import 'package:path/path.dart' as p;

import 'craft_exports.dart';

import 'package:flutter/services.dart';

class JreVersionManager {
  final String installDir;

  late JreManifestModel _manifest;

  JreVersionManager({required this.installDir}) {
    // read manifest
  }

  Future<void> init() async {
    final manifestStr = await rootBundle.loadString('assets/jre_manifest.json');
    _manifest = JreManifestModel.fromJson(
        json.decode(manifestStr) as Map<String, dynamic>);
  }

  String getRuntimeFolderPath(
      {required JrePlatform platform, required JreComponent codeName}) {
    return p.join(installDir, 'runtime', codeName.name, platform.name,
        codeName.name); // don't ask why
  }

  /// Check if the installation for a valid version is complete.
  Future<bool> isRuntimeInstalled(
      {required JrePlatform platform, required JreComponent codeName}) async {
    final componenInfo = _manifest.getComponent(platform, codeName);
    if (componenInfo == null) {
      return false;
    }

    // download manifest from url if not downloaded
    final manifestFile =
        p.join(installDir, 'runtime', 'manifests', componenInfo.manifest.sha1);

    if (!await PDREntry("", manifestFile,
            size: componenInfo.manifest.size,
            sha1Hash: componenInfo.manifest.sha1)
        .validateFileSelf()) {
      return false;
    }

    // TODO cache in jre manifest manager

    // ensure every lib is downloaded
    final manifesto = JreDownloadManifestModel.fromJson(
        json.decode(await File(manifestFile).readAsString())
            as Map<String, dynamic>);

    final downloadDir =
        getRuntimeFolderPath(platform: platform, codeName: codeName);

    // check every path
    for (final item in manifesto.files.entries) {
      final filepath = p.join(downloadDir, item.key);
      if (item.value.type == JreFSItemType.directory) {
        continue;
      } else if (item.value.type == JreFSItemType.link) {
        if (!Link(filepath).existsSync()) {
          return false;
        }
      } else if (await PDREntry("", filepath,
              size: item.value.downloads!.raw.size)
          .validateExistanceSelf()) {
        return false;
      }
    }

    return true;
  }

  String getJreDownloadManifestPath({
    required JrePlatform platform,
    required JreComponent codeName,
  }) {
    return p.join(installDir, 'runtime', 'manifests',
        _manifest.getComponent(platform, codeName)!.manifest.sha1);
  }

  Future<void> ensureRuntimeInstalled(
      {required JrePlatform platform, required JreComponent codeName}) async {
    final componenInfo = _manifest.getComponent(platform, codeName);
    if (componenInfo == null) {
      throw Exception(
          "JRE component not found for ${platform.name} ${codeName.name}");
    }

    // download manifest from url if not downloaded
    final downloadManifestoPath =
        getJreDownloadManifestPath(platform: platform, codeName: codeName);

    final manifestoEntry = PDREntry(
      componenInfo.manifest.url,
      downloadManifestoPath,
      size: componenInfo.manifest.size,
      sha1Hash: componenInfo.manifest.sha1,
    );

    if (!await manifestoEntry.validateFileSelf()) {
      // download
      await PDRaDSA.singleDownload(
        manifestoEntry,
        immediate: true,
        name: "JRE Manifest for ${platform.name} ${codeName.name}",
      );
    }

    // TODO cache in jre manifest manager

    final manifesto = JreDownloadManifestModel.fromJson(
        json.decode(await File(downloadManifestoPath).readAsString())
            as Map<String, dynamic>);

    await _downloadJreFiles(manifesto, codeName: codeName, platform: platform);

    final os = OsType.getSystemOS();
    if (os == OsType.osx || os == OsType.linux) {
      await _ensureExecutablePermissions(manifesto,
          codeName: codeName, platform: platform);
    }

    unawaited(BeaverLog.success(
        "JRE version ${codeName.name} ${componenInfo.version['name']} for ${platform.name} installed "));
  }

  Future<void> _setExecutablePermissions(String filePath) async {
    final result = await Process.run('chmod', ['+x', filePath]);
    if (result.exitCode == 0) {
      return;
    } else {
      throw Exception('Failed to set executable permissions for $filePath');
    }
  }

  Future<void> _ensureExecutablePermissions(
    JreDownloadManifestModel manifest, {
    required JrePlatform platform,
    required JreComponent codeName,
  }) async {
    final downloadFolder =
        getRuntimeFolderPath(platform: platform, codeName: codeName);

    BeaverLog.info(
        "Setting executable permissions for jre version ${codeName.name}");

    for (final item in manifest.files.entries) {
      // skip if dir
      if (item.value.type == JreFSItemType.file &&
          item.value.executable == true) {
        final downloadPath = p.join(downloadFolder, item.key);
        // chmod his file
        await _setExecutablePermissions(downloadPath);
      }
    }

    BeaverLog.success(
        "Executable permissions set for jre version ${codeName.name}");
  }

  Future<void> _downloadJreFiles(
    JreDownloadManifestModel manifest, {
    required JrePlatform platform,
    required JreComponent codeName,
  }) async {
    final downloadFolder =
        getRuntimeFolderPath(platform: platform, codeName: codeName);

    // check every path
    List<PDREntry> entriesToDownload = [];

    for (final item in manifest.files.entries) {
      // skip if dir
      if (item.value.type == JreFSItemType.directory) {
        continue; // automatically created if needed
      }

      if (item.value.type == JreFSItemType.link) {
        final linkPath = p.join(downloadFolder, item.key);
        final targetPath = p.join(item.value.target!);
        // check if exists

        if (Link(linkPath).existsSync()) {
          continue;
        }

        final linkFile = Link(linkPath);
        await linkFile.create(targetPath, recursive: true);
        continue;
      }

      final downloadPath = p.join(downloadFolder, item.key);
      final url = item.value.downloads!.raw.url;

      final fileEntry = PDREntry(
        url,
        downloadPath,
        size: item.value.downloads!.raw.size,
        sha1Hash: item.value.downloads!.raw.sha1,
      );

      if (await fileEntry.validateFileSelf()) {
        // do not download
        continue;
      }

      entriesToDownload.add(fileEntry);
    }

    await PDRaDSA.batchDownload(entriesToDownload,
        name: "JRE Files for ${codeName.name} ${platform.name}");
  }

  String findJreJavaExecutable(
      {required JrePlatform platform, required JreComponent codeName}) {
    // get platform folder
    final jreFolder =
        getRuntimeFolderPath(platform: platform, codeName: codeName);
    // if platform is macos then files is in jre.bundle/Contents/Home/bin/java
    if (platform == JrePlatform.macosArm64 ||
        platform == JrePlatform.macosX64) {
      return p.join(jreFolder, "jre.bundle", "Contents", "Home", "bin", "java");
    } else if (platform == JrePlatform.windowsArm64 ||
        platform == JrePlatform.windowsX64 ||
        platform == JrePlatform.windowsX86) {
      return p.join(jreFolder, "bin", "java.exe");
    }
    return p.join(jreFolder, "bin", "java");
  }

  /// Robust way of finding jre executable. Needs manifest to be downloaded
  Future<String> findJreExecutableByManifest(
      {required JrePlatform platform, required JreComponent codeName}) async {
    final downloadManifestoPath =
        getJreDownloadManifestPath(platform: platform, codeName: codeName);
    final manifesto = JreDownloadManifestModel.fromJson(
        json.decode(await File(downloadManifestoPath).readAsString())
            as Map<String, dynamic>);

    // get platform folder
    final jreFolder =
        getRuntimeFolderPath(platform: platform, codeName: codeName);

    for (final item in manifesto.files.entries) {
      if (item.value.executable == true &&
          (item.key.endsWith('/java') || item.key.endsWith('/java.exe'))) {
        return p.join(jreFolder, item.key);
      }
    }

    throw Exception(
        'No executable java file found in jre version ${codeName.name} for ${platform.name}');
  }
}
