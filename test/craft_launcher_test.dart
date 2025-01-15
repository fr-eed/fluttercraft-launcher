import 'package:fluttcraft_launcher/craft/craft_exports.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  String installDir = "";

  setUpAll(() async {
    installDir = p.join(".temp", "fluttcraft");
    // get full path (not realtive)
    installDir = p.join(Directory.current.path, installDir);
    // create dir
    Directory(installDir).createSync(recursive: true);
  });

  tearDownAll(() async {
    // erase everything
    Directory(installDir).deleteSync(recursive: true);
  });

  group('Craft launcher tests', () {
    group("manifests", () {
      test("VersionsManifest", () async {
        final manifestManager = CraftManifestManager(installDir: installDir);

        final manifest = await manifestManager.downloadVersionManifest();

        expect(manifest, isNotNull);

        // expect to have more than 10 versions
        expect(manifest.versions.length, greaterThan(10));
      });
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
