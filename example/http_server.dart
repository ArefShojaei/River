import 'package:river/river.dart';

void main() async {
  final app = await River.createHttpServer(port: 3000);

  app.use((req, res) async {
    Console.info('[${DateTime.now()}] ${req.method} ${req.path}');
  });

  app.get('/', (req, res) async {
    res.json({
      'message': 'Welcome to River HTTP Server',
      'version': '1.0.0',
    });
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

  app.all('/health', (req, res) async {
    res.json({'status': 'ok'});
  });

  // 404 is automatically handled by the framework.

  await app.listen();
}
