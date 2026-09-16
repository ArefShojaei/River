import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:river/river.dart';

void main() {
  group('SocketServer', () {
    test('should create SocketServer instance', () {
      final io = SocketServer();
      expect(io, isA<SocketServer>());
    });

    test('accepts WebSocket connection and emits connection event', () async {
      final io = SocketServer();
      final completer = Completer<Socket>();

      io.on('connection', (Socket socket) {
        completer.complete(socket);
      });

      final tmp = await HttpServer.bind('127.0.0.1', 0);
      final port = tmp.port;
      await tmp.close();

      // ignore: unawaited_futures
      io.listen(port, host: '127.0.0.1', path: '/ws');
      await Future.delayed(const Duration(milliseconds: 80));

      final client = await WebSocket.connect('ws://127.0.0.1:$port/ws');

      final socket = await completer.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () => throw TimeoutException('No connection event'),
      );

      expect(socket, isA<Socket>());
      expect(socket.id, isNotEmpty);

      await client.close();
      await io.close();
    });

    test('broadcast emit reaches all clients', () async {
      final io = SocketServer();
      final connected = Completer<void>();
      var connectionCount = 0;

      io.on('connection', (Socket socket) {
        connectionCount++;
        if (connectionCount == 2) connected.complete();
      });

      final tmp = await HttpServer.bind('127.0.0.1', 0);
      final port = tmp.port;
      await tmp.close();

      // ignore: unawaited_futures
      io.listen(port, host: '127.0.0.1', path: '/ws');
      await Future.delayed(const Duration(milliseconds: 80));

      final client1 = await WebSocket.connect('ws://127.0.0.1:$port/ws');
      final client2 = await WebSocket.connect('ws://127.0.0.1:$port/ws');

      await connected.future.timeout(const Duration(seconds: 3));

      final received1 = Completer<Map>();
      final received2 = Completer<Map>();

      client1.listen((data) {
        if (!received1.isCompleted) {
          received1.complete(jsonDecode(data as String) as Map);
        }
      });
      client2.listen((data) {
        if (!received2.isCompleted) {
          received2.complete(jsonDecode(data as String) as Map);
        }
      });

      await Future.delayed(const Duration(milliseconds: 30));

      io.emit('announce', {'msg': 'hello all'});

      final msg1 = await received1.future.timeout(const Duration(seconds: 3));
      final msg2 = await received2.future.timeout(const Duration(seconds: 3));

      expect(
          msg1,
          equals({
            'event': 'announce',
            'data': {'msg': 'hello all'}
          }));
      expect(
          msg2,
          equals({
            'event': 'announce',
            'data': {'msg': 'hello all'}
          }));

      await client1.close();
      await client2.close();
      await io.close();
    });

    test('room join / to works', () async {
      final io = SocketServer();
      Socket? s1;
      final bothConnected = Completer<void>();
      var count = 0;

      io.on('connection', (Socket socket) {
        count++;
        if (count == 1) s1 = socket;
        if (count == 2) {
          bothConnected.complete();
        }
      });

      final tmp = await HttpServer.bind('127.0.0.1', 0);
      final port = tmp.port;
      await tmp.close();

      // ignore: unawaited_futures
      io.listen(port, host: '127.0.0.1', path: '/ws');
      await Future.delayed(const Duration(milliseconds: 80));

      final client1 = await WebSocket.connect('ws://127.0.0.1:$port/ws');
      final client2 = await WebSocket.connect('ws://127.0.0.1:$port/ws');

      await bothConnected.future.timeout(const Duration(seconds: 3));

      io.join(s1!, 'roomA');

      final received1 = Completer<Map>();
      var client2GotMessage = false;

      client1.listen((data) {
        if (!received1.isCompleted) {
          received1.complete(jsonDecode(data as String) as Map);
        }
      });
      client2.listen((data) {
        client2GotMessage = true;
      });

      await Future.delayed(const Duration(milliseconds: 30));

      io.to('roomA', 'secret', {'only': 'for room'});

      final msg1 = await received1.future.timeout(const Duration(seconds: 3));
      expect(
          msg1,
          equals({
            'event': 'secret',
            'data': {'only': 'for room'}
          }));

      await Future.delayed(const Duration(milliseconds: 100));
      expect(client2GotMessage, isFalse);

      await client1.close();
      await client2.close();
      await io.close();
    });

    test('non-ws path returns 404', () async {
      final io = SocketServer();

      final tmp = await HttpServer.bind('127.0.0.1', 0);
      final port = tmp.port;
      await tmp.close();

      // ignore: unawaited_futures
      io.listen(port, host: '127.0.0.1', path: '/ws');
      await Future.delayed(const Duration(milliseconds: 80));

      final client = HttpClient();
      final request = await client.get('127.0.0.1', port, '/other');
      final response = await request.close();

      expect(response.statusCode, equals(404));

      client.close(force: true);
      await io.close();
    });
  });
}
