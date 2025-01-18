import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:crypto/crypto.dart';

import 'package:fluttcraft_launcher/util/beaver.dart';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;

/// Parallel Data Retrieval And Download Synchronization Apparatus
///
///
/// It provides a convenient API for downloading files in parallel from multiple sources.
class PDRaDSA extends ParallelDataRetrievalAndDownloadSynchronizationApparatus {
  PDRaDSA() : super();

  /// Download single file
  ///
  ///
  ///
  /// * [entry] - [PDREntry] that describes what and from where to download
  /// * [name] - if not null, will be used as the name of the downloaded file. User will see this
  /// * [immediate] - if true, will start download immediately without queue. Defaults to false
  ///   [ParallelDataRetrievalAndDownloadSynchronizationApparatus]
  static Future<void> singleDownload(PDREntry entry,
      {String? name, bool immediate = false}) async {
    return ParallelDataRetrievalAndDownloadSynchronizationApparatus
        .singleDownload(entry, name: name, immediate: immediate);
  }

  /// Download batch of files.
  ///
  /// Entries will be added in Batch download queue
  ///
  /// * [entries] - List of [PDREntry] that describes what and from where to download
  /// * [name] - if not null, will be used as the name of the batch download. User will see this
  static Future<void> batchDownload(List<PDREntry> entries,
      {String? name}) async {
    return ParallelDataRetrievalAndDownloadSynchronizationApparatus
        .batchDownload(entries, name: name);
  }
}

/// Parallel Data Retrieval Entry
///
/// Holds download url, filesize (optional but useful) and path.
class PDREntry {
  final String url;
  final String path;
  final int? size;
  final bool? isExecutable;
  final String? sha1Hash;

  bool isAborted = false;

  bool isCompleted = false;
  bool isFailed = false;

  PDREntry(this.url, this.path, {this.size, this.isExecutable, this.sha1Hash});

  /// Validates if file exists and if has proper size
  Future<bool> validateExistanceSelf() async {
    final file = File(path);

    if (!await file.exists()) {
      // no file
      return false;
    }
    // check filesize
    if (size != null) {
      if (await file.length() != size) {
        return false;
      }
    }

    return true;
  }

  /// Validates if file exists, if has proper size and sha1 hash
  Future<bool> validateFileSelf() async {
    final file = File(path);
    final existance = await validateExistanceSelf();

    if (!existance) {
      return false;
    }

    // sha1 check
    if (sha1Hash != null) {
      final fileBytes = await file.readAsBytes();
      final fileSha1Hash = sha1.convert(fileBytes).toString();

      // invalid hash
      if (fileSha1Hash != sha1Hash) {
        return false;
      }
    }

    return true;
  }

  Future<void> _downloadSelfBarbaric(
      {void Function(int chunkBytes)? onChunkBytes}) async {
    final file = File(path);
    await file.parent.create(recursive: true);

    final client = http.Client();
    final request = await client.send(http.Request('GET', Uri.parse(url)));

    // Listen to the streamed response body to track download progress
    final stream = request.stream;
    final sink = file.openWrite();

    await for (var chunk in stream) {
      if (isAborted) {
        client.close();
        await sink.close();
        // del file if exists
        if (file.existsSync()) {
          file.deleteSync();
        }
        throw Exception("Download aborted");
      }
      if (onChunkBytes != null) {
        onChunkBytes(chunk.length);
      }

      sink.add(chunk);
    }

    // Ensure the file is fully written after the download is complete
    await sink.flush();
    await sink.close();

    client.close();
  }

  /// Download file. report back progress using [onChunkBytes] and [onCompleted]
  Future<void> downloadSelf(
      {void Function(int chunkBytes)? onChunkBytes,
      void Function(bool isCompleted)? onCompleted}) async {
    try {
      await _downloadSelfBarbaric(onChunkBytes: onChunkBytes);
    } catch (e) {
      BeaverLog.error(
          "Failed to download file ${p.basename(path)}: ${e.toString()}");
      isFailed = true;
      if (onCompleted != null) {
        onCompleted(false);
      }
      return;
    }

    //BeaverLog.log("Downloaded file ${p.basename(path)}");
    isCompleted = true;
    if (onCompleted != null) {
      onCompleted(true);
    }
  }
}

