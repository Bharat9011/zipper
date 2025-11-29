import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:intl/intl.dart';
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
    final outputName = args['output'] as String?;

    if (args.rest.isEmpty) {
      printUsage();
      return;
    }

    final sourcePath = args.rest.first;
    final sourceDir = Directory(sourcePath);

    if (!await sourceDir.exists()) {
      print('Directory not found: $sourcePath');
      exit(1);
    }

    final logger = Logger(verbose: verbose);
    final ignoreHandler = IgnoreHandler();

    // Load .zipignore if exists
    final zipIgnoreFile = File(p.join(sourceDir.path, '.zipignore'));
    if (!await zipIgnoreFile.exists()) {
      logger.info('No .zipignore found. Generating one...');
      final generator = IgnoreGenerator();
      final content = await generator.generate(sourceDir);
      await zipIgnoreFile.writeAsString(content);
      logger.success(
        'Created .zipignore from defaults and .gitignore (if present).',
      );
    }

    await ignoreHandler.loadFromZipIgnore(zipIgnoreFile);

    final scanner = Scanner(ignoreHandler, logger);
    final zipEngine = ZipEngine(scanner, logger);

    if (dryRun) {
      await zipEngine.preview(sourceDir);
    } else {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final projectName = p.basename(sourceDir.path);
      final fileName = outputName ?? '${projectName}_$timestamp.zip';
      final outputFile = File(fileName);

      await zipEngine.zip(sourceDir, outputFile);
    }
  }
}
