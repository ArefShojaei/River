import 'package:test/test.dart';

import 'package:river/river.dart';

void main() {
  group('Cli', () {
    test('should create Cli instance', () {
      final cli = Cli(name: 'test', version: '1.0.0');
      expect(cli.name, equals('test'));
      expect(cli.version, equals('1.0.0'));
    });
  });
}
