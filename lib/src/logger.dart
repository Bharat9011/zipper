import 'dart:io';

class Logger {
  final bool verbose;

  Logger({this.verbose = false});

  void log(String message) {
    if (verbose) {
      stdout.writeln('[LOG] $message');
    }
  }

  void info(String message) {
    stdout.writeln(message);
  }

  void error(String message) {
    stderr.writeln('[ERROR] $message');
  }

  void success(String message) {
    stdout.writeln('[SUCCESS] $message');
  }

  void progress(String message) {
    stdout.write('\r$message');
  }
}
