# River

A lightweight **Express-like** HTTP & WebSocket framework for Dart with built-in CLI support.

River makes it easy to build fast, clean, and structured server-side applications in pure Dart — with almost zero external dependencies.

[![Pub Version](https://img.shields.io/pub/v/river.svg)](https://pub.dev/packages/river)
[![Pub Points](https://img.shields.io/pub/points/river)](https://pub.dev/packages/river/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Dart](https://img.shields.io/badge/Dart-3.6+-blue.svg)](https://dart.dev)

---

## Features

- Simple and expressive routing (`get`, `post`, `put`, `patch`, `delete`, `all`)
- Path parameters (`/users/:id`)
- Middleware support
- Automatic JSON body parsing
- Clean `Request` & `Response` API
- Built-in WebSocket server with rooms
- Powerful CLI system with colored console output
- Extremely lightweight (only depends on `path`)

---

## Installation

```yaml
dependencies:
  river: ^1.0.0
```

```bash
dart pub get
```

Package on pub.dev: [https://pub.dev/packages/river](https://pub.dev/packages/river)

---

## Quick Start

```dart
import 'package:river/river.dart';

void main() async {
  final app = await River.createHttpServer(port: 3000);

  app.get('/', (req, res) async {
    res.json({'message': 'Hello from River!'});
  });

  app.get('/users/:id', (req, res) async {
    res.json({
      'id': req.params['id'],
      'query': req.query,
    });
  });

  app.post('/users', (req, res) async {
    res.status(201).json({
      'created': true,
      'body': req.body,
    });
  });

  await app.listen();
}
```

---

## HTTP Server

### Create a server

```dart
final app = await River.createHttpServer(
  host: '0.0.0.0', // optional, default: 'localhost'
  port: 3000,      // optional, default: 8080
);
```

### Routing

```dart
app.get('/path', handler);
app.post('/path', handler);
app.put('/path', handler);
app.patch('/path', handler);
app.delete('/path', handler);
app.all('/path', handler); // matches any HTTP method
```

### Path parameters

```dart
app.get('/posts/:id/comments/:commentId', (req, res) async {
  final postId = req.params['id'];
  final commentId = req.params['commentId'];

  res.json({
    'postId': postId,
    'commentId': commentId,
  });
});
```

### Middleware

Middlewares run **before** route handlers, in the order they were registered.

```dart
app.use((req, res) async {
  Console.info('${req.method} ${req.path}');
});

// Auth example
app.use((req, res) async {
  final token = req.header('authorization');
  if (token == null) {
    res.status(401).json({'error': 'Unauthorized'});
    return;
  }
});

app.get('/profile', (req, res) async {
  res.json({'user': 'Aref'});
});
```

You can register multiple middlewares:

```dart
app.use(loggerMiddleware);
app.use(authMiddleware);
app.use(corsMiddleware);
```

### Request

| Property / Method    | Description                          |
|----------------------|--------------------------------------|
| `req.method`         | HTTP method (`GET`, `POST`, ...)     |
| `req.path`           | Request path (`/users/123`)          |
| `req.url`            | Full URL                             |
| `req.query`          | Query parameters (`Map<String, String>`) |
| `req.params`         | Route parameters (`Map<String, String>`) |
| `req.body`           | Parsed JSON body                     |
| `req.header('name')` | Get a header value                   |
| `req.text()`         | Raw body as `String`                 |
| `req.json()`         | Parse body as JSON                   |

### Response

```dart
res.status(201);                          // set status (chainable)
res.json({'success': true});              // send JSON
res.send('Hello World');                  // send text
res.send({'message': 'Hello'});           // send object as JSON
res.setHeader('X-Custom', 'value');       // set header
res.end();                                // end response
```

---

## WebSocket

```dart
final io = River.createSocketServer();

io.onConnection((socket) {
  print('Client connected: ${socket.id}');

  socket.emit('welcome', {'message': 'Hello!'});

  socket.on('chat', (data) {
    io.emit('chat', {
      'from': socket.id,
      'message': data,
    });
  });

  socket.on('disconnect', (_) {
    print('Client disconnected: ${socket.id}');
  });
});

await io.listen(3001); // ws://localhost:3001/ws
```

### SocketServer API

| Method | Description |
|--------|-------------|
| `on(event, handler)` | Listen for an event |
| `onConnection(handler)` | Listen for new connections |
| `onDisconnect(handler)` | Listen for disconnects |
| `emit(event, [data])` | Broadcast to all clients |
| `emitExcept(socket, event, [data])` | Broadcast to all except one |
| `to(room, event, [data])` | Send to a room |
| `join(socket, room)` | Add socket to a room |
| `leave(socket, room)` | Remove socket from a room |
| `listen(port, {host, path})` | Start the server |
| `close()` | Close the server |

### Socket API

| Method | Description |
|--------|-------------|
| `socket.id` | Unique client ID |
| `socket.on(event, handler)` | Listen for events |
| `socket.off(event)` | Remove listener |
| `socket.emit(event, [data])` | Send event to this client |
| `socket.disconnect()` | Close connection |
| `socket.data` | Custom data storage |

---

## CLI

```dart
import 'package:river/river.dart';

void main(List<String> args) async {
  final cli = River.createCli(args, name: 'myapp', version: '1.0.0');

  cli.command(
    name: 'serve',
    description: 'Start the HTTP server',
    aliases: ['s'],
    handler: (args, flags) async {
      final port = int.tryParse(flags['port'] ?? '3000') ?? 3000;

      final app = await River.createHttpServer(port: port);

      app.get('/', (req, res) async {
        res.json({'status': 'ok'});
      });

      await app.listen();
    },
  );

  await cli.run(args);
}
```

Run:

```bash
dart run bin/myapp.dart serve --port 3000
dart run bin/myapp.dart s --port 8080
dart run bin/myapp.dart --version
dart run bin/myapp.dart --help
```

### Colored Console

```dart
Console.success('Server started!');
Console.info('Listening on port 3000');
Console.warn('Something looks wrong');
Console.error('Failed to start');
Console.debug('Debug info');
Console.title('My App');
Console.log('Normal message');
```

---

## Examples

See the [`example/`](example/) folder:

- `http_server.dart` — HTTP only
- `socket_server.dart` — WebSocket only
- `cli_app.dart` — CLI example

---

## Recommended structure

```text
my_project/
├── bin/
│   └── server.dart
├── lib/
│   ├── routes/
│   ├── controllers/
│   └── middleware/
└── pubspec.yaml
```

---

## License

MIT © [Aref Shojaei](https://github.com/ArefShojaei)