import 'package:test/test.dart';
import 'package:river/river.dart';

void main() {
  group('SocketServer', () {
    late SocketServer io;

    setUp(() {
      io = SocketServer();
    });

    test('should create instance', () {
      expect(io, isA<SocketServer>());
    });

    test('should create via River.createSocketServer', () {
      final server = River.createSocketServer();
      expect(server, isA<SocketServer>());
    });

    test('should register event handler without error', () {
      expect(() {
        io.on('connection', (data) {});
        io.on('disconnect', (data) {});
        io.on('custom', (data) {});
      }, returnsNormally);
    });

    test('should register onConnection without error', () {
      expect(() {
        io.onConnection((socket) {
          expect(socket, isA<Socket>());
        });
      }, returnsNormally);
    });

    test('should register onDisconnect without error', () {
      expect(() {
        io.onDisconnect((socket) {
          expect(socket, isA<Socket>());
        });
      }, returnsNormally);
    });

    test('should call emit without error', () {
      expect(() {
        io.emit('test', {'message': 'hello'});
        io.emit('test');
      }, returnsNormally);
    });

    test('should call to without error when room is empty', () {
      expect(() {
        io.to('room1', 'message', 'hello');
      }, returnsNormally);
    });
  });

  group('Socket types', () {
    test('SocketHandler should accept dynamic data', () {
      void handler(dynamic data) {
        expect(data, isNotNull);
      }

      final SocketHandler h = handler;
      expect(h, isA<SocketHandler>());
    });

    test('SocketConnectionHandler should accept Socket', () {
      void handler(Socket socket) {
        expect(socket, isA<Socket>());
      }

      final SocketConnectionHandler h = handler;
      expect(h, isA<SocketConnectionHandler>());
    });
  });
}
