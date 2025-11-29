import 'dart:io';
import 'package:args/command_runner.dart';
import '../src/logger.dart';
import '../src/ignore_generator.dart';

class InitCommand extends Command {
  @override
  final String name = 'init';
  @override
  final String description = 'Generates a default .zipignore file based on project type.';

  InitCommand() {
    argParser.addFlag('force', abbr: 'f', help: 'Overwrite existing .zipignore file.');
  }

  @override
  Future<void> run() async {
    final args = argResults!;
    final force = args['force'] as bool;
    final logger = Logger(verbose: true);

    final file = File('.zipignore');
    if (await file.exists() && !force) {
      logger.error('.zipignore already exists. Use --force to overwrite.');
      return;
    }

    final generator = IgnoreGenerator();
    final content = await generator.generate(Directory.current);
    
    await file.writeAsString(content);
    logger.success('Generated .zipignore file.');
  }
}
