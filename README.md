# River

A lightweight **Express-like** HTTP & WebSocket framework for Dart with built-in CLI support.

River makes it easy to build fast, clean, and structured server-side applications in pure Dart — with zero heavy dependencies.

## Features

- Simple and expressive routing (`get`, `post`, `put`, `patch`, `delete`, `all`)
- Path parameters support (`/users/:id`)
- Automatic JSON body parsing
- Clean `Request` & `Response` API
- Built-in WebSocket server
- Powerful CLI system with colored console output
- Zero external runtime dependencies (only `path`)

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  river: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Quick Start (HTTP Server)

```dart
import 'package:river/river.dart';

void main() async {
  final app = await Http.createServer(port: 3000);

  app.get('/', (Request req, Response res) async {
    res.json({'message': 'Hello from River!'});
  });

  app.get('/users/:id', (Request req, Response res) async {
    res.json({
      'id': req.params['id'],
      'query': req.query,
    });
  });

  app.post('/users', (Request req, Response res) async {
    res.status(201).json({
      'created': true,
      'body': req.body,
    });
  });

  app.listen();
}
```

## Routing

```dart
app.get('/path', handler);
app.post('/path', handler);
app.put('/path', handler);
app.patch('/path', handler);
app.delete('/path', handler);
app.all('/path', handler); // matches any method
```

### Path Parameters

```dart
app.get('/posts/:id/comments/:commentId', (req, res) async {
  final postId = req.params['id'];
  final commentId = req.params['commentId'];
  // ...
});
```

## Request & Response

### Request

```dart
req.method;          // GET, POST, ...
req.path;            // /users/123
req.query;           // { page: '1' }
req.params;          // { id: '123' }
req.body;            // parsed JSON body
req.get('header');   // get a header
```

### Response

```dart
res.status(201);
res.json({ 'success': true });
res.send('Hello World');
res.setHeader('X-Custom', 'value');
```

## WebSocket Example

```dart
final io = SocketServer();

io.on('connection', (Socket socket) {
  print('Client connected: ${socket.id}');

  socket.emit('welcome', {'message': 'Hello!'});

  socket.on('chat', (data) {
    io.emit('chat', {
      'from': socket.id,
      'message': data,
    });
  });

  socket.on('disconnect', (_) {
    print('Client disconnected');
  });
});

await io.listen(3001);
```

## CLI Support

River comes with a built-in CLI system:

```dart
final cli = Cli(name: 'myapp', version: '1.0.0');

cli.command(
  name: 'serve',
  description: 'Start the HTTP server',
  aliases: ['s'],
  handler: (args, flags) async {
    final port = int.tryParse(flags['port'] ?? '3000') ?? 3000;
    // start your server...
  },
);

await cli.run(args);
```

Run it:

```bash
dart run myapp.dart serve --port 3000
```

### Colored Console

```dart
Console.success('Server started!');
Console.info('Listening on port 3000');
Console.warn('Something looks wrong');
Console.error('Failed to start');
```

## Project Structure Recommendation

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

## License

MIT