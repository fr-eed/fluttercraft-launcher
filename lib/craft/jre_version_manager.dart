import 'package:fluttcraft_launcher/util/beaver.dart';
import 'package:path/path.dart' as p;

import 'craft_exports.dart';

class JreVersionManager {
  final String installDir;

  late JreManifestModel _manifest;

  JreVersionManager({required this.installDir}) {
    // read manifest
    _manifest = JreManifestModel.fromJson(
        json.decode(File("assets/jre_manifest.json").readAsStringSync())
            as Map<String, dynamic>);
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

    if (!File(manifestFile).existsSync()) {
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
      }
      if (item.value.type == JreFSItemType.link) {
        if (!Link(filepath).existsSync()) {
          return false;
        }
      }
      if (!File(filepath).existsSync()) {
        return false;
      }
    }

    return true;
  }

  Future<void> ensureRuntimeInstalled(
      {required JrePlatform platform, required JreComponent codeName}) async {
    final componenInfo = _manifest.getComponent(platform, codeName);
    if (componenInfo == null) {
      throw Exception(
          "JRE component not found for ${platform.name} ${codeName.name}");
    }

    // download manifest from url if not downloaded
    final manifestFile =
        p.join(installDir, 'runtime', 'manifests', componenInfo.manifest.sha1);

    if (!File(manifestFile).existsSync()) {
      // download
      await DownloadManager.downloadFile(
          componenInfo.manifest.url, manifestFile);
    }

    // TODO cache in jre manifest manager

    final manifesto = JreDownloadManifestModel.fromJson(
        json.decode(await File(manifestFile).readAsString())
            as Map<String, dynamic>);

    await _downloadJreFiles(manifesto, codeName: codeName, platform: platform);

    final os = OsType.getSystemOS();
    if (os == OsType.osx || os == OsType.linux) {
      await _ensureExecutablePermissions(manifesto,
          codeName: codeName, platform: platform);
    }

    BeaverLog.success(
        "JRE version ${codeName.name} ${componenInfo.version['name']} for ${platform.name} installed ");
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

    for (final item in manifest.files.entries) {
      // skip if dir
      if (item.value.type == JreFSItemType.file &&
          item.value.executable == true) {
        final downloadPath = p.join(downloadFolder, item.key);
        // chmod his file
        BeaverLog.log(
            "Setting executable permissions for ${item.key} for jre version ${codeName.name}");
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
    List<Future> futures = [];
    const chunkSize = 30;
    for (final item in manifest.files.entries) {
      // skip if dir
      if (item.value.type == JreFSItemType.directory) {
        continue;
      }

      if (item.value.type == JreFSItemType.link) {
        final linkPath = p.join(downloadFolder, item.key);
        final targetPath = p.join(item.value.target!);
        // check if exists

        if (Link(linkPath).existsSync()) {
          continue;
        }

        BeaverLog.log(
            "Creating symlink ${item.key} for jre version ${codeName.name}");
        // create symlink

        final linkFile = Link(linkPath);
        await linkFile.create(targetPath, recursive: true);
        continue;
      }

      final downloadPath = p.join(downloadFolder, item.key);

      final url = item.value.downloads!.raw.url;

      if (File(downloadPath).existsSync()) {
        continue;
      }

      BeaverLog.log(
          "Downloading File ${item.key} for jre version ${codeName.name}");

      futures.add(DownloadManager.downloadFile(url, downloadPath));

      if (futures.length > chunkSize) {
        await Future.wait(futures.take(chunkSize));
        futures = futures.skip(chunkSize).toList();
      }
    }

    await Future.wait(futures);

    BeaverLog.success(
        "Finished downloading files for jre version ${codeName.name}");
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
}
