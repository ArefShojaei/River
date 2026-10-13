import 'package:river/river.dart';

void main() async {
  final app = await River.createHttpServer();

  app.get('/', (req, res) {
    res.json({'message': 'Hello from River!'});
  });

  await app.listen();
}
