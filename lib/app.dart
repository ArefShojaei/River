import 'package:river/cli/cli.dart';
import 'package:river/http/http.dart';
import 'package:river/socket/socket_server.dart';
import 'package:river/socket/socket_client.dart';

class River {
  static Future<Http> createHttpServer({
    String host = '0.0.0.0',
    int port = 8080,
  }) =>
      Http.createServer(host: host, port: port);

  static SocketServer createSocketServer({
    String host = '0.0.0.0',
    int port = 4040,
  }) =>
      SocketServer(host: host, port: port);

  static SocketClient createSocketConnector({
    String host = '127.0.0.1',
    int port = 4040,
  }) =>
      SocketClient(host: host, port: port);

  static Cli createCli(List<String> args,
          {String name = 'app', String version = '1.2.0'}) =>
      Cli(name: name, version: version);
}
