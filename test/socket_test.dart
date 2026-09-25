import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';
import 'package:river/river.dart';

void main() {
  late SocketServer server;
  late int port;

  setUp(() async {
    port = 4000 + Random().nextInt(1000);
    server = SocketServer(host: '127.0.0.1', port: port);
    await server.listen();
  });

  tearDown(() async {
    await server.stop();
  });

  group('SocketServer & SocketClient', () {
    test('client connects successfully and triggers connect event', () async {
      final client = SocketClient(host: '127.0.0.1', port: port);

      final connectCompleter = Completer<void>();

      client.on('connect', (_) {
        if (!connectCompleter.isCompleted) {
          connectCompleter.complete();
        }
      });

      await client.connect();

      await connectCompleter.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => fail('connect event was not triggered'),
      );

      await client.disconnect();
    });

    test('server triggers connection event when client connects', () async {
      final connectionCompleter = Completer<Socket>();

      server.onConnection((client) {
        if (!connectionCompleter.isCompleted) {
          connectionCompleter.complete(client);
        }
      });

      final client = SocketClient(host: '127.0.0.1', port: port);
      await client.connect();

      final connectedClient = await connectionCompleter.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => fail('server connection event was not triggered'),
      );

      expect(connectedClient, isA<Socket>());

      await client.disconnect();
    });

    test('server can emit event to specific client', () async {
      final client = SocketClient(host: '127.0.0.1', port: port);

      final welcomeCompleter = Completer<String>();

      client.on('welcome', (data) {
        if (!welcomeCompleter.isCompleted) {
          welcomeCompleter.complete(data as String);
        }
      });

      server.onConnection((socket) {
        server.emit(socket, 'welcome', 'hello from server');
      });

      await client.connect();

      final message = await welcomeCompleter.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => fail('welcome event was not received'),
      );

      expect(message, equals('hello from server'));

      await client.disconnect();
    });

    test('client can emit event and server receives it', () async {
      final client = SocketClient(host: '127.0.0.1', port: port);

      final chatCompleter = Completer<String>();

      server.on('chat', (data) {
        if (!chatCompleter.isCompleted) {
          chatCompleter.complete(data as String);
        }
      });

      client.on('connect', (_) {
        client.emit('chat', 'salam');
      });

      await client.connect();

      final message = await chatCompleter.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => fail('server did not receive chat event'),
      );

      expect(message, equals('salam'));

      await client.disconnect();
    });

    test('broadcast sends event to all connected clients', () async {
      final client1 = SocketClient(host: '127.0.0.1', port: port);
      final client2 = SocketClient(host: '127.0.0.1', port: port);

      final received1 = Completer<String>();
      final received2 = Completer<String>();

      client1.on('news', (data) {
        if (!received1.isCompleted) received1.complete(data as String);
      });

      client2.on('news', (data) {
        if (!received2.isCompleted) received2.complete(data as String);
      });

      await client1.connect();
      await client2.connect();

      await Future.delayed(const Duration(milliseconds: 100));

      server.broadcast('news', 'broadcast message');

      final msg1 = await received1.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => fail('client1 did not receive broadcast'),
      );

      final msg2 = await received2.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => fail('client2 did not receive broadcast'),
      );

      expect(msg1, equals('broadcast message'));
      expect(msg2, equals('broadcast message'));

      await client1.disconnect();
      await client2.disconnect();
    });

    test('broadcastExcept does not send to excluded client', () async {
      final client1 = SocketClient(host: '127.0.0.1', port: port);
      final client2 = SocketClient(host: '127.0.0.1', port: port);

      final received1 = Completer<String>();
      final received2 = Completer<String>();

      client1.on('private', (data) {
        if (!received1.isCompleted) received1.complete(data as String);
      });

      client2.on('private', (data) {
        if (!received2.isCompleted) received2.complete(data as String);
      });

      Socket? excludedSocket;

      server.onConnection((socket) {
        excludedSocket ??= socket;
      });

      await client1.connect();
      await client2.connect();
      await Future.delayed(const Duration(milliseconds: 100));

      server.broadcastExcept(excludedSocket!, 'private', 'only for others');

      final msg2 = await received2.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => fail('client2 did not receive message'),
      );
      expect(msg2, equals('only for others'));

      await expectLater(
        received1.future.timeout(const Duration(milliseconds: 300)),
        throwsA(isA<TimeoutException>()),
      );

      await client1.disconnect();
      await client2.disconnect();
    });

    test('disconnect events are triggered on both sides', () async {
      final client = SocketClient(host: '127.0.0.1', port: port);

      final clientDisconnect = Completer<void>();
      final serverDisconnect = Completer<void>();

      client.on('disconnect', (_) {
        if (!clientDisconnect.isCompleted) clientDisconnect.complete();
      });

      server.onDisconnect((_) {
        if (!serverDisconnect.isCompleted) serverDisconnect.complete();
      });

      await client.connect();
      await Future.delayed(const Duration(milliseconds: 50));

      await client.disconnect();

      await clientDisconnect.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => fail('client disconnect event not triggered'),
      );

      await serverDisconnect.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => fail('server disconnect event not triggered'),
      );
    });

    test('connect_error is triggered when server is down', () async {
      await server.stop();

      final client = SocketClient(host: '127.0.0.1', port: port);
      final errorCompleter = Completer<Object>();

      client.on('connect_error', (err) {
        if (!errorCompleter.isCompleted) {
          errorCompleter.complete(err);
        }
      });

      await client.connect();

      final error = await errorCompleter.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () => fail('connect_error was not triggered'),
      );

      expect(error, isNotNull);
    });
  });
}
