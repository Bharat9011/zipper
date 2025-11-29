import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'scanner.dart';
import 'logger.dart';

class ZipEngine {
  final Scanner _scanner;
  final Logger _logger;

  ZipEngine(this._scanner, this._logger);

  Future<void> zip(Directory sourceDir, File outputFile) async {
    _logger.info('Scanning files in ${sourceDir.path}...');
    
    final encoder = ZipFileEncoder();
    encoder.create(outputFile.path);

    int count = 0;
    await for (final file in _scanner.scan(sourceDir)) {
      final relativePath = p.relative(file.path, from: sourceDir.path);
      _logger.progress('Zipping: $relativePath');
      await encoder.addFile(file, relativePath);
      count++;
    }
    
    encoder.close();
    _logger.info(''); // New line after progress
    _logger.success('Successfully zipped $count files to ${outputFile.path}');
  }

  Future<void> preview(Directory sourceDir) async {
    _logger.info('Previewing files to be zipped in ${sourceDir.path}:');
    
    int count = 0;
    int totalSize = 0;

    await for (final file in _scanner.scan(sourceDir)) {
      final relativePath = p.relative(file.path, from: sourceDir.path);
      final size = await file.length();
      _logger.info('- $relativePath (${_formatSize(size)})');
      count++;
      totalSize += size;
    }

    _logger.info('Total: $count files, ${_formatSize(totalSize)}');
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
