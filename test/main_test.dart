import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

int add(int a, int b) {
  return a + b;
}

void main() {
  test('Addition Test', () {
    expect(add(2, 3), 5);
  });
}
