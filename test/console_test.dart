import 'package:test/test.dart';
import 'package:river/river.dart';

void main() {
  group('Console', () {
    test('should call all methods without error', () {
      expect(() {
        Console.log('log message');
        Console.info('info message');
        Console.success('success message');
        Console.warn('warn message');
        Console.error('error message');
        Console.debug('debug message');
        Console.title('Title');
      }, returnsNormally);
    });
  });
}
