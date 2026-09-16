import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:river/river.dart';

void main() {
  group('Http', () {
    test('createServer returns Http instance', () async {
      final server = await Http.createServer(host: '127.0.0.1', port: 0);
      expect(server, isA<Http>());
    });

    test('GET route returns JSON', () async {
      final tmp = await HttpServer.bind('127.0.0.1', 0);
      final actualPort = tmp.port;
      await tmp.close();

      final app = await Http.createServer(host: '127.0.0.1', port: actualPort);

      app.get('/hello', (Request req, Response res) async {
        res.json({'message': 'world'});
      });

      app.listen();
      await Future.delayed(const Duration(milliseconds: 80));

      final client = HttpClient();
      final request = await client.get('127.0.0.1', actualPort, '/hello');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      expect(response.statusCode, equals(200));
      expect(jsonDecode(body), equals({'message': 'world'}));
      expect(
          response.headers.contentType?.mimeType, equals('application/json'));

      client.close(force: true);
    });

    test('GET with path params', () async {
      final tmp = await HttpServer.bind('127.0.0.1', 0);
      final actualPort = tmp.port;
      await tmp.close();

      final app = await Http.createServer(host: '127.0.0.1', port: actualPort);

      app.get('/users/:id', (Request req, Response res) async {
        res.json({'id': req.params['id']});
      });

      app.listen();
      await Future.delayed(const Duration(milliseconds: 80));

      final client = HttpClient();
      final request = await client.get('127.0.0.1', actualPort, '/users/42');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      expect(response.statusCode, equals(200));
      expect(jsonDecode(body), equals({'id': '42'}));

      client.close(force: true);
    });

    test('GET with query parameters', () async {
      final tmp = await HttpServer.bind('127.0.0.1', 0);
      final actualPort = tmp.port;
      await tmp.close();

      final app = await Http.createServer(host: '127.0.0.1', port: actualPort);

      app.get('/search', (Request req, Response res) async {
        res.json({'q': req.query['q'], 'page': req.query['page']});
      });

      app.listen();
      await Future.delayed(const Duration(milliseconds: 80));

      final client = HttpClient();
      final request =
          await client.get('127.0.0.1', actualPort, '/search?q=Http&page=2');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      expect(response.statusCode, equals(200));
      expect(jsonDecode(body), equals({'q': 'Http', 'page': '2'}));

      client.close(force: true);
    });

    test('POST with JSON body', () async {
      final tmp = await HttpServer.bind('127.0.0.1', 0);
      final actualPort = tmp.port;
      await tmp.close();

      final app = await Http.createServer(host: '127.0.0.1', port: actualPort);

      app.post('/users', (Request req, Response res) async {
        res.status(201).json({
          'created': true,
          'name': req.body['name'],
        });
      });

      app.listen();
      await Future.delayed(const Duration(milliseconds: 80));

      final client = HttpClient();
      final request = await client.post('127.0.0.1', actualPort, '/users');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'name': 'Aref'}));
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      expect(response.statusCode, equals(201));
      expect(jsonDecode(body), equals({'created': true, 'name': 'Aref'}));

      client.close(force: true);
    });

    test('404 for unknown route', () async {
      final tmp = await HttpServer.bind('127.0.0.1', 0);
      final actualPort = tmp.port;
      await tmp.close();

      final app = await Http.createServer(host: '127.0.0.1', port: actualPort);

      app.get('/exists', (Request req, Response res) async {
        res.json({'ok': true});
      });

      app.listen();
      await Future.delayed(const Duration(milliseconds: 80));

      final client = HttpClient();
      final request =
          await client.get('127.0.0.1', actualPort, '/does-not-exist');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      expect(response.statusCode, equals(404));
      expect(jsonDecode(body), equals({'error': 'Not Found'}));

      client.close(force: true);
    });

    test('res.send with string', () async {
      final tmp = await HttpServer.bind('127.0.0.1', 0);
      final actualPort = tmp.port;
      await tmp.close();

      final app = await Http.createServer(host: '127.0.0.1', port: actualPort);

      app.get('/text', (Request req, Response res) async {
        res.send('Hello plain text');
      });

      app.listen();
      await Future.delayed(const Duration(milliseconds: 80));

      final client = HttpClient();
      final request = await client.get('127.0.0.1', actualPort, '/text');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      expect(response.statusCode, equals(200));
      expect(body, equals('Hello plain text'));

      client.close(force: true);
    });

    test('custom status and header', () async {
      final tmp = await HttpServer.bind('127.0.0.1', 0);
      final actualPort = tmp.port;
      await tmp.close();

      final app = await Http.createServer(host: '127.0.0.1', port: actualPort);

      app.get('/custom', (Request req, Response res) async {
        res.status(201).setHeader('X-Custom', 'Http').json({'ok': true});
      });

      app.listen();
      await Future.delayed(const Duration(milliseconds: 80));

      final client = HttpClient();
      final request = await client.get('127.0.0.1', actualPort, '/custom');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      expect(response.statusCode, equals(201));
      expect(response.headers.value('x-custom'), equals('Http'));
      expect(jsonDecode(body), equals({'ok': true}));

      client.close(force: true);
    });
  });

  group('Request', () {
    test('parses method, path, query and headers', () async {
      final server = await HttpServer.bind('127.0.0.1', 0);
      final port = server.port;

      late Request captured;
      final done = Completer<void>();

      server.listen((HttpRequest raw) {
        captured = Request(raw);
        raw.response
          ..statusCode = 200
          ..write('ok')
          ..close();
        done.complete();
      });

      final client = HttpClient();
      final request = await client.get('127.0.0.1', port, '/path?foo=bar');
      request.headers.set('X-Test', 'value');
      await request.close();

      await done.future.timeout(const Duration(seconds: 2));

      expect(captured.method, equals('GET'));
      expect(captured.path, equals('/path'));
      expect(captured.query, equals({'foo': 'bar'}));
      expect(captured.header('x-test'), equals('value'));

      client.close(force: true);
      await server.close(force: true);
    });

    test('json() parses body', () async {
      final server = await HttpServer.bind('127.0.0.1', 0);
      final port = server.port;

      late dynamic parsed;
      final done = Completer<void>();

      server.listen((HttpRequest raw) async {
        final req = Request(raw);
        parsed = await req.json();
        raw.response
          ..statusCode = 200
          ..close();
        done.complete();
      });

      final client = HttpClient();
      final request = await client.post('127.0.0.1', port, '/');
      request.headers.contentType = ContentType.json;
      request.write(jsonEncode({'hello': 'world'}));
      await request.close();

      await done.future.timeout(const Duration(seconds: 2));

      expect(parsed, equals({'hello': 'world'}));

      client.close(force: true);
      await server.close(force: true);
    });
  });

  group('Response', () {
    test('status, json and ended work', () async {
      final server = await HttpServer.bind('127.0.0.1', 0);
      final port = server.port;

      final done = Completer<void>();

      server.listen((HttpRequest raw) {
        final res = Response(raw.response);
        expect(res.ended, isFalse);
        res.status(201).json({'status': 'created'});
        expect(res.ended, isTrue);
        done.complete();
      });

      final client = HttpClient();
      final request = await client.get('127.0.0.1', port, '/');
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();

      await done.future.timeout(const Duration(seconds: 2));

      expect(response.statusCode, equals(201));
      expect(jsonDecode(body), equals({'status': 'created'}));

      client.close(force: true);
      await server.close(force: true);
    });
  });
}
