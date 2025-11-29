import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:zipper/commands/zip_command.dart';
import 'package:zipper/commands/preview_command.dart';
import 'package:zipper/commands/unzip_command.dart';
import 'package:zipper/commands/init_command.dart';

void main(List<String> arguments) async {
  final runner = CommandRunner('zipper', 'A CLI tool for smart zipping.')
    ..addCommand(InitCommand())
    ..addCommand(ZipCommand())
    ..addCommand(PreviewCommand())
    ..addCommand(UnzipCommand());

  try {
    await runner.run(arguments);
  } on UsageException catch (e) {
    print(e);
    exit(64);
  } catch (e) {
    print('An error occurred: $e');
    exit(1);
  }
}
