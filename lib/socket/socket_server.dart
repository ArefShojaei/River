import 'dart:convert';
import 'dart:io';

import 'package:river/cli/console.dart';
import 'package:river/types.dart';

class SocketServer {
  final String host;
  final int port;

  ServerSocket? _server;
  final List<Socket> _clients = [];
  final Map<String, List<SocketEventHandler>> _events = {};

  SocketServer({this.host = '0.0.0.0', this.port = 4040});

  Future<void> listen() async {
    _server = await ServerSocket.bind(host, port);
    Console.info('✅ Server started on $host:$port');

    _server!.listen((Socket client) {
      _clients.add(client);
      Console.info('👤 Client connected (${_clients.length})');

      // Register local event
      _emitLocal('connection', client);

      utf8.decoder.bind(client).transform(const LineSplitter()).listen(
            (line) {
              if (line.trim().isEmpty) return;

              try {
                final json = jsonDecode(line) as Map<String, dynamic>;
                final event = json['e'] as String?;
                final data = json['d'];

                if (event != null) {
                  // Register local event
                  _emitLocal(event, data, client: client);
                }
              } catch (e) {
                Console.error('Invalid message: $e');

                // Register local event
                _emitLocal('error', e, client: client);
              }
            },
            onDone: () => _handleDisconnect(client),
            onError: (e) {
              Console.error('Client error: $e');

              // Register local event
              _emitLocal('error', e, client: client);

              _handleDisconnect(client);
            },
            cancelOnError: true,
          );
    });
  }

  void _handleDisconnect(Socket client) {
    if (_clients.remove(client)) {
      Console.warn('👋 Client disconnected (${_clients.length})');

      // Register local event
      _emitLocal('disconnect', client);

      client.destroy();
    }
  }

  void on(String event, SocketEventHandler handler) {
    _events.putIfAbsent(event, () => []).add(handler);
  }

  void onConnection(SocketConnectionHandler handler) {
    on('connection', (data) => handler(data as Socket));
  }

  void onDisconnect(SocketConnectionHandler handler) {
    on('disconnect', (data) => handler(data as Socket));
  }

  void emit(Socket client, String event, [dynamic data]) {
    _send(client, event, data);
  }

  void broadcast(String event, [dynamic data]) {
    for (final client in List.of(_clients)) {
      _send(client, event, data);
    }
  }

  void broadcastExcept(Socket except, String event, [dynamic data]) {
    for (final client in List.of(_clients)) {
      if (client != except) {
        _send(client, event, data);
      }
    }
  }

  void _send(Socket client, String event, [dynamic data]) {
    try {
      final msg = jsonEncode({'e': event, 'd': data});

      client.write('$msg\n');
    } catch (e) {
      Console.error('Failed to send: $e');
    }
  }

  void _emitLocal(String event, dynamic data, {Socket? client}) {
    final handlers = _events[event];
    if (handlers == null) return;

    for (final handler in List.of(handlers)) {
      if (event == 'connection' || event == 'disconnect') {
        handler(client ?? data);
      } else {
        handler(data);
      }
    }
  }

  Future<void> stop() async {
    for (final client in List.of(_clients)) {
      await client.close();
    }

    _clients.clear();

    await _server?.close();

    Console.info('🛑 Server stopped');
  }
}
