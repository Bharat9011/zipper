import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:path/path.dart' as p;
import '../src/ignore_handler.dart';
import '../src/logger.dart';
import '../src/scanner.dart';
import '../src/zip_engine.dart';

class PreviewCommand extends Command {
  @override
  final String name = 'preview';
  @override
  final String description = 'Preview files to be zipped without creating the archive.';

  PreviewCommand() {
    argParser.addFlag('verbose', abbr: 'v', help: 'Show verbose output.');
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final verbose = args['verbose'] as bool;

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
    
    final zipIgnoreFile = File(p.join(sourceDir.path, '.zipignore'));
    await ignoreHandler.loadFromZipIgnore(zipIgnoreFile);

    final scanner = Scanner(ignoreHandler, logger);
    final zipEngine = ZipEngine(scanner, logger);

    await zipEngine.preview(sourceDir);
  }
}
