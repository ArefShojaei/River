import 'package:river/cli/cli.dart';
import 'package:river/http/http.dart';
import 'package:river/socket/socket_server.dart';

class River {
  static Future<Http> createHttpServer({
    String host = 'localhost',
    int port = 8080,
  }) {
    return Http.createServer(host: host, port: port);
  }

  static SocketServer createSocketServer() {
    return SocketServer();
  }

  static Cli createCli(List<String> args,
      {String name = 'app', String version = '1.0.0'}) {
    return Cli(name: name, version: version);
  }
}
