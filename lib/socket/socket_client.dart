import 'dart:convert';
import 'dart:io';

import 'package:river/cli/console.dart';
import 'package:river/types.dart';

class SocketClient {
  final String host;
  final int port;

  Socket? _socket;
  final Map<String, List<SocketEventHandler>> _events = {};

  SocketClient({this.host = '127.0.0.1', this.port = 4040});

  Future<void> connect() async {
    try {
      _socket = await Socket.connect(host, port);
      Console.info('✅ Connected to $host:$port');

      // Register local event
      _emitLocal('connect', null);

      utf8.decoder.bind(_socket!).transform(const LineSplitter()).listen(
            (line) {
              if (line.trim().isEmpty) return;

              try {
                final json = jsonDecode(line) as Map<String, dynamic>;
                final event = json['e'] as String?;
                final data = json['d'];

                if (event != null) {
                  // Register local event
                  _emitLocal(event, data);
                }
              } catch (e) {
                Console.error('Invalid message: $e');

                // Register local event
                _emitLocal('error', e);
              }
            },
            onDone: _handleDisconnect,
            onError: (error) {
              Console.error('Socket error: $error');

              // Register local even
              _emitLocal('error', error);

              _handleDisconnect();
            },
            cancelOnError: true,
          );
    } catch (e) {
      Console.error('Connection failed: $e');

      // Register local event
      _emitLocal('connect_error', e);
    }
  }

  void _handleDisconnect() {
    if (_socket != null) {
      Console.warn('🔌 Disconnected from server');

      // Register local event
      _emitLocal('disconnect', null);

      _socket?.destroy();

      _socket = null;
    }
  }

  void on(String event, SocketEventHandler handler) {
    _events.putIfAbsent(event, () => []).add(handler);
  }

  void emit(String event, [dynamic data]) {
    if (_socket == null) {
      Console.error('Cannot emit: not connected');
      return;
    }

    try {
      final msg = jsonEncode({'e': event, 'd': data});

      _socket!.write('$msg\n');
    } catch (e) {
      Console.error('Failed to emit: $e');
    }
  }

  void _emitLocal(String event, dynamic data) {
    final handlers = _events[event];

    if (handlers == null) return;

    for (final handler in List.of(handlers)) {
      handler(data);
    }
  }

  Future<void> disconnect() async {
    await _socket?.close();

    _handleDisconnect();
  }
}
