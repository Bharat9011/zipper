import 'package:test/test.dart';
import 'package:zipper/src/ignore_handler.dart';

void main() {
  group('IgnoreHandler', () {
    late IgnoreHandler ignoreHandler;

    setUp(() {
      ignoreHandler = IgnoreHandler();
    });

    test('should ignore default patterns', () {
      expect(ignoreHandler.shouldIgnore('.git/config'), isTrue);
      expect(ignoreHandler.shouldIgnore('node_modules/package.json'), isTrue);
      expect(ignoreHandler.shouldIgnore('.dart_tool/package_config.json'), isTrue);
      expect(ignoreHandler.shouldIgnore('build/app.dill'), isTrue);
      expect(ignoreHandler.shouldIgnore('logs/app.log'), isTrue);
    });

    test('should not ignore regular files', () {
      expect(ignoreHandler.shouldIgnore('lib/main.dart'), isFalse);
      expect(ignoreHandler.shouldIgnore('pubspec.yaml'), isFalse);
      expect(ignoreHandler.shouldIgnore('README.md'), isFalse);
    });

    test('should handle custom ignores', () {
      final customHandler = IgnoreHandler(['secret.txt', 'temp/**']);
      expect(customHandler.shouldIgnore('secret.txt'), isTrue);
      expect(customHandler.shouldIgnore('temp/file.tmp'), isTrue);
      expect(customHandler.shouldIgnore('lib/main.dart'), isFalse);
    });
  });
}
