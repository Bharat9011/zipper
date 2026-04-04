import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:args/command_runner.dart';

class CallGui extends Command {
  @override
  final String name = 'gui';

  @override
  final String description = 'Show GUI UI';

  CallGui() {
    argParser.addFlag('gui', abbr: 'g', help: "Show GUI UI");
  }

  @override
  FutureOr<void> run() async {
    final args = argResults!;
    final showGui = args['gui'] as bool;

    if (!showGui) {
      print("Use --gui or -g to open UI");
      return;
    }

    final exePath = Platform.isWindows
        ? 'assets\\gui\\windows_gui_release\\Release\\zipper_gui.exe'
        : './zipper_gui';

    print("Opening GUI...");

    final result = await Process.run(exePath, []);

    if (result.exitCode == 0) {
      final output = result.stdout.toString().trim();

      if (output.isEmpty) {
        print("No data received (user closed form)");
        return;
      }

      print("Raw Output: $output");

      try {
        final data = jsonDecode(output);

        print("Name: ${data['name']}");
        print("Age: ${data['age']}");
      } catch (e) {
        print("Invalid JSON received: $output");
      }
    } else {
      print("Error: ${result.stderr}");
    }
  }
}
