import 'package:http/http.dart' as http;

import 'craft_exports.dart';

class DownloadManager {
  // TODO add query in future
  static Future<void> downloadFile(String url, String path) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = response.bodyBytes;
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(data);
      return;
    }

    throw Exception("Failed to download from $url");
  }
}
