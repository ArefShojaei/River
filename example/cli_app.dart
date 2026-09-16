import 'package:river/river.dart';

void main(List<String> args) async {
  final cli = River.createCli(args, name: 'River CLI', version: '1.0.0');

  cli.command(
    name: 'serve',
    description: 'Start HTTP server',
    aliases: ['s'],
    handler: (args, flags) async {
      final port = int.tryParse(flags['port'] ?? '3000') ?? 3000;

      Console.info('Starting server on port $port...');

      final app = await River.createHttpServer(port: port);

      app.get('/', (req, res) async {
        res.json({'message': 'Server is running'});
      });

      await app.listen();
    },
  );

  cli.command(
    name: 'hello',
    description: 'Say hello',
    handler: (args, flags) async {
      final name = args.isNotEmpty ? args.first : 'World';
      Console.success('Hello, $name!');
    },
  );

  await cli.run(args);
}
