import 'package:river/river.dart';
import 'package:test/test.dart';

void main() {
  group('SocketServer', () {
    test('should create SocketServer instance', () {
      final io = SocketServer();
      expect(io, isA<SocketServer>());
    });
  });
}
