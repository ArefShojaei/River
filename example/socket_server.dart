import 'package:river/river.dart';

void main() async {
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
}
