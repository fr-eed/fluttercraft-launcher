import 'dart:convert';
import 'dart:io';

import 'package:fluttcraft_launcher/craft/craft_exports.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  setUpAll(() async {});

  tearDownAll(() async {
    // erase everything
  });

  String installDir = "";
  if (Platform.isMacOS) {
    final homeDir = Platform.environment['HOME'] ?? '';

    // Build the full path
    installDir =
        p.join(homeDir, "Library", "Application Support", "FluttCraft");
  } else {
    throw Exception("Unsupported OS");
  }

  group('Craft launcher tests', () {
    group("manifests", () {
      test("ClientManifest", () async {
        const craftVersion = "1.19.2";
        final manifestManager = CraftManifestManager(installDir: installDir);

        final manifest =
            await manifestManager.downloadClientManifest(craftVersion);

        expect(manifest.id, craftVersion);

        // to json
        final jsonifiedManifest = manifest.toJson();

        final newManifest =
            CraftClientManifestModel.fromJson(jsonifiedManifest);

        expect(
            json.encode(jsonifiedManifest), json.encode(newManifest.toJson()));
      });
    });
    group("SimpleUsage", () {
      test("Launch", () async {
        const craftVersion = "1.20.4";
        final launcher = CraftLauncher(installDir: installDir);
        await launcher.launch(craftVersion: craftVersion);
      }, timeout: Timeout(Duration(minutes: 4)));
    });
  });
}
