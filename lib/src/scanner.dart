import 'dart:io';
import 'package:path/path.dart' as p;
import 'ignore_handler.dart';
import 'logger.dart';

class Scanner {
  final IgnoreHandler _ignoreHandler;
  final Logger _logger;

  Scanner(this._ignoreHandler, this._logger);

  Stream<File> scan(Directory dir) async* {
    if (!await dir.exists()) {
      throw FileSystemException('Directory not found', dir.path);
    }

    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        final relativePath = p.relative(entity.path, from: dir.path);
        if (!_ignoreHandler.shouldIgnore(relativePath)) {
          yield entity;
        } else {
          _logger.log('Ignored: $relativePath');
        }
      }
    }
  }
}
