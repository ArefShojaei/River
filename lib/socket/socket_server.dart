import 'dart:io';

import 'package:river/socket/socket.dart';
import 'package:river/cli/console.dart';
import 'package:river/types.dart';

class SocketServer {
  final Map<String, Socket> _clients = {};
  final Map<String, List<SocketHandler>> _events = {};
  final Map<String, Set<String>> _rooms = {};
  HttpServer? _server;

  void on(String event, SocketHandler handler) {
    _events.putIfAbsent(event, () => []).add(handler);
  }

  void emit(String event, [dynamic data]) {
    for (final socket in _clients.values) {
      socket.emit(event, data);
    }
  }

  void onConnection(SocketConnectionHandler handler) {
    on('connection', (data) => handler(data as Socket));
  }

  void onDisconnect(SocketConnectionHandler handler) {
    on('disconnect', (data) => handler(data as Socket));
  }

  void emitExcept(Socket except, String event, [dynamic data]) {
    for (final socket in _clients.values) {
      if (socket.id != except.id) {
        socket.emit(event, data);
      }
    }
  }

  void to(String room, String event, [dynamic data]) {
    final members = _rooms[room];
    if (members == null) return;

    for (final id in members) {
      _clients[id]?.emit(event, data);
    }
  }

  void join(Socket socket, String room) {
    _rooms.putIfAbsent(room, () => {}).add(socket.id);
  }

  void leave(Socket socket, String room) {
    _rooms[room]?.remove(socket.id);
  }

  Future<void> listen(
    int port, {
    String host = 'localhost',
    String path = '/ws',
  }) async {
    _server = await HttpServer.bind(host, port);
    Console.info('🔌 Socket server running on ws://$host:$port$path');

    await for (final request in _server!) {
      if (request.uri.path == path) {
        final ws = await WebSocketTransformer.upgrade(request);
        final socket = Socket(ws);

        _clients[socket.id] = socket;

        socket.on('disconnect', (_) {
          _clients.remove(socket.id);

          for (final room in _rooms.values) {
            room.remove(socket.id);
          }

          _emitLocal('disconnect', socket);
        });

        _emitLocal('connection', socket);
      } else {
        request.response
          ..statusCode = HttpStatus.notFound
          ..write('Not a WebSocket endpoint')
          ..close();
      }
    }
  }

  Future<void> close() async {
    for (final socket in _clients.values) {
      await socket.disconnect();
    }
    await _server?.close(force: true);
  }

  void _emitLocal(String event, [dynamic data]) {
    final handlers = _events[event];

    if (handlers == null) return;

    for (final handler in List.from(handlers)) {
      handler(data);
    }
  }
}
