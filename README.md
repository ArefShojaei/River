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
  river: ^1.1.0
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
  final app = await River.createHttpServer();

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

  // 404 is automatically handled by the framework.

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

| Property / Method    | Description                              |
| -------------------- | ---------------------------------------- |
| `req.method`         | HTTP method (`GET`, `POST`, ...)         |
| `req.path`           | Request path (`/users/123`)              |
| `req.url`            | Full URL                                 |
| `req.query`          | Query parameters (`Map<String, String>`) |
| `req.params`         | Route parameters (`Map<String, String>`) |
| `req.body`           | Parsed JSON body                         |
| `req.header('name')` | Get a header value                       |
| `req.text()`         | Raw body as `String`                     |
| `req.json()`         | Parse body as JSON                       |

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

## Socket (TCP)

> Server

```dart
final server = River.createSocketServer();

// Triggered when a new client connects
server.onConnection((client) {
  print('Client connected');
  server.emit(client, 'welcome', 'Welcome to the server!');
});

// Triggered when a client disconnects
server.onDisconnect((client) {
  print('Client disconnected');
});

// Listen for join event
server.on('join', (name) {
  print('$name joined the chat');
  server.broadcast('system', '$name joined the chat');
});

// Listen for chat messages and broadcast them
server.on('chat', (message) {
  print('Message: $message');
  server.broadcast('new_message', message);
});

await server.listen();
```

> Client

```dart
final client = River.createSocketConnector();

client.on('connect', (_) {
  print('Connected to server');

  // Join the chat after connecting
  client.emit('join', 'Ali');

  // Send a chat message
  client.emit('chat', 'Hello everyone!');
});

client.on('disconnect', (_) {
  print('Disconnected from server');
});

client.on('connect_error', (error) {
  print('Connection error: $error');
});

client.on('welcome', (message) {
  print('Server: $message');
});

client.on('system', (message) {
  print('System: $message');
});

client.on('new_message', (message) {
  print('New message: $message');
});

await client.connect();

// Keep the connection alive for a few seconds
await Future.delayed(const Duration(seconds: 5));
await client.disconnect();
```

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

      app.get('/', (req, res) => res.json({'message': 'Server is running'}));

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

- `cli_app.dart` — CLI example
- `http_server.dart` — HTTP only
- `socket_server.dart` — Socket server only
- `socket_client.dart` — Socket client only

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
