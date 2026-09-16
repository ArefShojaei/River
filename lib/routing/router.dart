import 'package:river/http/request.dart';
import 'package:river/http/response.dart';
import 'package:river/routing/route.dart';
import 'package:river/types.dart';

class Router {
  final List<Route> _routes = [];
  final List<HttpHandler> _middlewares = [];

  void use(HttpHandler handler) {
    _middlewares.add(handler);
  }

  void get(String path, HttpHandler handler) =>
      _add(method: 'GET', path: path, handler: handler);

  void post(String path, HttpHandler handler) =>
      _add(method: 'POST', path: path, handler: handler);

  void put(String path, HttpHandler handler) =>
      _add(method: 'PUT', path: path, handler: handler);

  void patch(String path, HttpHandler handler) =>
      _add(method: 'PATCH', path: path, handler: handler);

  void delete(String path, HttpHandler handler) =>
      _add(method: 'DELETE', path: path, handler: handler);

  void all(String path, HttpHandler handler) =>
      _add(method: '*', path: path, handler: handler);

  void _add({
    required String method,
    required String path,
    required HttpHandler handler,
  }) {
    _routes.add(Route(method: method, path: path, handler: handler));
  }

  Future<void> dispatch(Request req, Response res) async {
    // 1. Run middlewares
    for (final middleware in _middlewares) {
      await middleware(req, res);

      if (res.ended) return;
    }

    // 2. Find and run route
    for (final route in _routes) {
      if (route.match(req.method, req.path)) {
        final params = route.extractParams(req.path);

        final requestWithParams = Request(req.raw, params: params);
        requestWithParams.body = req.body;

        await route.handler(requestWithParams, res);
        return;
      }
    }

    if (!res.ended) {
      res.status(404).json({'error': 'Not Found'});
    }
  }
}
