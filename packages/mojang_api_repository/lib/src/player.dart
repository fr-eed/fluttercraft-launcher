// Dart
import 'dart:convert';
import 'dart:io';

// Packages
import 'package:file_selector/file_selector.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// Models
import 'models/cape.dart';
import 'models/profile.dart';
import 'models/skin.dart';

/// Manages player appearance customizations including skins, capes and models
class PlayerCustomizationApi {
  final String _baseUrl = 'https://api.minecraftservices.com/minecraft/profile';
  // PlayerCustomizationApi(this._baseUrl);

  /// Changes the player's skin by uploading a custom skin file
  ///
  /// [skinFile] - The image file for the new skin (PNG format)
  /// [modelType] - The player model type (classic or slim)
  /// Returns a Future that completes with success status and timestamp
  Future<MinecraftProfile> uploadSkin(
    File skinFile,
    String modelType,
  ) async {
    final uri = Uri.parse('$_baseUrl/skins');

    var request = http.MultipartRequest('POST', uri);

    // Add the skin file
    request.files.add(await http.MultipartFile.fromPath(
      'skin',
      skinFile.path,
    ));

    // Add the model type field
    request.fields['model'] = modelType;

    // Send the request
    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return MinecraftProfile.fromJson(
          jsonDecode(responseData) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to upload skin: ${response.statusCode}');
    }
  }

  /// Equips a cape to the player's character
  ///
  /// [capeId] - Unique identifier for the cape to equip
  Future<MinecraftProfile> equipCape(String capeId) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/capes/active'),
      body: jsonEncode({'capeId': capeId}),
      headers: {'Content-Type': 'application/json'},
    );

    return MinecraftProfile.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Hides the currently equipped cape
  Future<MinecraftProfile> hideCape() async {
    final response = await http.delete(Uri.parse('$_baseUrl/capes/active'));
    return MinecraftProfile.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Changes the player model between classic (Steve) and slim (Alex)
  ///
  /// [isSlim] - Whether to use the slim player model
  Future<bool> setPlayerModel(bool isSlim) async {
    final modelType = isSlim ? 'slim' : 'classic';
    final response = await http.post(
      Uri.parse('$_baseUrl/model/set'),
      body: jsonEncode({'modelType': modelType}),
      headers: {'Content-Type': 'application/json'},
    );

    return response.statusCode == 200;
  }

  Future<List<FileSystemEntity>> getSkinsFromDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    final skinsDir = Directory('${directory.path}/skins');

    if (!await skinsDir.exists()) {
      await skinsDir.create(recursive: true);
    }

    return await skinsDir.list().toList();
  }

  Future<String> writeSkinToDirectory(XFile file) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final skinsDir = Directory('${directory.path}/skins');

      if (!await skinsDir.exists()) {
        await skinsDir.create(recursive: true);
      }

      final filePath = '${skinsDir.path}/${file.name}';
      final skinFile = File(filePath);

      await skinFile.writeAsBytes(await file.readAsBytes());
      return filePath;
    } catch (e) {
      throw Exception('Failed to write skin file: $e');
    }
  }
}
