import 'package:river/cli/cli.dart';
import 'package:river/http/http.dart';
import 'package:river/socket/socket_server.dart';
import 'package:river/socket/socket_client.dart';

class River {
  static Future<Http> createHttpServer({
    String host = 'localhost',
    int port = 8080,
  }) =>
      Http.createServer(host: host, port: port);

  static SocketServer createSocketServer({
    String host = 'localhost',
    int port = 4040,
  }) => SocketServer(host: host, port: port);

  static SocketClient createSocketConnector({
    String host = 'localhost',
    int port = 4040,
  }) => SocketClient(host: host, port: port);

  static Cli createCli(List<String> args,
          {String name = 'app', String version = '1.0.0'}) =>
      Cli(name: name, version: version);
}
