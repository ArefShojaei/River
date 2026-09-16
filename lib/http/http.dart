import 'dart:io';

import 'package:river/cli/console.dart';
import 'package:river/http/request.dart';
import 'package:river/http/response.dart';
import 'package:river/routing/router.dart';
import 'package:river/types.dart';

class Http {
  final HttpServer _server;
  final String _host;
  final int _port;
  final Router _router = Router();

  Http._(this._server, this._host, this._port);

  static Future<Http> createServer({
    String host = 'localhost',
    int port = 8080,
  }) async {
    final server = await HttpServer.bind(host, port);

    return Http._(server, host, port);
  }

  void get(String path, HttpHandler handler) => _router.get(path, handler);
  void post(String path, HttpHandler handler) => _router.post(path, handler);
  void put(String path, HttpHandler handler) => _router.put(path, handler);
  void patch(String path, HttpHandler handler) => _router.patch(path, handler);
  void delete(String path, HttpHandler handler) =>
      _router.delete(path, handler);
  void all(String path, HttpHandler handler) => _router.all(path, handler);

  Future<void> listen() async {
    Console.info('Server is running at http://$_host:$_port');

    await for (final raw in _server) {
      final req = Request(raw);
      final res = Response(raw.response);

      try {
        if (['POST', 'PUT', 'PATCH', 'DELETE'].contains(req.method)) {
          final contentType = req.header('content-type') ?? '';

          if (contentType.contains('application/json')) {
            req.body = await req.json();
          }
        }

        await _router.dispatch(req, res);
      } catch (e, stack) {
        Console.error('Error: $e\n$stack');

        if (!res.ended) {
          res.status(500).json({
            'error': 'Internal Server Error',
            'message': e.toString(),
          });
        }
      }
    }
  }
}
