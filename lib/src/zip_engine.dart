import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'scanner.dart';
import 'logger.dart';

class ZipEngine {
  final Scanner _scanner;
  final Logger _logger;

  ZipEngine(this._scanner, this._logger);

  Future<void> zip(Directory sourceDir, File outputFile) async {
    try {
      _logger.info('Scanning files in ${sourceDir.path}...');

      final archive = Archive();
      int count = 0;

      await for (final file in _scanner.scan(sourceDir)) {
        final relativePath = p.relative(file.path, from: sourceDir.path);
        _logger.progress('Zipping: $relativePath');

        final bytes = await file.readAsBytes();

        archive.addFile(ArchiveFile(relativePath, bytes.length, bytes));

        count++;
      }

      final zipData = ZipEncoder().encode(archive);

      if (zipData != null) {
        await outputFile.writeAsBytes(zipData);
      }

      _logger.info('');
      _logger.success('Successfully zipped $count files to ${outputFile.path}');
    } catch (e) {
      _logger.error('Failed to zip files: $e');
      exit(1);
    }
  }
Future<void> preview(Directory sourceDir) async {
  _logger.info('Preview (tree view) for ${sourceDir.path}:\n');

  final tree = <String, dynamic>{};
  int totalFiles = 0;
  int totalSize = 0;

  await for (final file in _scanner.scan(sourceDir)) {
    final relativePath = p.relative(file.path, from: sourceDir.path);
    final parts = relativePath.split(p.separator);

    int size = await file.length();
    totalSize += size;
    totalFiles++;

    Map<String, dynamic> current = tree;

    for (int i = 0; i < parts.length; i++) {
      final part = parts[i];

      if (i == parts.length - 1) {
        current[part] = size; // file with size
      } else {
        current = current.putIfAbsent(part, () => <String, dynamic>{});
      }
    }
  }

  _printTree(tree, '');

  _logger.info(
      '\nTotal: $totalFiles files, ${_formatSize(totalSize)}');
}
void _printTree(Map<String, dynamic> tree, String indent) {
 final keys = tree.keys.toList()
  ..sort((a, b) {
    final aIsDir = tree[a] is Map;
    final bIsDir = tree[b] is Map;
    if (aIsDir && !bIsDir) return -1;
    if (!aIsDir && bIsDir) return 1;
    return a.compareTo(b);
  });

  for (int i = 0; i < keys.length; i++) {
    final key = keys[i];
    final value = tree[key];

    final isLast = i == keys.length - 1;
    final branch = isLast ? '└── ' : '├── ';

    if (value is Map<String, dynamic>) {
      _logger.info('$indent$branch$key/');
      _printTree(value, indent + (isLast ? '    ' : '│   '));
    } else {
      _logger.info('$indent$branch$key (${_formatSize(value)})');
    }
  }
}
  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Future<void> zipSingleFile(File file, File outputFile) async {
    try {
      _logger.info('Zipping single file: ${file.path}');

      final archive = Archive();

      final bytes = await file.readAsBytes();
      final fileName = p.basename(file.path);

      archive.addFile(ArchiveFile(fileName, bytes.length, bytes));

      final zipData = ZipEncoder().encode(archive);

      if (zipData != null) {
        await outputFile.writeAsBytes(zipData);
      }

      _logger.success('Zipped 1 file to ${outputFile.path}');
    } catch (e) {
      _logger.error('Failed to zip file: $e');
      exit(1);
    }
  }
}
