import 'package:fluttcraft_launcher/craft/craft_exports.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

bool testJsonSerialization<T>(
    T object, T Function(Map<String, dynamic>) fromJson) {
  final json = (object as dynamic).toJson() as Map<String, dynamic>;

  final newObject = fromJson(json);

  return jsonEncode(object) == jsonEncode(newObject);
}

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

        expect(
            testJsonSerialization(manifest, CraftClientManifestModel.fromJson),
            true);
      });

      test("ClientManifest for important versions", () async {
        final manifestManager = CraftManifestManager(installDir: installDir);

        final manifest = await manifestManager.downloadVersionManifest();

        bool majorSnapshotChecked = false;

        int count = 0;
        // go through all versions
        for (final version in manifest.versions) {
          // only major for now
          if ((version.type == CraftVersionType.release) ||
              (version.type == CraftVersionType.snapshot &&
                  !majorSnapshotChecked)) {
            print("checked ${version.id}");
            final clientManifest =
                await manifestManager.downloadClientManifest(version.id);

            expect(
                testJsonSerialization(
                    clientManifest, CraftClientManifestModel.fromJson),
                true);

            // check that it has always argumets not null or minecraftArgs
            expect(
                clientManifest.arguments != null ||
                    clientManifest.minecraftArguments != null,
                true);

            count++;

            // we will check each snapshot before major versions (not to test 500+ snapshots)
            if (version.type == CraftVersionType.snapshot) {
              majorSnapshotChecked = true;
            } else {
              majorSnapshotChecked = false;
            }
          }
        }

        expect(count, greaterThan(10));
      });
    });
    group("SimpleUsage", () {
      test("Launch", () async {
        const craftVersion = "1.20.4";
        final launcher = CraftLauncher(installDir: installDir);
        final process = await launcher.launch(craftVersion: craftVersion);

        // await 10 seoconds
        await Future<void>.delayed(Duration(seconds: 10));
        // kill process
        process
            .kill(ProcessSignal.sigint); // ctrl+c closes the process gracefully
        // print stream of process
        await process.stderr
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .forEach(print);

        expect(await process.exitCode, 128 + ProcessSignal.sigint.signalNumber);
      }, timeout: Timeout(Duration(minutes: 10)));
    });
  });
}