/// Parallel Data Retrieval Batch
///
/// Holds PDREntries
class PDRBatch {
  final List<PDREntry> entries;
  final String name;

  late int totalSize = entries.fold(1, (a, b) => a + (b.size ?? 0));

  late int totalFiles = entries.length;

  int completedFiles = 0;

  int completedSize = 0;

  int failedFiles = 0;

  int maxActiveDownloads;
  int currentActiveDownloads = 0;

  double get progress => completedSize / totalSize;

  late Completer<void> downloadCompleter;

  PDRBatch(this.name, this.entries, {this.maxActiveDownloads = 100}) {
    downloadCompleter = Completer<void>();
  }

  Future<void> downloadSelf() async {
    BeaverLog.info("Downloading PDRBatch $name. Total Files: $totalFiles");
    // sort by size
    entries.sort((a, b) => b.size!.compareTo(a.size!)); // descending

    DateTime lastProgressUpdate = DateTime.tryParse("1984-01-01 00:00:00")!;

    for (final entry in entries) {
      unawaited(entry.downloadSelf(onChunkBytes: (chunkBytes) {
        completedSize += chunkBytes;
      }, onCompleted: (isCompleted) {
        if (isCompleted) {
          completedFiles++;
        } else {
          failedFiles++;
        }
        currentActiveDownloads--;
      }));

      currentActiveDownloads++;
      while (currentActiveDownloads >= maxActiveDownloads) {
        await Future<void>.delayed(Duration(milliseconds: 50));
      }

      // log progress
      // if progress update is more than 1 second
      if (DateTime.now().difference(lastProgressUpdate).inSeconds > 1) {
        BeaverLog.info(
            "Downloading PDRBatch $name. Progress: ${(progress * 100).round()}%, Completed Files: $completedFiles, Failed Files: $failedFiles");
        lastProgressUpdate = DateTime.now();
      }
    }

    // wait until all downloads are complete
    while (currentActiveDownloads > 0) {
      await Future<void>.delayed(Duration(milliseconds: 10));
    }

    if (failedFiles > 0) {
      BeaverLog.error(
          "Failed to download $failedFiles files from PDRBatch $name");
      downloadCompleter.completeError("Failed to download $failedFiles files");
      return;
    }

    BeaverLog.success(
        "Downloaded PDRBatch $name. Total Files: $totalFiles, Completed Files: $completedFiles, Failed Files: $failedFiles");

    downloadCompleter.complete();
  }
}

/// Parallel Data Retrieval Queue
///
/// Holds PDRBatches, has option to return active PDRBatche
/// Can download 1 PDRBatch at a time
class PDRQueue {
  static final Queue<PDRBatch> queue = Queue();

  PDRBatch? get activeBatch => queue.firstOrNull;

  void add(PDRBatch batch) {
    queue.addLast(batch);
  }

  void remove(PDRBatch batch) {
    queue.remove(batch);
  }
}

class ParallelDataRetrievalAndDownloadSynchronizationApparatus {
  static PDRQueue queue = PDRQueue();

  static bool mainLoopIsRunning = false;

  static void ensureMainLoopIsRunning() {
    if (!mainLoopIsRunning) {
      mainLoopIsRunning = true;
      unawaited(_mainLoop());
    }
  }

  static Future<void> singleDownload(PDREntry entry,
      {String? name, bool immediate = false}) async {
    final filename = p.basename(entry.path);
    final batch = PDRBatch(name ?? filename, [entry]);

    if (immediate == true) {
      // skip queue
      return batch.downloadSelf();
    }

    ensureMainLoopIsRunning();

    queue.add(batch);
    return batch.downloadCompleter.future;
  }

  static Future<void> batchDownload(List<PDREntry> entries,
      {String? name}) async {
    if (entries.isEmpty) {
      return Future.value(); // empty
    }
    ensureMainLoopIsRunning();
    final batch = PDRBatch(name ?? "Batch of ${entries.length} files", entries);
    queue.add(batch);
    return batch.downloadCompleter.future;
  }

  static Future<void> _mainLoop() async {
    while (true) {
      if (queue.activeBatch != null) {
        await queue.activeBatch!.downloadSelf();
        queue.remove(queue.activeBatch!);
      }
      await Future<void>.delayed(Duration(milliseconds: 100));
    }
  }
}
