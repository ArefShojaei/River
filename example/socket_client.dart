import 'package:river/river.dart';

void main() async {
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
}
