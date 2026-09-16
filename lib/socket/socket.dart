import 'dart:convert';
import 'dart:io';

import 'package:river/types.dart';

class Socket {
  final WebSocket _ws;
  final String id;
  final Map<String, List<SocketHandler>> _events = {};
  final Map<String, dynamic> data = {};

  Socket(this._ws) : id = DateTime.now().microsecondsSinceEpoch.toString() {
    _ws.listen(
      _onData,
      onDone: () => _emitLocal('disconnect'),
      onError: (e) => _emitLocal('error', e),
    );
  }

  void on(String event, SocketHandler handler) {
    _events.putIfAbsent(event, () => []).add(handler);
  }

  void off(String event, [SocketHandler? handler]) {
    if (handler == null) {
      _events.remove(event);
    } else {
      _events[event]?.remove(handler);
    }
  }

  void emit(String event, [dynamic data]) {
    final message = jsonEncode({'event': event, 'data': data});
    _ws.add(message);
  }

  Future<void> disconnect([int? code, String? reason]) async {
    await _ws.close(code, reason);
  }

  void _onData(dynamic raw) {
    try {
      final decoded = jsonDecode(raw as String);
      final event = decoded['event'] as String?;
      final data = decoded['data'];

      if (event != null) {
        _emitLocal(event, data);
      }
    } catch (e) {
      _emitLocal('message', raw);
    }
  }

  void _emitLocal(String event, [dynamic data]) {
    final handlers = _events[event];

    if (handlers == null) return;

    for (final handler in List.from(handlers)) {
      handler(data);
    }
  }
}
