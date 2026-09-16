import 'dart:async';

import 'package:river/http/request.dart';
import 'package:river/http/response.dart';
import 'package:river/socket/socket.dart';

/// HTTP route handler
typedef HttpHandler = FutureOr<void> Function(Request req, Response res);

/// CLI command handler
typedef CliHandler = FutureOr<void> Function(
  List<String> args,
  Map<String, String> flags,
);

/// Socket event handler
typedef SocketHandler = void Function(dynamic data);

// Socket connection handler
typedef SocketConnectionHandler = void Function(Socket socket);
