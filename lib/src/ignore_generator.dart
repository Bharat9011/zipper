import 'dart:io';
import 'package:path/path.dart' as p;

class IgnoreGenerator {
  Future<String> generate(Directory dir) async {
    final ignores = <String>{};

    // 1. Essential Defaults (Always ignore these)
    ignores.addAll([
      '# Version Control',
      '.git/',
      '.gitignore',
      '',
      '# Zipper',
      '.zipignore',
      '*.zip', // Don't zip other zip files by default? Maybe.
      '',
      '# OS Generated',
      '.DS_Store',
      'Thumbs.db',
      '',
      '# IDEs',
      '.idea/',
      '.vscode/',
      '*.swp',
      '*.iml',
      '',
    ]);

    // 2. Import .gitignore if exists
    final gitIgnoreFile = File(p.join(dir.path, '.gitignore'));
    if (await gitIgnoreFile.exists()) {
      ignores.add('# Imported from .gitignore');
      final lines = await gitIgnoreFile.readAsLines();
      ignores.addAll(lines);
      ignores.add('');
    }

    // 3. Project Type Defaults (in case .gitignore is missing or incomplete)
    // Dart/Flutter
    if (await File(p.join(dir.path, 'pubspec.yaml')).exists()) {
      ignores.addAll([
        '# Dart/Flutter',
        '.dart_tool/',
        'build/',
        'pubspec.lock',
        'coverage/',
        'android/app/build/',
        'ios/Flutter/App.framework',
        'ios/Pods/',
        '.flutter-plugins',
        '.flutter-plugins-dependencies',
      ]);
    }

    // Node.js
    if (await File(p.join(dir.path, 'package.json')).exists()) {
      ignores.addAll([
        '# Node.js',
        'node_modules/',
        'npm-debug.log',
        'yarn-error.log',
        'dist/',
        'coverage/',
      ]);
    }

    // Java/Gradle
    if (await File(p.join(dir.path, 'pom.xml')).exists() || 
        await File(p.join(dir.path, 'build.gradle')).exists()) {
      ignores.addAll([
        '# Java/Gradle',
        'target/',
        'build/',
        '.gradle/',
        '*.class',
        '*.jar',
        '*.war',
      ]);
    }
    
    // Python
    if (await File(p.join(dir.path, 'requirements.txt')).exists() || 
        await File(p.join(dir.path, 'pyproject.toml')).exists()) {
       ignores.addAll([
         '# Python',
         '__pycache__/',
         '*.py[cod]',
         'venv/',
         '.env',
         '.venv/',
         'env/',
       ]);
    }

    return ignores.join('\n');
  }
}
