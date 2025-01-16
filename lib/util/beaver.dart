import 'dart:io';

class BeaverLog {
  static late File _logFile;
  static bool _initialized = false;
  static bool _fileLoggingEnabled = false;

  static Future<void> init({String? logFilePath}) async {
    if (!_initialized) {
      if (logFilePath != null) {
        _logFile = File(logFilePath);
        if (!await _logFile.exists()) {
          await _logFile.create(recursive: true);
        }
        _fileLoggingEnabled = true;
      }
      _initialized = true;
    }
  }

  static String _getTimestamp() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  static Future<void> _writeToFile(String message) async {
    if (_fileLoggingEnabled) {
      await _logFile.writeAsString('$message\n', mode: FileMode.append);
    }
  }

  static Future<void> log(String message, {String color = '\x1B[0m'}) async {
    final timestamp = _getTimestamp();
    final logMessage = '[$timestamp] [BEAVER] $message';

    stdout.writeln('$color$logMessage\x1B[0m');

    await _writeToFile(logMessage);
  }

  static Future<void> info(String message) async {
    await log(message, color: '\x1B[34m');
  }

  static Future<void> success(String message) async {
    await log(message, color: '\x1B[32m');
  }

  static Future<void> warning(String message) async {
    final timestamp = _getTimestamp();
    final logMessage = '[$timestamp] [BEAVER] $message';

    stderr.writeln('\x1B[33m$logMessage\x1B[0m');

    await _writeToFile('WARNING: $logMessage');
  }

  static Future<void> error(String message) async {
    final timestamp = _getTimestamp();
    final logMessage = '[$timestamp] [BEAVER] $message';

    stderr.writeln('\x1B[31m$logMessage\x1B[0m');

    await _writeToFile('ERROR: $logMessage');
  }

  static Future<void> debug(String message) async {
    await log(message, color: '\x1B[35m');
  }

  static Future<void> clearLogFile() async {
    if (_fileLoggingEnabled) {
      await _logFile.writeAsString('');
    }
  }

  static Future<String> getLogContent() async {
    if (_fileLoggingEnabled) {
      return await _logFile.readAsString();
    }
    return '';
  }
}

// Initialize the logger with a file path
 // await BeaverLog.init(logFilePath: 'logs/beaver.log');

 // Example usage
 // await BeaverLog.info('Starting application...');
 // await BeaverLog.success('Operation completed successfully');
 // await BeaverLog.warning('Something might be wrong');
 // await BeaverLog.error('An error occurred');
 // await BeaverLog.debug('Debug information');

 // Read log content
 // final logs = await BeaverLog.getLogContent();
 // print('\nLog file content:\n$logs');
