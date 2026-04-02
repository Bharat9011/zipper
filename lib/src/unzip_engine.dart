import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'logger.dart';

class UnzipEngine {
  final Logger _logger;

  UnzipEngine(this._logger);

  Future<void> unzip(File zipFile, Directory outputDir) async {
    if (!await zipFile.exists()) {
      throw FileSystemException('Zip file not found', zipFile.path);
    }

    final size = await zipFile.length();
    _logger.info('Zip size: $size bytes');

    if (size == 0) {
      throw Exception('ZIP file is empty');
    }

    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    try {
      // ✅ NEW WAY (latest archive package)
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      _logger.info('Total files: ${archive.length}');

      for (final file in archive) {
        var filename = file.name;

        // 🔥 Convert to relative path only
        filename = p.normalize(filename);

        // remove leading slash if exists
        filename = filename.replaceFirst(RegExp(r'^[/\\]+'), '');
        final destPath = p.normalize(p.join(outputDir.path, filename));

        if (!p.isWithin(outputDir.path, destPath)) {
          _logger.error('Skipping unsafe path: $filename');
          continue;
        }

        if (file.isFile) {
          final outFile = File(destPath);

          if (!await outFile.parent.exists()) {
            await outFile.parent.create(recursive: true);
          }

          try {
            final data = file.content as List<int>;
            await outFile.writeAsBytes(data, flush: true);
            _logger.info('Extracted: ${p.join(outputDir.path, filename)}');
          } catch (e) {
            _logger.error('Write failed: $filename → $e');
          }
        } else {
          await Directory(destPath).create(recursive: true);
        }
      }

      _logger.success('Extraction complete ✅');
    } catch (e) {
      _logger.error('Unzip failed: $e');
      exit(1);
    }
  }
}
