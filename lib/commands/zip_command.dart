import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import '../src/ignore_handler.dart';
import '../src/ignore_generator.dart';
import '../src/logger.dart';
import '../src/scanner.dart';
import '../src/zip_engine.dart';

class ZipCommand extends Command {
  @override
  final String name = 'zip';
  @override
  final String description = 'Zips a project folder.';

  ZipCommand() {
    argParser
      ..addFlag('verbose', abbr: 'v', help: 'Show verbose output.')
      ..addFlag('dry-run', abbr: 'd', help: 'Preview files without zipping.')
      ..addOption('output', abbr: 'o', help: 'Output zip file name.');
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final verbose = args['verbose'] as bool;
    final dryRun = args['dry-run'] as bool;

    if (args.rest.isEmpty) {
      printUsage();
      return;
    }

    final sourcePath = args.rest.first;
    // final sourceDir = Directory(sourcePath);

    // if (!await sourceDir.exists()) {
    //   print('Directory not found: $sourcePath');
    //   exit(1);
    // }

    final type = FileSystemEntity.typeSync(sourcePath);

    if (type == FileSystemEntityType.notFound) {
      print('Path not found: $sourcePath');
      exit(1);
    }

    final isFile = type == FileSystemEntityType.file;
    final sourceDir = isFile ? File(sourcePath).parent : Directory(sourcePath);

    final logger = Logger(verbose: verbose);
    final ignoreHandler = IgnoreHandler();

    // Load .zipignore if exists
    if (!isFile) {
      final zipIgnoreFile = File(p.join(sourceDir.path, '.zipignore'));

      if (!await zipIgnoreFile.exists()) {
        logger.info('No .zipignore found. Generating one...');
        final content = await IgnoreGenerator.generate(sourceDir);
        await zipIgnoreFile.writeAsString(content);
        logger.success(
          'Created .zipignore from defaults and .gitignore (if present).',
        );
      }

      await ignoreHandler.loadFromZipIgnore(zipIgnoreFile);
    }

    final scanner = Scanner(ignoreHandler, logger);
    final zipEngine = ZipEngine(scanner, logger);

    if (dryRun) {
      await zipEngine.preview(sourceDir);
    } else {
      final outputOption = args['output'] as String?;

String name;

if (outputOption != null) {
  name = outputOption;
} else {
  name = p.basename(
    sourcePath == '.'
        ? Directory.current.path
        : p.normalize(sourcePath),
  );

  // ✅ FIX: remove .zip if already present
  if (name.toLowerCase().endsWith('.zip')) {
    name = name.substring(0, name.length - 4);
  }
}

// ✅ Ensure final file always ends with .zip
final outputFile = name.toLowerCase().endsWith('.zip')
    ? File(name)
    : File('$name.zip');
      if (isFile) {
        await zipEngine.zipSingleFile(File(sourcePath), outputFile);
      } else {
        await zipEngine.zip(sourceDir, outputFile);
      }
      // await zipEngine.zip(sourceDir, outputFile);
      // final fileName = '${sourcePath.split("\\").last}.zip';
      // final outputFile = File(fileName);
    }
  }
}
