import 'dart:io';

import 'package:fluttcraft_launcher/craft/craft_launcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  setUpAll(() async {});

  tearDownAll(() async {
    // erase everything
  });

  group('Craft launcher tests', () {
    group("SimpleUsage", () {
      test("Launch", () async {
        String installDir = "";
        if (Platform.isMacOS) {
          final homeDir = Platform.environment['HOME'] ?? '';

          // Build the full path
          installDir =
              p.join(homeDir, "Library", "Application Support", "minecraft");
        } else {
          throw Exception("Unsupported OS");
        }

        const craftVersion = "1.20.4";
        final launcher = CraftLauncher();
        await launcher.launch(
            installDir: installDir, craftVersion: craftVersion);
      });
    });
  });
}
