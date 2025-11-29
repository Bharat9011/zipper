import 'dart:io';
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

    _logger.info('Extracting ${zipFile.path} to ${outputDir.path}...');

    final bytes = await zipFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive.files) {
      if (file.isFile) {
        final filename = file.name;
        final destPath = p.join(outputDir.path, filename);
        
        // Ensure parent directory exists
        final parentDir = Directory(p.dirname(destPath));
        if (!await parentDir.exists()) {
          await parentDir.create(recursive: true);
        }

        final outputFile = File(destPath);
        final outputStream = OutputFileStream(destPath);
        file.writeContent(outputStream);
        outputStream.close();
        
        _logger.progress('Extracted: $filename');
      }
    }
    
    // inputStream.close();
    _logger.info(''); // New line
    _logger.success('Extraction complete.');
  }
}
