import 'package:fluttercraft_launcher/craft/craft_exports.dart';
import 'package:fluttercraft_launcher/util/beaver.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

/// Checks if any data is lost during serialization
bool testJsonSerialization<T>(
    T object, T Function(Map<String, dynamic>) fromJson) {
  final json = (object as dynamic).toJson() as Map<String, dynamic>;

  final newObject = fromJson(json);

  return jsonEncode(object) == jsonEncode(newObject);
}

Future<void> main() async {
  String tmpDir = p.join(Directory.current.path, ".temp");
  String installDir = p.join(tmpDir, "FlutterCraft");

  setUpAll(() async {
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

        expect(
            testJsonSerialization(
                manifest, CraftVersionsManifestModel.fromJson),
            true);

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
            BeaverLog.log("checked version ${version.id}");
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
      }, timeout: Timeout(Duration(minutes: 1)));
    });
    group("SimpleUsage", () {
      test("Launch", () async {
        final launcher = CraftLauncher(installDir: installDir);

        await launcher.init();

        final manifest = launcher.manifestManager.versionsManifestV2;

        final craftVersion = manifest!.latest.release;

        final process = await launcher.launch(craftVersion: craftVersion);

        // await 10 seoconds
        await Future<void>.delayed(Duration(seconds: 10));
        // kill process
        process
            .kill(ProcessSignal.sigint); // ctrl+c closes the process gracefully
        // print stream of process
        final exitCode = await process.exitCode;

        if (exitCode != 128 + ProcessSignal.sigint.signalNumber) {
          await process.stderr
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .forEach(BeaverLog.error);
          expect(
              await process.exitCode, 128 + ProcessSignal.sigint.signalNumber,
              reason: "Process exited with unexpected exit code");
        }
      }, timeout: Timeout(Duration(minutes: 10)));
    });
  });
}
