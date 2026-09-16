import 'package:river/river.dart';

void main() async {
  final io = River.createSocketServer();

  io.onConnection((socket) {
    Console.success('Connected: ${socket.id}');

    socket.emit('welcome', {
      'message': 'Hello from River!',
      'id': socket.id,
    });

    socket.on('chat', (data) {
      Console.info('Message: $data');

      io.emit('chat', {
        'from': socket.id,
        'message': data,
      });
    });

    socket.on('disconnect', (_) {
      Console.warn('Disconnected: ${socket.id}');
    });
  });

  await io.listen(3001);
}
