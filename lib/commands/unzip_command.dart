import 'dart:io';
import 'package:args/command_runner.dart';
import '../src/logger.dart';
import '../src/unzip_engine.dart';

class UnzipCommand extends Command {
  @override
  final String name = 'unzip';
  @override
  final String description = 'Extracts a zip archive.';

  UnzipCommand() {
    argParser
      ..addFlag('verbose', abbr: 'v', help: 'Show verbose output.')
      ..addOption('output', abbr: 'o', help: 'Output directory.');
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final verbose = args['verbose'] as bool;
    final outputDirName = args['output'] as String?;

    if (args.rest.isEmpty) {
      printUsage();
      return;
    }

    final zipPath = args.rest.first;
    final zipFile = File(zipPath);

    if (!await zipFile.exists()) {
      print('Zip file not found: $zipPath');
      exit(1);
    }

    final logger = Logger(verbose: verbose);
    final unzipEngine = UnzipEngine(logger);

    final outputDir = Directory(outputDirName ?? '.');
    
    await unzipEngine.unzip(zipFile, outputDir);
  }
}
