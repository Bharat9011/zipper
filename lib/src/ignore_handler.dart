import 'dart:io';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

class IgnoreHandler {
  final List<Glob> _ignoreGlobs = [];
  final List<String> _defaultIgnores = [
    '.git/**',
    'node_modules/**',
    '.dart_tool/**',
    'build/**',
    '.idea/**',
    '**/*.log',
    '**/.DS_Store',
  ];

  IgnoreHandler([List<String>? extraIgnores]) {
    _addPatterns(_defaultIgnores);
    if (extraIgnores != null) {
      _addPatterns(extraIgnores);
    }
  }

  void _addPatterns(List<String> patterns) {
    for (var pattern in patterns) {
      // Ensure directory patterns match contents
      if (pattern.endsWith('/')) {
        _ignoreGlobs.add(Glob('$pattern**'));
        _ignoreGlobs.add(Glob(pattern.substring(0, pattern.length - 1)));
      } else {
        _ignoreGlobs.add(Glob(pattern));
      }
    }
  }

  Future<void> loadFromZipIgnore(File file) async {
    if (await file.exists()) {
      final lines = await file.readAsLines();
      final patterns = lines
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty && !l.startsWith('#'))
          .toList();
      _addPatterns(patterns);
    }
  }

  bool shouldIgnore(String relativePath) {
    // Normalize path to forward slashes for glob matching
    final normalized = relativePath.replaceAll(r'\', '/');
    
    for (var glob in _ignoreGlobs) {
      if (glob.matches(normalized)) {
        return true;
      }
    }
    return false;
  }
}
